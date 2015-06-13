
#===============================================================================
#  Core alterations to the animation player
#    by Luka S.J.
#
#  additional functions added to help with sprite animations and their
#  positioning.
#===============================================================================
class PokeBattle_Scene
  #=============================================================================
  #  Misc code to automize sprite animation and placement
  #=============================================================================
  def animateBattleSprites(align=false)
    @idleTimer+=1 if @idleTimer >= 0
    for i in 0...4
      if @sprites["pokemon#{i}"]
        if @sprites["pokemon#{i}"].loaded
          status=@battle.battlers[i].status
          if status==PBStatuses::SLEEP
            @sprites["pokemon#{i}"].actualBitmap.setSpeed(3)
          elsif status==PBStatuses::PARALYSIS
            @sprites["pokemon#{i}"].actualBitmap.setSpeed(2)
          elsif status==PBStatuses::FROZEN
            @sprites["pokemon#{i}"].actualBitmap.setSpeed(0)
          else
            @sprites["pokemon#{i}"].actualBitmap.setSpeed(1)
          end
          if status==PBStatuses::POISON
            @sprites["pokemon#{i}"].status=1
          elsif status==PBStatuses::PARALYSIS
            @sprites["pokemon#{i}"].status=2
          elsif status==PBStatuses::FROZEN
            @sprites["pokemon#{i}"].status=3
          elsif status==PBStatuses::BURN
            @sprites["pokemon#{i}"].status=4
          else
            @sprites["pokemon#{i}"].status=0
          end
        end
        @sprites["pokemon#{i}"].update
        @sprites["battlebox#{i}"].update if @sprites["battlebox#{i}"] && @sprites["pokemon#{i}"].loaded
      end
      next if !align
      if !@orgPosX.nil? && @idleTimer < 0
        @sprites["battlebg"].x+=(@orgPosX[0]-@sprites["battlebg"].x)*0.2
        @sprites["enemybase"].x+=(@orgPosX[1]-@sprites["enemybase"].x)*0.2
        @sprites["playerbase"].x+=(@orgPosX[2]-@sprites["playerbase"].x)*0.2
      end
      if !@orgPosY.nil? && @idleTimer < 0
        @sprites["battlebg"].y+=(@orgPosY[0]-@sprites["battlebg"].y)*0.2
        @sprites["enemybase"].y+=(@orgPosY[1]-@sprites["enemybase"].y)*0.2
        @sprites["playerbase"].y+=(@orgPosY[2]-@sprites["playerbase"].y)*0.2
      end
      if !@orgPosX.nil? && @idleTimer > BATTLEMOTIONTIMER
        @sprites["battlebg"].x-=(@sprites["battlebg"].x-(@orgPosX[0]-@idleSpeed[0]*2))*0.005
        @sprites["enemybase"].x-=(@sprites["enemybase"].x-(@orgPosX[1]-@idleSpeed[0]*2))*0.005
        @sprites["playerbase"].x-=(@sprites["playerbase"].x-(@orgPosX[2]-@idleSpeed[0]))*0.01
        @sprites["battlebg"].y-=(@sprites["battlebg"].y-(@orgPosY[0]-@idleSpeed[0]*0.5-20))*0.005
        @sprites["enemybase"].y-=(@sprites["enemybase"].y-(@orgPosY[1]-@idleSpeed[0]*0.5-20))*0.005
        @sprites["playerbase"].y-=(@sprites["playerbase"].y-(@orgPosY[2]-@idleSpeed[0]*0.5-20))*0.005
        @idleSpeed[1]+=1
        if @idleSpeed[1] > BATTLEMOTIONTIMER*1.5
          if @idleSpeed[0] > 0
            @idleSpeed[0]=-40
          else
            @idleSpeed[0]=40
          end
          @idleSpeed[1]=0
        end
      end
      if @sprites["trainer"]
        @sprites["trainer"].x=@sprites["enemybase"].x
        @sprites["trainer"].y=@sprites["enemybase"].y
        @sprites["trainer"].zoom_x=@sprites["enemybase"].zoom_x
        @sprites["trainer"].zoom_y=@sprites["enemybase"].zoom_y
      end
      if @sprites["trainer2"]
        @sprites["trainer2"].x=@sprites["enemybase"].x
        @sprites["trainer2"].y=@sprites["enemybase"].y
        @sprites["trainer2"].zoom_x=@sprites["enemybase"].zoom_x
        @sprites["trainer2"].zoom_y=@sprites["enemybase"].zoom_y
      end
      if i%2==0
        @sprites["pokemon#{i}"].x=@sprites["playerbase"].x if @sprites["pokemon#{i}"]
        @sprites["pokemon#{i}"].y=@sprites["playerbase"].y if @sprites["pokemon#{i}"]
        @sprites["pokemon#{i}"].zoom_x=@sprites["playerbase"].zoom_x if @sprites["pokemon#{i}"]
        @sprites["pokemon#{i}"].zoom_y=@sprites["playerbase"].zoom_y if @sprites["pokemon#{i}"]
      else
        @sprites["pokemon#{i}"].x=@sprites["enemybase"].x if @sprites["pokemon#{i}"]
        @sprites["pokemon#{i}"].y=@sprites["enemybase"].y if @sprites["pokemon#{i}"]
        @sprites["pokemon#{i}"].zoom_x=@sprites["enemybase"].zoom_x if @sprites["pokemon#{i}"]
        @sprites["pokemon#{i}"].zoom_y=@sprites["enemybase"].zoom_y if @sprites["pokemon#{i}"]
      end
      if @battle.doublebattle && i/2==0
        @sprites["pokemon#{i}"].x-=50*@sprites["pokemon#{i}"].zoom_x if @sprites["pokemon#{i}"].x
      elsif @battle.doublebattle && i/2==1
        @sprites["pokemon#{i}"].x+=50*@sprites["pokemon#{i}"].zoom_x if @sprites["pokemon#{i}"].x
      end
    end
  end

  def moveEntireScene(x=0,y=0)
    for i in 0...4
      @sprites["pokemon#{i}"].x+=x if @sprites["pokemon#{i}"]
      @sprites["pokemon#{i}"].y+=y if @sprites["pokemon#{i}"]
    end
    @sprites["enemybase"].x+=x
    @sprites["enemybase"].y+=y
    @sprites["playerbase"].x+=x
    @sprites["playerbase"].y+=y
    @sprites["battlebg"].x+=x
    @sprites["battlebg"].y+=y
    return if @orgPosX.nil?
    for i in 0...3
      @orgPosX[i]+=x
      @orgPosY[i]+=y
    end
  end
  #=============================================================================
  #  Move and Common animations player
  #=============================================================================
  alias pbAnimationCore_old pbAnimationCore
  def pbAnimationCore(animation,user,target,oppmove=false)
    return if !animation
    clearMessageWindow
    @sprites["battlebox0"].visible=false if @sprites["battlebox0"]
    @sprites["battlebox1"].visible=false if @sprites["battlebox1"]
    @sprites["battlebox2"].visible=false if @sprites["battlebox2"]
    @sprites["battlebox3"].visible=false if @sprites["battlebox3"]
    @briefmessage=false
    usersprite=(user) ? @sprites["pokemon#{user.index}"] : nil
    targetsprite=(target) ? @sprites["pokemon#{target.index}"] : nil
    target=user if !targetsprite && !target
    olduserx=usersprite ? usersprite.x : 0
    oldusery=usersprite ? usersprite.y : 0
    oldtargetx=targetsprite ? targetsprite.x : 0
    oldtargety=targetsprite ? targetsprite.y : 0
    if target && target.index%2==0 && !(target==user)
      10.times do
        moveEntireScene(6,-4)
        animateBattleSprites
        pbGraphicsUpdate
      end
    end
    animplayer=PBAnimationPlayerX.new(animation,user,target,self,oppmove)
    if !targetsprite
      userwidth=(!usersprite || !usersprite.bitmap || usersprite.bitmap.disposed?) ? 128 : usersprite.bitmap.width
      userheight=(!usersprite || !usersprite.bitmap || usersprite.bitmap.disposed?) ? 128 : usersprite.bitmap.height
      animplayer.setLineTransform(
         PokeBattle_SceneConstants::FOCUSUSER_X,PokeBattle_SceneConstants::FOCUSUSER_Y,
         PokeBattle_SceneConstants::FOCUSTARGET_X,PokeBattle_SceneConstants::FOCUSTARGET_Y,
         olduserx+(userwidth/2),oldusery,
         olduserx+(userwidth/2),oldusery)
    else
      userwidth=(!usersprite || !usersprite.bitmap || usersprite.bitmap.disposed?) ? 128 : usersprite.bitmap.width
      userheight=(!usersprite || !usersprite.bitmap || usersprite.bitmap.disposed?) ? 128 : usersprite.bitmap.height
      targetwidth=(!targetsprite.bitmap || targetsprite.bitmap.disposed?) ? 128 : targetsprite.bitmap.width
      targetheight=(!targetsprite.bitmap || targetsprite.bitmap.disposed?) ? 128 : targetsprite.bitmap.height
      animplayer.setLineTransform(
         PokeBattle_SceneConstants::FOCUSUSER_X,PokeBattle_SceneConstants::FOCUSUSER_Y,
         PokeBattle_SceneConstants::FOCUSTARGET_X,PokeBattle_SceneConstants::FOCUSTARGET_Y,
         olduserx+(userwidth/2),oldusery,
         oldtargetx+(targetwidth/2),oldtargety)
    end
    animplayer.start
    while animplayer.playing?
      animplayer.update
      animateBattleSprites
      pbGraphicsUpdate
      pbInputUpdate
    end
    animplayer.dispose
    animateBattleSprites(true)
    if target && target.index%2==0 && !(target==user)
      10.times do
        moveEntireScene(-6,4)
        animateBattleSprites
        pbGraphicsUpdate
      end
    end
    @sprites["battlebox0"].visible=true if @sprites["battlebox0"]
    @sprites["battlebox1"].visible=true if @sprites["battlebox1"]
    @sprites["battlebox2"].visible=true if @sprites["battlebox2"]
    @sprites["battlebox3"].visible=true if @sprites["battlebox3"]
  end
end

#===============================================================================
#  New aliased methods for Sprite animations within the battle system
#===============================================================================
alias pbSpriteSetAnimFrame_old pbSpriteSetAnimFrame
def pbSpriteSetAnimFrame(sprite,frame,user=nil,target=nil,ineditor=false)
  return if !sprite
  if !frame
    sprite.visible=false
    sprite.src_rect=Rect.new(0,0,1,1)
    return
  end
  pattern=frame[AnimFrame::PATTERN]
  zoom_ratio=1
  zoom_ratio=user.zoom_x if sprite==user
  zoom_ratio=target.zoom_x if sprite==target
  sprite.blend_type=frame[AnimFrame::BLENDTYPE]
  sprite.angle=frame[AnimFrame::ANGLE]
  sprite.mirror=(frame[AnimFrame::MIRROR] > 0)
  sprite.opacity=frame[AnimFrame::OPACITY]
  sprite.visible=true
  if !frame[AnimFrame::VISIBLE]==1 && ineditor
    sprite.opacity/=2
  else
    sprite.visible=(frame[AnimFrame::VISIBLE]==1)
  end
  if pattern >=0 # moves with no sprite manipulation
    animwidth=192
    sprite.src_rect.set((pattern%5)*animwidth,(pattern/5)*animwidth,animwidth,animwidth)
    if target
      offset=((target.oy-target.bitmap.height)+target.bitmap.height/2)*target.zoom_y
    elsif user
      offset=((user.oy-user.bitmap.height)+user.bitmap.height/2)*user.zoom_y
    else
      offset=0
    end
    sprite.ox=animwidth/2
    sprite.oy=animwidth/2+offset
  else
    sprite.src_rect.set(0,0,
       sprite.bitmap ? sprite.bitmap.width : 128,
       sprite.bitmap ? sprite.bitmap.height : 128)
    if !(sprite==user || sprite==target) # moves with multiple sprites
      if sprite.bitmap==user.bitmap # user
        zoom_ratio=user.zoom_x
        sprite.oy=user.oy
        sprite.ox=user.ox
      elsif sprite.bitmap==target.bitmap # target
        zoom_ratio=target.zoom_x
        sprite.oy=target.oy
        sprite.ox=target.ox
      end
    end
  end
  sprite.zoom_x=(frame[AnimFrame::ZOOMX]/100.0)*zoom_ratio
  sprite.zoom_y=(frame[AnimFrame::ZOOMY]/100.0)*zoom_ratio
  sprite.color.set(
     frame[AnimFrame::COLORRED],
     frame[AnimFrame::COLORGREEN],
     frame[AnimFrame::COLORBLUE],
     frame[AnimFrame::COLORALPHA]
  )
  sprite.tone.set(
     frame[AnimFrame::TONERED],
     frame[AnimFrame::TONEGREEN],
     frame[AnimFrame::TONEBLUE],
     frame[AnimFrame::TONEGRAY] 
  )
  sprite.x=frame[AnimFrame::X]
  sprite.y=frame[AnimFrame::Y]
  if sprite!=user && sprite!=target
    case frame[AnimFrame::PRIORITY]
      when 0   # Behind everything
        sprite.z=5
      when 1   # In front of everything
        sprite.z=35
      when 2   # Just behind focus
        if frame[AnimFrame::FOCUS]==1 # Focused on target
          sprite.z=(target) ? target.z-1 : 5
        elsif frame[AnimFrame::FOCUS]==2 # Focused on user
          sprite.z=(user) ? user.z-1 : 5
        else # Focused on user and target, or screen
          sprite.z=5
        end
      when 3   # Just in front of focus
        if frame[AnimFrame::FOCUS]==1 # Focused on target
          sprite.z=(target) ? target.z+1 : 35
        elsif frame[AnimFrame::FOCUS]==2 # Focused on user
          sprite.z=(user) ? user.z+1 : 35
        else # Focused on user and target, or screen
          sprite.z=35
        end
      else
        sprite.z=35
    end
  end
end

#alias getSpriteCenter_old getSpriteCenter
def getSpriteCenter2(sprite)
  return [0,0] if !sprite || sprite.disposed?
  return [sprite.x,sprite.y] if !sprite.bitmap || sprite.bitmap.disposed?
  centerX=sprite.ox
  centerY=sprite.oy
  offsetX=(centerX-sprite.ox)*sprite.zoom_x
  offsetY=(centerY-sprite.oy)*sprite.zoom_y
  return [sprite.x+offsetX,sprite.y+offsetY]
end

class PBAnimationPlayerX
  alias update_old update
  def update
    return if @frame < 0
    if (@frame>>1) >= @animation.length
      @frame=(@looping) ? 0 : -1
      if @frame < 0
        @animbitmap.dispose if @animbitmap
        @animbitmap=nil
        return
      end
    end
    if !@animbitmap || @animbitmap.disposed?
      @animbitmap=AnimatedBitmap.new("Graphics/Animations/"+@animation.graphic,
         @animation.hue).deanimate
      for i in 0...MAXSPRITES
        @animsprites[i].bitmap=@animbitmap if @animsprites[i]
      end
    end
    @bgGraphic.update
    @bgColor.update
    @foGraphic.update
    @foColor.update
    if (@frame&1)==0
      thisframe=@animation[@frame>>1]
      # Make all cel sprites invisible
      for i in 0...MAXSPRITES
        @animsprites[i].visible=false if @animsprites[i]
      end
      # Set each cel sprite acoordingly
      for i in 0...thisframe.length
        cel=thisframe[i]
        next if !cel
        sprite=@animsprites[i]
        next if !sprite
        # Set cel sprite's graphic
        if cel[AnimFrame::PATTERN]==-1
          sprite.bitmap=@userbitmap
        elsif cel[AnimFrame::PATTERN]==-2
          sprite.bitmap=@targetbitmap
        else
          sprite.bitmap=@animbitmap
        end
        # Apply settings to the cel sprite
        pbSpriteSetAnimFrame(sprite,cel,@usersprite,@targetsprite)
        case cel[AnimFrame::FOCUS]
        when 1   # Focused on target
          sprite.x=cel[AnimFrame::X]+@targetOrig[0]-PokeBattle_SceneConstants::FOCUSTARGET_X
          sprite.y=cel[AnimFrame::Y]+@targetOrig[1]-PokeBattle_SceneConstants::FOCUSTARGET_Y
          if cel[AnimFrame::PATTERN] >=0 && @targetsprite
            sprite.y+=(@targetsprite.bitmap.height*@targetsprite.zoom_y)/2
          end
        when 2   # Focused on user
          sprite.x=cel[AnimFrame::X]+@userOrig[0]-PokeBattle_SceneConstants::FOCUSUSER_X
          sprite.y=cel[AnimFrame::Y]+@userOrig[1]-PokeBattle_SceneConstants::FOCUSUSER_Y
          if cel[AnimFrame::PATTERN] >=0 && @usersprite
            sprite.y+=(@usersprite.bitmap.height*@usersprite.zoom_y)/2
          end
        when 3   # Focused on user and target
          if @srcLine && @dstLine
            point=transformPoint(
               @srcLine[0],@srcLine[1],@srcLine[2],@srcLine[3],
               @dstLine[0],@dstLine[1],@dstLine[2],@dstLine[3],
               sprite.x,sprite.y)
            sprite.x=point[0] 
            sprite.y=point[1]
            if isReversed(@srcLine[0],@srcLine[2],@dstLine[0],@dstLine[2]) &&
               cel[AnimFrame::PATTERN] >=0
              # Reverse direction
              sprite.mirror=!sprite.mirror
            end
          end
        end
        sprite.x+=64 if @ineditor
        sprite.y+=64 if @ineditor
        # changes made by Elite Battle syste
        # additional y value added to account for the sprite y center changes
        if cel[AnimFrame::PATTERN] < 0
          offset=( (sprite.oy*sprite.zoom_y)-(sprite.bitmap.height-sprite.oy) )/2
          sprite.y+=offset
        end
      end
      # Play timings
      @animation.playTiming(@frame>>1,@bgGraphic,@bgColor,@foGraphic,@foColor,@oldbg,@oldfo,@user)
    end
    @frame+=1
  end
end