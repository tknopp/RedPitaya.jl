using Redpitaya
using PyPlot

rp = RedPitaya("192.168.1.26")

freq = 25000
dec = optimalDecimation(dec,freq)

numPeriods = 4
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
semilogy(abs(rfft(u1))[1:numPeriods*4],"o-b",lw=2)


#Lets check if the data is periodic
figure(2)
clf()
plot(1:length(u1),u1,"x-r",lw=2)
plot(length(u1)+1:2*length(u1),u1,"x-b",lw=2)
