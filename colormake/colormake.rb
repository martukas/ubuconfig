require 'benchmark'
require 'open3'

#presets
default_cmd_line_compiler = "make"
$compilers = ["gcc ", "g++ ", "clang++ ", "/moc ", "/uic "]
$error_aux_phrases = ["in member function", "in constructor", "in function", "in file included"]
$maxerrors = 9


# Globals
$no_of_warnings = 0
$no_of_errors = 0
$no_of_items = 0
$initlines = 1

def time_dif_fancy(total_seconds)
  seconds = total_seconds % 60
  minutes = (total_seconds / 60) % 60
  hours = total_seconds / (60 * 60)

  format("%02d:%02d:%02d", hours, minutes, seconds) #=> "01:00:00"
end

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

def colorcode(str, type)
  if type.include? "error"
    str.lred
  elsif type.include? "warning"
    str.yellow
  elsif type.include? "aux"
    str.lblue
  elsif
    str.pink
  end
end

def colorcode2(str, type)
  if type.include? "error"
    str.red
  elsif type.include? "warning"
    str.brown
  elsif type.include? "aux"
    str.blue
  elsif
    str.magenta
  end
end

def is_compiler_line(str)
  $compilers.any? { |cmp| str.include? cmp }
end

def is_error_aux_line(str)
  $error_aux_phrases.any? { |cmp| str.include? cmp }
end


def print_err_aux(str)
  if $initlines != 0 
    puts
  end
  if ($no_of_errors > $maxerrors)
    print colorcode(".".bold, "aux")
  elsif
    puts colorcode(str.bold, "aux") 
  end
    $initlines = 0
end

def print_boring(str)
  nn = str.scan(/(\S+[.]cpp|\S+[.]cc|\S+[.]ui)/)
  nl = str.scan(/-o (\S+)/)
  if not nn.empty?
    print (nn.join).green + "   ";
  elsif (not nl.empty?) && is_compiler_line(str) && (not nl.join.include? ".o")
    puts ("\nLINKING " + nl.join).bold.green;
  else
    print colorcode2(".".bold, "")
  end
end

def nothing_exciting(str)
  print_boring(str)
  $no_of_items += 1
  if $initlines == 0
    $initlines = 1
  end
end

def format_substantial(str, type)
  nstr = ""
  header = 0
  str.split(':').each { |piece|
    token = piece
    nn = piece.scan(/\d+/)
    if header == 0
      nstr += colorcode2((token + "  ").bold, type)
      header = 1
    elsif header == 5
      nstr += colorcode2((token + ":"), type)
    elsif not nn.empty?
      if header < 2
        nstr += ("[" + nn.join + "]").bold.white
      end
      header += 1
    elsif (token.downcase.include? type)
      nstr += " "
      header = 5
    elsif (token.empty?)
      nstr += " "
    else
      nstr += colorcode(token.to_s + ":", type)
    end
  }
  nstr
end

def substantial(str, type)
  if $initlines != 0
    puts
  end
  if ($no_of_errors > $maxerrors)
    print colorcode2(".".bold, type)
  elsif
    puts format_substantial(str, type)
  end
  $initlines = 0
end





# build command line based on command line input or just use the default
cmd_line = ""
if( ARGV.size>0 )
  ARGV.each do|a|
    cmd_line = cmd_line + a + " "
  end
  cmd_line = default_cmd_line_compiler + " " + cmd_line
else
  cmd_line = default_cmd_line_compiler
end

# show the command line to the user
scols = %x( tput cols )
cols = scols.scan(/\d+/).first.to_i
if (cols < 1)
  cols = 80
end
cmd_spaced = cmd_line.gsub(/(.)/, '\1 ').upcase
half = (cols - cmd_spaced.length) / 2;
#puts (" " * cols).bg_magenta
puts (" " * cols).bg_magenta
puts (" " * half + cmd_spaced + " " * half).bg_magenta
puts (" " * cols).bg_magenta
#puts (" " * cols).bg_magenta

time_start = Time.now
Open3.popen2e(cmd_line) do |stdin, stdout, stderr, wait_thr|
    while str = stdout.gets do
      str.delete!("\n")

      if is_error_aux_line(str.downcase)
        print_err_aux(str)
      elsif str.downcase.include? "warning:"
        substantial(str, "warning")
        $no_of_warnings += 1
      elsif (str.downcase.include? "error:") or (str.downcase.include? "undefined reference to")
        substantial(str, "error")
        $no_of_errors += 1
      elsif str.include? " Error "
        if $initlines != 0
          puts
        end
        puts str.bold.lred
        $no_of_errors += 1		
        $initlines = 5
      elsif is_compiler_line(str)
        nothing_exciting(str)
      elsif $initlines == 1
        print_boring(str)
      else
        if ($no_of_errors > $maxerrors)
          print colorcode(".".bold, "aux")
        elsif
          puts colorcode(str.bold, "aux") 
        end
      end
      
    end
end
tdif = Time.now - time_start

summary_text  = "   Items: " + $no_of_items.to_s

if ($no_of_errors > 0)
  summary_text += "   Errors: " + $no_of_errors.to_s
end

if ($no_of_warnings > 0)
  summary_text += "   Warnings: " + $no_of_warnings.to_s
end

time_text = "Compile time: " + time_dif_fancy(tdif) + "   "

summarylen = summary_text.length + time_text.length
summary_text += " " * (cols - summarylen) + time_text

if ($no_of_errors > 0)
  summary_text = summary_text.bg_red
elsif ($no_of_warnings > 0)
  summary_text = summary_text.bg_brown
else
  summary_text = summary_text.bg_green
end

puts summary_text

if $no_of_errors > 0
  exit 1
else
  exit 0
end
