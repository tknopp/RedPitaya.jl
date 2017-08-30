export direction, state, value

### GPIO and LED ###

"""
Set the direction of digital IO pin to either input (true)
or output (false)
"""
function direction(rp::RedPitaya, pin::String, input::Bool)
  dir = input ? "INP" : "OUTP"
  send(rp,"DIG:PIN:DIR $(pin),$(dir)")
end

function state(rp::RedPitaya, pin::String)
  send(rp,"DIG:PIN? $(pin)")
  return parse(Int, receive(rp)) == 1
end

function state(rp::RedPitaya, pin::String, value::Bool)
  cmd ="DIG:PIN $(pin),$(Int(value))"
  send(rp,cmd)
end

### Analog IO ###

function value(rp::RedPitaya, pin::String)
  send(rp,"ANALOG:PIN? $(pin)")
  return parse(Float64, receive(rp))
end

function value(rp::RedPitaya, pin::String, value::Float64)
  cmd ="ANALOG:PIN $(pin),$(value)"
  send(rp,cmd)
end
