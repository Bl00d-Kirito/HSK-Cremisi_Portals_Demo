
#===============================================================================
#  New animation methods for Pokemon sprites
#    by Luka S.J.
#
#  supports both animated, and static sprites
#  does not support the usage of GIFs
#  any one frame of sprite needs to be of equal width and height
#  all sprites need to be in 1*1 px resolution
#  use dragonnite's(Lucy's) GIF to PNG converter to properly format your sprites
#  
#  allows the use of custom looping points
#===============================================================================

class AnimatedBitmapWrapper
  attr_reader :width
  attr_reader :height
  attr_reader :totalFrames
  attr_reader :animationFrames
  attr_reader :currentIndex
  attr_reader :scale
  
  def initialize(file,twoframe=false)
    raise "filename is nil" if file==nil
    @scale = 2
    @width = 0
    @height = 0
    @frame = 0
    @frames = 2
    @direction = +1
    @twoframe = twoframe
    @animationFinish = false
    @totalFrames = 0
    @currentIndex = 0
    @speed = 1
      # 0 - not moving at all
      # 1 - normal speed
      # 2 - medium speed
      # 3 - slow speed
    @bitmapFile=BitmapCache.load_bitmap(file)
      # initializes full Pokemon bitmap
    @bitmap=Bitmap.new(@bitmapFile.width,@bitmapFile.height)
    @bitmap.blt(0,0,@bitmapFile,Rect.new(0,0,@bitmapFile.width,@bitmapFile.height))
    @width=@bitmap.height*@scale
    @height=@bitmap.height*@scale
    
    @totalFrames=@bitmap.width/@bitmap.height
    @animationFrames=@totalFrames*@frames
      # calculates total number of frames
    @loop_points=[0,@totalFrames]
      # first value is start, second is end
    
    @actualBitmap=Bitmap.new(@width,@height)
    @actualBitmap.clear
    @actualBitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmap,Rect.new(@currentIndex*(@width/@scale),0,@width/@scale,@height/@scale))
  end
    
  def length; @totalFrames; end
  def disposed?; @actualBitmap.disposed?; end
  def dispose; @actualBitmap.dispose; end
  def copy; @actualBitmap.clone; end
  def bitmap; @actualBitmap; end
  def bitmap=(val); @actualBitmap=val; end
  def each; end
  def alterBitmap(index); return @strip[index]; end
    
  def prepareStrip
    @strip=[]
    for i in 0...@totalFrames
      bitmap=Bitmap.new(@width,@height)
      bitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmapFile,Rect.new((@width/@scale)*i,0,@width/@scale,@height/@scale))
      @strip.push(bitmap)
    end
  end
  def compileStrip
    @bitmap.clear
    for i in 0...@strip.length
      @bitmap.stretch_blt(Rect.new((@width/@scale)*i,0,@width/@scale,@height/@scale),@strip[i],Rect.new(0,0,@width,@height))
    end
  end
  
  def reverse
    if @direction  >  0
      @direction=-1
    elsif @direction < 0
      @direction=+1
    end
  end
  
  def setLoop(start, finish)
    @loop_points=[start,finish]
  end
  
  def setSpeed(value)
    @speed=value
  end
  
  def toFrame(frame)
    if frame.is_a?(String)
      if frame=="last"
        frame=@totalFrames-1
      else
        frame=0
      end
    end
    frame=@totalFrames if frame > @totalFrames
    frame=0 if frame < 0
    @currentIndex=frame
    @actualBitmap.clear
    @actualBitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmap,Rect.new(@currentIndex*(@width/@scale),0,@width/@scale,@height/@scale))
  end
  
  def play
    break if @currentIndex >= @loop_points[1]-1
    self.update
  end
  
  def update
    return false if @speed < 1
    case @speed
    # frame skip
    when 1
      @frames=2
    when 2
      @frames=4
    when 3
      @frames=5
    end
    @frame+=1
    
    if @frame >=@frames
      # processes animation speed
      @currentIndex+=@direction
      @currentIndex=@loop_points[0] if @currentIndex >=@loop_points[1]
      @currentIndex=@loop_points[1]-1 if @currentIndex < @loop_points[0]
      @frame=0
    end
    @actualBitmap.clear
    @actualBitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmap,Rect.new(@currentIndex*(@width/@scale),0,@width/@scale,@height/@scale))
      # updates the actual bitmap
  end
    
  # returns bitmap to original state
  def deanimate
    @frame=0
    @currentIndex=0
    @actualBitmap.clear
    @actualBitmap.stretch_blt(Rect.new(0,0,@width,@height),@bitmap,Rect.new(@currentIndex*(@width/@scale),0,@width/@scale,@height/@scale))
  end
end

#===============================================================================
#  Aliases old PokemonBitmap generating functions and creates new ones,
#  utilizing the new BitmapWrapper
#===============================================================================

alias pbLoadPokemonBitmap_old pbLoadPokemonBitmap
def pbLoadPokemonBitmap(pokemon, back=false,animate=false)
  return pbLoadPokemonBitmapSpecies(pokemon,pokemon.species,back)
end

# Note: Returns an AnimatedBitmap, not a Bitmap
alias pbLoadPokemonBitmapSpecies_old pbLoadPokemonBitmapSpecies
def pbLoadPokemonBitmapSpecies(pokemon, species, back=false)
  ret=nil
  if pokemon.isEgg?
    bitmapFileName=sprintf("Graphics/Battlers/%segg",getConstantName(PBSpecies,species)) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName=sprintf("Graphics/Battlers/%03degg",species)
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName=sprintf("Graphics/Battlers/egg")
      end
    end
    bitmapFileName=pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName=pbCheckPokemonBitmapFiles([species,back,
                                              (pokemon.isFemale?),
                                              pokemon.isShiny?,
                                              (pokemon.form rescue 0),
                                              (pokemon.isShadow? rescue false)])    
  end
  animatedBitmap=AnimatedBitmapWrapper.new(bitmapFileName) if bitmapFileName
  ret=animatedBitmap if bitmapFileName
  # Full compatibility with the alterBitmap methods is maintained
  # but unless the alterBitmap method gets rewritten and sprite animations get
  # hardcoded in the system, the bitmap alterations will not function properly
  # as they will not account for the sprite animation itself
  
  # alterBitmap methods for static sprites will work just fine
  alterBitmap=(MultipleForms.getFunction(species,"alterBitmap") rescue nil) if !pokemon.isEgg? && animatedBitmap && animatedBitmap.totalFrames==1 # remove this totalFrames clause to allow for dynamic sprites too
  if bitmapFileName && alterBitmap
    animatedBitmap.prepareStrip
    for i in 0...animatedBitmap.totalFrames
      alterBitmap.call(pokemon,animatedBitmap.alterBitmap(i))
    end
    animatedBitmap.compileStrip
    ret=animatedBitmap
  end
  return ret
end

#===============================================================================
#  Pokemon Sprite GIF to PNG converter
#    by Luka S.J.
#
#  Create a directory called "Convert" in your game's root folder
#  and place all the GIFs you want to convert in it.
#  Newly formatted PNGs will retain old GIF names.
#===============================================================================

class GifExtra
  def initialize(file=nil,viewport=nil)
    @file=file
    @sprite=SpriteWrapper.new(viewport)
    if file
      @bitmap=AnimatedBitmap.new(file)
      @sprite.bitmap=@bitmap.bitmap
    end
  end
  def totalFrames; @bitmap.totalFrames; end
  def bitmap; @bitmap.bitmap; end
  def visible=(val); @sprite.visible=val; end
  def dispose; @sprite.dispose; end
  def update
    if @bitmap
      @bitmap.update
      @sprite.update
      if self.bitmap!=@bitmap.bitmap
        oldrc=self.src_rect
        self.bitmap=@bitmap.bitmap
        self.src_rect=oldrc
      end
    end
  end
end

#===============================================================================
#  Just a little utility I made to load up all the correct files from a directory
#===============================================================================
def readDirectoryFiles(directory,formats)
  files=[]
  Dir.chdir(directory){
    for i in 0...formats.length
      Dir.glob(formats[i]){|f| files.push(f) }
    end
  }
  return files
end
#===============================================================================
#  Use this to automatically scale down any 2*2 px resolution sprites you may
#  have, to the smaller 1*1 px resolution, for full compatibility with the new
#  bitmap wrappers utilized in displaying and animating sprites
#===============================================================================
def resizePngs
  destination="./Convert/"
  search_for=["*.png"]
 
  @files=readDirectoryFiles(destination,search_for)
  @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  @viewport.z=999999
  
  @bar=Sprite.new(@viewport)
  @bar.bitmap=Bitmap.new(Graphics.width,34)
  pbSetSystemFont(@bar.bitmap)
 
  for i in 0...@files.length
    @files[i]=@files[i].gsub(/.png/) {""}
  end
  
  return false if !Kernel.pbConfirmMessage(_INTL("There is a total of #{@files.length} PNG(s) available for conversion. Would you like to begin the process?"))
  for i in 0...@files.length
    file=@files[i]
    
    width=((i*1.000)/@files.length)*Graphics.width
    @bar.bitmap.clear
    @bar.bitmap.fill_rect(0,0,Graphics.width,34,Color.new(255,255,255))
    @bar.bitmap.fill_rect(0,0,Graphics.width,32,Color.new(0,0,0))
    @bar.bitmap.fill_rect(0,0,width,32,Color.new(25*4,90*2,25*4))
    text=[["#{i}/#{@files.length}",Graphics.width/2,2,2,Color.new(255,255,255),nil]]
    pbDrawTextPositions(@bar.bitmap,text)
    
    next if RTP.exists?("#{destination}New/#{file}.png")
    
    sprite=pbBitmap("#{destination}#{file}.png")
    width=sprite.width
    height=sprite.height
      
    bitmap=Bitmap.new(width/2,height/2)
    bitmap.stretch_blt(Rect.new(0,0,width/2,height/2),sprite,Rect.new(0,0,width,height))
    bitmap.saveToPng("#{destination}New/#{file}.png")
    sprite.dispose
    pbWait(1)
    RPG::Cache.clear
  end
  @bar.dispose
  @viewport.dispose
  Kernel.pbMessage(_INTL("Done!"))
end  
#===============================================================================
#  Call this through event, or other scripts to start up GIF to PNG conversion
#
#  Don't use this script to convert GIFs anymore
#  @dragonnite (Lucy) has made a better tool to convert GIFs without corrupted
#  frames. Use that one instead
#===============================================================================
def decompressGifs
  destination="./Convert/"
  search_for=["*.gif"]
 
  @files=readDirectoryFiles(destination,search_for)
  @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  @viewport.z=999999
  
  @bar=Sprite.new(@viewport)
  @bar.bitmap=Bitmap.new(Graphics.width,34)
  pbSetSystemFont(@bar.bitmap)
 
  for i in 0...@files.length
    @files[i]=@files[i].gsub(/.gif/) {""}
  end
 
  return false if !Kernel.pbConfirmMessage(_INTL("There is a total of #{@files.length} GIF(s) available for conversion. Would you like to begin the process?"))
   
  for i in 0...@files.length
    file=@files[i]
    
    width=((i*1.000)/@files.length)*Graphics.width
    @bar.bitmap.clear
    @bar.bitmap.fill_rect(0,0,Graphics.width,34,Color.new(255,255,255))
    @bar.bitmap.fill_rect(0,0,Graphics.width,32,Color.new(0,0,0))
    @bar.bitmap.fill_rect(0,0,width,32,Color.new(25*4,90*2,25*4))
    text=[["#{i}/#{@files.length}",Graphics.width/2,2,2,Color.new(255,255,255),nil]]
    pbDrawTextPositions(@bar.bitmap,text)
    
    next if RTP.exists?("#{destination}#{file}.png")
    
    sprite=GifExtra.new("#{destination}#{file}.gif")
    frames=sprite.totalFrames
    width=sprite.bitmap.width
    height=sprite.bitmap.height
    sprite.visible=false  
   
    if width < height
      size=height
    elsif height < width
      size=width
    else
      size=width
    end
   
    bitmap=Bitmap.new(size*frames,size)
    x=0
    ox=((size-width)/2)
    oy=((size-height)/2)
    rect=Rect.new(0,0,width,height)
    frames.times do
      bitmap.blt((x*size)+ox,0+oy,sprite.bitmap,rect)
      sprite.update
      x+=1
    end
    bitmap.saveToPng("#{destination}#{file}.png")
    sprite.dispose
    pbWait(1)
    RPG::Cache.clear
  end
  @bar.dispose
  @viewport.dispose
  Kernel.pbMessage(_INTL("Done!"))
end  
#===============================================================================
#  Misc. scripting tools
#===============================================================================

def pbBitmap(name)
  return BitmapCache.load_bitmap(name)
end

def downloadSprites
  site="http://sprites.pokecheck.org/"
  dest="./Convert/"
  dir=["i/","s/","b/","bs/"]
  ext=["","s","b","sb"]

  @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  @viewport.z=999999
  
  @bar=Sprite.new(@viewport)
  @bar.bitmap=Bitmap.new(Graphics.width,34)
  pbSetSystemFont(@bar.bitmap)
  
  for i in 1...650
    
    width=((i*1.000)/649)*Graphics.width
    @bar.bitmap.clear
    @bar.bitmap.fill_rect(0,0,Graphics.width,34,Color.new(255,255,255))
    @bar.bitmap.fill_rect(0,0,Graphics.width,32,Color.new(0,0,0))
    @bar.bitmap.fill_rect(0,0,width,32,Color.new(25*4,90*2,25*4))
    text=[["#{i}/649",Graphics.width/2,2,2,Color.new(255,255,255),nil]]
    pbDrawTextPositions(@bar.bitmap,text)
    
    for j in 0...4
      index = sprintf("%03d",i)
      url = "#{site}#{dir[j]}#{index}f.gif"
      file = "#{dest}#{index}f#{ext[j]}.gif"
      pbDownloadToFile(url, file)
    end
    pbWait(1)
  end
  @bar.dispose
  @viewport.dispose
  Kernel.pbMessage(_INTL("Done!"))
end    