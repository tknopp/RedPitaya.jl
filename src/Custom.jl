export apply1DAcquisition

function apply1DAcquisition(ip, numSamplesPerPeriod=100, numPeriods=100)
  socket = connect(ip,7777)
  write(socket,UInt32(numSamplesPerPeriod))
  write(socket,UInt32(numPeriods))

  uMeas = zeros(Int16,numSamplesPerPeriod,numPeriods)
  uControl = zeros(Int16,numSamplesPerPeriod,numPeriods)
  u = zeros(Int16,numSamplesPerPeriod,numPeriods,2)
  data_send = 0
  packet_size = 10000
  buff_size = numSamplesPerPeriod * numPeriods
  while data_send < buff_size
    local_packet_size = (data_send + packet_size > buff_size) ?
                             (buff_size-data_send) : packet_size
    uMeas[data_send+1:(data_send+local_packet_size)] = read(socket,Int16, local_packet_size)
    uControl[data_send+1:(data_send+local_packet_size)] = read(socket,Int16, local_packet_size)
    write(socket,"OK")
    data_send += local_packet_size
  end
  close(socket)
  u[:,:,1] = uMeas
  u[:,:,2] = uControl
  u = reshape(u,numSamplesPerPeriod*numPeriods,2)
  return u
end
