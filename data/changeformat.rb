#!/usr/bin/ruby

# program: changeformat.rb
# usage:   ruby cahngeformat.rb InputFilename > OutputFilename

# define a "location" class to represent the csv-columns
class Location <

  # a Location has a start_time, end_time, service, conn_direction, longitude and latitude
  Struct.new(:start_time, :end_time, :service, :conn_direction, :longitude, :latitude)

  # a method to print out a csv record for the current Location.
  # note that you can easily re-arrange columns here, if desired.
  # also note that this method compensates for blank fields.
  def print_csv_record
	unless longitude.length==0 or latitude.length==0 or end_time.length==0
		#start_time.length==0 ? printf(";") : printf("%s;", start_time)
		end_time.length==0 ? printf(";") : printf("%s;", end_time)
		service.length==0 ? printf(";") : printf("%s;", service)
		#conn_direction.length==0 ? printf(";") : printf("%s;", conn_direction)
		latitude.length==0 ? printf(";") : printf("%s;", latitude)
		longitude.length==0 ? printf("") : printf("%s", longitude)
		printf("\n")
	end
end

#------#
# MAIN #
#------#

# bail out unless we get the right number of command line arguments
unless ARGV.length == 2
  puts "Wrong length of arguments."
  puts "Usage: ruby changeformat.rb daten.csv > out.csv\n"
  exit
end

# get the input and output filename from the command line
input_file = ARGV[0]

output_file = ARGV[1]

# define an array to hold the Location records
arr = Array.new


# # this is how a csv entry looks like 
# # 8/31/09 7:57;8/31/09 8:09;"GPRS";"ausgehend";"13.39611111";52,52944444

# loop through each record in the csv file, adding
# each record to our array.
f = File.open(input_file, "r")
f.each_line { |line|
  words = line.split(';')
  p = Location.new
  # do a little work here to get rid of double-quotes and blanks / at latitude change , to .
  p.start_time = words[0].tr_s('"', '').strip
  p.end_time = words[1].tr_s('"', '').strip
  p.service = words[2].tr_s('"', '').strip
  p.conn_direction = words[3].tr_s('"', '').strip
  p.longitude = words[4].tr_s('"', '').strip
  p.latitude = words[5].tr_s(',', '.').strip
  arr.push(p)
}

# sort the data by the last_name field
# arr.sort! { |a,b| a.last_name.downcase <=> b.last_name.downcase }

# print out all the sorted records to a file
file = File.new(output_file, "w")
  # 
  arr.each { |p|
   #p.print_csv_record [2,8]
   	unless p.longitude.length==0 or not p.longitude.to_f.between?(13.100000, 13.800000) or p.latitude.length==0 or not p.latitude.to_f.between?(52.370000, 52.6600) or p.end_time.length==0
		#p.start_time.length==0 ? file.print(";") : file.print(p.start_time + ";")
		file.print p.end_time
		file.print ";"
		p.service.length==0 ? file.print(";") : file.print(p.service + ";")
		#p.conn_direction.length==0 ? file.print(";") : file.print(p.conn_direction + ";")
		file.print p.latitude
		file.print ";"
		file.print p.longitude
		file.print "\n"
	end
  }
end
  
 