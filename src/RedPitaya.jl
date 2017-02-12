module Redpitaya

import Base: send, start, reset

export RedPitaya, receive, query, stop,
       receiveBinaryFloat,receiveBinaryInt16,receiveASCIIArray

type RedPitaya
  delim::String
  socket::TCPSocket

  function RedPitaya(host, port=5000)
    socket = connect(host,port)
    return new("\r\n", socket)
  end
end

"""
Send a command to the RedPitaya
"""
function send(rp::RedPitaya,cmd::String)
  write(rp.socket,cmd*rp.delim)
end

"""
Receive a String from the RedPitaya
"""
function receive(rp::RedPitaya)
  readline(rp.socket)[1:end-2]
end

function readBinaryHeader(rp::RedPitaya)
  n = read(rp.socket,UInt8,1)
  n = read(rp.socket,UInt8,1)
  m = parse(Int64,String(copy(n)))
  numBytesStr = read(rp.socket,UInt8,m)
  numBytes = parse(Int64,String(copy(numBytesStr)))
  return numBytes
end

function receiveBinaryFloat(rp::RedPitaya)
  numBytes = readBinaryHeader(rp)
  u = read(rp.socket,Float32, div(numBytes,4))
  uFl = [bswap(a) for a in u]
end

function receiveBinaryInt16(rp::RedPitaya)
  numBytes = readBinaryHeader(rp)
  u = read(rp.socket,Int16, div(numBytes,2))
  uFl = [Float32(bswap(a)) for a in u]
end

function receiveASCIIArray(rp::RedPitaya)
  u = receive(rp)
  uFl = [parse(Float64,o) for o in split(u[2:end-1],",")]
end


"""
Perform a query with the RedPitaya. Return String
"""
function query(rp::RedPitaya,cmd::String)
  send(rp,cmd)
  return receive(rp)
end

"""
Perform a query with the RedPitaya. Parse result as type T
"""
function query(rp::RedPitaya,cmd::String,T::Type)
  a = query(rp,cmd)
  return parse(T,a)
end

include("IO.jl")
include("Generator.jl")
include("Acquire.jl")
include("Utils.jl")
include("Measurements.jl")



end #module
