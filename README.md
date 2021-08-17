#   DNS-over-TLS

DNS-Over-TLS is used to send DNS queries over an encrypted connection. This script is a DNS forwarder that acts as a DNS resolver but requires an upstream DNS server. Cloudflare DNS server is used as upstream DNS server. 

## Source Code
Used ruby-2.6 version 

In the dot.rb script I have used Cloudflare DNS IP 1.1.1.1 for DNS quering.
  - Using getUdpSocket() method this script creates a socket connection and bind it with the Docker's network (172.168.1.2) on port 53
  - Gets UDP DNS request on this connection and establishes a TLS connection with cloudflare dns server on port 853 using the method getSslTcpConnection(). 

### Installing
Run this project
* Create docker image by using Dockerfile 
  - docker build -t dot .
* Create docker network by using this command:
  - docker network create --subnet 172.16.64.0/24 dot_network
* Run the container by using that docker image we created.
  - docker run --net dot_network  -it dot
* Update your /etc/resolv.conf file for the nslookup by adding the nameserver entry:
  - nameserver 172.16.64.2  #container ip
* Test this by making dig request
  - dig @172.16.64.2 google.com

### To run the script locally
* Edit dot.rb file and change the host IP to your machines IP. 
* Run the ruby script 
  - sudo ruby dot.rb
* Test this by making dig request
  - dig @<your_machines-ip> google.com
