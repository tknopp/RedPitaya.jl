module Redpitaya

import Base: send

export RedPitaya, receive

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



end # module
