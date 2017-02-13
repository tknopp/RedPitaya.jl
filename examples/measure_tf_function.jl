using Redpitaya
using PyPlot

#rp = RedPitaya("192.168.1.26")
rp = RedPitaya("10.167.6.99")

freqs  = linspace( 10e3, 40e3, 50)
tf = measureTransferFunction(rp, freqs)

figure(1)
clf()
subplot(2,1,1)
plot(freqs,angle(tf),"o-r",lw=2)
subplot(2,1,2)
semilogy(freqs,abs(tf),"o-b",lw=2)
