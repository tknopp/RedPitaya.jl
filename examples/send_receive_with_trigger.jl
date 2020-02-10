using Redpitaya
using PyPlot
using FFTW

rp = RedPitaya("rp-f07083.local")

freq = 80374.0
dec = optimalDecimation(rp,freq)
numPeriods = 4
freqR = roundFreq(rp,dec,freq)
numSampPerPeriod = numSamplesPerPeriod(rp,dec,freqR)
numSamp = numSampPerPeriod*numPeriods

println("Frequency = $freqR Hz")
println("Number Sampling Points per Period: $numSampPerPeriod")

# start sending
send(rp,"GEN:RST")
#change this to SQUARE to get a SQUARE excitation
sendAnalogSignal(rp,1,"SINE",freqR,0.4,numPeriods*2)

# receive data
trigger = "AWG_NE" # "CH1_PE"
u1 = receiveAnalogSignalWithTrigger(rp, 1, 0, numSamp, dec=dec, delay=0.2, typ="OLD",
                      trigger=trigger, triggerLevel=-0.0, binary=true, raw=false,
                      triggerDelay=numSampPerPeriod)

figure(1)
clf()
subplot(2,1,1)
plot(u1)
subplot(2,1,2)
semilogy(abs.(rfft(u1))[1:numPeriods*4],"o-b",lw=2)


#Lets check if the data is periodic
figure(2)
clf()
plot(1:length(u1),u1,"x-r",lw=2)
plot(length(u1)+1:2*length(u1),u1,"x-b",lw=2)
