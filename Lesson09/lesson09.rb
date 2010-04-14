#!/usr/bin/ruby
# This code was created by Jeff Molofee '99 
# Conversion to Ruby by Chris Lundquist (ChrisMLundquist@gmail.com)
require "rubygems"
require "opengl"
require "glut"
require "../bitmap"


Struct.new(:star, :r,:g,:b,:dist,:angle)


$texture = Array.new(1)                # Storage For Three Textures
$zoom = -15.0
$tilt = 90.0
$spin = 0.0
$stars = Array.new

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
    bitmap = Bitmap.new("Data/Star.bmp")
    $texture = glGenTextures(1) # Create 3 Texture

    # Create Linear Filtered Texture
    glBindTexture(GL_TEXTURE_2D, $texture[0])
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)
    glTexImage2D(GL_TEXTURE_2D, 0, 3, bitmap.size_x, bitmap.size_y, 0, GL_RGB, GL_UNSIGNED_BYTE, bitmap.data)
end


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
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)	# Clear The Screen And The Depth Buffer
	glBindTexture(GL_TEXTURE_2D, $texture[0])			# Select Our Texture

	$stars.each_with_index do |star,i|					# Loop Through All The Stars
		glLoadIdentity()								# Reset The View Before We Draw Each Star
		glTranslatef(0.0, 0.0, $zoom)					# Zoom Into The Screen (Using The Value In 'zoom')
		glRotatef($tilt,1.0,0.0,0.0)					# Tilt The View (Using The Value In 'tilt')
		glRotatef(star.angle,0.0,1.0,0.0)		        # Rotate To The Current Stars Angle
		glTranslatef(star.dist,0.0,0.0)		            # Move Forward On The X Plane
		glRotatef(-star.angle,0.0,1.0,0.0)	            # Cancel The Current Stars Angle
		glRotatef(-$tilt,1.0,0.0,0.0)	    			# Cancel The Screen Tilt
		
		if ($twinkle != 0)
			glColor4ub($stars[-i].r, $stars[-i].g,$stars[-i].b,255)
			glBegin(GL_QUADS)
				glTexCoord2f(0.0, 0.0); glVertex3f(-1.0,-1.0, 0.0)
				glTexCoord2f(1.0, 0.0); glVertex3f( 1.0,-1.0, 0.0)
				glTexCoord2f(1.0, 1.0); glVertex3f( 1.0, 1.0, 0.0)
				glTexCoord2f(0.0, 1.0); glVertex3f(-1.0, 1.0, 0.0)
			glEnd()
        end

		glRotatef($spin,0.0,0.0,1.0)
		glColor4ub(star.r, star.g, star.b,255)
		glBegin(GL_QUADS)
			glTexCoord2f(0.0, 0.0); glVertex3f(-1.0,-1.0, 0.0)
			glTexCoord2f(1.0, 0.0); glVertex3f( 1.0,-1.0, 0.0)
			glTexCoord2f(1.0, 1.0); glVertex3f( 1.0, 1.0, 0.0)
			glTexCoord2f(0.0, 1.0); glVertex3f(-1.0, 1.0, 0.0)
		glEnd()

		$spin += 0.01
		star.angle += i.to_f / $stars.length
		star.dist -= 0.01
		if (star.dist < 0.0)
			star.dist += 5.0
			star.r = rand(255)
			star.g = rand(255)
			star.b = rand(255)
        end
    end
    GLUT.SwapBuffers()
	true										# Everything Went OK
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
    when 'T'.sum,'t'.sum
        $twinkle = !$twinkle
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
