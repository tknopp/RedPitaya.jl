module Redpitaya

using Sockets

import Base: reset

export RedPitaya, receive, query, start, stop, send,
       receiveBinaryFloat,receiveBinaryInt16,receiveASCIIArray

mutable struct RedPitaya
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
  readline(rp.socket)#[1:end-2]
end

function readBinaryHeader(rp::RedPitaya)
  n = read!(rp.socket,Array{UInt8}(undef,1))
  n = read!(rp.socket,Array{UInt8}(undef,1))
  m = parse(Int64,String(copy(n)))
  numBytesStr = read!(rp.socket,Array{UInt8}(undef,m))
  numBytes = parse(Int64,String(copy(numBytesStr)))
  return numBytes
end

function receiveBinaryFloat(rp::RedPitaya)
  numBytes = readBinaryHeader(rp)
  u = read!(rp.socket, Array{Float32}(undef, div(numBytes,4)))
  uFl = [bswap(a) for a in u]
end

function receiveBinaryInt16(rp::RedPitaya)
  numBytes = readBinaryHeader(rp)
  u = read!(rp.socket, Array{Int16}(undef, div(numBytes,2)))
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
include("Custom.jl")


end #module
