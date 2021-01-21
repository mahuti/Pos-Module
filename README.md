# POS Module

The Pos (Layout Scaling) Module module for AttractMode helps position, scale or stretch items to fit a wide variety of screen dimensions using easy-to-reference pixel values. The goal of this module is to make it easier to design a layout using pixels in a layout editor like Photoshop and then scale it dynamically to fit any format, whether it's 16x9, 4x3 or vertical. Basically you can tell the pos module your original sizes and positioning in Photoshop and the pos module will scale or stretch your content smartly to fit the current layout. 

## Installation

Add the module file to the modules folder of AttractMode (make sure the correct permissions are set on the folder so that AttractMode can see the newly added module). Start (or restart) AttractMode.

## Use

Multiple instances of the positioning module can be used. This can be useful for calculating both scaled and stretched values where some objects should be scaled and some just stretched. Multiple instances can be used together in one command... for instance a stretched x & y combined with scaled width and height. Typically I use scaling for all critical visual elements and stretching for colored objects or surfaces.

    ```c++
    fe.load_module("pos"); 

    // create an array containing any values you want to set. You only need to pass the items you want. Any item not passed in will use a default */ 

    local posData =  {
         base_width = 480.0, /* the width of the layout as you designed it */ 
         base_height = 640.0, /* the height of the layout as you designed it */ 
         layout_width = fe.layout.width, /* usually not necessary, but allows you to override the layout width and height */ 
         layout_height = fe.layout.height, 
         rotate = 90, /* setting to 90, -90 will rotate the layout, otherwise leave at 0 */  
         scale= "stretch" /* stretch, scale, none. Stretch scales without preserving aspect ratio. Scale preserves aspect ratio 
         debug="false" /* set to true if you need to see more information about values being passed around in the module */ 
    }
    local pos = Pos(posData)

    /* the calculations below were made using a file 480x640 (tall) but the pos module will adjust those values relative to where they'd be in a 640x480 (or any other sized) layout automatically */ 
    local vid = fe.add_artwork( "snap", pos.x(10), pos.y(20), pos.width(480), pos.height(640) ); /* my design file shows the image 10x, 20y, 480wide, 640tall */	
    vid.preserve_aspect_ratio = false;

    local instruction_card = fe.add_image("instruction_card_bg.png" , pos.x(10), pos.y(20), pos.width(1440), pos.height(1080));
    instruction_card.x = pos.x(10, "right", instruction_card, vid); /* this is for an image whos right edge is 10 pixels from the right edge of  the video in my design */ 
  
    /* used with PreserveArt/PreserveImage */ 
    fe.load_module("preserve-art"); 

    local bg = PreserveImage( "image.png", pos.x(20), pos.y(20), pos.width(300), pos.height(400) );
    bg.set_fit_or_fill( "fill" );
    bg.set_anchor( ::Anchor.Top );
    ``` 
    
### Methods

#### X Position
x( num, anchor="left", object = null, object_container=null,align_to="left" )
returns float value 

##### Parameters (for both x & y methods)

    type:string 
        acceptable values x,y
    
    num:float/int
    
    anchor: string  
        acceptable values: left,right,center,centre,middle,top,bottom
        anchor position of the object, or if object is not available, postion relative to screen
    
    object: float/int/object
        acceptable values: 
            object:  if an object is present, it will be positioned relative to the screen
            float/int: will be used in place of object's width/height. xy coordinate assumed to be 0
            
    relative_object: float/int/object
        acceptable values: 
            object: if an relative_object is present, the object will be positioned relative to this instead of the screen
            float/int: will be used in place of relative_object's width/height. xy coordinate assumed to be 0
         
    align_to: string
        acceptible values: left,right,center,centre,middle,top,bottom
        if an object is present, it will be aligned relative to relative_object (if available) otherwise to the screen
        Using this, you could set the anchor to the left of object1, and align the left of the object with the right of the object2
 

#### Y Position 
y( num, anchor="top", object = null, object_container=null,align_to="top" )
returns float value

same details as x method

#### Width
width(number)
returns float value 

##### Parameters
number = width value as originally designed. 

#### Height
height(number)

same details as width method

#### Set Font Height
This will set several parameters on a font so that its positioning and size is very easily calcuable. 
It removes margin, sets alignment and a scaled charsize. Alignment and margin can be overriden if necessary. By default this module assumes that most designs were created for a 4:3 or 16:9 layout. Fonts will be scaled slightly smaller on vertical screens, so if your design is vertical, you may need to bump this value up a bit. 

set_font_height(font_height, text_object, text_align="TopLeft" , text_margin=0)
returns false

##### Parameters
font_height = number used to set charsize based on scaled values

text_object = this is the object that should be manipulated

text_align = uses AttractMode's default alignment values TopLeft, TopCentre, TopRight, etc to set the positioning of the text relative to the text object

text_margin = padding normally present around text_object. Set to 0 by default

#### Charsize
charsize(number)
returns integer

Returns a scaled value to use in text_object.charsize. By default this module assumes that most designs were created for a 4:3 or 16:9 layout. Fonts will be scaled slightly smaller on vertical screens, so if your design is vertical, you may need to bump this value up a bit. 

### Examples

    local box = fe.add_image("boxpic.png", 0, scalepos.y(30), scalepos.width(1708), scalepos.height(2004)) /* this positions & scales the box */ 
    box.x = scalepos.x(-600,"left",box,null,"right")  /* aligns the left edge of the object with the right edge of the screen, and positions it -600 (scaled) pixels from the right edge

    if (wheel != null){
        box.y = scalepos.y(-400,"top",box,wheel,"bottom") /*  this positions the top of the box -400 (scaled) pixels above the bottom of the wheel
    }
    else
    {
        box.y = scalepos.y(-400,"top",box,null,"bottom") /*  this positions the top of the box -400 (scaled) pixels above the bottom of the screen
    }
    
    
    playtime = fe.add_text("Playtime: [PlayedTime] [Name]", pos.x(14),0, pos.width(800), pos.height(108))
    pos.set_font_height(25,playtime, "BottomLeft") /* this sets the playtime font height to 25 (scaled) pixels, with no margins, aligned to the bottom left of the text object