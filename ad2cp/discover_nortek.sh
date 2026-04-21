INTERFACE=enp4s0

#sudo arp-scan -vvv --interface=$INTERFACE -M 1 -x 169.254.0.0/16
sudo arp-scan  --interface=$INTERFACE -M 3 -x 192.168.1.0/24

using | grep Nortek gives this:
192.168.1.100	8c:68:78:00:1e:c5	Nortek-AS

Works if adcp is connected to the router, because then it gets an ip address. 