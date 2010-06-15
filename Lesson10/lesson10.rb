#!/usr/bin/ruby
require 'rubygems'
require 'opengl'
require '../bitmap'

$blend = nil             # Blending ON/OFF

PIOVER180 = 0.0174532925
$heading = nil
$xpos = 0.0
$zpos = 0.0

$yrot = 0.0              # Y Rotation

$walkbias = 0;
$walkbiasangle = 0
$lookupdown = 0.0
$z = 0.0               # Depth Into The Screen
$filter = 0                # Which Filter To Use
$textures = nil            # Storage For 3 Textures

class Vertex
    attr_accessor :x, :y, :z, :u, :v

    def initialize(*params)
        @x, @y, @z, @u, @v = params
        [@x, @y, @z, @u, @v].each do |var|
            raise "value not coercable to float" unless var.respond_to?(:to_f) or var.respond_to(:to_float)
        end
    end
end

class Triangle
    attr_accessor :vertex

    def initialize(*params)
        @vertex = params.flatten
        # Make sure our Triangle is made of 3 Vertexes
        raise "Malformed Triangle #{@vertex.inspect}" unless @vertex.map(&:class) == [Vertex, Vertex, Vertex]
    end
end

$sector = Array.new  # Our Model Goes Here:

def SetupWorld
    vertexes = Array.new # buffer for incomplete triangles

    file = File.open("Data/World.txt");               # File To Load World Data From

    file.each do |line|
        next if line.start_with?("//","\n","NUMPOLLIES")  # Reject the lines that don't contain point data

        # Parse our line from text into floats and assign them
        x, y, z, u, v = line.split.map(&:to_f)
        # Append this Vertex to our container
        vertexes.push(Vertex.new(x,y,z,u,v))

        # If we have three vertexes we can make a Triangle
        if vertexes.length == 3
            # Add our Triangle to this sector
            $sector.push(Triangle.new(vertexes))

            # Reset our buffer for the next Triangle
            vertexes.clear
        end
    end
    # Remember to close our File
    file.close
    true
end

def init_gl(width, height) # We call this right after our OpenGL window 
    load_gl_textures() or raise("Unable to load textures")   # If Texture Didn't Load Return FALSE 
    glEnable(GL_TEXTURE_2D)                         # Enable Texture Mapping
    glShadeModel(GL_SMOOTH)                         # Enable Smooth Shading
    glClearColor(0.0, 0.0, 0.0, 0.5)                # Black Background
    glClearDepth(1.0)                                   # Depth Buer Setup
    glEnable(GL_DEPTH_TEST)                         # Enables Depth Testing
    glDepthFunc(GL_LEQUAL)                              # The Type Of Depth Testing To Do
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)   # Really Nice Perspective Calculations

    glColor4f(1.0, 1.0, 1.0, 0.5)                   # Full Brightness 50% alpha
    glBlendFunc(GL_SRC_ALPHA,GL_ONE)

    glEnable(GL_BLEND)

    50.times do 
        star = Star.new
        star.angle = 0.0
        star.dist = rand(50) * 5.0
        star.r = rand(255)
        star.g = rand(255)
        star.b = rand(255)

        $stars.push(star)
    end
end

def load_gl_textures
    bitmap = Bitmap.new("Data/Mud.bmp")
    $textures = glGenTextures(3) # Create 3 Texture

    GL.BindTexture(GL_TEXTURE_2D, $textures[0])
    GL.TexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
    GL.TexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST)
    GL.TexImage2D(GL_TEXTURE_2D, 0, 3, bitmap.size_x, bitmap.size_y, 0, GL_RGB, GL_UNSIGNED_BYTE, bitmap.data)

    # Create Linear Filtered Texture
    GL.BindTexture(GL_TEXTURE_2D, $textures[1])
    GL.TexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
    GL.TexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)
    GL.TexImage2D(GL_TEXTURE_2D, 0, 3, bitmap.size_x, bitmap.size_y, 0, GL_RGB, GL_UNSIGNED_BYTE, bitmap.data)

    GL.BindTexture(GL_TEXTURE_2D, $textures[2])
    GL.TexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
    GL.TexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST)
    GL.TexImage2D(GL_TEXTURE_2D, 0, 3, bitmap.size_x, bitmap.size_y, 0, GL_RGB, GL_UNSIGNED_BYTE, bitmap.data)

    true
end

# because we're fullscreen) 
def resize_gl_scene(width, height)
    # Prevent A Divide By Zero If The Window Is Too Small
    height = 1 if height == 0

    GL.Viewport(0,0,width,height) # Reset The Current Viewport And
    # Perspective Transformation
    GL.MatrixMode(GL::PROJECTION)
    GL.LoadIdentity()
    GLU.Perspective(45.0,Float(width)/Float(height),0.1,100.0)
    GL.MatrixMode(GL::MODELVIEW)
    GL.LoadIdentity()
end

def InitGL(width,height)
    return false  unless load_gl_textures # Jump To Texture Loading Routine


    glEnable(GL_TEXTURE_2D)                            # Enable Texture Mapping
    glBlendFunc(GL_SRC_ALPHA,GL_ONE)                   # Set The Blending Function For Translucency
    glClearColor(0.0, 0.0, 0.0, 0.0)                   # This Will Clear The Background Color To Black
    glClearDepth(1.0)                                  # Enables Clearing Of The Depth Buffer
    glDepthFunc(GL_LESS)                               # The Type Of Depth Test To Do
    glEnable(GL_DEPTH_TEST)                            # Enables Depth Testing
    glShadeModel(GL_SMOOTH)                            # Enables Smooth Color Shading
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)  # Really Nice Perspective Calculations

    SetupWorld()

    return true                                       # Initialization Went OK
end

def key_pressed(key, x, y)
    case key
    when "\e",27 # Escape key depending on ruby version
        # If escape is pressed, kill everything and shut down our window.
        GLUT.DestroyWindow($window)
        # exit the program...normal termination.
        exit(0)
    when 'L'.sum,'l'.sum
        # Toggle the flag
        $light = !$light

        # Do what they wanted
        if $light
            glEnable(GL_LIGHTING)
        else
            glDisable(GL_LIGHTING)
        end
    when 'B'.sum,'b'.sum
        $blend = !$blend
        if $blend
            glEnable(GL_BLEND)
            glDisable(GL_DEPTH_TEST)
        else
            glDisable(GL_BLEND)
            glEnable(GL_DEPTH_TEST)
        end
    when 'F'.sum,'f'.sum
        # Increment the filter we are using
        $filter += 1
        # Keep te filter in the domain of texture length
        $filter = $filter % $texture.length
    else
        # Do Nothing
    end
end


def draw_gl_scene # Here's Where We Do All The Drawing
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # Clear The Screen And The Depth Buffer
    glLoadIdentity()                                   # Reset The View

    xtrans = -$xpos
    ztrans = -$zpos
    ytrans = -$walkbias-0.25
    sceneroty = 360.0 - $yrot

    glRotatef($lookupdown,1.0,0,0)
    glRotatef($sceneroty,0,1.0,0)

    glTranslatef(xtrans, ytrans, ztrans)
    glBindTexture(GL_TEXTURE_2D, $textures[$filter])

    glBegin(GL_TRIANGLES)
    glNormal3f( 0.0, 0.0, 1.0)
    # Process Each Triangle
    $sector.each do |triangle|
        triangle.vertex.each do |vertex|
            glTexCoord2f(vertex.u, vertex.v)
            glVertex3f(vertex.x, vertex.y, vertex.z)
        end
    end
    glEnd()
    return true                                        # Everything Went OK
end
#Initialize GLUT state - glut will take any command line arguments that pertain
# to it or X Windows - look at its documentation at
# http://reality.sgi.com/mjk/spec3/spec3.html
GLUT.Init

#Select type of Display mode:
# Double buffer 
# RGBA color
# Alpha components supported 
# Depth buffer
GLUT.InitDisplayMode(GLUT::RGBA|GLUT::DOUBLE|GLUT::ALPHA|GLUT::DEPTH)

# get a 640x480 window
GLUT.InitWindowSize(640,480)

# the window starts at the upper left corner of the screen
GLUT.InitWindowPosition(0,0)

# Open a window
$window = GLUT.CreateWindow("Jeff Molofee's GL Code Tutorial ... NeHe '99")

# Register the function to do all our OpenGL drawing.
GLUT.DisplayFunc(lambda{draw_gl_scene})

# Go fullscreen. This is as soon as possible.
GLUT.FullScreen()

# Even if there are no events, redraw our gl scene.
GLUT.IdleFunc(lambda{draw_gl_scene})

# Register the function called when our window is resized.
GLUT.ReshapeFunc(lambda{ |x,y|resize_gl_scene(x,y)})

# Register the function called when the keyboard is pressed.
GLUT.KeyboardFunc(lambda{ |key,x,y| key_pressed(key,x,y)})

# Initialize our window.
InitGL(640, 480)

# Start Event Processing Engine
GLUT.MainLoop()

