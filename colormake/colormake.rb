require 'benchmark'
require 'open3'

# Globals
$no_of_warnings = 0
$no_of_errors = 0
$no_of_items = 0
$initlines = 1

$maxerrors = 9

class String
def black;          "\e[30m#{self}\e[0m" end
def red;            "\e[31m#{self}\e[0m" end
def green;          "\e[32m#{self}\e[0m" end
def brown;          "\e[33m#{self}\e[0m" end
def blue;           "\e[34m#{self}\e[0m" end
def magenta;        "\e[35m#{self}\e[0m" end
def cyan;           "\e[36m#{self}\e[0m" end
def gray;           "\e[37m#{self}\e[0m" end

def bg_black;       "\e[40m#{self}\e[0m" end
def bg_red;         "\e[41m#{self}\e[0m" end
def bg_green;       "\e[42m#{self}\e[0m" end
def bg_brown;       "\e[43m#{self}\e[0m" end
def bg_blue;        "\e[44m#{self}\e[0m" end
def bg_magenta;     "\e[45m#{self}\e[0m" end
def bg_cyan;        "\e[46m#{self}\e[0m" end
def bg_gray;        "\e[47m#{self}\e[0m" end

def gray2;          "\e[30m#{self}\e[0m" end
def lred;           "\e[31m#{self}\e[0m" end
def lgreen;         "\e[32m#{self}\e[0m" end
def yellow;         "\e[33m#{self}\e[0m" end
def lblue;          "\e[34m#{self}\e[0m" end
def pink;           "\e[35m#{self}\e[0m" end
def lcyan;          "\e[36m#{self}\e[0m" end
def white;          "\e[37m#{self}\e[0m" end

def bold;           "\e[1m#{self}\e[22m" end
def italic;         "\e[3m#{self}\e[23m" end
def underline;      "\e[4m#{self}\e[24m" end
def blink;          "\e[5m#{self}\e[25m" end
def reverse_color;  "\e[7m#{self}\e[27m" end
end

default_cmd_line_compiler = "make"

puts (" " * 107).bg_magenta
puts (" " * 107).bg_magenta
puts (" " * 50 + "M A K E" + " " * 50).bg_magenta
puts (" " * 107).bg_magenta
puts (" " * 107).bg_magenta

#puts (" " * 107).magenta.swap
#puts (" " * 107).magenta.swap
#puts (" " * 50 + "M A K E" + " " * 50).magenta.swap
#puts (" " * 107).magenta.swap
#puts (" " * 107).magenta.swap

cmd_line = ""

# build command line based on command line input or just use the default
if( ARGV.size>0 )
	ARGV.each do|a|
	  cmd_line = cmd_line + a + " "
	end
	cmd_line = default_cmd_line_compiler + " " + cmd_line
else
	cmd_line = default_cmd_line_compiler
end

# show the command line to the user
puts
puts cmd_line.bold.magenta

time = Benchmark.realtime{
  Open3.popen2e(cmd_line) do |stdin, stdout, stderr, wait_thr|
    while str = stdout.gets do
      str.delete!("\n")

      if str.downcase.include? "in member function" 
        if $initlines != 0 
          puts
        end
        if ($no_of_errors > $maxerrors)
          print ".".bold.lblue
        elsif
          puts str.bold.lblue 
        end
        $initlines = 0
      elsif str.downcase.include? "in constructor" 
        if $initlines != 0
          puts
        end
        if ($no_of_errors > $maxerrors)
          print ".".bold.lblue
        elsif
          puts str.bold.lblue 
        end
        $initlines = 0
      elsif str.downcase.include? "in function" 
        if $initlines != 0
          puts
        end
        if ($no_of_errors > $maxerrors)
          print ".".bold.lblue
        elsif
          puts str.bold.lblue 
        end
        $initlines = 0
      elsif str.downcase.include? "warning:"
        if $initlines != 0
          puts
        end
        nstr = ""
        $header = 0
        str.split(':').each { |piece|
          token = piece
          nn = piece.scan(/\d+/)
          if $header == 0
			nstr += (token + "  ").bold.brown
			$header = 1
          elsif $header == 5
			nstr += (token + ":").brown
          elsif not nn.empty?
            if $header < 2
				nstr += ("[" + nn.join + "]").bold.white
			end
            $header += 1
          elsif (token.downcase.include? "warning")
            nstr += " "
            $header = 5
          elsif (token.empty?)
            nstr += " "
          else
            nstr += (token.to_s + ":").yellow
          end
        }
        if ($no_of_errors > $maxerrors)
          print ".".bold.brown
        elsif
          puts nstr
        end
        $no_of_warnings += 1
        $initlines = 0
      elsif (str.downcase.include? "error:") or (str.downcase.include? "undefined reference to")
        if $initlines != 0
          puts
        end
        nstr = ""
        $header = 0
        str.split(':').each { |piece|
          token = piece
          nn = piece.scan(/\d+/)
          if $header == 0
			nstr += (token + "  ").bold.red
			$header = 1
          elsif $header == 5
			nstr += (token + ":").red
          elsif not nn.empty?
            if $header < 2
				nstr += ("[" + nn.join + "]").bold.white
			end
            $header += 1
          elsif (token.downcase.include? "error")
            nstr += " "
            $header = 5
          elsif (token.empty?)
            nstr += " "
          else
            nstr += (token.to_s + ":").lred
          end
        }
        if ($no_of_errors > $maxerrors)
          print ".".bold.red
        elsif
          puts nstr
        end
        $no_of_errors += 1
        $initlines = 0
      elsif str.include? " Error "
        if $initlines != 0
          puts
        end
        puts str.bold.lred
        $no_of_errors += 1		
        $initlines = 5
      elsif str[0..2] == "gcc"
        print ".".bold.magenta
        $no_of_items += 1
        if $initlines == 0
           $initlines = 1
        end
      elsif str[0..2] == "g++"
        print ".".bold.magenta
        $no_of_items += 1		
        if $initlines == 0
           $initlines = 1
        end
      elsif str.include? "/moc "
        print ".".bold.magenta
        $no_of_items += 1		
        if $initlines == 0
           $initlines = 1
        end
      elsif $initlines == 1
        print ".".bold.magenta
      else
        if ($no_of_errors > $maxerrors)
          print ".".bold.lblue
        elsif
          puts str.bold.lblue 
        end
      end
      
    end
  end
}
  
  # show our statistics to the user
  puts
  puts " Build Statistics".bg_cyan + (" " * (" Compile time: #{time} seconds".length - " Build Statistics".length)).bg_cyan
  puts (" Items: " + $no_of_items.to_s + (" " * (" Compile time: #{time} seconds".length - " Items: ".length -  $no_of_items.to_s.length))).bg_cyan
  puts (" Warnings: " + $no_of_warnings.to_s + (" " * (" Compile time: #{time} seconds".length - " Warnings: ".length -  $no_of_warnings.to_s.length))).bg_cyan
  puts (" Errors: " + $no_of_errors.to_s + (" " * (" Compile time: #{time} seconds".length - " Errors: ".length -  $no_of_errors.to_s.length))).bg_cyan
  puts " Compile time: #{time} seconds".bg_cyan

if $no_of_errors > 0
	exit 1
else
	exit 0
end
