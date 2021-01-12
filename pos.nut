/////////////////////////////////////////////////////////
//
// Attract-Mode Frontend - Pos (Layout Scaling) Module
//
/////////////////////////////////////////////////////////
// Pos (Position) module helps position, scale or stretch items to fit a wide variety of screen dimensions using easy-to-reference pixel values. 
// 
// I made this module so that I could just look at the pixel dimensions of objects in my Photoshop design of a layout 
// without having to do any further calculations and scale easily to multiple layout resolutions
// 
// Layouts using this module can easily stretch or scale to vertical, 4:3 and 16:9 (or other) screen sizes
// The Pos module can responsively position items from the right and bottom of the screen
// so that elements in your layout can float depending on the screen size.
// This module can also be used in tandem with the PreserveArt (and similar) modules 
//
// Usage:
//
// create an array containing any values you want to set. You only need to pass the items you want. Any item not passed in will use a default 
// you can use multiple instances. I use one for scaled and one for stretched items. This example will generate stretched values

// fe.load_module("pos"); 
//
// local posData =  {
//     base_width = 480.0, /* the width of the layout as you designed it */ 
//     base_height = 640.0, /* the height of the layout as you designed it */ 
//     layout_width = fe.layout.width, /* usually not necessary, but allows you to override the layout width and height */ 
//     layout_height = fe.layout.height, 
//     rotate = 90, /* setting to 90, -90 will rotate the layout, otherwise leave at 0 */  
//     scale= "stretch" /* stretch, scale, none. Stretch scales without preserving aspect ratio. Scale preserves aspect ratio */
// }
//
// local pos = Pos(posData)
// 
//	local vid = fe.add_artwork( "snap", pos.x(10), pos.y(20), pos.width(480), pos.height(640) ); /* my design file shows the image 10x, 20y, 480wide, 640tall */	
//	vid.preserve_aspect_ratio = false;
//
// 	local instruction_card = fe.add_image("instruction_card_bg.png" , pos.x(10), pos.y(20), pos.width(1440), pos.height(1080));
//	instruction_card.x = pos.x(272, "right", instruction_card.width); /* this is for an image whos right edge is 272 pixels from the right edge of my design */ 
//  
//  /* used with PreserveArt/PreserveImage */ 
// 
// fe.load_module("preserve-art");  
//
// local bg = PreserveImage( "image.png", pos.x(20), pos.y(20), pos.width(300), pos.height(400) );
// bg.set_fit_or_fill( "fill" );
// bg.set_anchor( ::Anchor.Top );

::Posdata <-
{
    base_width = 640.0,
    base_height = 480.0,
    layout_width = fe.layout.width,
    layout_height = fe.layout.height,
    rotate =0, 
    scale= "stretch",
    debug= false,
}
 
// scale can be stretch, scale, none
// rotate can be 0, 90, -90 ( any other value will trigger -90)

class Pos
{
    VERSION = 1.0
    pos_debug = false
    xconv = 1
    yconv = 1
    nostretch_xconv = 1
    nostretch_yconv = 1
    pos_scale = "stretch"
    pos_layout_width = 640.0
    pos_layout_height = 480.0
    pos_base_width = 640.0
    pos_base_height = 480.0
    pos_rotate = 0
    charsize_conv = 1
    width_to_height_ratio = 1
    font_scale = 1
    
    constructor( properties )
    {
        foreach(key, value in properties) {
            try {
                switch (key) {
                    case "base_width":
                        pos_base_width = value.tofloat()
                        break
                    case "base_height":
                        pos_base_height = value.tofloat()
                        break
                    case "layout_width":
                        pos_layout_width = value.tofloat()
                        break
                    case "layout_height":
                        pos_layout_height = value.tofloat()
                        break
                    case "rotate":
                        pos_rotate = value.tofloat()
                        break
                    case "scale":
                        switch(value){
                            case "scale": 
                                pos_scale = "scale"
                                break
                            case "none":
                                pos_scale = "none"
                                break
                            default:
                                pos_scale = "stretch"   
                        }
                        break
                   case "debug":
                        if (value==true){pos_debug = true }
                        break
                }
            }
            catch(e) { if (pos_debug) printL("Error setting property: " + key); } 
        }

        if (pos_rotate.tofloat() != 0)
        {
            if (::fe.layout.orient  == 0 ) // only do anything if it's not already rotated
            {
                local templayout_w = pos_layout_width
                local templayout_h = pos_layout_height
                ::fe.layout.width = pos_layout_width = templayout_h
                ::fe.layout.height= pos_layout_height = templayout_w

                if (pos_rotate==90)
                {
                    ::fe.layout.orient=RotateScreen.Right
                }
                else
                {
                    ::fe.layout.orient=RotateScreen.Left
                }
            }
        }

        // width conversion factor
        xconv = pos_layout_width / pos_base_width 
        nostretch_xconv = xconv
        
        // height conversion factor
        yconv = pos_layout_height / pos_base_height
        nostretch_yconv = yconv

        // width to height
        width_to_height_ratio = pos_layout_width / pos_layout_height
        if (width_to_height_ratio <= 1 )
        {
            charsize_conv = width_to_height_ratio
        }
            
        if (pos_scale=="scale")
        {
            if (pos_layout_width > pos_layout_height)
            {
                xconv = yconv 
                nostretch_xconv = yconv
            }
            else
            {
                yconv = xconv 
                nostretch_yconv = xconv
            }
         
        }
        if (pos_scale=="none")
        {
            xconv = 1 
            yconv = 1
            nostretch_xconv = 1
            nostretch_yconv = 1
        }
        if (pos_scale=="stretch")
        {
            if (pos_layout_width > pos_layout_height)
            {
                nostretch_xconv = yconv
            }
            else
            {
                nostretch_yconv = xconv
            }
        }
        
        printLine("nostretch_xconv", nostretch_xconv)
        printLine("nostretch_yconv", nostretch_yconv)
        printLine("xconv", xconv)
        printLine("yconv", yconv)

    }

    // Print line
    function printLine(lineheader, x) {
        if (pos_debug){
            if (!lineheader)
            {
                lineheader = "key" 
            }
            print(lineheader + ": " + x + " \n")            
        }
    }

    // get a width value converted using conversion factor
    // allow_stretch=false will cause the value to use the scaling, not stretching values. Handy when an item shouldn't be stretched (like a Logo)
    function width(num, allow_stretch=true )
    {	
        if (!allow_stretch)
        {
            return num * nostretch_xconv
        }
        else if (allow_stretch == "y")
        {
            return num * yconv
        }
        return num * xconv
    }

    // get a height value converted using conversion factor
    // allow_stretch=false will cause the image to scale height, without stretching. This is useful for backgrounds that don't need to line up perfectly with the content. 
    function height ( num, allow_stretch=true)
    {
        if (!allow_stretch)
        {
            return num * nostretch_yconv 
        } 
        else if (allow_stretch == "x")
        {
            return num * xconv
        }
        return num * yconv
    }
    
    /*
        set_font_height is used to adjust text objects to use relatively scaled type
        
        height= height of your type in your design
        text_object = name of a text object you've already created
        text_align = how the type should be aligned in your text object (uses standard AM alignment names)
        text_margin = if you'd like a margin set, add it, otherwise this defaults to zero
        
        Example usage: 
        create a text object. THEN call something like this: 
        
        pos.set_font_height(24,my_text_label, "Centre")
        
        This will create a relatively sized text object with have margins removed and the text aligned to it's vertical and horizontal center
        
    */ 
    function set_font_height(height, text_object, text_align="TopLeft" , text_margin=0)
    {
        if ( typeof text_object == typeof fe.Text())
        {
            text_object.charsize = charsize(height)
            text_object.margin=0
            
            if (text_margin){
                 text_object.margin=text_margin
            }   
            switch (text_align) {
                case "TopCentre":
                   text_object.align = Align.TopCentre 
                    break
                case "TopRight":
                   text_object.align = Align.TopRight 
                    break
                case "Left":
                   text_object.align = Align.Left 
                    break
                case "Centre":
                   text_object.align = Align.Centre 
                    break
                case "Right":
                   text_object.align = Align.Right 
                    break
                case "BottomLeft":
                   text_object.align = Align.BottomLeft 
                    break
                case "BottomCentre":
                   text_object.align = Align.BottomCentre 
                    break
                case "BottomRight":
                   text_object.align = Align.BottomRight 
                    break
               default:
                    text_object.align = Align.TopLeft
            }
        }
        return false
    }
    
    /*
        charsize is used to set a relative typesize for an existing text object
        
        example usage: 
        
        local info_text = fe.add_text("Hello World", pos.x(10), pos.y(10), pos.width(100), pos.height(100))
        info_text.charsize = pos.charsize(18)
    */ 
    function charsize(num)
    {
        local gs = num * yconv * charsize_conv
        return gs.tointeger()
    }

    /* 
    get x position converted to a scaled value using conversion factor
    
    use anchor="right" to calculate distance from the right edge of the screen instead of the left (which is the default)
    use anchor="middle" or "centre" to calculate a middle position
    Pass in the object you're working with, and the object_container 
        (sorry... that's a badly named variable that means: "second object you want to align your first object against")
        Passing those 2 objects will return an x position value for the first object relative to the second object
    */ 
    
    function x( num, anchor="left", object = null, object_container=null )
    {
        local object_width = 1
        local object_container_x = 0 
        local object_container_width = ::fe.layout.width
        anchor = anchor.tolower()
        
        if (object != null &&  typeof object !="float" && typeof object !="integer")
        {
            try {
                object_width = object.width
            }
            catch (e) {
                printLine("object is: ", typeof object)
            }
        }
        else if (object != null)
        {
            object_width = object.tofloat() * xconv
        }
        
        
        if (object_container != null && typeof object_container !="float" && typeof object_container !="integer")
        {
            try {
                object_container_x = object_container.x
                object_container_width = object_container.width
            }
            catch (e) {
                printLine("object container is: ", typeof object_container)
            }
        }
        else if (object_container != null)
        {
            object_container_x = object_container.tofloat() * xconv
        }
        
        if (anchor == "right")
        {
            return (object_container_width + object_container_x - object_width) - (num * xconv)
        }
        else if (anchor == "middle" || anchor == "centre")
        {
            printLine("object_container", object_container_x)
            printLine("object_width", object_width)
            printLine("xconv", xconv)
            return (object_container_width/2) + object_container_x - (object_width / 2) + (num*xconv) 
        }
        else 
        {
            if (object_container != null)
            {
                return object_container_width + object_container_x + (num*xconv)
            }
             
           return num * xconv
        }
    }
    
    /* 
    get y position converted to a scaled value using conversion factor
    
    use anchor="bottom" to calculate distance from the bottom edge of the screen instead of the top (which is the default)
    use anchor="middle" or "centre" to calculate a middle position
    Pass in the object you're working with, and the object_container 
        (sorry... that's a badly named variable that means: "second object you want to align your first object against")
        Passing those 2 objects will return a y position value for the first object relative to the second object
    */ 
    
    function y( num, anchor="top", object = null, object_container=null )
    {
        local object_height = 1
        local object_container_y = 0 
        local object_container_height = ::fe.layout.height
        anchor = anchor.tolower()
        
        if (object != null &&  typeof object !="float" && typeof object !="integer")
        {
            try {
                object_height = object.height
            }
            catch (e) {
                printLine("object is: ", typeof object)
            }
        }
        else if (object != null)
        {
            object_height = object.tofloat() * yconv
        }
        
        
        if (object_container != null && typeof object_container !="float" && typeof object_container !="integer")
        {
            try {
                object_container_y = object_container.y
                object_container_height = object_container.height
            }
            catch (e) {
                printLine("object_container_y is: ", typeof object_container_y)
            }
        }
        else if (object_container != null)
        {
            object_container_y = object_container.tofloat() * yconv
        }
        
        if (anchor == "bottom")
        {
            return (object_container_height + object_container_y - object_height) - (num * yconv)
        }
        else if (anchor == "middle" || anchor=="centre")
        {
            printLine("object_container", object_container_y)
            printLine("object_height", object_height)
            printLine("yconv", yconv)
            return (object_container_height/2) + object_container_y - (object_height / 2) + (num*yconv) 
        }
        else 
        {
            if (object_container != null)
            {
                return object_container_height + object_container_y + (num*yconv)
            }
             
           return num * yconv
        }
    }
    
}
