# POS Module

The Pos (Layout Scaling) Module module for AttractMode helps position, scale or stretch items to fit a wide variety of screen dimensions using easy-to-reference pixel values. The goal of this module is to make it easier to design a layout using pixels in a layout editor like Photoshop and then scale it dynamically to fit any format, whether it's 16x9, 4x3 or vertical. Basically you can tell the pos module your original sizes and positioning in Photoshop and the pos module will scale or stretch your content smartly to fit the current layout. 

## Installation

Add module to the modules folder of AttractMode (make sure the correct permissions are set on the folder so that AttractMode can see the newly added module). Start (or restart) AttractMode.

## Use

Multiple instances of the positioning module can be used. This can be useful for calculating both scaled and stretched values where some objects should be scaled and some just stretched. 

    fe.load_module("pos"); 

    // create an array containing any values you want to set. You only need to pass the items you want. Any item not passed in will use a default */ 

    local posData =  {
         base_width = 480.0, /* the width of the layout as you designed it */ 
         base_height = 640.0, /* the height of the layout as you designed it */ 
         layout_width = fe.layout.width, /* usually not necessary, but allows you to override the layout width and height */ 
         layout_height = fe.layout.height, 
         rotate = 90, /* setting to 90, -90 will rotate the layout, otherwise leave at 0 */  
         scale= "stretch" /* stretch, scale, none. Stretch scales without preserving aspect ratio. Scale preserves aspect ratio 
    }
    local pos = Pos(posData)

    /* the calculations below we made using a file 480x640 (tall) but the pos module will adjust those values relative to where they'd be in a 640x480 (or any other sized) layout automatically */ 
    local vid = fe.add_artwork( "snap", pos.x(10), pos.y(20), pos.width(480), pos.height(640) ); /* my design file shows the image 10x, 20y, 480wide, 640tall */	
    vid.preserve_aspect_ratio = false;

    local instruction_card = fe.add_image("instruction_card_bg.png" , pos.x(10), pos.y(20), pos.width(1440), pos.height(1080));
    instruction_card.x = pos.x(10, "right", instruction_card, vid); /* this is for an image whos right edge is 10 pixels from the right edge of  the video in my design */ 
  
    /* used with PreserveArt/PreserveImage */ 
    fe.load_module("preserve-art"); 

    local bg = PreserveImage( "image.png", pos.x(20), pos.y(20), pos.width(300), pos.height(400) );
    bg.set_fit_or_fill( "fill" );
    bg.set_anchor( ::Anchor.Top );

### Methods

#### X Position
x( num, anchor="left", object = null, object_container=null )
returns float value 

##### Parameters

num = x value as originally designed. This is the position relative to the canvas or to an object_container

anchor = left/right/middle(or centre) If an anchor other than the default "left" is provided, you should also provide the object so that it's current width can be used to determine it's position relative to other objects, or the layout canvas. 

object = text object, image object, or float value of the object's current x position. You only need to pass the object or object's x value if you're using right or centre positioning.

object_container = text oject, image object or float value of the object container's width. You only need to pass the object_container or object_container's width if you're using right or centre positioning. The default value is the width of the page 


#### Y Position 
y( num, anchor="top", object = null, object_container=null )
returns float value

##### Parameters
num = y value as originally designed. This is the position relative to the canvas or to an object_container

anchor = top/bottom/middle(or centre) If an anchor other than the default "top" is provided, you should also provide the object so that it's current height can be used to determine it's position relative to other objects, or the layout canvas. 

object = text object, image object, or float value of the object's current y position. You only need to pass the object or object's y value if you're using bottom or centre positioning.

object_container = text oject, image object or float value of the object container's height. You only need to pass the object_container or object_container's height if you're using bottom or centre positioning. The default value is the height of the page 

#### Width
width(number, allow_stretch = true)
returns float value 

##### Parameters
number = width value as originally designed. 

allow_stretch = if the instance of pos is set to allow stretching, then this can override it

#### Height
height(number, allow_stretch = true)
returns float value 

##### Parameters
number = height value as originally designed. 

allow_stretch = if the instance of pos is set to allow stretching, then this can override it
 
#### Set Font Height
this will set several parameters on a font so that it's positioning and size is very easily calcuable. 
It removes margin, sets alignment and a scaled charsize. Alignment and margin can be overriden if necessary.

set_font_height(font_height, text_object, text_align="TopLeft" , text_margin=0)
returns false

##### Parameters
font_height = used to set charsize based on scaled values

text_object = this is the object that should be manipulated

text_align = uses AttractMode's default alignment values TopLeft, TopCentre, TopRight, etc to set the positioning of the text relative to the text object

text_margin = padding normally present around text_object. Set to 0 by default here

#### Charsize
charsize(number)
returns integer

Returns a scaled value to use in text_object.charsize 