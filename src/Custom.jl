export apply1DAcquisition

function apply1DAcquisition(ip)
  socket = connect(ip,7777)
  write(socket,UInt32(100))
  write(socket,UInt32(100))

  u=read(socket,Int16, 100*100*2)
  u = reshape(u,100*100,2)
  close(socket)
  return u
end
