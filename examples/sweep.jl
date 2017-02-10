using Redpitaya
using PyPlot

rp = RedPitaya("192.168.1.26")

dec = 8 # this may have to be matched to the send frequency

USE_TRIGGER_VERSION = true

freqs  = linspace( 1000, 1e6, 400)
for freq in freqs
  dec = freq < 50e3 ? 64 : 8

  numPeriods = 10
  freqR = roundFreq(rp,dec,freq)
  numSampPerPeriod = numSamplesPerPeriod(rp,dec,freqR)
  numSamp = numSampPerPeriod*numPeriods

  println("Frequency = $freqR Hz")
  println("Number Sampling Points per Period: $numSampPerPeriod")

  # start sending
  send(rp,"GEN:RST")
  if !USE_TRIGGER_VERSION
    sendAnalogSignal(rp,1,"SINE",freqR,0.4)
  else
    sendAnalogSignal(rp,1,"SINE",freqR,0.4, numPeriods*2)
  end

  # receive data
  if !USE_TRIGGER_VERSION
    u1 = receiveAnalogSignal(rp, 1, 0, numSamp, dec=dec, delay=0.2)
  else
    u1 = receiveAnalogSignalWithTrigger(rp, 1, 0, numSamp, dec=dec,
                delay=0.1, typ="OLD", trigger="CH1_PE", triggerLevel=-0.1)
    #u1 = receiveAnalogSignalWithTrigger(rp, 1, 0, numSamp, dec=dec, delay=0.0001, typ="CUS")
    #u1 = receiveAnalogSignalWithTrigger(rp, 1, -1, -1, dec=dec, delay=0.0, typ="OLD")
  end


  figure(1)
  clf()
  subplot(2,1,1)
  plot(u1)
  subplot(2,1,2)
  semilogy(abs(rfft(u1))[1:numPeriods*2],"o-b",lw=2)
end
