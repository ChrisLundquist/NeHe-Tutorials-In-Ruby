#!/usr/bin/ruby
# This code was created by Jeff Molofee '99 
# Conversion to Ruby by Manolo Padron Martinez (manolopm@cip.es)

require "rubygems"
require "opengl"
require "glut"


# Rotation angle for the triangle.
$rtri = 0.0

#Rotation angle for the quadrilateral.
$rquad = 0.0

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

  # Calculate The Aspect Ratio Of The Window
  GLU.Perspective(45.0,Float(width)/Float(height),0.1,100.0) 
  GL.MatrixMode(GL::MODELVIEW)
end

# The Function Called When Our Window Is Resized (Which Shouldn't Happen, 
# Because We're Fullscreen) 
resize_gl_scene = Proc.new {|width, height|
  height = 1 if height == 0 # Prevent A Divide By Zero 
  # If The Window Is Too Small
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
  GL.Color3f(  1.0, 0.0, 0.0)             # Set The Color To Red
  GL.Vertex3f( 0.0, 1.0, 0.0)             # Top
  GL.Color3f(  0.0, 1.0, 0.0)             # Set The Color To Green
  GL.Vertex3f( 1.0,-1.0, 0.0)             # Bottom Right
  GL.Color3f(  0.0, 0.0, 1.0)             # Set The Color To Blue
  GL.Vertex3f(-1.0,-1.0, 0.0)             # Bottom Left  
  GL.End()                                # We're done with the polygon 
  # (smooth color interpolation)    
  GL.LoadIdentity()                       # Make sure we're no longer rotated.
  GL.Translate(1.5,0.0,-6.0)              # Move Right 3 Units, and back into 
                                          # the screen 6.0
  GL.Rotate($rquad,1.0,0.0,0.0)           # Rotate the quad on the X Axis

  # Draw a square (quadrilateral)
  GL.Color3f(0.5,0.5,1.0)                 # Set color to a blue shade.
  GL.Begin(GL::QUADS)                     # Start drawing a polygon
  GL.Vertex3f(-1.0, 1.0, 0.0)             # Top Left
  GL.Vertex3f( 1.0, 1.0, 0.0)             # Top Right
  GL.Vertex3f( 1.0,-1.0, 0.0)             # Bottom Right
  GL.Vertex3f(-1.0,-1.0, 0.0)             # Bottom Left  
  GL.End();                               # Done with the polygon

  $rtri += 0.15                           # Increase the rotation variable for
                                          # the Triangle
  $rquad -= 0.15                          # Decrease the rotation variable for 
                                          # the Quad
  # We need to swap the buffer to display our drawing.
  GLUT.SwapBuffers();
}



# The function called whenever a key is pressed.
key_pressed = Proc.new {|key, x, y| 
  # If escape is pressed, kill everything. 
  case key
  when "\e",27 # Escape key depending on ruby version
    GLUT.DestroyWindow($window) # Shut Down Our Window 
    exit(0) # Exit the program...normal termination.
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

# Get a 640x480 window
GLUT.InitWindowSize(640,480)

# The window starts at the upper left corner of the screen
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
