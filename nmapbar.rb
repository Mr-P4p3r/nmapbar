#!/usr/bin/ruby
require 'pty'
require 'tty-progressbar'
require 'pastel'

#Starting color variables
$pastel = Pastel.new
cyan  = $pastel.on_cyan(" ")
red   = $pastel.on_red(" ")


#Complete Scan
def complete_scan(line)

#Regex to get scan % progress
  $progress =  line.match(/About (.*)%/)

#SYN SCAN
    if ($progress != nil) and line.include? "SYN Stealth Scan Timing:" 
          $novo_status = $progress.to_a[1].to_i
          $synscan.current = $novo_status
    end

#SERVICE SCAN
    if ($progress != nil) and line.include? "Service scan Timing:" 
      $novo_status = $progress.to_a[1].to_i
      $synscan.current = 100
      $servicescan.current = $novo_status
    end

#NSE SCAN
    if ($progress != nil) and line.include? "NSE Timing:" and !line.match(/NSE Timing: About 0.00% done/)
      $novo_status = $progress.to_a[1].to_i
      $servicescan.current = 100
      $nsescan.current = $novo_status
    end

 #Print open ports with color
    if !line.match(/\d.\d\d%|undergoing|rDNS record|Starting Nmap|retransmission/) and !line.match(/open/)
      $bars.finish
      puts line.chomp
    end

 #Print all other results 
    if !line.match(/\d.\d\d%|undergoing|rDNS record|Starting Nmap|retransmission/) and line.include? "open"
      $bars.finish
      puts $pastel.green.bold(line.chomp)
    end

  #Zero to scan bars and initial msg
    if line.match(/Starting Nmap/) 
      puts $pastel.cyan "[!]Starting Nmap Scan\t[#{ARGV[1]}]"
      $synscan.current = 0
      $servicescan.current = 0
      $nsescan.current = 0
    end

end
#Simple Scan
def simple_scan(line)
#Regex to get scan % progress
  $progress =  line.match(/About (.*)%/)

#SYN SCAN
    if ($progress != nil) and line.include? "SYN Stealth Scan Timing:" 
          $novo_status = $progress.to_a[1].to_i
          $synscan.current = $novo_status
    end

#SERVICE SCAN
    if ($progress != nil) and line.include? "Service scan Timing:" 
      $novo_status = $progress.to_a[1].to_i
      $synscan.current = 100
      $servicescan.current = $novo_status
    end

#NSE SCAN
    if ($progress != nil) and line.include? "NSE Timing:" and !line.match(/NSE Timing: About 0.00% done/)
      $novo_status = $progress.to_a[1].to_i
      $servicescan.current = 100
      $nsescan.current = $novo_status
    end

 #Print all other results 
    if !line.match(/\d.\d\d%|undergoing|rDNS record|Starting Nmap|retransmission/) and !line.match(/open/)
      $bars.finish
      puts line.chomp
    end

 #Print open ports with color
    if !line.match(/\d.\d\d%|undergoing|rDNS record|Starting Nmap|retransmission/) and line.include? "open"
      $bars.finish
      puts $pastel.green.bold(line.chomp)
    end

  #Zero to scan bars and initial msg
    if line.match(/Starting Nmap/) 
      puts $pastel.cyan "[!]Starting Nmap Scan\t[#{ARGV[1]}]"
      $synscan.current = 0
      $servicescan.current = 0
      $nsescan.current = 0
    end


end

#ARGV tests if is complete scan
if  ARGV[0] == "-c" and  ARGV[1] != nil
$cmd = "nmap  -sS -A -p- -n -T4 -oN completescan#{ARGV[1]}.txt #{ARGV[1]}"
#Bars Setup
$bars = TTY::ProgressBar::Multi.new("Main  Progress [:bar] :percent, :elapsed",head:'>', width: 100)
$synscan = $bars.register("SYN Scan     [:bar] :percent", total: 100)
$servicescan = $bars.register("Service Scan [:bar] :percent", total: 100)
$nsescan = $bars.register("NSE Scan     [:bar] :percent", total: 100)
  PTY.spawn( $cmd ) do |stdout, stdin, pid|
    stdout.each do |line|
    stdin.puts '  '
    complete_scan(line)
#If match, END.
      if line.include? "Nmap done:"
      break
      end
    end
  end
end
#ARGV tests if is simple scan
if  ARGV[0] == "-s" and  ARGV[1] != nil
$cmd = "nmap  -sV -sC -n -oN simplescan#{ARGV[1]}.txt #{ARGV[1]}"
#Bars Setup
$bars = TTY::ProgressBar::Multi.new("Main  Progress [:bar] :percent, :elapsed",head:'>', width: 100)
$synscan = $bars.register("SYN Scan     [:bar] :percent", total: 100)
$servicescan = $bars.register("Service Scan [:bar] :percent", total: 100)
$nsescan = $bars.register("NSE Scan     [:bar] :percent", total: 100)
  PTY.spawn( $cmd ) do |stdout, stdin, pid|
    stdout.each do |line|
    stdin.puts '  '
    simple_scan(line)
#If match, END.
    if line.include? "Nmap done:"
    break
    end
   end
  end
end
#ARGV validation and help output
if ARGV[0] != "-s" && ARGV[0] != "-c" or ARGV[1] == nil
  puts $pastel.cyan " ruby nmapbar.rb -[switch] TARGET\n"
  puts $pastel.cyan"-s          It will run a well-balanced scan, suitable for most situations. "
  puts $pastel.cyan"            Nmap will run with theses flags enabled -sV -sC -n "
  puts $pastel.cyan"-c          It will run a complete scan, but much slower."
  puts $pastel.cyan"            Nmap will run with these flags enabled -sS -A -p- -n -T4 "
  puts $pastel.cyan"Example:"
  puts $pastel.green.bold"ruby nmapbar.rb -s 10.0.14.5"
end
