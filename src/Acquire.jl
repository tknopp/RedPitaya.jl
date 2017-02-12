export average, decimation, optimalDecimation,
       acqStart, acqStop, acqReset, bufferSize

### Sampling Rate and Decimation ###

decimation(rp::RedPitaya) = query(rp, "ACQ:DEC?", Int)

decimation(rp::RedPitaya, dec::Integer) = send(rp,"ACQ:DEC $dec")

function optimalDecimation(rp::RedPitaya, freq)
  if freq > 100e3#2e6
    return 1
  elseif freq > 2e3#50e3
    return 8
  elseif freq > 1e3
    return 64
  elseif freq > 0.5e3
    return 1024
  else
    return 8192
  end
end

function average(rp::RedPitaya)
  a = query(rp,"ACQ:AVG?")
  return a == "ON" ? true : false
end

function average(rp::RedPitaya, avg::Bool)
  avgStr = avg ? "ON" : "OFF"
  cmd ="ACQ:AVG $avgStr"
  send(rp,cmd)
end

### Acquisition Control ###

"""
Start acquisition of RedPitaya
"""
acqStart(rp::RedPitaya) = send(rp,"ACQ:START")

"""
Stop acquisition of RedPitaya
"""
acqStop(rp::RedPitaya) = send(rp,"ACQ:STOP")

"""
Reset acquisition of RedPitaya
"""
acqReset(rp::RedPitaya) = send(rp,"ACQ:RST")

### Acquisition Functions ###


bufferSize(rp::RedPitaya) = query(rp, "ACQ:BUF:SIZE?", Int)


export receiveAnalogSignal
function receiveAnalogSignal(rp::RedPitaya, chan::Integer, from::Int=-1, to::Int=-1;
                             dec::Integer=1, delay=0.2, typ="STA", binary=false, raw=false)

  acqReset(rp)
  decimation(rp,dec)
  acqStart(rp)
  sleep(delay) # fill buffers

  return receiveAnalogSignalLowLevel(rp,chan,from,to,typ,binary,raw)
end

function _awg_trigger_delay(rp::RedPitaya, dec::Integer)
  if dec == 1
    return 25
  elseif dec == 8
    return 3
  else
    return 0
  end
end

export receiveAnalogSignalWithTrigger
function receiveAnalogSignalWithTrigger(rp::RedPitaya, chan::Integer, from::Int=-1, to::Int=-1;
                             dec::Integer=1, delay=0.2, typ="OLD", trigger="AWG_NE",
                             triggerLevel=0.2, binary=false, raw=false, triggerDelay=0)

  acqReset(rp)
  decimation(rp,dec)
  send(rp,"ACQ:TRIG:LEV $triggerLevel")
  additionalDelay = contains(trigger,"AWG") ? _awg_trigger_delay(rp, dec) : 0
  send(rp,"ACQ:TRIG:DLY $(8192+additionalDelay+triggerDelay)")
  acqStart(rp)
  sleep(delay) # fill buffers

  send(rp,"ACQ:TRIG $trigger")
  send(rp,"SOUR1:TRIG:IMM")

  while true
    trig_rsp = query(rp,"ACQ:TRIG:STAT?")
    println(trig_rsp)
    if trig_rsp[1:2] == "TD"
       break
     end
  end

  if typ=="CUS"
    tpos = parse(Int64,query(rp,"ACQ:TPOS?"))
    return receiveAnalogSignalLowLevel(rp,chan,tpos,to,"STA",binary,raw)
  else
    return receiveAnalogSignalLowLevel(rp,chan,from,to,typ,binary,raw)
  end
end

export receiveAnalogSignalLowLevel
function receiveAnalogSignalLowLevel(rp::RedPitaya, chan::Integer, from::Int=-1,
                                     to::Int=-1, typ="OLD", binary::Bool=false,
                                     raw::Bool=false)

  if binary
    send(rp,"ACQ:DATA:FORMAT BIN")
  else
    send(rp,"ACQ:DATA:FORMAT ASCII")
  end

  if raw
    send(rp,"ACQ:DATA:UNITS RAW")
  end

  if from == to == -1
    send(rp,"ACQ:SOUR$(chan):DATA?")
  elseif typ == "STA"
    send(rp,"ACQ:SOUR$(chan):DATA:STA:N? $(from),$(to)")
  else
    send(rp,"ACQ:SOUR$(chan):DATA:$(typ):N? $(to)")
  end

  if binary
    if raw
      uFl = receiveBinaryInt16(rp)
    else
      uFl = receiveBinaryFloat(rp)
    end
  else
    uFl = receiveASCIIArray(rp)
  end

  return uFl
end
