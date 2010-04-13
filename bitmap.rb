#
# Author: Chris Lundquist <ChrisMLundquist@gmail.com>
#
# Description: 
# This class loads bitmap files facilitating their use
# with OpenGL
class Bitmap
attr_accessor :width,:height,:color_depth,:data,:header
alias size_x width
alias size_y height
    def initialize(file)
        case file
        when String
           open_file(file) 
        when File
        else
            raise "Unable to create bitmap from #{file.class}"
        end
        parse_header()
        parse_bitmap()
    end

private
    def open_file(file_path)
        f = File.open(file_path,"rb")

    # Read the file
        @data = f.read
        f.close
    end

    def parse_header
        # Get each attribute as an unsigned int
        @data_start = @data[0x0A..0x0D].unpack("I").first
        @header_size = @data[0x0E..0x11].unpack("I").first
        @width = @data[0x12..0x15].unpack("I").first
        @height = @data[0x16..0x19].unpack("I").first
        @color_depth = @data[0x1C..0x1D].unpack("S").first
        @image_size = @data[0x22..0x25].unpack("I").first


        # For Formality
        @header = @data[0..@header_size]
        @data = @data[@data_start..-1]
    end

    def parse_bitmap
        case @color_depth 
        when 24
            load_24bit
        when 8
            load_8bit
        else
            raise "Unsupported Bit Depth of: #{@color_depth}" 
        end
    end

    def load_24bit
        # Turn the string into an array
        @data = @data.unpack("C*")

        i = 0
        while i + 2 < @data.length
        # This rotates BGR -> RGB which makes it 'correct'
            @data[i], @data[i + 2] = @data[i + 2], @data[i]
            i += 3
        end

        # Turn it back into a string for memory effeciency
        @data = @data.pack("C*")
    end

    def load_8bit
       @data = @data.unpack("C*")
    
       # R 0123 4567 & 0xE0 = 012x xxxx
       # G 0123 4567 & 0x18 = xxx3 4xxx
       # B 0123 4567 & 0x07 = xxxx x567
       @data.map! do |i|
           [r = i & 0xE0, g = i & 0x18, b = i & 0x07]
       end.flatten!
    
       # Turn it back into a string for memory effeciency
       @data = @data.pack("C*")
    end


end

