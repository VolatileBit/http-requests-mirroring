#!/bin/bash -xe
#
#
### update and install ###
#
export HOME=~
yum update -y
yum install git -y
yum install go -y
# dependency of github.com/google/gopacket
yum install install libpcap-devel -y
#
#
### dependency of main.go ###
go env GOPATH
echo 'export GOPATH=$HOME/go' >>~/.bash_profile
source ~/.bash_profile
go get "github.com/google/gopacket"
#
#
#
### create a virtual network interface that gets decapsulated VXLAN packets
#### compile & run go script ###
mkdir $GOPATH"/src/vxlan-to-http-request"
wget https://github.com/VolatileBit/http-requests-mirroring/raw/main/main.go -P $GOPATH"/src/vxlan-to-http-request"
go install "vxlan-to-http-request"
sudo ip link add vxlan0 type vxlan id 10 dev eth0 dstport 4789
sudo ip link set vxlan0 up
$GOPATH"/bin/vxlan-to-http-request" -destination "{{TARGET HTTP/HTTPS ADDRESS e.g. http://localhost:8000}}" -percentage "100" -percentage-by "" -percentage-by-header "" -filter-request-port "80"