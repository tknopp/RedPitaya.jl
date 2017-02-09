using Redpitaya

ip = "10.167.6.97"
rp = RedPitaya(ip)

# enable LED2
digital_LED(rp,2,true)

# ask if LED2 is on
b = digital_LED(rp,2)

println("LED2 is $b")

