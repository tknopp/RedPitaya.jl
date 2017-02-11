using Redpitaya
using PyPlot

rp = RedPitaya("192.168.1.26")

freqs  = linspace( 1000, 1e6, 50)
tf = zeros(Complex128, length(freqs))

USE_TRIGGER_VERSION = true

for (i,freq) in enumerate(freqs)
  dec = optimalDecimation(rp,freq)

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
    trigger = "AWG_PE" #"CH1_PE"
    u1 = receiveAnalogSignalWithTrigger(rp, 1, 0, numSamp, dec=dec, delay=0.01, typ="OLD",
                              trigger=trigger, triggerLevel=-0.1,
                              triggerDelay=numSampPerPeriod)
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
