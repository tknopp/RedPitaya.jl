export sendAnalogSignal

### Analog Output Interface ###

function sendAnalogSignal(rp::RedPitaya, chan::Integer, func::String,
                          freq::Number, amplitude::Number, ncycBurst::Integer=0)
  if !in(func,["SINE", "SQUARE", "TRIANGLE", "SAWU", "SAWD", "PWD"])
    error("waveform $func not supported")
  end
  source = "SOUR$(chan)"
  #send(rp,"GEN:RST")
  send(rp,"$(source):FUNC $(func)") # Set function of output signal
  send(rp,"$(source):FREQ:FIX $(freq)") # Set frequency of output signal
  send(rp,"$(source):VOLT $(amplitude)") # Set amplitude of output signal

  if ncycBurst > 0
    #send(rp,"$(source):BURS:STAT ON") #Set burst mode to ON
    #bufferSize(rp)
    send(rp,"$(source):BURS:NCYC $ncycBurst") #Set 1 pulses of sine wave
  end
  send(rp,"OUTPUT$(chan):STATE ON") # Set output to ON
end
