# This file contains high level Measurement routines based on the low level
# send/receive routines

export measureTransferFunction

# TODO: Currently only one channel is recorded -> measure input channel and
#       relate the output to that

function measureTransferFunction(rp::RedPitaya, freqs)
  tf = zeros(Complex128, length(freqs))

  for (i,freq) in enumerate(freqs)
    dec = optimalDecimation(rp,freq)

    numPeriods = 5
    freqR = roundFreq(rp,dec,freq)
    numSampPerPeriod = numSamplesPerPeriod(rp,dec,freqR)
    numSamp = numSampPerPeriod*numPeriods

    println("Frequency = $freqR Hz")
    println("Number Sampling Points per Period: $numSampPerPeriod")

    # start sending
    send(rp,"GEN:RST")
    sendAnalogSignal(rp,1,"SINE",freqR,0.4)#, numPeriods*2)

    # receive data
    #u1 = receiveAnalogSignal(rp, 1, 0, numSamp, dec=dec, delay=0.2) # NO TRIGGER VERSION
    trigger = "NOW" #"AWG_PE" #"CH1_PE"
    uMeas, uRef = receiveAnalogSignalWithTrigger(rp, 0, 0, numSamp, dec=dec, delay=0.1, typ="OLD",
                                trigger=trigger, triggerLevel=-0.1,
                                triggerDelay=numSampPerPeriod)

    #tf[i] = rfft(uMeas)[numPeriods+1] / length(uMeas)
    tf[i] = rfft(uMeas)[numPeriods+1] / rfft(uRef)[numPeriods+1]
  end
  return tf
end
