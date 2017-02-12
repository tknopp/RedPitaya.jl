export samplingFreq, roundFreq, numSamplesPerPeriod

function samplingFreq(rp::RedPitaya,dec::Integer)
  baseFreq = 125e6
  freq = div(baseFreq,dec)
  return freq
end

function roundFreq(rp::RedPitaya,dec::Integer,freq)
  numPeriods = round(Int64,samplingFreq(rp,dec) / freq)
  return div(samplingFreq(rp,dec), numPeriods)
end


function numSamplesPerPeriod(rp::RedPitaya,dec::Integer,freqR)
  return Int64(div(samplingFreq(rp,dec),freqR))
end


function test2(rp)
  a=zeros(30)
  for l=1:30
    wpos = parse(Int32,query(rp,"ACQ:WPOS?"))
    u = receiveAnalogSignalLowLevel(rp,1,0,16384,"STA",true,true)
    a[l] = wpos
  end
  return a
end
