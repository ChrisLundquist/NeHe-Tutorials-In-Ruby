#!/usr/bin/ruby
# This code was created by Jeff Molofee '99 
# Conversion to Ruby by Chris Lundquist (ChrisMLundquist@gmail.com)
require "rubygems"
require "opengl"
require "glut"
require "../bitmap"


$xrot = 0.0                               # X Rotation 
$yrot = 0.0                               # Y Rotation 
$zrot = 0.0                               # Z Rotation 
$light = true
$fp = nil

$texture = Array.new(3)                # Storage For Three Textures

$LightAmbient = [ 0.5, 0.5, 0.5, 1.0 ]
$LightDiffuse = [ 1.0, 1.0, 1.0, 1.0 ]
$LightPosition = [ 0.0, 0.0, 2.0, 1.0 ]

$filter	 = 0 # Which Filter To Use


# A general OpenGL initialization function.  Sets all of the initial parameters

def InitGL(width, height) # We call this right after our OpenGL window 
  return false unless load_gl_textures()        # If Texture Didn't Load Return FALSE 
	glEnable(GL_TEXTURE_2D)							# Enable Texture Mapping
	glShadeModel(GL_SMOOTH)							# Enable Smooth Shading
	glClearColor(0.0, 0.0, 0.0, 0.5)				# Black Background
	glClearDepth(1.0)									# Depth Buer Setup
	glEnable(GL_DEPTH_TEST)							# Enables Depth Testing
	glDepthFunc(GL_LEQUAL)								# The Type Of Depth Testing To Do
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)	# Really Nice Perspective Calculations

	glLightfv(GL_LIGHT1, GL_AMBIENT, $LightAmbient)		# Setup The Ambient Light
	glLightfv(GL_LIGHT1, GL_DIFFUSE, $LightDiffuse)		# Setup The Diffuse Light
	glLightfv(GL_LIGHT1, GL_POSITION,$LightPosition)	# Position The Light
	glEnable(GL_LIGHT1)								# Enable Light One
	return true                                     # Initialization Went OK
end

def load_gl_textures

        bitmap = Bitmap.new("Data/Crate.bmp")
        $texture = glGenTextures(3) # Create 3 Texture
        # Create Nearest Filtered Texture
        glBindTexture(GL_TEXTURE_2D, $texture[0])
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST)
        glTexImage2D(GL_TEXTURE_2D, 0, 3, bitmap.size_x, bitmap.size_y, 0, GL_RGB, GL_UNSIGNED_BYTE, bitmap.data)

        # Create Linear Filtered Texture
        glBindTexture(GL_TEXTURE_2D, $texture[1])
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)
        glTexImage2D(GL_TEXTURE_2D, 0, 3, bitmap.size_x, bitmap.size_y, 0, GL_RGB, GL_UNSIGNED_BYTE, bitmap.data)

        # Create MipMapped Texture
        glBindTexture(GL_TEXTURE_2D, $texture[2])
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST)
        gluBuild2DMipmaps(GL_TEXTURE_2D, 3, bitmap.size_x, bitmap.size_y, GL_RGB, GL_UNSIGNED_BYTE, bitmap.data)
end

# The function called when our window is resized (which shouldn't happen, 
# because we're fullscreen) 
resize_gl_scene = Proc.new {|width, height|
 # Prevent A Divide By Zero If The Window Is Too Small
   height = 1 if height == 0
  
  GL.Viewport(0,0,width,height) # Reset The Current Viewport And
                                # Perspective Transformation
  GL.MatrixMode(GL::PROJECTION)
  GL.LoadIdentity()
  GLU.Perspective(45.0,Float(width)/Float(height),0.1,100.0)
  GL.MatrixMode(GL::MODELVIEW)
  GL.LoadIdentity()
}

# The main drawing function. 
draw_gl_scene = Proc.new {
  GL.Clear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # Clear Screen And Depth Buffer
  GL.LoadIdentity()                                   # Reset The Current Matrix
  GL.Translatef( 0.0, 0.0, -5.0)                      # Move Into The Screen 5 Units

  GL.Rotatef($xrot, 1.0, 0.0, 0.0)                        # Rotate On The X Axis
  GL.Rotatef($yrot, 0.0, 1.0, 0.0)                        # Rotate On The Y Axis
  GL.Rotatef($zrot, 0.0, 0.0, 1.0)                        # Rotate On The Z Axis

  GL.BindTexture(GL_TEXTURE_2D, $texture[$filter])        # Select Our Texture

  GL.Begin(GL_QUADS);
    # Front Face
	glNormal3f( 0.0, 0.0, 1.0)
    GL.TexCoord2f(0.0, 0.0); GL.Vertex3f(-1.0, -1.0,  1.0) # Bottom Left Of The Texture and Quad
    GL.TexCoord2f(1.0, 0.0); GL.Vertex3f( 1.0, -1.0,  1.0) # Bottom Right Of The Texture and Quad
    GL.TexCoord2f(1.0, 1.0); GL.Vertex3f( 1.0,  1.0,  1.0) # Top Right Of The Texture and Quad
    GL.TexCoord2f(0.0, 1.0); GL.Vertex3f(-1.0,  1.0,  1.0) # Top Left Of The Texture and Quad
    # Back Face
	glNormal3f( 0.0, 0.0, -1.0)
    GL.TexCoord2f(1.0, 0.0); GL.Vertex3f(-1.0, -1.0, -1.0) # Bottom Right Of The Texture and Quad
    GL.TexCoord2f(1.0, 1.0); GL.Vertex3f(-1.0,  1.0, -1.0) # Top Right Of The Texture and Quad
    GL.TexCoord2f(0.0, 1.0); GL.Vertex3f( 1.0,  1.0, -1.0) # Top Left Of The Texture and Quad
    GL.TexCoord2f(0.0, 0.0); GL.Vertex3f( 1.0, -1.0, -1.0) # Bottom Left Of The Texture and Quad
    # Top Face
	glNormal3f( 0.0, 1.0, 0.0)
    GL.TexCoord2f(0.0, 1.0); GL.Vertex3f(-1.0,  1.0, -1.0) # Top Left Of The Texture and Quad
    GL.TexCoord2f(0.0, 0.0); GL.Vertex3f(-1.0,  1.0,  1.0) # Bottom Left Of The Texture and Quad
    GL.TexCoord2f(1.0, 0.0); GL.Vertex3f( 1.0,  1.0,  1.0) # Bottom Right Of The Texture and Quad
    GL.TexCoord2f(1.0, 1.0); GL.Vertex3f( 1.0,  1.0, -1.0) # Top Right Of The Texture and Quad
    # Bottom Face
	glNormal3f( 0.0, -1.0, 0.0)
    GL.TexCoord2f(1.0, 1.0); GL.Vertex3f(-1.0, -1.0, -1.0) # Top Right Of The Texture and Quad
    GL.TexCoord2f(0.0, 1.0); GL.Vertex3f( 1.0, -1.0, -1.0) # Top Left Of The Texture and Quad
    GL.TexCoord2f(0.0, 0.0); GL.Vertex3f( 1.0, -1.0,  1.0) # Bottom Left Of The Texture and Quad
    GL.TexCoord2f(1.0, 0.0); GL.Vertex3f(-1.0, -1.0,  1.0) # Bottom Right Of The Texture and Quad
    # Right face
	glNormal3f( 1.0, 0.0, 0.0)
    GL.TexCoord2f(1.0, 0.0); GL.Vertex3f( 1.0, -1.0, -1.0) # Bottom Right Of The Texture and Quad
    GL.TexCoord2f(1.0, 1.0); GL.Vertex3f( 1.0,  1.0, -1.0) # Top Right Of The Texture and Quad
    GL.TexCoord2f(0.0, 1.0); GL.Vertex3f( 1.0,  1.0,  1.0) # Top Left Of The Texture and Quad
    GL.TexCoord2f(0.0, 0.0); GL.Vertex3f( 1.0, -1.0,  1.0) # Bottom Left Of The Texture and Quad
    # Left Face
	glNormal3f( -1.0, 0.0, 0.0)
    GL.TexCoord2f(0.0, 0.0); GL.Vertex3f(-1.0, -1.0, -1.0) # Bottom Left Of The Texture and Quad
    GL.TexCoord2f(1.0, 0.0); GL.Vertex3f(-1.0, -1.0,  1.0) # Bottom Right Of The Texture and Quad
    GL.TexCoord2f(1.0, 1.0); GL.Vertex3f(-1.0,  1.0,  1.0) # Top Right Of The Texture and Quad
    GL.TexCoord2f(0.0, 1.0); GL.Vertex3f(-1.0,  1.0, -1.0) # Top Left Of The Texture and Quad
  GL.End()

  # We need to swap the buffer to display our drawing.
  GLUT.SwapBuffers()
  $xrot += 0.03                            # X Axis Rotation
  $yrot += 0.02                            # Y Axis Rotation
  $zrot += 0.04                            # Z Axis Rotation
}



# The function called whenever a key is pressed.
key_pressed = Proc.new {|key, x, y| 

  case key
  when 27
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
    when 'F'.sum,'f'.sum
        # Increment the filter we are using
        $filter += 1
        # Keep te filter in the domain of texture length
        $filter = $filter % $texture.length
  else
    # Do Nothing
  end
}

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
GLUT.DisplayFunc(draw_gl_scene)

# Go fullscreen. This is as soon as possible.
GLUT.FullScreen()

# Even if there are no events, redraw our gl scene.
GLUT.IdleFunc(draw_gl_scene)

# Register the function called when our window is resized.
GLUT.ReshapeFunc(resize_gl_scene)

# Register the function called when the keyboard is pressed.
GLUT.KeyboardFunc(key_pressed)

# Initialize our window.
InitGL(640, 480)

# Start Event Processing Engine
GLUT.MainLoop()
