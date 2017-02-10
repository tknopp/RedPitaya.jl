using Redpitaya
using PyPlot

rp = RedPitaya("192.168.1.26")

baseFreq = 125e6
dec = 64 # this may have to be matched to the send frequency

freqs  = linspace( 1000, 1e6, 200)
for freq in freqs
  numPeriods = 10
  freqR = roundFreq(rp,dec,freq)
  numSampPerPeriod = numSamplesPerPeriod(rp,dec,freqR)
  numSamp = numSampPerPeriod*numPeriods

  println("Frequency = $freqR Hz")
  println("Number Sampling Points per Period: $numSampPerPeriod")

  # start sending
  send(rp,"GEN:RST")
  sendAnalogSignal(rp,1,"SINE",freqR,0.4)

  # receive data
  u1 = receiveAnalogSignal(rp, 1, 0, numSamp, dec=dec, delay=0.8)

  figure(1)
  clf()
  subplot(2,1,1)
  plot(u1)
  subplot(2,1,2)
  semilogy(abs(rfft(u1))[1:numPeriods*2],"o-b",lw=2)
end
