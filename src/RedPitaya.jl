module Redpitaya

import Base: send, start, reset

export RedPitaya, receive, query, stop

type RedPitaya
  delim
  socket

  function RedPitaya(host, port=5000)
    socket = connect(host,port)
    return new("\r\n", socket)
  end
end

function send(rp::RedPitaya,cmd::String)
  write(rp.socket,cmd*rp.delim)
end

function receive(rp::RedPitaya)
  # not sure which to use...
  #read(rp.socket,String)
  #readline(rp.socket)
  #read(rp.socket)

  readline(rp.socket)[1:end-2]
end

function query(rp::RedPitaya,cmd::String)
  send(rp,cmd)
  return receive(rp)
end

### LED Interface ###

export digital_LED
function digital_LED(rp::RedPitaya, id::Integer)
  send(rp,"DIG:PIN? LED$(id)")
  return parse(Int, receive(rp)) == 1
end

function digital_LED(rp::RedPitaya, id::Integer, value::Bool)
  cmd ="DIG:PIN LED$(id),$(Int(value))"
  println(cmd)
  send(rp,cmd)
end

### Analog Output Interface ###

export sendAnalogSignal
function sendAnalogSignal(rp::RedPitaya, chan::Integer, func::String,
                          freq::Number, amplitude::Number, ncycBurst::Integer=0)
  if !in(func,["SINE", "SQUARE", "TRIANGLE", "SAWU", "SAWD", "PWD"])
    error("waveform $func not supported")
  end
  source = "SOUR$(chan)"
  #send(rp,"GEN:RST")
  send(rp,"$(source):FUNC $(func)") # Set function of output signal
  bufferSize(rp)
  send(rp,"$(source):FREQ:FIX $(freq)") # Set frequency of output signal
  bufferSize(rp)
  send(rp,"$(source):VOLT $(amplitude)") # Set amplitude of output signal
  bufferSize(rp)

  if ncycBurst > 0
    #send(rp,"$(source):BURS:STAT ON") #Set burst mode to ON
    #bufferSize(rp)
    send(rp,"$(source):BURS:NCYC $ncycBurst") #Set 1 pulses of sine wave
    bufferSize(rp)
  end
  send(rp,"OUTPUT$(chan):STATE ON") # Set output to ON
  bufferSize(rp)
end

export receiveAnalogSignal
function receiveAnalogSignal(rp::RedPitaya, chan::Integer, from::Int=-1, to::Int=-1;
                             dec::Integer=1, delay=0.2, typ="STA", binary=false)

  acqReset(rp)
  decimation(rp,dec)
  acqStart(rp)
  sleep(delay) # fill buffers

  return receiveAnalogSignalLowLevel(rp,chan,from,to,typ, binary)
end

export receiveAnalogSignalWithTrigger
function receiveAnalogSignalWithTrigger(rp::RedPitaya, chan::Integer, from::Int=-1, to::Int=-1;
                             dec::Integer=1, delay=0.2, typ="OLD", trigger="AWG_NE",
                             triggerLevel=0.2, binary=false)

  acqReset(rp)
  decimation(rp,dec)
  send(rp,"ACQ:TRIG:LEV $triggerLevel")
  send(rp,"ACQ:TRIG:DLY 8192")
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
    return receiveAnalogSignalLowLevel(rp,chan,tpos,to,"STA",binary)
  else
    return receiveAnalogSignalLowLevel(rp,chan,from,to,typ,binary)
  end
end

export receiveAnalogSignalLowLevel
function receiveAnalogSignalLowLevel(rp::RedPitaya, chan::Integer, from::Int=-1,
                                     to::Int=-1, typ="OLD", binary::Bool=false)

  if binary
    send(rp,"ACQ:DATA:FORMAT BIN")
    send(rp,"ACQ:DATA:UNITS RAW")
  else
    send(rp,"ACQ:DATA:FORMAT ASCII")
  end

  if from == to == -1
    send(rp,"ACQ:SOUR$(chan):DATA?")
  elseif typ == "STA"
    send(rp,"ACQ:SOUR$(chan):DATA:STA:N? $(from),$(to)")
  else
    send(rp,"ACQ:SOUR$(chan):DATA:$(typ):N? $(to)")
  end

  u = receive(rp)
  if binary
    lenData = (from == to == -1) ? 16384 : to
    u = read(rp.socket,Int16, lenData) # this still does not work
    #u = [bswap(a) for a in u]
    uFl = map(Float32,u)
  else
    uFl = [parse(Float64,o) for o in split(u[2:end-1],",")]
  end

  return uFl
end

export bufferSize
function bufferSize(rp::RedPitaya)
  cmd ="ACQ:BUF:SIZE?"
  send(rp,cmd)
  return parse(Int, receive(rp))
end

###### Acquire #####

### Control ###
export acqStart, acqStop, acqReset
function acqStart(rp::RedPitaya)
  send(rp,"ACQ:START")
end

function acqStop(rp::RedPitaya)
  send(rp,"ACQ:STOP")
end

function acqReset(rp::RedPitaya)
  send(rp,"ACQ:RST")
end

### Sampling Rate and Decimation ###

export decimation
function decimation(rp::RedPitaya)
  cmd ="ACQ:DEC?"
  send(rp,cmd)
  return parse(Int, receive(rp))
end

function decimation(rp::RedPitaya, dec::Integer)
  cmd ="ACQ:DEC $dec"
  send(rp,cmd)
end

export optimalDecimation
function optimalDecimation(rp::RedPitaya, freq)
  if freq > 2e6
    return 1
  elseif freq > 50e3
    return 8
  elseif freq > 8e3
    return 64
  elseif freq > 1e3
    return 1024
  else
    return 8192
  end
end

export average
function average(rp::RedPitaya)
  cmd ="ACQ:AVG?"
  send(rp,cmd)
  return receive(rp) == "ON" ? true : false
end

function average(rp::RedPitaya, avg::Bool)
  avgStr = avg ? "ON" : "OFF"
  cmd ="ACQ:AVG $avgStr"
  send(rp,cmd)
end

export samplingFreq
function samplingFreq(rp::RedPitaya,dec::Integer)
  baseFreq = 125e6
  freq = div(baseFreq,dec)
  return freq
end

export roundFreq
function roundFreq(rp::RedPitaya,dec::Integer,freq)
  numPeriods = round(Int64,samplingFreq(rp,dec) / freq)
  return div(samplingFreq(rp,dec), numPeriods)
end

export numSamplesPerPeriod
function numSamplesPerPeriod(rp::RedPitaya,dec::Integer,freqR)
  return Int64(div(samplingFreq(rp,dec),freqR))
end


end #module
