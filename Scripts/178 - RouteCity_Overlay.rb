SYMBOL = ['a','ß','?']

BGDIM = 15
ENDDIM = 51
ALPHADIM = 45
BGHEIGHT = 152
VELOCITY = 1
FADE = 7

class RouteName
  def self.route(name, num)
    @dim = name.length
    @imageBg =[]

    @imageBgEnd = Sprite.new
    @imageBgEnd.x = -ENDDIM
    @imageBgEnd.bitmap = Cache.picture("route-bar-end")
    for i in 0..@dim
      @imageBg[i] = Sprite.new
      @imageBg[i].x = -((i+1)*BGDIM)-ENDDIM
      @imageBg[i].bitmap = Cache.picture("route-bar-bg")
    end
    
    @imageAlpha = Sprite.new
    @imageAlpha.bitmap = Cache.picture("alpha-bg")
    @imageAlpha.x = -ENDDIM-ALPHADIM-(@dim+1)*BGDIM 
    
    @imageTextAlpha = Sprite.new
    @imageTextAlpha.bitmap = Bitmap.new(ALPHADIM, 45)
    @imageTextAlpha.bitmap.font = Font.new("Arial",40)
    @imageTextAlpha.bitmap.font.color = Color.new(65,65,65)
    @imageTextAlpha.bitmap.draw_text(13, 0, 35, 40, SYMBOL[num])
    @imageTextAlpha.x = -((@dim+1)*BGDIM)-ENDDIM-ALPHADIM
    
    @imageText = Sprite.new
    @imageText.bitmap = Bitmap.new(((@dim)*BGDIM), 45)
    @imageText.bitmap.font = Font.new("SAO UI",40)
    @imageText.bitmap.font.color = Color.new(65,65,65)
    @imageText.bitmap.draw_text(8, 0, (@dim) * BGDIM + ENDDIM, 40, name)
    @imageText.x = -((@dim+1)*BGDIM)-ENDDIM


    for i in 0..((@dim+1)*BGDIM+ENDDIM+ALPHADIM)/VELOCITY
      for k in 0..@dim
        @imageBg[k].x += VELOCITY
      end
      @imageBgEnd.x += VELOCITY
      @imageText.x += VELOCITY
      @imageAlpha.x += VELOCITY
      @imageTextAlpha.x += VELOCITY
    end
    
    Graphics.update
		
    for k in 0..@dim
      @imageBg[k].x = ALPHADIM+BGDIM*k
    end
    @imageBgEnd.x = ALPHADIM+BGDIM*(@dim+1)
    @imageText.x = ALPHADIM
    @imageAlpha.x = 0
    @imageTextAlpha.x = 0
    
    Graphics.update
    
      for i in 0..300
        Graphics.freeze
      end
      
      Graphics.transition
    
    for i in 0..((@dim)*BGDIM+51+ALPHADIM)/VELOCITY
    Graphics.update
      for k in 0..@dim
        @imageBg[k].x -= VELOCITY
      end
      @imageBgEnd.x -= VELOCITY
      @imageText.x -= VELOCITY
      @imageTextAlpha.x -= VELOCITY
      @imageAlpha.x -= VELOCITY
    end
    
    for i in 0..@dim
      @imageBg[i].dispose
    end
    @imageBgEnd.dispose
    @imageText.dispose
    @imageTextAlpha.dispose
    @imageAlpha.dispose
    end
    
    def self.town(name)
      @dim = name.length
      @imageBg = Sprite.new
      @imageBg.x = 0
      @imageBg.y = DEFAULTSCREENHEIGHT-BGHEIGHT/2-50
      @imageBg.bitmap = Cache.picture("city-bar")
      @imageBg.opacity = 0
      
      @imageText = Sprite.new
      @imageText.x = 0
      @imageText.y = DEFAULTSCREENHEIGHT-BGHEIGHT/2-55
      @imageText.bitmap = Bitmap.new(DEFAULTSCREENWIDTH,BGHEIGHT)
      @imageText.bitmap.font = Font.new("SAO UI", 91)
      @imageText.bitmap.font.color = Color.new(37,37,37)
      @imageText.bitmap.draw_text((DEFAULTSCREENWIDTH/2)-(12*@dim),0,DEFAULTSCREENWIDTH,BGHEIGHT,name)
      @imageText.opacity = 0
      
      for i in 1..255/FADE
        Graphics.update
        @imageBg.opacity = i*FADE
        @imageText.opacity = i*FADE
      end
      
      Graphics.update
      @imageBg.opacity = 255
      @imageText.opacity = 255
      
      for i in 0..200
        Graphics.freeze
      end
      
      Graphics.transition
      
      for i in 0..255/FADE
        Graphics.update
        @imageBg.opacity = 255 - i*FADE
        @imageText.opacity = 255 - i*FADE
      end
      
      @imageBg.dispose
      @imageText.dispose
  end
end
=begin
def initialize(name)
    @sprites = {}
    
    @sprites["overlay"]=Sprite.new
    @sprites["overlay"].bitmap=Bitmap.new(Graphics.width*4,Graphics.height*4)
    @sprites["overlay"].z=9999999
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @overlay = @sprites["overlay"].bitmap
    @overlay.clear
    @baseColor=Color.new(0,0,0)
    @shadowColor=Color.new(148,148,165)
        
    @sprites["Alpha"] = Sprite.new
    @sprites["Alpha"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/alpha-bg")
		@sprites["Area"] = Sprite.new
    @sprites["Area"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/route-name-bar")
    @sprites["Alpha"].x = 0 - (@sprites["Alpha"].bitmap.width + @sprites["Area"].bitmap.width)
    @sprites["Alpha"].y = 0 
		@sprites["Area"].x = 0 - @sprites["Area"].bitmap.width
    @sprites["Area"].y = 0 
		
    
    @window=Window_AdvancedTextPokemon.new(name)
    @window.resizeToFit(name,Graphics.width)
    @window.x=0
    @window.y=-@window.height
    @window.z=99999
    @currentmap=$game_map.map_id
    @frames=0
  end

  def disposed?
    @window.disposed?
  end

  def dispose
    @window.dispose
    @sprites["Alpha"].dispose
		@sprites["Area"].dispose
    @overlay.dispose
  end

  def update
    return if @window.disposed?
    @window.update
    @sprites["overlay"].update
    if $game_temp.message_window_showing ||
       @currentmap!=$game_map.map_id
      @window.dispose
			@sprites["Alpha"].dispose
			@sprites["Area"].dispose
      @overlay.dispose
      return
    end
    if @frames>70
      @sprites["Alpha"].x-= 4
			@sprites["Area"].x -= 4
      @overlay.clear
      textPositions=[]
      textPositions.push([_INTL("{1}", $game_map.name),((@sprites["Area"].x) + 150)-0,8,0,@baseColor,@shadowColor])
      pbDrawTextPositions(@overlay,textPositions)
      @overlay.dispose if @sprites["Area"].x+@sprites["Area"].bitmap.width<0
      @window.dispose if @sprites["Area"].x+@sprites["Area"].bitmap.width<0
      @sprites["Alpha"].dispose if @sprites["Alpha"].x+@sprites["Alpha"].bitmap.width<0
			@sprites["Area"].dispose if @sprites["Area"].x+@sprites["Area"].bitmap.width<0
    else
      @sprites["Alpha"].x += 4 if @sprites["Alpha"].x<0
			@sprites["Area"].x += 4 if @sprites["Area"].x<0-@sprites["Alpha"].bitmap.width
      @overlay.clear
      textPositions=[]
      textPositions.push([_INTL("{1}", $game_map.name),((@sprites["Area"].x) + 150)-0,8,0,@baseColor,@shadowColor])
      pbDrawTextPositions(@overlay,textPositions)
      @frames+=1
    end
end
=end