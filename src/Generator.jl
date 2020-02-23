export sendAnalogSignal, disableAnalogOutput, sendAnalogBurstSignal, trapeziod

### Analog Output Interface ###

function sendAnalogSignal(rp::RedPitaya, chan::Integer, func::String,
                          freq::Number, amplitude::Number; offset::Number=0,AWG_data::Array=[])
  if !in(func,["SINE", "SQUARE", "TRIANGLE", "SAWU", "SAWD", "PWD", "AWG"])
    error("waveform $func not supported")
  end
  source = "SOUR$(chan)"
  send(rp,"GEN:RST")
  send(rp,"$(source):FUNC $(func)") # Set function of output signal
  send(rp,"$(source):FREQ:FIX $(freq)") # Set frequency of output signal
  send(rp,"$(source):VOLT $(amplitude)") # Set amplitude of output signal
  send(rp,"$(source):VOLT:OFFS $(offset)") # Set offset of output signal
  if func=="AWG"
    send(rp, "$(source):TRAC:DATA:DATA $(AWG_data)")
  end
  send(rp,"OUTPUT$(chan):STATE ON") # Set output to ON
end

function sendAnalogBurstSignal(rp::RedPitaya, chan::Integer, func::String,
                          freq::Number, amplitude::Number; offset::Number=0,
                          ncycBurst::Integer=0, repetitions::Integer=0,
                          repetitionCycleTime::Float64=0 , AWG_data::Array=[])
  if !in(func,["SINE", "SQUARE", "TRIANGLE", "SAWU", "SAWD", "PWD", "ARBITRARY"])
    error("waveform $func not supported")
  end
  source = "SOUR$(chan)"
  send(rp,"GEN:RST")
  send(rp,"$(source):FUNC $(func)") # Set function of output signal
  send(rp,"$(source):FREQ:FIX $(freq)") # Set frequency of output signal
  send(rp,"$(source):VOLT $(amplitude)") # Set amplitude of output signal
  send(rp,"$(source):VOLT:OFFS $(offset)") # Set offset of output signal
  if ncycBurst > 0
   println("BurstMode On. Sending $(ncycBurst) Bursts")
   println("$(source):BURS:NCYC $ncycBurst") 

   send(rp,"$(source):BURS:STAT ON") #Set burst mode to ON
  #bufferSize(rp)
   send(rp,"$(source):BURS:NCYC $ncycBurst") #Set 1 pulses of sine wave
   if repetitions!=0
     send(rp, "$(source):BURS:NOR $repetitions")
     println("$(repetitionCycleTime)")
     send(rp, "$(source):BURS:INT:PER $(repetitionCycleTime)")
   end
 end
   if func=="ARBITRARY"
    AWG_data=join(AWG_data, ",")
    send(rp, "$(source):TRAC:DATA:DATA $(AWG_data)")
  end
  send(rp,"OUTPUT$(chan):STATE ON") # Set output to ON
end


function disableAnalogOutput(rp::RedPitaya, chan::Integer)
  send(rp,"OUTPUT$(chan):STATE OFF") # Set output to ON
end
function trapeziod(flankratio; len=2^14, offset=0)
    x = range(0, stop=2*pi, length=len)     #generates clean periodic signal

    rise = x * 2/(1-flankratio)      #calc width of rising edge and mirror it ...
    fall = - rise
    edge_point = trunc(Int, (1-flankratio)/2 * len)
    top = trunc(Int, (2^14 - 4*edge_point ) / 2 )

    p1 = collect( rise[1 : edge_point] / (2*pi))
    p2 = collect( ones(top))
    p3 = collect( (fall[1 : 2*edge_point] / (2*pi) .+ 1))
    p4 = collect( -ones(top))
    p5 = collect( rise[1 : edge_point] / (2*pi) .- 1)

    trapez = vcat(p1,p2,p3,p4,p5).-offset

     if length(trapez) != len   #test
        error("ERROR: failed to concatenate array parts correctly, $(len) $(length(trapez))")
    end
return trapez
end



