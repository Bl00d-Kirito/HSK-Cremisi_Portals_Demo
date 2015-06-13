
#===============================================================================
#  New methods for creating in-battle Pokemon sprites
#    by Luka S.J.
#
#  creates fixed shadows in the sprite itself
#  calculates correct positions according to metric data in here
#  sprites have a different focal point for more precise base placement
#===============================================================================

class DynamicPokemonSprite
  attr_accessor :shadow
  attr_accessor :sprite
  attr_accessor :src_rect
  attr_accessor :showshadow
  attr_accessor :status
  attr_reader :loaded
  attr_reader :selected

  def initialize(doublebattle,index,viewport=nil)
    @viewport=viewport
    @metrics=load_data("Data/metrics.dat")
    @selected=0
    @frame=0
    
    @status=0
    @loaded=false
    @index=index
    @doublebattle=doublebattle
    @showshadow=true
    @altitude=0
    @yposition=0
    @shadow=Sprite.new(@viewport)
    @sprite=Sprite.new(@viewport)
    @overlay=Sprite.new(@viewport)
    @lock=false
  end
  
  def x; @sprite.x; end
  def y; @sprite.y; end
  def z; @sprite.z; end
  def ox; @sprite.ox; end
  def oy; @sprite.oy; end
  def ox=(val);;end
  def oy=(val);;end
  def zoom_x; @sprite.zoom_x; end
  def zoom_y; @sprite.zoom_y; end
  def visible; @sprite.visible; end
  def opacity; @sprite.opacity; end
  def width; @bitmap.width; end
  def height; @bitmap.height; end
  def tone; @sprite.tone; end
  def bitmap; @bitmap.bitmap; end
  def actualBitmap; @bitmap; end
  def disposed?; @sprite.disposed?; end
  def color; @sprite.color; end
  def src_rect; @sprite.src_rect; end
  def blend_type; @sprite.blend_type; end
  def angle; @sprite.angle; end
  def mirror; @sprite.mirror; end
  def lock
    @lock=true
  end
  def bitmap=(val)
    @bitmap.bitmap=val
  end
  def x=(val)
    @sprite.x=val
    @shadow.x=val
  end
  def ox=(val)
    @sprite.ox=val
    self.formatShadow
  end
  def oy=(val)
    @sprite.oy=val
    self.formatShadow
  end
  def y=(val)
    @sprite.y=val
    @shadow.y=val
  end
  def z=(val)
    @shadow.z=10
    @sprite.z=val
  end
  def zoom_x=(val)
    @sprite.zoom_x=val
    self.formatShadow
  end
  def zoom_y=(val)
    @sprite.zoom_y=val
    self.formatShadow
  end
  def visible=(val)
    @sprite.visible=val
    self.formatShadow
  end
  def opacity=(val)
    @sprite.opacity=val
    self.formatShadow
  end
  def tone=(val)
    @sprite.tone=val
    self.formatShadow
  end
  def color=(val)
    @sprite.color=val
    self.formatShadow
  end
  def blend_type=(val)
    @sprite.blend_type=val
    self.formatShadow
  end
  def angle=(val)
    @sprite.angle=(val)
    self.formatShadow
  end
  def mirror=(val)
    @sprite.mirror=(val)
    self.formatShadow
  end
  def dispose
    @sprite.dispose
    @shadow.dispose
  end
  def selected=(val)
    @selected=val
    @sprite.visible=true
  end
  
  def setPokemonBitmap(pokemon,back=false)
    @altitude=@metrics[2][pokemon.species]
    @yposition=@metrics[1][pokemon.species]
    if back
      @altitude/=1
      @yposition/=1
    end
    
    @bitmap=pbLoadPokemonBitmap(pokemon,back)
    @sprite.bitmap=@bitmap.bitmap.clone
    @shadow.bitmap=@bitmap.bitmap.clone
    @sprite.ox=@bitmap.width/2
    @sprite.oy=@bitmap.height
    @sprite.oy+=@altitude
    @sprite.oy-=@yposition
    
    @loaded=true
    self.formatShadow
  end
  
  def formatShadow
    @shadow.zoom_x=@sprite.zoom_x*1.00
    @shadow.zoom_y=@sprite.zoom_y*0.30
    @shadow.ox=@sprite.ox-6
    @shadow.oy=@sprite.oy-6
    @shadow.opacity=@sprite.opacity*0.3
    @shadow.tone=Tone.new(-255,-255,-255,255)
    @shadow.visible=@sprite.visible
    @shadow.mirror=@sprite.mirror
    
    @shadow.visible=false if !@showshadow
  end
  
  def update(angle=60)
    return if @lock
    if @bitmap
      @bitmap.update
      @sprite.bitmap=@bitmap.bitmap.clone
      @shadow.bitmap=@bitmap.bitmap.clone
      @shadow.skew(angle)
    end
      case @status
      when 0
        @sprite.color=Color.new(0,0,0,0)
      when 1 #PSN
        @sprite.color=Color.new(153,102,204,50)
      when 2 #PAR
        @sprite.color=Color.new(255,255,153,50)
      when 3 #FRZ
        @sprite.color=Color.new(153,204,204,50)
      when 4 #BRN
        @sprite.color=Color.new(204,51,51,50)
      end
    # Pokémon sprite blinking when targeted or damaged
    @frame+=1
    if @selected==2 # When targeted or damaged
      @sprite.visible=(@frame%10<7)
    end
    self.formatShadow
  end  
end

class DynamicTrainerSprite  <  DynamicPokemonSprite
  
  def totalFrames; @bitmap.animationFrames; end
  def toLastFrame 
    @bitmap.toFrame(@bitmap.totalFrames-1)
    self.update
  end
  def selected; end
    
  def setTrainerBitmap(file)
    @bitmap=AnimatedBitmapWrapper.new(file)
    @sprite.bitmap=@bitmap.bitmap.clone
    @shadow.bitmap=@bitmap.bitmap.clone
    @sprite.ox=@bitmap.width/2
    if @doublebattle
      if @index==-2
        @sprite.ox-=50
      elsif @index==-1
        @sprite.ox+=50
      end
    end
    @sprite.oy=@bitmap.height-12
    
    self.formatShadow
    @shadow.skew(60)
  end

end

class Sprite
  def skew(angle=90)
    return false if !self.bitmap
    bitmap=self.bitmap
    rect=Rect.new(0,0,bitmap.width,bitmap.height)
    width=rect.width+(rect.height/Math.tan(angle))
    self.bitmap=Bitmap.new(width,rect.height)
    angle=angle*(Math::PI/180)
    for i in 0...rect.height
      y=rect.height-i
      x=i/Math.tan(angle)
      self.bitmap.blt(x+rect.x,y+rect.y,bitmap,Rect.new(0,y,rect.width,1))
    end
  end
end