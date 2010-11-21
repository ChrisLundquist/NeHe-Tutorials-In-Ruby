#!/usr/bin/ruby
# This code was created by Jeff Molofee '99 
# Conversion to Ruby by Manolo Padron Martinez (manolopm@cip.es)
# Bug Fixes by Chris Lundquist (chrismlundquist@gmail.com)
require "rubygems"
require "opengl"
require "glut"
require "../bitmap"


$xrot = 0.0                               # X Rotation ( NEW )
$yrot = 0.0                               # Y Rotation ( NEW )
$zrot = 0.0                               # Z Rotation ( NEW )

$texture = Array.new                # Storage For One Texture ( NEW )

# A general OpenGL initialization function.  Sets all of the initial parameters

def InitGL(width, height) # We call this right after our OpenGL window 
    # is created.

    return false unless load_gl_textures()                          # If Texture Didn't Load Return FALSE ( NEW )

    glEnable(GL_TEXTURE_2D);                      # Enable Texture Mapping ( NEW )

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


def load_gl_textures
    bitmap = Bitmap.new("Data/NeHe.bmp")

    $texture = glGenTextures(1) # Create 1 Texture
    glBindTexture(GL_TEXTURE_2D, $texture[0]) # Bind The Texture 
    glTexImage2D(GL_TEXTURE_2D, 0, 4, bitmap.width, bitmap.height, 0, GL_RGB, GL_UNSIGNED_BYTE, bitmap.data) # Build Texture Using Information In bitmap

    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
    $texture[0] # Return The Texture ID
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
    GL.Clear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # Clear Screen And Depth Buffer
    GL.LoadIdentity()                                   # Reset The Current Matrix
    GL.Translatef( 0.0, 0.0, -5.0)                      # Move Into The Screen 5 Units

    GL.Rotatef($xrot, 1.0, 0.0, 0.0)                        # Rotate On The X Axis
    GL.Rotatef($yrot, 0.0, 1.0, 0.0)                        # Rotate On The Y Axis
    GL.Rotatef($zrot, 0.0, 0.0, 1.0)                        # Rotate On The Z Axis

    GL.BindTexture(GL_TEXTURE_2D, $texture[0])               # Select Our Texture

    GL.Begin(GL_QUADS);
    # Front Face
    GL.TexCoord2f(0.0, 0.0); GL.Vertex3f(-1.0, -1.0,  1.0) # Bottom Left Of The Texture and Quad
    GL.TexCoord2f(1.0, 0.0); GL.Vertex3f( 1.0, -1.0,  1.0) # Bottom Right Of The Texture and Quad
    GL.TexCoord2f(1.0, 1.0); GL.Vertex3f( 1.0,  1.0,  1.0) # Top Right Of The Texture and Quad
    GL.TexCoord2f(0.0, 1.0); GL.Vertex3f(-1.0,  1.0,  1.0) # Top Left Of The Texture and Quad
    # Back Face
    GL.TexCoord2f(1.0, 0.0); GL.Vertex3f(-1.0, -1.0, -1.0) # Bottom Right Of The Texture and Quad
    GL.TexCoord2f(1.0, 1.0); GL.Vertex3f(-1.0,  1.0, -1.0) # Top Right Of The Texture and Quad
    GL.TexCoord2f(0.0, 1.0); GL.Vertex3f( 1.0,  1.0, -1.0) # Top Left Of The Texture and Quad
    GL.TexCoord2f(0.0, 0.0); GL.Vertex3f( 1.0, -1.0, -1.0) # Bottom Left Of The Texture and Quad
    # Top Face
    GL.TexCoord2f(0.0, 1.0); GL.Vertex3f(-1.0,  1.0, -1.0) # Top Left Of The Texture and Quad
    GL.TexCoord2f(0.0, 0.0); GL.Vertex3f(-1.0,  1.0,  1.0) # Bottom Left Of The Texture and Quad
    GL.TexCoord2f(1.0, 0.0); GL.Vertex3f( 1.0,  1.0,  1.0) # Bottom Right Of The Texture and Quad
    GL.TexCoord2f(1.0, 1.0); GL.Vertex3f( 1.0,  1.0, -1.0) # Top Right Of The Texture and Quad
    # Bottom Face
    GL.TexCoord2f(1.0, 1.0); GL.Vertex3f(-1.0, -1.0, -1.0) # Top Right Of The Texture and Quad
    GL.TexCoord2f(0.0, 1.0); GL.Vertex3f( 1.0, -1.0, -1.0) # Top Left Of The Texture and Quad
    GL.TexCoord2f(0.0, 0.0); GL.Vertex3f( 1.0, -1.0,  1.0) # Bottom Left Of The Texture and Quad
    GL.TexCoord2f(1.0, 0.0); GL.Vertex3f(-1.0, -1.0,  1.0) # Bottom Right Of The Texture and Quad
    # Right face
    GL.TexCoord2f(1.0, 0.0); GL.Vertex3f( 1.0, -1.0, -1.0) # Bottom Right Of The Texture and Quad
    GL.TexCoord2f(1.0, 1.0); GL.Vertex3f( 1.0,  1.0, -1.0) # Top Right Of The Texture and Quad
    GL.TexCoord2f(0.0, 1.0); GL.Vertex3f( 1.0,  1.0,  1.0) # Top Left Of The Texture and Quad
    GL.TexCoord2f(0.0, 0.0); GL.Vertex3f( 1.0, -1.0,  1.0) # Bottom Left Of The Texture and Quad
    # Left Face
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
    when "\e",27 # Escape key depending on ruby version
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
