#require "rubygems"
#require "opengl"
#require "glut"
#
#
# Author: Chris Lundquist <ChrisMLundquist@gmail.com>
#
# Description: 
# This class loads bitmap files facilitating their use
# with OpenGL
class Bitmap
attr_accessor :width,:height,:color_depth,:data
    def initialize(file)
        case file
        when String
           parse_bitmap(file) 
        when File
        else
            raise "Unable to create bitmap from #{file.class}"
        end
    end

private
def parse_bitmap(file_name)
  f = File.open(file_name,"rb")

  # Read the file
  data = f.read
  f.close

  # For Formality
  header = data[0..53]
  data = data[54..-1]

  # Get each attribute as an unsigned int
  @width = header[18..21].unpack("I").first
  @height = header[22..25].unpack("I").first
  @color_depth = header[28..31].unpack("I").first
  raise "Unsupported Bit Depth" unless color_depth == 24

  # Since the image was stored upside down we need to flip it. 
  # But if we flip it we have to resort it from BGR -> RGB
  #data = data.reverse

  # Turn the string into an array
  data = data.unpack("C*")

  i = 0

  while i + 2 < data.length
    # This rotates BGR -> RBG which makes it 'correct'
    data[i], data[i + 2] = data[i + 2], data[i]
    i += 3
  end

  # Turn it back into a string for memory effeciency
  @data = data.pack("C*")
end

end

