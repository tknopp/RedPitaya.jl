export samplingFreq, roundFreq, numSamplesPerPeriod, phaseShift

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
  return Int(div(samplingFreq(rp,dec),freqR))
end

"""
Return the number of time points the signal u has the be shifted
in order to have phase pi/2 (i.e. be a sine wave)
"""
function phaseShift(u, numPeriods)
  numSampPerPeriod = div(length(u),numPeriods)
  complexSine = exp(-2*pi*im*numPeriods*(0:length(u)-1)/length(u))
  fourierCoeff = dot(complexSine,u)
  return round(Int,numSampPerPeriod*(angle(fourierCoeff) -pi/2) / (2pi))
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
