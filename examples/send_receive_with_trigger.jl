using Redpitaya
using PyPlot

rp = RedPitaya("192.168.1.26")

dec = 8 # this may have to be matched to the send frequency

freq = 81380.0 #125000
numPeriods = 4
freqR = roundFreq(rp,dec,freq)
numSampPerPeriod = numSamplesPerPeriod(rp,dec,freqR)
numSamp = numSampPerPeriod*numPeriods

println("Frequency = $freqR Hz")
println("Number Sampling Points per Period: $numSampPerPeriod")

# start sending
send(rp,"GEN:RST")
sendAnalogSignal(rp,1,"SINE",freqR,0.4,numPeriods*2)

# receive data
u1 = receiveAnalogSignalWithTrigger(rp, 1, 0, numSamp, dec=dec, delay=0.2, typ="OLD")
#u1 = receiveAnalogSignalWithTrigger(rp, 1, -1, -1, dec=dec, delay=0.0, typ="OLD")

figure(1)
clf()
subplot(2,1,1)
plot(u1)
subplot(2,1,2)
semilogy(abs(rfft(u1))[1:numPeriods*4],"o-b",lw=2)


#Lets check if the data is periodic
figure(2)
clf()
plot(1:length(u1),u1,"x-r",lw=2)
plot(length(u1)+1:2*length(u1),u1,"x-b",lw=2)
