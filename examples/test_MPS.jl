using Redpitaya


export showMPSData
function showMPSData(u, freq)
  figure(1)
  clf()
  subplot(2,1,1)
  plot(u)
  subplot(2,1,2)
  semilogy(freq, abs(rfft(u)),"o-b",lw=2)
  sleep(0.1)
end




rp = RedPitaya("10.167.6.87")

amplitude = 0.39
  dec = 8
  txFreqDivider = 4836
  freq = div(125e6,txFreqDivider)
  numPeriods = 25
  freqR = roundFreq(rp,dec,freq)
  numSampPerPeriod = numSamplesPerPeriod(rp,dec,freqR)
  numSamp = numSampPerPeriod*numPeriods
  println("Frequency = $freqR Hz")
  println("Number Sampling Points per Period: $numSampPerPeriod")
  # start sending
  send(rp,"GEN:RST")
  sendAnalogSignal(rp,1,"SINE",freqR,amplitude)
  sleep(0.4)
    trigger = "NOW" #"AWG_NE" # or NOW
    uMeas, uRef = receiveAnalogSignalWithTrigger(rp, 0, 0, numSamp, dec=dec, delay=0.01,
                typ="OLD", trigger=trigger, triggerLevel=-0.0,
                binary=true, triggerDelay=numSampPerPeriod)
    uMeas[:] = circshift(uMeas,-phaseShift(uRef, numPeriods))

lenFFT = length(rfft(uMeas))
fr = linspace(0,125e6/2/dec,lenFFT)
println(length(fr))

showMPSData(vec(uMeas),fr)
writecsv("MPS.csv",hcat(uMeas,uRef))
