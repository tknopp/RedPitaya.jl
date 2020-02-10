using Redpitaya

ip = "rp-f07083.local"
rp = RedPitaya(ip)

# enable LED2
state(rp, "LED2", true)

# ask if LED2 is on
b = state(rp, "LED2")

println("LED2 is $b")
