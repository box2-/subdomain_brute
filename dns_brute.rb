#! /usr/bin/env ruby
# Brute force resolve subdomains for a list of domains
# Are input arguments at paths to 2 input files:
#   1) a list of domain names to attempt brute on
#   2) our dictionary file of subdomains to attempt

require 'resolv'

if ARGV[2].nil?
    abort "Use: dns_brute.rb <path to domains.txt> <path to subdomains.txt> <output file>"
end

domains = ARGV[0]
subdomains = ARGV[1]
outfile = ARGV[2]

d = File.open(domains, "r").read
s = File.open(subdomains, "r").read

d.each_line do |domline|
  domline.gsub!(/\n/, "")
  s.each_line do |subline|
    subline.gsub!(/\n/, "")
    entry = subline + "." + domline
    begin
      resolved = Resolv.getaddress(entry)
      puts "#{entry} #{resolved}"
      @output = @output.to_s + "#{entry} #{resolved}\n"
    rescue 
      # do nothing?
    end
  end
end

File.write(outfile, @output)
