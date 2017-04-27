export apply1DAcquisition

function apply1DAcquisition(ip, numSamplesPerPeriod=100, numPeriods=100)
  socket = connect(ip,7777)
  write(socket,UInt32(numSamplesPerPeriod))
  write(socket,UInt32(numPeriods))

  u=read(socket,Int16, 100*100*2)
  u = reshape(u,100*100,2)
  close(socket)
  return u
end
