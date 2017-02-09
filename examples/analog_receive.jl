using PyPlot
using Redpitaya

rp = RedPitaya("10.167.6.97")

# start sending
sendAnalogSignal(rp,1,"SINE",25000,0.4)

# prepare acquisition
# Set decimation vale (sampling rate) in respect to you 
# acquired signal frequency
acqReset(rp)
acqStop(rp)
decimation(rp,8)
send(rp,"ACQ:TRIG:LEV 0.4")


# Set trigger delay to 0 samples
# 0 samples delay set trigger to center of the buffer
# Signal on your graph will have trigger in the center (symmetrical)
# Samples from left to the center are samples before trigger 
# Samples from center to the right are samples after trigger
send(rp,"ACQ:TRIG:DLY 0")

## Start & Trigg
# Trigger source setting must be after ACQ:START
# Set trigger to source 1 positive edge

acqStart(rp)
# After acquisition is started some time delay is needed in order to acquire fresh samples in to buffer
# Here we have used time delay of one second but you can calculate exact value taking in to account buffer
# length and smaling rate
sleep(1)

#send(rp,"ACQ:TRIG CH1_PE")
#send(rp,"ACQ:TRIG NOW")

# Wait for trigger
# Until trigger is true wait with acquiring
# Be aware of while loop if trigger is not achieved
# Ctrl+C will stop code executing in Julia

while false
  send(rp,"ACQ:TRIG:STAT?")
  trig_rsp = receive(rp)
  println(trig_rsp) 
  if trig_rsp[1:2] == "TD"
     break
   end
end

# Read data from buffer 
u=receiveAnalogSignal(rp,1)

plot(u)



