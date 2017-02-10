using Redpitaya
using PyPlot

rp = RedPitaya("192.168.1.26")

dec = 8 # this may have to be matched to the send frequency

freqs  = linspace( 1000, 1e6, 50)
tf = zeros(Complex128, length(freqs))

USE_TRIGGER_VERSION = true

for (i,freq) in enumerate(freqs)
  dec = freq < 50e3 ? 64 : 8

  numPeriods = 4
  freqR = roundFreq(rp,dec,freq)
  numSampPerPeriod = numSamplesPerPeriod(rp,dec,freqR)
  numSamp = numSampPerPeriod*numPeriods

  println("Frequency = $freqR Hz")
  println("Number Sampling Points per Period: $numSampPerPeriod")

  # start sending
  send(rp,"GEN:RST")
  if !USE_TRIGGER_VERSION
    sendAnalogSignal(rp,1,"SINE",freqR,0.4) # NO TRIGGER VERSION
  else
    sendAnalogSignal(rp,1,"SINE",freqR,0.4, numPeriods*2)
  end

  # receive data
  if !USE_TRIGGER_VERSION
    u1 = receiveAnalogSignal(rp, 1, 0, numSamp, dec=dec, delay=0.2) # NO TRIGGER VERSION
  else
    u1 = receiveAnalogSignalWithTrigger(rp, 1, 0, numSamp, dec=dec, delay=0.1, typ="OLD",
                              trigger="CH1_PE", triggerLevel=-0.1)
    #u1 = receiveAnalogSignalWithTrigger(rp, 1, 0, numSamp, dec=dec, delay=0.1, typ="CUS")
  end

  tf[i] = rfft(u1)[numPeriods+1] / length(u1)
end

figure(1)
clf()
subplot(2,1,1)
plot(freqs,angle(tf),"o-r",lw=2)
subplot(2,1,2)
semilogy(freqs,abs(tf),"o-b",lw=2)
