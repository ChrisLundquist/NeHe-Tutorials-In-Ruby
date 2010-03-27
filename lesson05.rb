#!/usr/bin/ruby
# This code was created by Jeff Molofee '99 
# Conversion to Ruby by Manolo Padron Martinez (manolopm@cip.es)
# Bug Fixes by Chris Lundquist (chrismlundquist@gmail.com)
require "rubygems"
require "opengl"
require "glut"


# Rotation angle for the triangle.
$rtri=0.0

#Rotation angle for the quadrilateral.
$rquad=0.0

# A general OpenGL initialization function.  Sets all of the initial parameters

def InitGL(width, height) # We call this right after our OpenGL window 
                          # is created.

  GL.ClearColor(0.0, 0.0, 0.0, 0.0) # This Will Clear The Background 
                                    # Color To Black
  GL.ClearDepth(1.0)                # Enables Clearing Of The Depth Buffer
  GL.DepthFunc(GL::LESS)            # The Type Of Depth Test To Do
  GL.Enable(GL::DEPTH_TEST)         # Enables Depth Testing
  GL.ShadeModel(GL::SMOOTH)         # Enables Smooth Color Shading
  GL.MatrixMode(GL::PROJECTION)
  GL.LoadIdentity()                 # Reset The Projection Matrix
  GLU.Perspective(45.0,Float(width)/Float(height),0.1,100.0) # Calculate The Aspect Ratio 
                                               # Of The Window
  GL.MatrixMode(GL::MODELVIEW)
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
}

# The main drawing function. 
draw_gl_scene = Proc.new {
  GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT) # Clear The Screen And
                                          # The Depth Buffer
  GL.LoadIdentity()                       # Reset The View
  GL.Translate(-1.5, 0.0, -6.0)           # Move Left 1.5 Units And Into The 
                                          # Screen 6.0
  GL.Rotate($rtri,0.0,1.0,0.0)            # Rotate the triangle on the Y Axis

  # draw a triangle (in smooth coloring mode)
  GL.Begin(GL::POLYGON)                   # start drawing a polygon
    # front face of pyramid
    GL.Color3f(  1.0, 0.0, 0.0)           # Set The Color To Red
    GL.Vertex3f( 0.0, 1.0, 0.0)           # Top
    GL.Color3f(  0.0, 1.0, 0.0)           # Set The Color To Green
    GL.Vertex3f( -1.0,-1.0, 1.0)          # Bottom Right
    GL.Color3f(  0.0, 0.0, 1.0)           # Set The Color To Blue
    GL.Vertex3f(1.0,-1.0, 1.0)            # Bottom Left  

    # right face of pyramid
    GL.Color3f(  1.0, 0.0, 0.0)           # Red
    GL.Vertex3f( 0.0, 1.0, 0.0)           # Top of triangle (Right)
    GL.Color3f(  0.0, 0.0, 1.0)           # Blue
    GL.Vertex3f( 1.0,-1.0, 1.0)           # Left of triangle (Right)
    GL.Color3f(  0.0, 1.0, 0.0)           # Green
    GL.Vertex3f( 1.0,-1.0,-1.0)           # Right of triangle (Right)

    # back face of pyramid
    GL.Color3f(  1.0, 0.0, 0.0)           # Red
    GL.Vertex3f( 0.0, 1.0, 0.0)           # Top of triangle (Back)
    GL.Color3f(  0.0, 1.0, 0.0)           # Green
    GL.Vertex3f( 1.0,-1.0,-1.0)           # Left of triangle (Back)
    GL.Color3f(  0.0, 0.0, 1.0)           # Blue
    GL.Vertex3f(-1.0,-1.0,-1.0)           # Right of triangle (Back

    # left face of pyramid
    GL.Color3f(  1.0, 0.0, 0.0)           # Red
    GL.Vertex3f( 0.0, 1.0, 0.0)           # Top of triangle (Left)
    GL.Color3f(  0.0, 0.0, 1.0)           # Blue
    GL.Vertex3f(-1.0,-1.0,-1.0)           # Left of triangle (Left)
    GL.Color3f(  0.0, 1.0, 0.0)           # Green
    GL.Vertex3f(-1.0,-1.0, 1.0)           # Right of triangle (Left)
  GL.End()                                # Done drawing the pyramid

  GL.LoadIdentity()                       # make sure we're no longer rotated.
  GL.Translate(1.5,0.0,-7.0)              # Move Right 3 Units, and back into 
                                          # the screen 7.0
  GL.Rotate($rquad,1.0,1.0,1.0)           # Rotate the quad on the X Axis
  # Draw a cube (6 quadrilateral)
  GL.Begin(GL::QUADS)                     # start drawing the cube

  # Top of cube
  GL.Color3f(0.0,1.0,0.0)                 # Set The Color To Blue
  GL.Vertex3f( 1.0, 1.0,-1.0)             # Top Right Of The Quad (Top)
  GL.Vertex3f(-1.0, 1.0,-1.0)             # Top Left Of The Quad (Top)
  GL.Vertex3f(-1.0, 1.0, 1.0)             # Bottom Left Of The Quad (Top)
  GL.Vertex3f( 1.0, 1.0, 1.0)             # Bottom Right Of The Quad (Top)

  # Bottom of cube
  GL.Color3f(1.0,0.5,0.0)                 # Set The Color To Orange
  GL.Vertex3f( 1.0,-1.0, 1.0)             # Top Right Of The Quad (Bottom)
  GL.Vertex3f(-1.0,-1.0, 1.0)             # Top Left Of The Quad (Bottom)
  GL.Vertex3f(-1.0,-1.0,-1.0)             # Bottom Left Of The Quad (Bottom)
  GL.Vertex3f( 1.0,-1.0,-1.0)             # Bottom Right Of The Quad (Bottom)

  # Front of cube
  GL.Color3f(1.0,0.0,0.0)                 # Set The Color To Red
  GL.Vertex3f( 1.0, 1.0, 1.0)             # Top Right Of The Quad (Front)
  GL.Vertex3f(-1.0, 1.0, 1.0)             # Top Left Of The Quad (Front)
  GL.Vertex3f(-1.0,-1.0, 1.0)             # Bottom Left Of The Quad (Front)
  GL.Vertex3f( 1.0,-1.0, 1.0)             # Bottom Right Of The Quad (Front)

  # Back of cube.
  GL.Color3f(1.0,1.0,0.0)                 # Set The Color To Yellow
  GL.Vertex3f( 1.0,-1.0,-1.0)             # Top Right Of The Quad (Back)
  GL.Vertex3f(-1.0,-1.0,-1.0)             # Top Left Of The Quad (Back)
  GL.Vertex3f(-1.0, 1.0,-1.0)             # Bottom Left Of The Quad (Back)
  GL.Vertex3f( 1.0, 1.0,-1.0)             # Bottom Right Of The Quad (Back)

  # Left of cube
  GL.Color3f(0.0,0.0,1.0)                 # Blue
  GL.Vertex3f(-1.0, 1.0, 1.0)             # Top Right Of The Quad (Left)
  GL.Vertex3f(-1.0, 1.0,-1.0)             # Top Left Of The Quad (Left)
  GL.Vertex3f(-1.0,-1.0,-1.0)             # Bottom Left Of The Quad (Left)
  GL.Vertex3f(-1.0,-1.0, 1.0)             # Bottom Right Of The Quad (Left)

  # Right of cube
  GL.Color3f(1.0,0.0,1.0)                 # Set The Color To Violet
  GL.Vertex3f( 1.0, 1.0,-1.0);            # Top Right Of The Quad (Right)
  GL.Vertex3f( 1.0, 1.0, 1.0)             # Top Left Of The Quad (Right)
  GL.Vertex3f( 1.0,-1.0, 1.0)             # Bottom Left Of The Quad (Right)
  GL.Vertex3f( 1.0,-1.0,-1.0)             # Bottom Right Of The Quad (Right)
  GL.End();                               # done with the polygon

  $rtri += 0.05                           # Increase the rotation variable for
                                          # the Triangle
  $rquad -= 0.05                          # Decrease the rotation variable for 
                                          # the Quad
  # We need to swap the buffer to display our drawing.
  GLUT.SwapBuffers();
}



# The function called whenever a key is pressed.
keyPressed = Proc.new {|key, x, y| 

  case key
  when 27
    # If escape is pressed, kill everything and shut down our window.
    GLUT.DestroyWindow($window)
    # exit the program...normal termination.
    exit(0)
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
