using Redpitaya
using PyPlot
using FFTW

rp = RedPitaya("10.167.6.139")

freq = 25000.0
dec = optimalDecimation(rp,freq)
#freq=25000
numPeriods = 30
freqR = roundFreq(rp,dec,freq)
numSampPerPeriod = numSamplesPerPeriod(rp,dec,freqR)
numSamp = numSampPerPeriod*numPeriods
if numSamp>16384
#	error("To many sampling points for RedPitaya buffer. Reduce Decimation or reduce number of periods")
end

println("Frequency = $freqR Hz")
println("Number Sampling Points per Period: $numSampPerPeriod")

# start sending
send(rp,"GEN:RST")
#send(rp,"SOUR1:BURS:STAT ON")
#change this to SQUARE to get a SQUARE excitation
sendAnalogSignal(rp,1,"SINE",freqR,0.4,offset=0.2,ncycBurst=60)
#send(rp,"SOUR1:VOLT:OFFS 0")
# receive data
trigger = "AWG_NE" # "CH1_PE"
u1 = receiveAnalogSignalWithTrigger(rp, 1, 0, numSamp, dec=dec, delay=0.2, typ="OLD",
                      trigger=trigger, triggerLevel=-0.0, binary=true, raw=false,
                      triggerDelay=numSampPerPeriod)


figure(3)
subplot(2,1,1)
plot(u1)
subplot(2,1,2)
semilogy(abs.(rfft(u1)),"o-b",lw=2)


#Lets check if the data is periodic
figure(4)
plot(1:length(u1),u1,"x-r",lw=2)
plot(length(u1)+1:2*length(u1),u1,"x-b",lw=2)
