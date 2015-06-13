
# Requires module Mouse
# Requires module Input
#===============================================================================
#  Mouse input class written by Luka S.J. to enable the usage of the native 
#  mouse module in Essentials.
#  Please give credit if used.
#===============================================================================
class Game_Mouse
  attr_reader :visible
  attr_reader :x
  attr_reader :y
  
  # replace nil with a valid path to a graphics location to display a sprite
  # for the mouse
  @@graphics_path = nil
  
  # starts up the mouse and determines initial co-ordinate
  def initialize
    @mouse = Mouse
    @position = @mouse.getMousePos
    @cursor = Win32API.new("user32", "ShowCursor", "i", "i" ) 
    @visible = false
    if @position.nil?
      @x = 0
      @y = 0
    else
      @x = @position[0]
      @y = @position[1]
    end
    @static_x = @x
    @static_y = @y
    @object_ox = nil
    @object_oy = nil
    # used to make on screen mouse sprite (if a graphics path is defined)
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 0x3FFFFFFF
      @sprite = Sprite.new(@viewport)
      if !@@graphics_path.nil?
        @sprite.bitmap = BitmapCache.load_bitmap(@@graphics_path)
        self.show
      end
      @sprite.visible = @visible
      @sprite.x = @x
      @sprite.y = @y
    # ===================================================================
  end
  
  # updates the mouse (update placed in Input.update)
  def update
    @position = @mouse.getMousePos
    if !@position.nil?
      @x = @position[0]
      @y = @position[1]
    end
    @sprite.visible = @visible
    @sprite.x = @x
    @sprite.y = @y
  end
   
  # manipulation of the visibility of the mouse sprite
  def show
    @cursor.call(0)
    @visible=true
  end
  
  def hide
    @cursor.call(1)
    @visible=false
  end
  
  # checks if mouse is over a sprite (can define custom width and height)
  def over?(object=nil,width=-1,height=-1)
    return false if object.nil?
    params=self.getObjectParams(object)
    x=params[0]
    y=params[1]
    width=params[2] if width < 0
    height=params[3] if height < 0
    return true if @x >= x && @x <= (x + width) and @y >= y && @y <= (y + height)
    return false
  end
  
  # special method to check whether the mouse is over sprites with special shapes
  def overPixel?(sprite)
    return false if !sprite.bitmap
    bitmap=sprite.bitmap
    return false if !self.over?(sprite)
    bx=@x-sprite.x
    by=@y-sprite.y
    if defined?(sprite.viewport) && sprite.viewport
      bx-=sprite.viewport.rect.x
      by-=sprite.viewport.rect.y
    end
    pixel=bitmap.get_pixel(bx,by)
    return true if pixel.alpha>0
    return false
  end
  
  # checks if mouse is left clicking a sprite (can define custom width and height)
  def leftClick?(object=nil,width=-1,height=-1)
    if object.nil?
      return Input.triggerex?(Input::Mouse_Left)
    else
      return (self.over?(object,width,height) && Input.triggerex?(Input::Mouse_Left))
    end
  end
  
  # checks if mouse is right clicking a sprite (can define custom width and height)
  def rightClick?(object=nil,width=-1,height=-1)
    if object.nil?
      return Input.triggerex?(Input::Mouse_Left)
    else
      return (self.over?(object,width,height) && Input.triggerex?(Input::Mouse_Right))
    end
  end
  
  # checks if mouse is left clicking a sprite / continuous (can define custom width and height)
  def leftPress?(object=nil,width=-1,height=-1)
    if object.nil?
      return Input.pressed(Input::Mouse_Left)
    else
      return (self.over?(object,width,height) && Input.pressed(Input::Mouse_Left))
    end
  end
  
  # checks if mouse is right clicking a sprite / continuous (can define custom width and height)
  def rightPress?(object=nil,width=-1,height=-1)
    if object.nil?
      return Input.pressed(Input::Mouse_Left)
    else
      return (self.over?(object,width,height) && Input.pressed(Input::Mouse_Right))
    end
  end
    
  # checks if the mouse is in a certain area of the App window
  def inArea?(x,y,width,height)
    rect=Rect.new(x,y,width,height)
    return self.over?(rect)
  end
  
  # checks if the mouse is left clicking in a certain area of the App window
  def inAreaLeft?(x,y,width,height)
    return (self.inArea?(x,y,width,height) && Input.triggerex?(Input::Mouse_Left))
  end
  
  # checks if the mouse is right clicking in a certain area of the App window
  def inAreaRight?(x,y,width,height)
    return (self.inArea?(x,y,width,height) && Input.triggerex?(Input::Mouse_Right))
  end
          
  # checks if the mouse is idle/ not moving around
  def isStatic?
    ret=false
    ret=true if @static_x==@x && @static_y==@y
    if !(@static_x==@x) or !(@static_y==@y)
      @static_x=@x
      @static_y=@y
    end
    return ret
  end
  
  # moves a targeted object with the mouse.x when left clicked (range of movement can be specified in terms of position and dimensions in the App window)
  def drag_x(object,limit_x=nil,limit_width=nil)\
    return false if !defined?(object.x)
    if self.leftPress?(object)
      if @object_ox.nil?
        @object_ox = @x - object.x
      end
      object.x = @x - @object_ox
      object.x = limit_x if limit_x && object.xlimit_width
    else
      @object_ox=nil
    end
  end
  
  # moves a targeted object with the mouse.y when left clicked (range of movement can be specified in terms of position and dimensions in the App window)
  def drag_y(object,limit_y=nil,limit_height=nil)
    return false if !defined?(object.y)
    if self.leftPress?(object)
      if @object_oy.nil?
        @object_oy = @y - object.y
      end
      object.y = @y - @object_oy
      object.y = limit_y if limit_y && object.ylimit_height
    else
      @object_oy=nil
    end
  end
  
  # moves a targeted object with the mouse when left clicked (range of movement can be specified in terms of position and dimensions in the App window)
  def drag_xy(object,limit_x=nil,limit_y=nil,limit_width=nil,limit_height=nil)
    return false if !defined?(object.x) or !defined?(object.y)
    if self.leftPress?(object)
      if @object_ox.nil?
        @object_ox = @x - object.x
      end
      if @object_oy.nil?
        @object_oy = @y - object.y
      end
      object.x = @x - @object_ox
      object.x = limit_x if limit_x && object.xlimit_width
      object.y = @y - @object_oy
      object.y = limit_y if limit_y && object.ylimit_height
    else
      @object_ox=nil
      @object_oy=nil
    end
  end
    
  def getObjectParams(object)
    params=[0,0,0,0]
    if object.is_a?(Sprite)
      params[0]=(object.x)
      params[1]=(object.y)
      if defined?(object.viewport) && object.viewport
        params[0]+=object.viewport.rect.x
        params[1]+=object.viewport.rect.y
      end
      params[2]=(object.bitmap.width*object.zoom_x) if object.bitmap
      params[3]=(object.bitmap.height*object.zoom_y) if object.bitmap
    elsif object.is_a?(Viewport)
      params=[object.rect.x,object.rect.y,object.rect.width,object.rect.height]
    else
      params[0]=(object.x) if object.x
      params[1]=(object.y) if object.y
      if defined?(object.viewport) && object.viewport
        params[0]+=object.viewport.rect.x
        params[1]+=object.viewport.rect.y
      end
      params[2]=(object.width) if object.width
      params[3]=(object.height) if object.height
    end
    return params
  end
end
#===============================================================================
#  Initializes the Game_Mouse class
#===============================================================================
$mouse = Game_Mouse.new
#===============================================================================
#  Mouse input methods for the Input module
#===============================================================================
module Input
  Mouse_Left = 1
  Mouse_Right = 2
  Mouse_Middle = 4
  
  class << Input
    alias update_org update
  end
  
  def self.update
    $mouse.update if defined?($mouse) && $mouse
    update_org
  end
  
  def self.pressed(key)
    return true unless Win32API.new("user32","GetKeyState",['i'],'i').call(key).between?(0, 1)
    return false
  end
end
