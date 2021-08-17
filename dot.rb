#  Methos to return address and data send to UDPSocket
#     @param  host  [String] 
#     @param  port  [String]
def getUdpSocket(host, port)
  socket = UDPSocket.new
  socket.bind(host,port)
  socket
end

# Method to establish and  return a tcp ssl socket. 
#     @param  host  [String]
#     @param  port  [String]
def getSslTcpConnection(host, port)
  store = OpenSSL::X509::Store.new
  store.add_file(OpenSSL::X509::DEFAULT_CERT_FILE)
  sslContext = OpenSSL::SSL::SSLContext.new
  sslContext.cert_store = store
  sslContext.ssl_version = :SSLv23
  sslSocket = OpenSSL::SSL::SSLSocket.new(TCPSocket.new(host, port), sslContext)
  sslSocket.hostname = host #for Server Name Indication (SNI)
  sslSocket.sync_close = true #instead of calling close on tcp socket
  sslSocket.connect
  sslSocket
end


######################################
##  DNS Ovet TLS Ruby Script        ##
######################################
require 'socket'
require 'net/smtp'
require 'openssl'


dns_host = '1.1.1.1'          # =>  Cloudflare DNS server IP address
dns_port = 853                # =>  DNS server tls port
#host='172.16.64.2'            # =>  IP address of the machine were this script runs
host='192.168.29.27'            # =>  IP address of the machine were this script runs
port = 53                     # =>  DNS port

loop do
  socket = getUdpSocket(host,port)  
  mesg, addr = socket.recvfrom(4096)  # => variables mesg [String] & addr [Array]
  query = "\x00"+mesg.length.chr + mesg

  sslSocket = getSslTcpConnection(dns_host,dns_port)
  sslSocket.puts(query)
  tcp_result = sslSocket.gets
  if tcp_result
    rcode = tcp_result[0..6].hex
    rcode = rcode.to_s[0..11]
    if rcode.to_i(16) == 1      
      puts "Invalid DNS query"
    else
      udp_result = tcp_result[2..]
      socket.send(udp_result, 0, addr[2], addr[1])
    end
  else
    puts "Invalid DNS query"
  end
  sslSocket.sysclose
  socket.close
end
