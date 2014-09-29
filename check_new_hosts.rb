#!/usr/bin/env ruby
# check_new_hosts.rb
# After we have run dns_brute.rb, we can compare it to a \n seperated list
#   of IP addresses given to us by the client.  We want to keep only _new_ IP
#   addresses that might be in scope, but were forgotten to be added to scope
# Input arguments are 2 input files:
#   1) the output file created by dns_brute.txt
#   2) a hosts.txt file with one IP address/range per line
#   And one output file path

require 'ipaddr'

if ARGV[2].nil?
  abort "Use: check_new_hosts.rb <path to dnsbrute.txt output file> <path to hosts.txt> <output file>"
end

dnsbrute = ARGV[0]
hosts = ARGV[1]
outfile = ARGV[2]

d = File.open(dnsbrute, "r").read
h = File.open(hosts, "r").read

@ips = []
@hosts = []
@final = []
@output = []

# pull all IPs into array
d.each_line do |line|
  line.gsub!(/n/, "")
  @ips << line.split.last
end

# dedupe array
@ips = @ips.uniq

# hosts file to array of ip ranges
h.each_line do |line|
  line.gsub!(/\n/, "")
  @hosts << IPAddr.new(line)
end

# save IPs not found in hosts range
@ips.each do |line|
  @found = 0
  @hosts.each do |x|
    if x===line
      @found = 1
    end
  end
  if @found == 0
    @final << line
  end
end

# sort that shit
@final.sort_by! { |ip| ip.to_s.split(".").map(&:to_i) }

# pull the subdomains back to match new IP addresses
@final.each do |line|
  d.each_line do |x|
    if x =~ /#{line}/
      @output << x
    end
  end
end

# write out the results
File.write(outfile, @output.join(""))
