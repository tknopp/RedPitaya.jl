using PyPlot
using Redpitaya

# OLD FILE: DO NOT USE!!!


#rp = RedPitaya("10.167.6.99")
rp = RedPitaya("192.168.1.26")

baseFreq = 125e6
dec = 8

numSampPerPeriod = 100
numPeriods = 10
numSamp = numSampPerPeriod*numPeriods
freq = div(baseFreq,dec*numSampPerPeriod)#*dec

println(freq)

# start sending
send(rp,"GEN:RST")
sendAnalogSignal(rp,1,"SINE",freq,0.4,numPeriods*2)

#sendAnalogSignal(rp,2,"TRIANGLE",25000,0.4)

# prepare acquisition
# Set decimation vale (sampling rate) in respect to you
# acquired signal frequency
acqReset(rp)
decimation(rp,dec)
send(rp,"ACQ:TRIG:LEV 0.01")


# Set trigger delay to 0 samples
# 0 samples delay set trigger to center of the buffer
# Signal on your graph will have trigger in the center (symmetrical)
# Samples from left to the center are samples before trigger
# Samples from center to the right are samples after trigger
send(rp,"ACQ:TRIG:DLY 8190")
#send(rp,"ACQ:TRIG:DLY 0")

## Start & Trigg
# Trigger source setting must be after ACQ:START
# Set trigger to source 1 positive edge

acqStart(rp)
# After acquisition is started some time delay is needed in order to acquire fresh samples in to buffer
# Here we have used time delay of one second but you can calculate exact value taking in to account buffer
# length and smaling rate
sleep(0.1)


send(rp,"ACQ:TRIG AWG_PE")
send(rp,"SOUR1:TRIG:IMM")
#send(rp,"SOUR2:TRIG:IMM")

# Wait for trigger
# Until trigger is true wait with acquiring
# Be aware of while loop if trigger is not achieved
# Ctrl+C will stop code executing in Julia

while true
  send(rp,"ACQ:TRIG:STAT?")
  trig_rsp = receive(rp)
  println(trig_rsp)
  if trig_rsp[1:2] == "TD"
     break
   end
end
#sleep(0.1)
#acqStop(rp)

println( query(rp,"ACQ:TPOS?") )
println( query(rp,"ACQ:WPOS?") )

tpos = parse(Int64,query(rp,"ACQ:TPOS?"))

# Read data from buffer
u1=receiveAnalogSignalLowLevel(rp,1)
u2=receiveAnalogSignalLowLevel(rp,1,0,numSamp,"STA")
u3=receiveAnalogSignalLowLevel(rp,1,0,numSamp,"OLD")
u4=receiveAnalogSignalLowLevel(rp,1,0,numSamp,"LAT")
u5=receiveAnalogSignalLowLevel(rp,1,tpos,numSamp,"STA")

figure(1)
clf()
subplot(2,1,1)
plot(u1)
subplot(2,1,2)
semilogy(abs(rfft(u1))[1:numPeriods*4],"o-b",lw=2)

figure(2)
clf()
subplot(5,1,1)
plot(u1,"g")
subplot(5,1,2)
plot(u2,"b")
subplot(5,1,3)
plot(u3,"r")
subplot(5,1,4)
plot(u4,"y")
subplot(5,1,5)
plot(u5,"y")
#subplot(2,1,2)
#plot(u2)
