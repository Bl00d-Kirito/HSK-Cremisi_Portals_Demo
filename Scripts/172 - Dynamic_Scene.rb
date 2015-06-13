
#===============================================================================
#  Elite Battle system
#    by Luka S.J.
#  
#  system is based off the original Essentials battle system, made by the 
#  Essentials team.
#  No additional features added to AI, or functionality of the battle system.
#  This update is purely cosmetic, and includes B/W like dynamic scene with a 
#  custom interface.
#
#  Enjoy the script, and make sure to give credit!
#===============================================================================
# General settings
USENEWUI = false # Toggle to use the new UI
BATTLEMOTIONTIMER = 40*40*1 # Waiting period (in frames) before
                            # battle "camera" starts moving
                            
module PokeBattle_SceneConstants
  if USENEWUI
    MESSAGEBASECOLOR        = Color.new(255,255,255)
    MESSAGESHADOWCOLOR      = Color.new(32,32,32)
    MENUBASECOLOR           = MESSAGEBASECOLOR
    MENUSHADOWCOLOR         = MESSAGESHADOWCOLOR
    BOXTEXTBASECOLOR        = MESSAGEBASECOLOR
    BOXTEXTSHADOWCOLOR      = MESSAGESHADOWCOLOR
    HPGAUGESIZE             = 168
    EXPGAUGESIZE            = 260
  end
end
#===============================================================================  

class PokeBattle_Scene
  attr_accessor :idleTimer
  # Retained to prevent any potential conflicts
  # Returns whether the party line-ups are currently appearing on-screen
  alias inPartyAnimation_old inPartyAnimation?
  def inPartyAnimation?; return false; end
  # Shows the party line-ups appearing on-screen
  alias partyAnimationUpdate_old partyAnimationUpdate
  def partyAnimationUpdate; end
  #=============================================================================
  #  A slightly different way to loading backdrops
  #  Backdrops now get tinted according to the daytime
  #=============================================================================
  alias pbBackdrop_old pbBackdrop
  def pbBackdrop
    environ=@battle.environment
    # Choose backdrop
    backdrop="Field"
    if environ==PBEnvironment::Cave
      backdrop="Cave"
    elsif environ==PBEnvironment::MovingWater || environ==PBEnvironment::StillWater
      backdrop="Water"
    elsif environ==PBEnvironment::Underwater
      backdrop="Underwater"
    elsif environ==PBEnvironment::Rock
      backdrop="Mountain"
    else
      if !$game_map || !pbGetMetadata($game_map.map_id,MetadataOutdoor)
        backdrop="IndoorA"
      end
    end
    if $game_map
      back=pbGetMetadata($game_map.map_id,MetadataBattleBack)
      if back && back!=""
        backdrop=back
      end
    end
    if $PokemonGlobal && $PokemonGlobal.nextBattleBack
      backdrop=$PokemonGlobal.nextBattleBack
    end
    # Choose bases
    base=""
    trialname=""
    if environ==PBEnvironment::Grass || environ==PBEnvironment::TallGrass
      trialname="Grass"
    elsif environ==PBEnvironment::Sand
      trialname="Sand"
    elsif $PokemonGlobal.surfing
      trialname="Water"
    end
    if pbResolveBitmap(sprintf("Graphics/Battlebacks/playerbase"+backdrop+trialname))
      base=trialname
    end
    # Choose time of day
    time=""
    trialname=""
    timenow=pbGetTimeNow
    # Apply graphics
    battlebg="Graphics/Battlebacks/battlebg"+backdrop
    enemybase="Graphics/Battlebacks/enemybase"+backdrop+base
    playerbase="Graphics/Battlebacks/playerbase"+backdrop+base
    pbAddSprite("battlebg",0,0,battlebg,@viewport)
    pbAddSprite("playerbase",0,0,playerbase,@viewport)
    pbAddSprite("enemybase",0,0,enemybase,@viewport)
    pbAddSprite("shades",0,0,battlebg,@viewport)
    @sprites["battlebg"].z=0
    @sprites["playerbase"].z=1
    @sprites["enemybase"].z=1
    @sprites["shades"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    @sprites["shades"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(255,255,255))
    @sprites["shades"].z=2
    @sprites["shades"].opacity=0
    pbDayNightTint(@sprites["battlebg"])
    pbDayNightTint(@sprites["playerbase"])
    pbDayNightTint(@sprites["enemybase"])
  end
  #=============================================================================
  #  Initialization of the battle scene
  #=============================================================================
  def pbLoadUIElements(battle)
    if USENEWUI
      @sprites["battlebox0"]=PokemonNewDataBox.new(battle.battlers[0],battle.doublebattle,@viewport,battle.pbPlayer)
      @sprites["battlebox1"]=PokemonNewDataBox.new(battle.battlers[1],battle.doublebattle,@viewport,battle.pbPlayer)
      if battle.doublebattle
        @sprites["battlebox2"]=PokemonNewDataBox.new(battle.battlers[2],battle.doublebattle,@viewport,battle.pbPlayer)
        @sprites["battlebox3"]=PokemonNewDataBox.new(battle.battlers[3],battle.doublebattle,@viewport,battle.pbPlayer)
      end
      pbAddSprite("messagebox",0,Graphics.height-96,"Graphics/Pictures/newBattleMessageBox",@viewport)
      @sprites["messagebox"].z=90
      @sprites["messagebox"].visible=false
    
      @sprites["helpwindow"]=Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
      @sprites["helpwindow"].visible=false
      @sprites["helpwindow"].z=90
    
      @sprites["messagewindow"]=Window_AdvancedTextPokemon.new("")
      @sprites["messagewindow"].letterbyletter=true
      @sprites["messagewindow"].viewport=@viewport
      @sprites["messagewindow"].z=100 
    
      @sprites["commandwindow"]=CommandMenuDisplay.new(@viewport) # Retained for compatibility
      @sprites["commandwindow"].visible=false # Retained for compatibility
      @sprites["fightwindow"]=FightMenuDisplay.new(nil,@viewport) # Retained for compatibility
      @sprites["fightwindow"].visible=false # Retained for compatibility
      @commandWindow=NewCommandWindow.new(@viewport,@battle)
      @fightWindow=NewFightWindow.new(@viewport)
      10.times do
        @commandWindow.hide
        @fightWindow.hide
      end
    else
      @sprites["battlebox0"]=PokemonDataBox.new(battle.battlers[0],battle.doublebattle,@viewport)
      @sprites["battlebox1"]=PokemonDataBox.new(battle.battlers[1],battle.doublebattle,@viewport)
      if battle.doublebattle
        @sprites["battlebox2"]=PokemonDataBox.new(battle.battlers[2],battle.doublebattle,@viewport)
        @sprites["battlebox3"]=PokemonDataBox.new(battle.battlers[3],battle.doublebattle,@viewport)
      end
      pbAddSprite("messagebox",0,Graphics.height-96,"Graphics/Pictures/battleMessage",@viewport)
      @sprites["messagebox"].z=90
      @sprites["helpwindow"]=Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
      @sprites["helpwindow"].visible=false
      @sprites["helpwindow"].z=90
      @sprites["messagewindow"]=Window_AdvancedTextPokemon.new("")
      @sprites["messagewindow"].letterbyletter=true
      @sprites["messagewindow"].viewport=@viewport
      @sprites["messagewindow"].z=100
      @sprites["commandwindow"]=CommandMenuDisplay.new(@viewport)
      @sprites["commandwindow"].z=100
      @sprites["fightwindow"]=FightMenuDisplay.new(nil,@viewport)
      @sprites["fightwindow"].z=100
      pbShowWindow(MESSAGEBOX)
    end
  end
  
  alias pbStartBattle_old pbStartBattle
  def pbStartBattle(battle)
    @battle=battle
    @firstsendout=true
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
    @orgPosX=nil
    @orgPosY=nil
    @shadowAngle=60
    @idleTimer=0
    @idleSpeed=[40,0]
    @showingplayer=true
    @showingenemy=true
    @sprites.clear
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @traineryoffset=(Graphics.height-320) # Adjust player's side for screen size
    @foeyoffset=(@traineryoffset*3/4).floor  # Adjust foe's side for screen size
    pbBackdrop
    if @battle.player.is_a?(Array)
      trainerfile=pbPlayerSpriteBackFile(@battle.player[0].trainertype)
      pbAddSprite("player",0,0,trainerfile,@viewport)
      @sprites["player"].opacity=0
      trainerfile=pbTrainerSpriteBackFile(@battle.player[1].trainertype)
      pbAddSprite("playerB",0,0,trainerfile,@viewport)
      @sprites["playerB"].opacity=0
    else
      trainerfile=pbPlayerSpriteBackFile(@battle.player.trainertype)
      pbAddSprite("player",0,0,trainerfile,@viewport)
      @sprites["player"].opacity=0
    end
    if @battle.opponent
      if @battle.opponent.is_a?(Array)
        trainerfile=pbTrainerSpriteFile(@battle.opponent[1].trainertype)
        @sprites["trainer2"]=DynamicTrainerSprite.new(@battle.doublebattle,-2,@viewport)
        @sprites["trainer2"].setTrainerBitmap(trainerfile)
        @sprites["trainer2"].z=16
        trainerfile=pbTrainerSpriteFile(@battle.opponent[0].trainertype)
        @sprites["trainer"]=DynamicTrainerSprite.new(@battle.doublebattle,-1,@viewport)
        @sprites["trainer"].setTrainerBitmap(trainerfile)
        @sprites["trainer"].z=11
      else
        trainerfile=pbTrainerSpriteFile(@battle.opponent.trainertype)
        @sprites["trainer"]=DynamicTrainerSprite.new(@battle.doublebattle,-1,@viewport)
        @sprites["trainer"].setTrainerBitmap(trainerfile)
        @sprites["trainer"].z=11
      end
    else
      trainerfile="Graphics/Characters/trfront"
      @sprites["trainer"]=DynamicTrainerSprite.new(@battle.doublebattle,-1,@viewport)
      @sprites["trainer"].setTrainerBitmap(trainerfile)
      @sprites["trainer"].z=11
    end
    @sprites["pokemon0"]=DynamicPokemonSprite.new(battle.doublebattle,0,@viewport)
    @sprites["pokemon0"].z=21 
    @sprites["pokemon1"]=DynamicPokemonSprite.new(battle.doublebattle,1,@viewport)
    @sprites["pokemon1"].z=11
    if battle.doublebattle
      @sprites["pokemon2"]=DynamicPokemonSprite.new(battle.doublebattle,2,@viewport)
      @sprites["pokemon2"].z=26
      @sprites["pokemon3"]=DynamicPokemonSprite.new(battle.doublebattle,3,@viewport)
      @sprites["pokemon3"].z=16
    end
    
    # Compatibility for gen 6 Effect messages
    if PokeBattle_Scene.method_defined?(:pbDisplayEffect) && PokeBattle_Scene.method_defined?(:pbHideEffect)
      # Draw message effect sprites
      # not shown here
      pbAddSprite("EffectFoe",0,90,"Graphics/Pictures/battleEffectFoe",@viewport)
      pbAddSprite("EffectPlayer",Graphics.width-192,158,"Graphics/Pictures/battleEffectPlayer",@viewport)
      @sprites["EffectFoe"].visible=false
      @sprites["EffectFoe"].z=95
      @sprites["EffectPlayer"].visible=false
      @sprites["EffectPlayer"].z=95
    end
    pbLoadUIElements(battle)
    
    pbSetMessageMode(false)
    trainersprite1=@sprites["trainer"]
    trainersprite2=@sprites["trainer2"]
    if !@battle.opponent
      @sprites["trainer"].visible=false
      if @battle.party2.length >=1
        if @battle.party2.length==1
          # wild (single) battle initialization
          @sprites["pokemon1"].setPokemonBitmap(@battle.party2[0],false)
          @sprites["pokemon1"].tone=Tone.new(-128,-128,-128,-128)
          @sprites["pokemon1"].visible=true
          trainersprite1=@sprites["pokemon1"]
        elsif @battle.party2.length==2
          # wild (double battle initialization)
          @sprites["pokemon1"].setPokemonBitmap(@battle.party2[0],false)
          @sprites["pokemon1"].tone=Tone.new(-128,-128,-128,-128)
          @sprites["pokemon1"].visible=true
          trainersprite1=@sprites["pokemon1"]
          @sprites["pokemon3"].setPokemonBitmap(@battle.party2[1],false)
          @sprites["pokemon3"].tone=Tone.new(-128,-128,-128,-128)
          @sprites["pokemon3"].visible=true
          trainersprite2=@sprites["pokemon3"]
        end
      end
    end
    #################
    # Position for initial transition
    black=Sprite.new(@viewport)
    black.z=99999999
    black.bitmap=Bitmap.new(Graphics.width,Graphics.height)
    black.bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0))
    @sprites["playerbase"].ox=@sprites["playerbase"].bitmap.width/2
    @sprites["playerbase"].oy=@sprites["playerbase"].bitmap.height/2
    @sprites["enemybase"].ox=@sprites["enemybase"].bitmap.width/2
    @sprites["enemybase"].oy=@sprites["enemybase"].bitmap.height/2
    @sprites["battlebg"].ox=426+268+60
    @sprites["battlebg"].oy=200+166
    
    @sprites["battlebg"].x=446
    @sprites["battlebg"].y=200-10
    @sprites["enemybase"].x=440+150
    @sprites["enemybase"].y=200-10-35
    @sprites["playerbase"].x=138+25
    @sprites["playerbase"].y=342-6-35
    animateBattleSprites(true)
    10.times do
      @sprites["enemybase"].x-=14
      @sprites["enemybase"].y+=10
      @sprites["enemybase"].zoom_x+=0.1
      @sprites["enemybase"].zoom_y+=0.1
      @sprites["battlebg"].x-=20
      @sprites["battlebg"].y+=10
      @sprites["battlebg"].zoom_x+=0.1
      @sprites["battlebg"].zoom_y+=0.1
      @sprites["playerbase"].x-=60
      @sprites["playerbase"].y+=30
      @sprites["playerbase"].zoom_x+=0.14
      @sprites["playerbase"].zoom_y+=0.14
      animateBattleSprites(true)
    end
    moveEntireScene(-210)
    animateBattleSprites(true)
    #################
    # Play battle entrance
    i=13*2
    13.times do
      black.opacity-=25.5
      moveEntireScene(i)
      i-=1*2
      animateBattleSprites(true)
      Graphics.update
    end
    black.dispose
    4.times do
      animateBattleSprites(true)
      Graphics.update
    end
    10.times do
      @sprites["enemybase"].x+=14
      @sprites["enemybase"].y-=10
      @sprites["enemybase"].zoom_x-=0.1
      @sprites["enemybase"].zoom_y-=0.1
      @sprites["battlebg"].x+=20
      @sprites["battlebg"].y-=10
      @sprites["battlebg"].zoom_x-=0.1
      @sprites["battlebg"].zoom_y-=0.1
      @sprites["playerbase"].x+=60
      @sprites["playerbase"].y-=30
      @sprites["playerbase"].zoom_x-=0.1
      @sprites["playerbase"].zoom_y-=0.1
      animateBattleSprites(true)
      Graphics.update
    end
    #################
    # Play cry for wild Pokémon
    if !@battle.opponent
      pbPlayCry(@battle.party2[0])
      pbPlayCry(@battle.party2[1]) if @battle.doublebattle
    end
    if @battle.opponent
      frames1=0
      frames2=0
      frames1=@sprites["trainer"].totalFrames if @sprites["trainer"]
      frames2=@sprites["trainer2"].totalFrames if @sprites["trainer2"]
      if frames1  >  frames2
        maxframes=frames1
      else
        maxframes=frames2
      end
      for i in 1...maxframes
        @sprites["trainer"].update if @sprites["trainer"] && i < frames1
        @sprites["trainer2"].update if @sprites["trainer2"] && i < frames2
        pbGraphicsUpdate
        animateBattleSprites(true)
      end
    else
      @sprites["battlebox1"].x=-264-10
      @sprites["battlebox1"].y=24
      @sprites["battlebox1"].appear
      if @battle.party2.length==2
        @sprites["battlebox1"].y=60
        @sprites["battlebox3"].x=-264-8
        @sprites["battlebox3"].y=8
        @sprites["battlebox3"].appear
      end
      10.times do
        pbGraphicsUpdate
        pbInputUpdate
        if !USENEWUI
          @sprites["battlebox1"].update
        else
          @sprites["battlebox1"].x+=26
        end
        @sprites["pokemon1"].tone.red+=12.8 if @sprites["pokemon1"].tone.red < 0
        @sprites["pokemon1"].tone.blue+=12.8 if @sprites["pokemon1"].tone.blue < 0
        @sprites["pokemon1"].tone.green+=12.8 if @sprites["pokemon1"].tone.green < 0
        @sprites["pokemon1"].tone.gray+=12.8 if @sprites["pokemon1"].tone.gray < 0
        if @battle.party2.length==2 
          if !USENEWUI
            @sprites["battlebox1"].update
          else
            @sprites["battlebox3"].x+=26
          end
          @sprites["pokemon3"].tone.red+=12.8 if @sprites["pokemon3"].tone.red < 0
          @sprites["pokemon3"].tone.blue+=12.8 if @sprites["pokemon3"].tone.blue < 0
          @sprites["pokemon3"].tone.green+=12.8 if @sprites["pokemon3"].tone.green < 0
          @sprites["pokemon3"].tone.gray+=12.8 if @sprites["pokemon3"].tone.gray < 0
        end
        animateBattleSprites
      end
      # Show shiny animation for wild Pokémon
      if @battle.party2[0].isShiny? && @battle.battlescene
        pbCommonAnimation("Shiny",@battle.battlers[1],nil)
      end
      if @battle.party2.length==2
        if @battle.party2[1].isShiny? && @battle.battlescene
          pbCommonAnimation("Shiny",@battle.battlers[3],nil)
        end
      end
    end
  end
  #=============================================================================
  #  Additional changes to opponent's sprites
  #=============================================================================
  alias pbShowOpponent_old pbShowOpponent
  def pbShowOpponent(index=0)
    if @battle.opponent
      if @battle.opponent.is_a?(Array)
        trainerfile=pbTrainerSpriteFile(@battle.opponent[index].trainertype)
      else
        trainerfile=pbTrainerSpriteFile(@battle.opponent.trainertype)
      end
    else
      trainerfile="Graphics/Characters/trfront"
    end
    @sprites["battlebox0"].visible=false if @sprites["battlebox0"]
    @sprites["battlebox1"].visible=false if @sprites["battlebox1"]
    @sprites["battlebox2"].visible=false if @sprites["battlebox2"]
    @sprites["battlebox3"].visible=false if @sprites["battlebox3"]
    
    @sprites["opponent"]=DynamicTrainerSprite.new(false,-1,@viewport)
    @sprites["opponent"].setTrainerBitmap(trainerfile)
    @sprites["opponent"].toLastFrame
    @sprites["opponent"].lock
    @sprites["opponent"].z=16
    @sprites["opponent"].x=@sprites["enemybase"].x+120
    @sprites["opponent"].y=@sprites["enemybase"].y+50
    @sprites["opponent"].opacity=0
    20.times do
      moveEntireScene(-3,-2)
      @sprites["opponent"].opacity+=12.8
      @sprites["opponent"].x-=4
      @sprites["opponent"].y-=2
      animateBattleSprites(true)
      pbGraphicsUpdate
      pbInputUpdate
    end
  end  
  alias pbHideOpponent_old pbHideOpponent
  def pbHideOpponent(showboxes=false)
    20.times do
      moveEntireScene(+3,+2)
      @sprites["opponent"].opacity-=12.8
      @sprites["opponent"].x+=4
      @sprites["opponent"].y+=2
      animateBattleSprites(true)
      pbGraphicsUpdate
      pbInputUpdate
    end
    if showboxes
      @sprites["battlebox0"].visible=true if @sprites["battlebox0"]
      @sprites["battlebox1"].visible=true if @sprites["battlebox1"]
      @sprites["battlebox2"].visible=true if @sprites["battlebox2"]
      @sprites["battlebox3"].visible=true if @sprites["battlebox3"]
    end
    @sprites["opponent"].dispose
  end  
  alias pbCommandMenu_old pbCommandMenu
  def pbCommandMenu(index)
    @orgPosX=[@sprites["battlebg"].x,@sprites["enemybase"].x,@sprites["playerbase"].x] if @orgPosX.nil?
    @orgPosY=[@sprites["battlebg"].y,@sprites["enemybase"].y,@sprites["playerbase"].y] if @orgPosY.nil?
    @idleTimer=0 if @idleTimer < 0
    if !@battle.doublebattle && @battle.opponent && @battle.midspeech!="" && !@battle.midspeech_done
      speech=@battle.midspeech
      pokemon=@battle.battlers[1]
      if @battle.party2.length > 1
        val=@battle.pbPokemonCount(@battle.party2)
        canspeak=(val==1) ? true : false
      else
        canspeak=(pokemon.hp < pokemon.totalhp*0.5) ? true : false
      end
      if canspeak
        pbShowOpponent
        @battle.pbDisplayPaused(speech)
        pbHideOpponent(true)
        @battle.midspeech_done=true
      end
    end
    pbCommandMenu_old(index)
  end
  #=============================================================================
  #  New methods of displaying the pbRecall animation
  #=============================================================================
  alias pbRecall_old pbRecall
  def pbRecall(battlerindex)
    pbSEPlay("recall")
    zoom=@sprites["pokemon#{battlerindex}"].zoom_x/20.0
    20.times do
      @sprites["pokemon#{battlerindex}"].tone.red+=25.5
      @sprites["pokemon#{battlerindex}"].tone.green+=25.5
      @sprites["pokemon#{battlerindex}"].tone.blue+=25.5
      if battlerindex%2==0
        @sprites["battlebox#{battlerindex}"].x+=26
      else
        @sprites["battlebox#{battlerindex}"].x-=26
      end
      @sprites["battlebox#{battlerindex}"].opacity-=25.5
      @sprites["pokemon#{battlerindex}"].zoom_x-=zoom
      @sprites["pokemon#{battlerindex}"].zoom_y-=zoom
      animateBattleSprites
      Graphics.update
    end
    @sprites["pokemon#{battlerindex}"].visible=false
  end
  #=============================================================================
  #  New Pokemon damage animations
  #=============================================================================
  alias pbDamageAnimation_old pbDamageAnimation
  def pbDamageAnimation(pkmn,effectiveness)
    pkmnsprite=@sprites["pokemon#{pkmn.index}"]
    sprite=@sprites["battlebox#{pkmn.index}"]
    oldvisible=sprite.visible
    sprite.selected=2
    @briefmessage=false
    6.times do
      animateBattleSprites
      pbGraphicsUpdate
      pbInputUpdate
    end
    case effectiveness
      when 0
        pbSEPlay("normaldamage")
      when 1
        pbSEPlay("notverydamage")
      when 2
        pbSEPlay("superdamage")
    end
    8.times do
      pkmnsprite.visible=!pkmnsprite.visible
      4.times do
        animateBattleSprites
        pbGraphicsUpdate
        pbInputUpdate
        sprite.update
      end
    end
    sprite.selected=0
    sprite.visible=oldvisible
  end
  #=============================================================================
  #  New methods of displaying the pbFainted animation
  #=============================================================================
  alias pbFainted_old pbFainted
  def pbFainted(pkmn)
    battlerindex=pkmn.index
    frames=pbCryFrameLength(pkmn.pokemon)
    pbPlayCry(pkmn.pokemon)
    frames.times do
      animateBattleSprites
      pbGraphicsUpdate
      pbInputUpdate
    end
    pbSEPlay("faint")
    zoom=@sprites["pokemon#{battlerindex}"].zoom_x/(20.0*2)
    @sprites["pokemon#{battlerindex}"].showshadow=false
    20.times do
      @sprites["pokemon#{battlerindex}"].y+=1
      @sprites["pokemon#{battlerindex}"].opacity-=12.8
      @sprites["battlebox#{battlerindex}"].opacity-=25.5
      animateBattleSprites
      Graphics.update
    end
  end
  #=============================================================================
  #  Allow for sprite animation during Battlebox HP changes
  #=============================================================================
  alias pbHPChanged_old pbHPChanged
  def pbHPChanged(pkmn,oldhp,anim=false)
    @briefmessage=false
    hpchange=pkmn.hp-oldhp
    if hpchange < 0
      hpchange=-hpchange
      PBDebug.log("[#{pkmn.pbThis} lost #{hpchange} HP, now has #{pkmn.hp} HP]") if $INTERNAL
    else
      PBDebug.log("[#{pkmn.pbThis} gained #{hpchange} HP, now has #{pkmn.hp} HP]") if $INTERNAL
    end
    if anim && @battle.battlescene
      if pkmn.hp > oldhp
        pbCommonAnimation("HealthUp",pkmn,nil)
      elsif pkmn.hp < oldhp
        pbCommonAnimation("HealthDown",pkmn,nil)
      end
    end
    sprite=@sprites["battlebox#{pkmn.index}"]
    sprite.animateHP(oldhp,pkmn.hp)
    while sprite.animatingHP
      animateBattleSprites
      pbGraphicsUpdate
      pbInputUpdate
      sprite.update
    end
  end
  #=============================================================================
  #  Allow for sprite animation during Battlebox EXP changes
  #=============================================================================
  alias pbEXPBar_old pbEXPBar
  def pbEXPBar(pokemon,battler,startexp,endexp,tempexp1,tempexp2)
    if battler
      @sprites["battlebox#{battler.index}"].refreshExpLevel
      exprange=(endexp-startexp)
      startexplevel=0
      endexplevel=0
      if exprange!=0
        startexplevel=(tempexp1-startexp)*PokeBattle_SceneConstants::EXPGAUGESIZE/exprange
        endexplevel=(tempexp2-startexp)*PokeBattle_SceneConstants::EXPGAUGESIZE/exprange
      end
      @sprites["battlebox#{battler.index}"].animateEXP(startexplevel,endexplevel)
      while @sprites["battlebox#{battler.index}"].animatingEXP
        animateBattleSprites
        pbGraphicsUpdate
        pbInputUpdate
        @sprites["battlebox#{battler.index}"].update
      end
    end
  end
  #=============================================================================
  #  For in battle sprite changes
  #=============================================================================
  alias pbChangePokemon_old pbChangePokemon
  def pbChangePokemon(attacker,pokemon)
    pkmn=@sprites["pokemon#{attacker.index}"]
    back=!@battle.pbIsOpposing?(attacker.index)
    pkmn.setPokemonBitmap(pokemon,back)
  end
  #=============================================================================
  # Shows the player's Poké Ball being thrown to capture a Pokémon.
  #=============================================================================
  alias pbThrowAndDeflect_old pbThrowAndDeflect
  def pbThrowAndDeflect(ball,targetBattler)
  end
  
  alias pokeballThrow_old pokeballThrow
  def pokeballThrow(ball,shakes,targetBattler,scene,battler,burst=-1,showplayer=false)
    balltype=pbGetBallType(ball)
    ballframe=0
    # sprites
    spritePoke=@sprites["pokemon#{targetBattler}"]
    @sprites["captureball"]=Sprite.new(@viewport)
    @sprites["captureball"].bitmap=BitmapCache.load_bitmap("Graphics/Pictures/pokeballs")
    balltype=0 if balltype*41 >= @sprites["captureball"].bitmap.width
    @sprites["captureball"].src_rect.set(balltype*41,ballframe*40,41,40)
    @sprites["captureball"].ox=20
    @sprites["captureball"].oy=20
    @sprites["captureball"].z=32
    @sprites["captureball"].zoom_x=4
    @sprites["captureball"].zoom_y=4
    @sprites["captureball"].visible=false
    pokeball=@sprites["captureball"]
    # position "camera"
    clearMessageWindow
    @sprites["battlebox0"].visible=false if @sprites["battlebox0"]
    @sprites["battlebox2"].visible=false if @sprites["battlebox2"]
    10.times do
      @sprites["enemybase"].x-=14
      @sprites["enemybase"].y+=6
      @sprites["enemybase"].zoom_x+=0.1
      @sprites["enemybase"].zoom_y+=0.1
      @sprites["battlebg"].x-=20
      @sprites["battlebg"].y+=6
      @sprites["battlebg"].zoom_x+=0.1
      @sprites["battlebg"].zoom_y+=0.1
      @sprites["playerbase"].x-=60
      @sprites["playerbase"].y+=30
      @sprites["playerbase"].zoom_x+=0.1
      @sprites["playerbase"].zoom_y+=0.1
      animateBattleSprites(true)
      pbGraphicsUpdate
    end
    # position pokeball
    pokeball.x=spritePoke.x-260
    pokeball.y=spritePoke.y-100
    pokeball.visible=true
    pbSEPlay("throw")
    20.times do
      ballframe+=1
      ballframe=0 if ballframe > 7
      pokeball.x+=13
      pokeball.y-=6
      pokeball.zoom_x-=0.1
      pokeball.zoom_y-=0.1
      pokeball.src_rect.set(balltype*41,ballframe*40,41,40)
      animateBattleSprites
      pbGraphicsUpdate
    end  
    19.times do
      ballframe+=1
      ballframe=0 if ballframe > 7
      pokeball.src_rect.set(balltype*41,ballframe*40,41,40)
      animateBattleSprites
      pbGraphicsUpdate
    end  
    for i in 0...4
      pokeball.src_rect.set(balltype*41,(7+i)*40,41,40)
      animateBattleSprites
      pbGraphicsUpdate
    end
    pbSEPlay("recall")
    spritePoke.showshadow=false
    20.times do
      spritePoke.zoom_x-=0.1
      spritePoke.zoom_y-=0.1
      spritePoke.tone.red+=25.5
      spritePoke.tone.green+=25.5
      spritePoke.tone.blue+=25.5
      spritePoke.y-=11
      pbGraphicsUpdate
      animateBattleSprites
    end
    spritePoke.y+=220
    # Burst animation here
    if burst >=0 && scene.battle.battlescene
      scene.pbCommonAnimation("BallBurst#{burst}",battler,nil)
    end
    pokeball.src_rect.y-=40
    pbGraphicsUpdate
    animateBattleSprites
    pokeball.src_rect.y=0
    pbGraphicsUpdate
    animateBattleSprites
    #################
    pbSEPlay("jumptoball")
    20.times do
      pokeball.y+=11
      pbGraphicsUpdate
      animateBattleSprites
    end
    pbSEPlay("balldrop")
    inc=8
    2.times do
      10.times do
        pokeball.y-=inc
        pbGraphicsUpdate
        animateBattleSprites
      end
      10.times do
        pokeball.y+=inc
        pbGraphicsUpdate
        animateBattleSprites
      end
      inc/=2
      pbSEPlay("balldrop")
    end
    [shakes,3].min.times do
      pbWait(40)
      pbSEPlay("ballshake")
      pokeball.src_rect.y=11*40
      pbGraphicsUpdate
      animateBattleSprites
      2.times do
        pokeball.src_rect.y+=40
        pbGraphicsUpdate
        animateBattleSprites
      end
      2.times do
        pokeball.src_rect.y-=40
        pbGraphicsUpdate
        animateBattleSprites
      end
      pokeball.src_rect.y=14*40
      pbGraphicsUpdate
      animateBattleSprites
      2.times do
        pokeball.src_rect.y+=40
        pbGraphicsUpdate
        animateBattleSprites
      end
      2.times do
        pokeball.src_rect.y-=40
        pbGraphicsUpdate
        animateBattleSprites
      end
      pokeball.src_rect.y=0
      pbGraphicsUpdate
      animateBattleSprites
    end
    if shakes < 4
      pokeball.src_rect.y=9*40
      pbGraphicsUpdate
      pokeball.src_rect.y+=40
      pbGraphicsUpdate
      pbSEPlay("recall")
      spritePoke.showshadow=true
      20.times do
        pokeball.opacity-=25.5
        spritePoke.zoom_x+=0.1
        spritePoke.zoom_y+=0.1
        spritePoke.tone.red-=12.8
        spritePoke.tone.green-=12.8
        spritePoke.tone.blue-=12.8
        animateBattleSprites
        pbGraphicsUpdate
      end
      @sprites["battlebox0"].visible=true if @sprites["battlebox0"]
      @sprites["battlebox2"].visible=true if @sprites["battlebox2"]
      10.times do
        @sprites["enemybase"].x+=14
        @sprites["enemybase"].y-=6
        @sprites["enemybase"].zoom_x-=0.1
        @sprites["enemybase"].zoom_y-=0.1
        @sprites["battlebg"].x+=20
        @sprites["battlebg"].y-=6
        @sprites["battlebg"].zoom_x-=0.1
        @sprites["battlebg"].zoom_y-=0.1
        @sprites["playerbase"].x+=60
        @sprites["playerbase"].y-=30
        @sprites["playerbase"].zoom_x-=0.1
        @sprites["playerbase"].zoom_y-=0.1
        animateBattleSprites(true)
        pbGraphicsUpdate
      end
    else
      spritePoke.visible=false
      pokeball.tone=Tone.new(150,150,150)
      pbSEPlay("balldrop",100,150)
      10.times do
        pokeball.tone.red-=15
        pokeball.tone.green-=15
        pokeball.tone.blue-=15
        pbGraphicsUpdate
        animateBattleSprites
      end
      if @battle.opponent
        spritePoke.visible=false
        5.times do
          pokeball.opacity-=51
          pbGraphicsUpdate
          animateBattleSprites
        end
        10.times do
          @sprites["enemybase"].x+=14
          @sprites["enemybase"].y-=6
          @sprites["enemybase"].zoom_x-=0.1
          @sprites["enemybase"].zoom_y-=0.1
          @sprites["battlebg"].x+=20
          @sprites["battlebg"].y-=6
          @sprites["battlebg"].zoom_x-=0.1
          @sprites["battlebg"].zoom_y-=0.1
          @sprites["playerbase"].x+=60
          @sprites["playerbase"].y-=30
          @sprites["playerbase"].zoom_x-=0.1
          @sprites["playerbase"].zoom_y-=0.1
          animateBattleSprites(true)
          pbGraphicsUpdate
        end
      end
    end
  end
  #=============================================================================
  #  New methods of displaying TrainerSendOut animations
  #=============================================================================
  alias pbTrainerSendOut_old pbTrainerSendOut
  def pbTrainerSendOut(battlerindex,pkmn)
    metrics=load_data("Data/metrics.dat")
    
    if @firstsendout
      # First time opponent sends out their Pokemon
      @sprites["battlebox1"].x=-264-10
      @sprites["battlebox1"].y=24
      @sprites["battlebox1"].appear
      if @sprites["battlebox3"]
        @sprites["battlebox1"].y=60
        @sprites["battlebox3"].x=-264-8
        @sprites["battlebox3"].y=8
        @sprites["battlebox3"].appear
      end
      
      @ballframe=0
      @sprites["pokeball1"]=Sprite.new(@viewport)
      @sprites["pokeball1"].bitmap=BitmapCache.load_bitmap("Graphics/Pictures/pokeballs")
      @sprites["pokeball1"].src_rect.set(0,@ballframe*40,41,40)
      @sprites["pokeball1"].ox=20
      @sprites["pokeball1"].oy=20
      @sprites["pokeball1"].zoom_x=0.1
      @sprites["pokeball1"].zoom_y=0.1
      @sprites["pokeball1"].z=30
      @sprites["pokeball1"].opacity=0
      if @sprites["pokemon3"]
        @sprites["pokeball3"]=Sprite.new(@viewport)
        @sprites["pokeball3"].bitmap=BitmapCache.load_bitmap("Graphics/Pictures/pokeballs")
        @sprites["pokeball3"].src_rect.set(0,@ballframe*40,41,40)
        @sprites["pokeball3"].ox=20
        @sprites["pokeball3"].oy=20
        @sprites["pokeball3"].zoom_x=0.1
        @sprites["pokeball3"].zoom_y=0.1
        @sprites["pokeball3"].z=30
        @sprites["pokeball3"].opacity=0
      end
    
      @sprites["pokemon1"].setPokemonBitmap(@battle.battlers[1].pokemon,false)
      @sprites["pokemon1"].showshadow=false
      orgcord=@sprites["pokemon1"].oy
      @sprites["pokemon1"].oy=@sprites["pokemon1"].height/2
      @sprites["pokemon1"].tone=Tone.new(255,255,255)
      @sprites["pokemon1"].opacity=255
      @sprites["pokemon1"].visible=false
      if @sprites["pokemon3"]
        @sprites["pokemon3"].setPokemonBitmap(@battle.battlers[3].pokemon,false)
        @sprites["pokemon3"].showshadow=false
        orgcord2=@sprites["pokemon3"].oy
        @sprites["pokemon3"].oy=@sprites["pokemon3"].height/2
        @sprites["pokemon3"].tone=Tone.new(255,255,255)
        @sprites["pokemon3"].opacity=255
        @sprites["pokemon3"].visible=false
      end
      pbSEPlay("throw")
      @sprites["pokeball1"].x=@sprites["pokemon1"].x
      @sprites["pokeball1"].y=@sprites["enemybase"].y-60-(orgcord-@sprites["pokemon1"].oy)
      if @sprites["pokeball3"]   
        @sprites["pokeball3"].x=@sprites["pokemon3"].x
        @sprites["pokeball3"].y=@sprites["enemybase"].y-60-(orgcord2-@sprites["pokemon3"].oy)
      end
      30.times do
        @ballframe+=1
        @ballframe=0 if @ballframe > 7
        @sprites["trainer"].zoom_x-=0.02
        @sprites["trainer"].zoom_y-=0.02
        @sprites["trainer"].x+=1
        @sprites["trainer"].y-=2
        @sprites["trainer"].opacity-=12.8
        if @sprites["trainer2"]
          @sprites["trainer2"].zoom_x-=0.02
          @sprites["trainer2"].zoom_y-=0.02
          @sprites["trainer2"].x+=2
          @sprites["trainer2"].y-=2
          @sprites["trainer2"].opacity-=12.8
        end
        @sprites["pokeball1"].src_rect.set(0,@ballframe*40,41,40)
        @sprites["pokeball1"].opacity+=25.5
        if @sprites["pokeball3"]
          @sprites["pokeball3"].opacity+=25.5
          @sprites["pokeball3"].src_rect.set(0,@ballframe*40,41,40)
        end
        animateBattleSprites
        Graphics.update
      end
      @sprites["pokeball1"].visible=false
      @sprites["pokeball3"].visible=false if @sprites["pokeball3"]
      @sprites["pokemon1"].visible=true
      @sprites["pokemon1"].y-=60+(orgcord-@sprites["pokemon1"].oy)
      @sprites["pokemon1"].zoom_x=0
      @sprites["pokemon1"].zoom_y=0
      if @sprites["pokemon3"]
        @sprites["pokemon3"].visible=true
        @sprites["pokemon3"].y-=60+(orgcord2-@sprites["pokemon3"].oy)
        @sprites["pokemon3"].zoom_x=0
        @sprites["pokemon3"].zoom_y=0
      end
      pbSEPlay("recall")
      clearMessageWindow
      12.times do
        @sprites["pokemon1"].zoom_x+=0.1/1.75
        @sprites["pokemon1"].zoom_y+=0.1/1.75
        if !USENEWUI
          @sprites["battlebox1"].update
        else
          @sprites["battlebox1"].x+=22
        end
        if @sprites["pokemon3"]
          if !USENEWUI
            @sprites["battlebox3"].update
          else
            @sprites["battlebox3"].x+=22
          end
          @sprites["pokemon3"].zoom_x+=0.1*1.75
          @sprites["pokemon3"].zoom_y+=0.1*1.75
        end
        animateBattleSprites
        Graphics.update
      end
      2.times do
        @sprites["pokemon1"].zoom_x-=0.1/1.75
        @sprites["pokemon1"].zoom_y-=0.1/1.75
        @sprites["battlebox1"].x-=2 if USENEWUI
        if @sprites["pokemon3"]
          @sprites["battlebox3"].x-=2 if USENEWUI
          @sprites["pokemon3"].zoom_x-=0.1*1.75
          @sprites["pokemon3"].zoom_y-=0.1*1.75
        end
        animateBattleSprites
        Graphics.update
      end
      pbPlayCry(@battle.battlers[1].pokemon ? @battle.battlers[1].pokemon : @battle.battlers[1].species)
      pbPlayCry(@battle.battlers[3].pokemon ? @battle.battlers[3].pokemon : @battle.battlers[3].species) if @sprites["pokemon3"]
      5.times do
        @sprites["pokemon1"].tone.red-=51
        @sprites["pokemon1"].tone.green-=51
        @sprites["pokemon1"].tone.blue-=51
        if @sprites["pokemon3"]
          @sprites["pokemon3"].tone.red-=51
          @sprites["pokemon3"].tone.green-=51
          @sprites["pokemon3"].tone.blue-=51
        end
        animateBattleSprites
        Graphics.update
      end
      frame=0
      @sprites["pokemon1"].y+=orgcord-@sprites["pokemon1"].oy
      @sprites["pokemon1"].oy=orgcord
      @sprites["pokemon3"].y+=orgcord2-@sprites["pokemon3"].oy if @sprites["pokemon3"]
      @sprites["pokemon3"].oy=orgcord2 if @sprites["pokemon3"]
      10.times do
        frame+=1
        @sprites["pokemon1"].y+=6
        @sprites["pokemon3"].y+=6 if @sprites["pokemon3"]
        animateBattleSprites
        Graphics.update
      end
      @sprites["pokemon1"].showshadow=true
      @sprites["pokemon3"].showshadow=true if @sprites["pokemon3"]
      alt1=metrics[2][@battle.battlers[1].pokemon.species]
      alt2=1
      alt2=metrics[2][@battle.battlers[3].pokemon.species] if @sprites["pokemon3"]
      pbSEPlay("drop") if alt1 < 1 or alt2 < 1
      3.times do
        moveEntireScene(0,2)# if alt1 < 1 or alt2 < 1
        animateBattleSprites(true)
        Graphics.update
      end
      3.times do
        moveEntireScene(0,-2)# if alt1 < 1 or alt2 < 1
        animateBattleSprites(true)
        Graphics.update
      end
      if @battle.battlers[1].pokemon.isShiny?
        pbCommonAnimation("Shiny",@battle.battlers[1],nil)
      end
      if @battle.doublebattle && @battle.battlers[3].pokemon.isShiny?
        pbCommonAnimation("Shiny",@battle.battlers[3],nil)
      end
      return
    end
    # Every other time the Pokemon is sent out
    @sprites["battlebox#{battlerindex}"].x=-264-10
    @sprites["battlebox#{battlerindex}"].appear
    
    @ballframe=0
    @sprites["pokeball1"]=Sprite.new(@viewport)
    @sprites["pokeball1"].bitmap=BitmapCache.load_bitmap("Graphics/Pictures/pokeballs")
    @sprites["pokeball1"].src_rect.set(0,@ballframe*40,41,40)
    @sprites["pokeball1"].ox=20
    @sprites["pokeball1"].oy=20
    @sprites["pokeball1"].zoom_x=0.1
    @sprites["pokeball1"].zoom_y=0.1
    @sprites["pokeball1"].z=30
    @sprites["pokeball1"].opacity=0
  
    @sprites["pokemon#{battlerindex}"].setPokemonBitmap(@battle.battlers[battlerindex].pokemon,false)
    @sprites["pokemon#{battlerindex}"].showshadow=false
    orgcord=@sprites["pokemon#{battlerindex}"].oy
    @sprites["pokemon#{battlerindex}"].oy=@sprites["pokemon#{battlerindex}"].height/2
    @sprites["pokemon#{battlerindex}"].tone=Tone.new(255,255,255)
    @sprites["pokemon#{battlerindex}"].opacity=255
    @sprites["pokemon#{battlerindex}"].visible=false
    pbSEPlay("throw")
    @sprites["pokeball1"].x=@sprites["pokemon#{battlerindex}"].x
    @sprites["pokeball1"].y=@sprites["enemybase"].y-60-(orgcord-@sprites["pokemon#{battlerindex}"].oy)
    30.times do
      @ballframe+=1
      @ballframe=0 if @ballframe > 7
      @sprites["pokeball1"].src_rect.set(0,@ballframe*40,41,40)
      @sprites["pokeball1"].opacity+=25.5
      animateBattleSprites
      Graphics.update
    end
    @sprites["pokeball1"].visible=false
    @sprites["pokemon#{battlerindex}"].visible=true
    @sprites["pokemon#{battlerindex}"].y-=60+(orgcord-@sprites["pokemon#{battlerindex}"].oy)
    @sprites["pokemon#{battlerindex}"].zoom_x=0
    @sprites["pokemon#{battlerindex}"].zoom_y=0
    pbSEPlay("recall")
    clearMessageWindow
    12.times do
      if !USENEWUI
        @sprites["battlebox#{battlerindex}"].update
      else
        @sprites["battlebox#{battlerindex}"].x+=22
      end
      @sprites["pokemon#{battlerindex}"].zoom_x+=0.1
      @sprites["pokemon#{battlerindex}"].zoom_y+=0.1
      animateBattleSprites
      Graphics.update
    end
    2.times do
      @sprites["battlebox#{battlerindex}"].x-=2 if USENEWUI
      @sprites["pokemon#{battlerindex}"].zoom_x-=0.1
      @sprites["pokemon#{battlerindex}"].zoom_y-=0.1
      animateBattleSprites
      Graphics.update
    end
    pbPlayCry(@battle.battlers[battlerindex].pokemon ? @battle.battlers[battlerindex].pokemon : @battle.battlers[battlerindex].species)
    5.times do
      @sprites["pokemon#{battlerindex}"].tone.red-=51
      @sprites["pokemon#{battlerindex}"].tone.green-=51
      @sprites["pokemon#{battlerindex}"].tone.blue-=51
      animateBattleSprites
      Graphics.update
    end
    frame=0
    @sprites["pokemon#{battlerindex}"].y+=orgcord-@sprites["pokemon#{battlerindex}"].oy
    @sprites["pokemon#{battlerindex}"].oy=orgcord
    10.times do
      frame+=1
      @sprites["pokemon#{battlerindex}"].y+=6
      animateBattleSprites
      Graphics.update
    end
    @sprites["pokemon#{battlerindex}"].showshadow=true
    alt1=metrics[2][@battle.battlers[1].pokemon.species]
    pbSEPlay("drop") if alt1 < 1
    3.times do
      moveEntireScene(0,2)# if alt1 < 1
      animateBattleSprites(true)
      Graphics.update
    end
    3.times do
      moveEntireScene(0,-2)# if alt1 < 1
      animateBattleSprites(true)
      Graphics.update
    end
    if @battle.battlers[battlerindex].pokemon.isShiny?
      pbCommonAnimation("Shiny",@battle.battlers[battlerindex],nil)
    end
  end
  #=============================================================================
  #  New methods of displaying PokemonSendOut animations
  #=============================================================================
  alias pbSendOut_old pbSendOut
  def pbSendOut(battlerindex,pkmn) # Player sending out Pokémon
    metrics=load_data("Data/metrics.dat")
    
    if @firstsendout
      # First time the Pokemon is sent out
      @sprites["battlebox0"].x=Graphics.width+10
      @sprites["battlebox0"].y=204
      @sprites["battlebox0"].appear
      if @sprites["battlebox2"]
        @sprites["battlebox0"].y=180
        @sprites["battlebox2"].x=Graphics.width+8
        @sprites["battlebox2"].y=232
        @sprites["battlebox2"].appear
      end
      
      @balltype=@battle.battlers[0].pokemon.ballused
      @frames=0
      @ballframe=0
      @sprites["pokeball0"]=Sprite.new(@viewport)
      @sprites["pokeball0"].bitmap=BitmapCache.load_bitmap("Graphics/Pictures/pokeballs")
      @balltype=0 if @balltype*41 >= @sprites["pokeball0"].bitmap.width
      @sprites["pokeball0"].src_rect.set(@balltype*41,@ballframe*40,41,40)
      @sprites["pokeball0"].ox=20
      @sprites["pokeball0"].oy=20
      @sprites["pokeball0"].zoom_x=0.1
      @sprites["pokeball0"].zoom_y=0.1
      @sprites["pokeball0"].z=30
      @sprites["pokeball0"].opacity=0
      if @sprites["pokemon2"]
        @balltype2=@battle.battlers[2].pokemon.ballused
        @sprites["pokeball2"]=Sprite.new(@viewport)
        @sprites["pokeball2"].bitmap=BitmapCache.load_bitmap("Graphics/Pictures/pokeballs")
        @balltype2=0 if @balltype2*41 >= @sprites["pokeball2"].bitmap.width
        @sprites["pokeball2"].src_rect.set(@balltype2*41,@ballframe*40,41,40)
        @sprites["pokeball2"].ox=20
        @sprites["pokeball2"].oy=20
        @sprites["pokeball2"].zoom_x=0.1
        @sprites["pokeball2"].zoom_y=0.1
        @sprites["pokeball2"].z=30
        @sprites["pokeball2"].opacity=0
      end
    
      @sprites["pokemon0"].setPokemonBitmap(@battle.battlers[0].pokemon,true)
      @sprites["pokemon0"].showshadow=false
      orgcord=@sprites["pokemon0"].oy
      @sprites["pokemon0"].oy=@sprites["pokemon0"].height/2
      @sprites["pokemon0"].tone=Tone.new(255,255,255)
      @sprites["pokemon0"].opacity=255
      @sprites["pokemon0"].visible=false
      if @sprites["pokemon2"]
        @sprites["pokemon2"].setPokemonBitmap(@battle.battlers[2].pokemon,true)
        @sprites["pokemon2"].showshadow=false
        orgcord2=@sprites["pokemon2"].oy
        @sprites["pokemon2"].oy=@sprites["pokemon2"].height/2
        @sprites["pokemon2"].tone=Tone.new(255,255,255)
        @sprites["pokemon2"].opacity=255
        @sprites["pokemon2"].visible=false
      end
    
      @sprites["player"].x=40
      @sprites["player"].y=Graphics.height-@sprites["player"].bitmap.height
      @sprites["player"].z=30
      @sprites["player"].opacity=0
      @sprites["player"].src_rect.set(0,0,@sprites["player"].bitmap.width/4,@sprites["player"].bitmap.height)
      if @sprites["playerB"]
        @sprites["playerB"].x=140
        @sprites["playerB"].y=Graphics.height-@sprites["playerB"].bitmap.height
        @sprites["playerB"].z=30
        @sprites["playerB"].opacity=0
        @sprites["playerB"].src_rect.set(0,0,@sprites["playerB"].bitmap.width/4,@sprites["playerB"].bitmap.height)
      end
    
      10.times do
        @sprites["enemybase"].x+=1
        @sprites["enemybase"].y-=0
        @sprites["enemybase"].zoom_x-=0.05
        @sprites["enemybase"].zoom_y-=0.05
        @sprites["battlebg"].x-=2
        @sprites["battlebg"].y-=1
        @sprites["battlebg"].zoom_x-=0.045
        @sprites["battlebg"].zoom_y-=0.045
        @sprites["playerbase"].x+=14
        @sprites["playerbase"].y-=9
        @sprites["playerbase"].zoom_x-=0.05
        @sprites["playerbase"].zoom_y-=0.05
        @sprites["player"].opacity+=25.5
        @sprites["playerB"].opacity+=25.5 if @sprites["playerB"]
        animateBattleSprites(true)
        Graphics.update
      end
      34.times do
        animateBattleSprites(true)
        Graphics.update
      end
      @sprites["player"].src_rect.x+=@sprites["player"].bitmap.width/4
      @sprites["playerB"].src_rect.x+=@sprites["playerB"].bitmap.width/4 if @sprites["playerB"]
      6.times do
        @sprites["player"].x-=2
        @sprites["playerB"].x-=2 if @sprites["playerB"]
        animateBattleSprites(true)
        Graphics.update
      end
      6.times do
        animateBattleSprites(true)
        Graphics.update
      end
      2.times do
        @sprites["player"].src_rect.x+=@sprites["player"].bitmap.width/4
        @sprites["playerB"].src_rect.x+=@sprites["playerB"].bitmap.width/4 if @sprites["playerB"]
        2.times do
          @sprites["player"].x+=3
          @sprites["playerB"].x+=3 if @sprites["playerB"]
          animateBattleSprites(true)
          Graphics.update
        end
      end
      pbSEPlay("throw")
      @sprites["pokeball0"].x=@sprites["pokemon0"].x-60
      @sprites["pokeball0"].y=@sprites["playerbase"].y-84-(orgcord-@sprites["pokemon0"].oy)
      if @sprites["pokeball2"]   
        @sprites["pokeball2"].x=@sprites["pokemon2"].x-60
        @sprites["pokeball2"].y=@sprites["playerbase"].y-84-(orgcord2-@sprites["pokemon2"].oy)
      end
      12.times do
        @ballframe+=1
        @ballframe=0 if @ballframe > 7
        @sprites["pokeball0"].src_rect.set(@balltype*41,@ballframe*40,41,40)
        @sprites["pokeball0"].x+=3
        @sprites["pokeball0"].y-=3
        @sprites["pokeball0"].opacity+=42
        if @sprites["pokeball2"]
          @sprites["pokeball2"].src_rect.set(@balltype2*41,@ballframe*40,41,40)
          @sprites["pokeball2"].x+=3
          @sprites["pokeball2"].y-=3
          @sprites["pokeball2"].opacity+=42
        end
        animateBattleSprites
        Graphics.update
      end
      8.times do
        @ballframe+=1
        @ballframe=0 if @ballframe > 7
        @sprites["pokeball0"].src_rect.set(@balltype*41,@ballframe*40,41,40)
        @sprites["pokeball0"].x+=2
        @sprites["pokeball0"].y-=1
        if @sprites["pokeball2"]
          @sprites["pokeball2"].src_rect.set(@balltype2*41,@ballframe*40,41,40)
          @sprites["pokeball2"].x+=2
          @sprites["pokeball2"].y-=1
        end
        animateBattleSprites
        Graphics.update
      end
      8.times do
        @ballframe+=1
        @ballframe=0 if @ballframe > 7
        @sprites["pokeball0"].src_rect.set(@balltype*41,@ballframe*40,41,40)
        @sprites["pokeball0"].x+=1
        @sprites["pokeball0"].y+=1
        if @sprites["pokeball2"]
          @sprites["pokeball2"].src_rect.set(@balltype2*41,@ballframe*40,41,40)
          @sprites["pokeball2"].x+=1
          @sprites["pokeball2"].y+=1
        end
        animateBattleSprites
        Graphics.update
      end
      20.times do
        @ballframe+=1
        @ballframe=0 if @ballframe > 7
        @sprites["pokeball0"].src_rect.set(@balltype*41,@ballframe*40,41,40)
        @sprites["pokeball2"].src_rect.set(@balltype2*41,@ballframe*40,41,40) if @sprites["pokeball2"]
        animateBattleSprites
        Graphics.update
      end
      @sprites["pokeball0"].visible=false
      @sprites["pokeball2"].visible=false if @sprites["pokeball2"]
      @sprites["pokemon0"].visible=true
      @sprites["pokemon0"].y-=120+(orgcord-@sprites["pokemon0"].oy)
      @sprites["pokemon0"].zoom_x=0
      @sprites["pokemon0"].zoom_y=0
      if @sprites["pokemon2"]
        @sprites["pokemon2"].visible=true
        @sprites["pokemon2"].y-=120+(orgcord2-@sprites["pokemon2"].oy)
        @sprites["pokemon2"].zoom_x=0
        @sprites["pokemon2"].zoom_y=0
      end
      pbSEPlay("recall")
      clearMessageWindow
      12.times do
        @sprites["player"].opacity-=25.5
        @sprites["playerB"].opacity-=25.5 if @sprites["playerB"]
        @sprites["pokemon0"].zoom_x+=0.1/1.5
        @sprites["pokemon0"].zoom_y+=0.1/1.5
        if !USENEWUI
          @sprites["battlebox0"].update
          @sprites["battlebox2"].update if @sprites["battlebox2"]
        else
          @sprites["battlebox0"].x-=22
          @sprites["battlebox2"].x-=22 if @sprites["battlebox2"]
        end
        if @sprites["pokemon2"]
          @sprites["pokemon2"].zoom_x+=0.1*1.5
          @sprites["pokemon2"].zoom_y+=0.1*1.5
        end
        animateBattleSprites
        Graphics.update
      end
      2.times do
        @sprites["pokemon0"].zoom_x-=0.1/1.5
        @sprites["pokemon0"].zoom_y-=0.1/1.5
        @sprites["battlebox0"].x+=2 if USENEWUI
        @sprites["battlebox2"].x+=2 if @sprites["battlebox2"] && USENEWUI
        if @sprites["pokemon2"]
          @sprites["pokemon2"].zoom_x-=0.1*1.5
          @sprites["pokemon2"].zoom_y-=0.1*1.5
        end
        animateBattleSprites
        Graphics.update
      end
      pbPlayCry(@battle.battlers[0].pokemon ? @battle.battlers[0].pokemon : @battle.battlers[0].species)
      pbPlayCry(@battle.battlers[2].pokemon ? @battle.battlers[2].pokemon : @battle.battlers[2].species) if @sprites["pokemon2"]
      5.times do
        @sprites["pokemon0"].tone.red-=51
        @sprites["pokemon0"].tone.green-=51
        @sprites["pokemon0"].tone.blue-=51
        if @sprites["pokemon2"]
          @sprites["pokemon2"].tone.red-=51
          @sprites["pokemon2"].tone.green-=51
          @sprites["pokemon2"].tone.blue-=51
        end
        animateBattleSprites
        Graphics.update
      end
      frame=0
      @sprites["pokemon0"].y+=orgcord-@sprites["pokemon0"].oy
      @sprites["pokemon0"].oy=orgcord
      @sprites["pokemon2"].y+=orgcord2-@sprites["pokemon2"].oy if @sprites["pokemon2"]
      @sprites["pokemon2"].oy=orgcord2 if @sprites["pokemon2"]
      10.times do
        frame+=1
        @sprites["pokemon0"].y+=12
        @sprites["pokemon2"].y+=12 if @sprites["pokemon2"]
        animateBattleSprites
        Graphics.update
      end
      @sprites["pokemon0"].showshadow=true
      @sprites["pokemon2"].showshadow=true if @sprites["pokemon2"]
      alt1=metrics[2][@battle.battlers[0].pokemon.species]
      alt2=1
      alt2=metrics[2][@battle.battlers[2].pokemon.species] if @sprites["pokemon2"]
      pbSEPlay("drop") if alt1 < 1 or alt2 < 1
      3.times do
        moveEntireScene(0,2)# if alt1 < 1 or alt2 < 1
        animateBattleSprites(true)
        Graphics.update
      end
      3.times do
        moveEntireScene(0,-2)# if alt1 < 1 or alt2 < 1
        animateBattleSprites(true)
        Graphics.update
      end
      if @battle.battlers[0].pokemon.isShiny?
        pbCommonAnimation("Shiny",@battle.battlers[0],nil)
      end
      if @battle.doublebattle && @battle.battlers[2].pokemon.isShiny?
        pbCommonAnimation("Shiny",@battle.battlers[2],nil)
      end
      10.times do
        @sprites["enemybase"].x-=1
        @sprites["enemybase"].y+=0
        @sprites["enemybase"].zoom_x+=0.05
        @sprites["enemybase"].zoom_y+=0.05
        @sprites["battlebg"].x+=2
        @sprites["battlebg"].y+=1
        @sprites["battlebg"].zoom_x+=0.045
        @sprites["battlebg"].zoom_y+=0.045
        @sprites["playerbase"].x-=14
        @sprites["playerbase"].y+=9
        @sprites["playerbase"].zoom_x+=0.05
        @sprites["playerbase"].zoom_y+=0.05
        animateBattleSprites(true)
        Graphics.update
      end
      @firstsendout=false
      return
    end
    # Every other time the Pokemon is sent out
    ext=12 if battlerindex==0
    ext=8 if battlerindex==2
    @sprites["battlebox#{battlerindex}"].x=Graphics.width+ext
    @sprites["battlebox#{battlerindex}"].appear
      
    @balltype=pkmn.ballused
    @frames=0
    @ballframe=0
    @sprites["pokeball0"]=Sprite.new(@viewport)
    @sprites["pokeball0"].bitmap=BitmapCache.load_bitmap("Graphics/Pictures/pokeballs")
    @balltype=0 if @balltype*41 >= @sprites["pokeball0"].bitmap.width
    @sprites["pokeball0"].src_rect.set(@balltype*41,@ballframe*40,41,40)
    @sprites["pokeball0"].ox=20
    @sprites["pokeball0"].oy=20
    @sprites["pokeball0"].zoom_x=1.5
    @sprites["pokeball0"].zoom_y=1.5
    @sprites["pokeball0"].z=30
    @sprites["pokeball0"].opacity=0
    if battlerindex%2==0
      @sprites["pokeball0"].z=24
    else
      @sprites["pokeball0"].z=14
    end
    
    @sprites["pokemon#{battlerindex}"].setPokemonBitmap(@battle.battlers[battlerindex].pokemon,true)
    @sprites["pokemon#{battlerindex}"].showshadow=false
    orgcord=@sprites["pokemon#{battlerindex}"].oy
    @sprites["pokemon#{battlerindex}"].oy=@sprites["pokemon#{battlerindex}"].height/2
    @sprites["pokemon#{battlerindex}"].tone=Tone.new(255,255,255)
    @sprites["pokemon#{battlerindex}"].opacity=255
    @sprites["pokemon#{battlerindex}"].visible=false
    
    20.times do
      animateBattleSprites(true)
      Graphics.update
    end
    pbSEPlay("throw")
    @sprites["pokeball0"].x=@sprites["pokemon#{battlerindex}"].x-60
    @sprites["pokeball0"].y=@sprites["playerbase"].y-114-(orgcord-@sprites["pokemon#{battlerindex}"].oy)*2
    12.times do
      @ballframe+=1
      @ballframe=0 if @ballframe > 7
      @sprites["pokeball0"].src_rect.set(@balltype*41,@ballframe*40,41,40)
      @sprites["pokeball0"].x+=3
      @sprites["pokeball0"].y-=3
      @sprites["pokeball0"].opacity+=42
      animateBattleSprites
      Graphics.update
    end
    8.times do
      @ballframe+=1
      @ballframe=0 if @ballframe > 7
      @sprites["pokeball0"].src_rect.set(@balltype*41,@ballframe*40,41,40)
      @sprites["pokeball0"].x+=2
      @sprites["pokeball0"].y-=1
      animateBattleSprites
      Graphics.update
    end
    8.times do
      @ballframe+=1
      @ballframe=0 if @ballframe > 7
      @sprites["pokeball0"].src_rect.set(@balltype*41,@ballframe*40,41,40)
      @sprites["pokeball0"].x+=1
      @sprites["pokeball0"].y+=1
      animateBattleSprites
      Graphics.update
    end
    20.times do
      @ballframe+=1
      @ballframe=0 if @ballframe > 7
      @sprites["pokeball0"].src_rect.set(@balltype*41,@ballframe*40,41,40)
      animateBattleSprites
      Graphics.update
    end
    @sprites["pokeball0"].visible=false
    @sprites["pokemon#{battlerindex}"].visible=true
    @sprites["pokemon#{battlerindex}"].y-=150+(orgcord-@sprites["pokemon#{battlerindex}"].oy)*2
    @sprites["pokemon#{battlerindex}"].zoom_x=0
    @sprites["pokemon#{battlerindex}"].zoom_y=0
    pbSEPlay("recall")
    clearMessageWindow
    12.times do
      if !USENEWUI
        @sprites["battlebox#{battlerindex}"].update
      else
        @sprites["battlebox#{battlerindex}"].x-=22
      end
      @sprites["pokemon#{battlerindex}"].zoom_x+=0.1
      @sprites["pokemon#{battlerindex}"].zoom_y+=0.1
      animateBattleSprites
      Graphics.update
    end
    2.times do
      @sprites["battlebox#{battlerindex}"].x+=2 if USENEWUI
      @sprites["pokemon#{battlerindex}"].zoom_x-=0.1
      @sprites["pokemon#{battlerindex}"].zoom_y-=0.1
      animateBattleSprites
      Graphics.update
    end
    pbPlayCry(@battle.battlers[battlerindex].pokemon ? @battle.battlers[battlerindex].pokemon : @battle.battlers[battlerindex].species)
    5.times do
      @sprites["pokemon#{battlerindex}"].tone.red-=51
      @sprites["pokemon#{battlerindex}"].tone.green-=51
      @sprites["pokemon#{battlerindex}"].tone.blue-=51
      animateBattleSprites
      Graphics.update
    end
    frame=0
    @sprites["pokemon#{battlerindex}"].y+=(orgcord-@sprites["pokemon#{battlerindex}"].oy)*2
    @sprites["pokemon#{battlerindex}"].oy=orgcord
    10.times do
      frame+=1
      @sprites["pokemon#{battlerindex}"].y+=15
      animateBattleSprites
      Graphics.update
    end
    @sprites["pokemon#{battlerindex}"].showshadow=true
    alt1=metrics[2][@battle.battlers[battlerindex].pokemon.species]
    pbSEPlay("drop") if alt1 < 1
    3.times do
      moveEntireScene(0,2)# if alt1 < 1
      animateBattleSprites(true)
      Graphics.update
    end
    3.times do
      moveEntireScene(0,-2)# if alt1 < 1
      animateBattleSprites(true)
      Graphics.update
    end
    if @battle.battlers[battlerindex].pokemon.isShiny?
      pbCommonAnimation("Shiny",@battle.battlers[battlerindex],nil)
    end
  end
  #=============================================================================
  #  All the various types of displaying messages in battle
  #=============================================================================
  def clearMessageWindow
    @sprites["messagewindow"].text=""
    @sprites["messagewindow"].refresh
    @sprites["messagebox"].visible=false
  end  
  
  alias pbFrameUpdate_old pbFrameUpdate
  def pbFrameUpdate(cw)
    cw.update if cw
    animateBattleSprites(true)
  end
  
  alias pbShowWindow_old pbShowWindow
  def pbShowWindow(windowtype)
    if !USENEWUI
      return pbShowWindow_old(windowtype)
    end
    @sprites["messagebox"].visible = (windowtype==MESSAGEBOX ||
                                      windowtype==COMMANDBOX ||
                                      windowtype==FIGHTBOX ||
                                      windowtype==BLANK )
    @sprites["messagewindow"].visible = (windowtype==MESSAGEBOX)
  end
  
  alias pbWaitMessage_old pbWaitMessage
  def pbWaitMessage
    if @briefmessage
      cw=@sprites["messagewindow"]
      60.times do
        animateBattleSprites(true)
        pbGraphicsUpdate
        pbInputUpdate
      end
      cw.text=""
      cw.visible=false
      @briefmessage=false
    end
  end

  alias pbDisplayMessage_old pbDisplayMessage
  def pbDisplayMessage(msg,brief=false)
    pbWaitMessage
    pbRefresh
    pbShowWindow(MESSAGEBOX)
    cw=@sprites["messagewindow"]
    cw.text=msg
    i=0
    loop do
      animateBattleSprites(true)
      pbGraphicsUpdate
      pbInputUpdate
      cw.update
      if i==40
        cw.text=""
        cw.visible=false
        return
      end
      if Input.trigger?(Input::C) || @abortable
        if cw.pausing?
          pbPlayDecisionSE() if !@abortable
          cw.resume
        end
      end
      if !cw.busy?
        if brief
          @briefmessage=true
          return
        end
        i+=1
      end
    end
  end

  alias pbDisplayPausedMessage_old pbDisplayPausedMessage
  def pbDisplayPausedMessage(msg)
    pbWaitMessage
    pbRefresh
    pbShowWindow(MESSAGEBOX)
    if @messagemode
      @switchscreen.pbDisplay(msg)
      return
    end
    cw=@sprites["messagewindow"]
    cw.text=_ISPRINTF("{1:s}\1",msg)
    loop do
      animateBattleSprites(true)
      pbGraphicsUpdate
      pbInputUpdate
      if Input.trigger?(Input::C) || @abortable
        if cw.busy?
          pbPlayDecisionSE() if cw.pausing? && !@abortable
          cw.resume
        elsif !inPartyAnimation?
          cw.text=""
          pbPlayDecisionSE()
          cw.visible=false if @messagemode
          return
        end
      end
      cw.update
    end
  end

  alias pbShowCommands_old pbShowCommands
  def pbShowCommands(msg,commands,defaultValue)
    pbWaitMessage
    pbRefresh
    pbShowWindow(MESSAGEBOX)
    dw=@sprites["messagewindow"]
    dw.text=msg
    cw = Window_CommandPokemon.new(commands)
    cw.x=Graphics.width-cw.width
    cw.y=Graphics.height-cw.height-dw.height
    cw.index=0
    cw.viewport=@viewport
    pbRefresh
    loop do
      cw.visible=!dw.busy?
      animateBattleSprites(true)
      pbGraphicsUpdate
      pbInputUpdate
      cw.update
      dw.update
      if Input.trigger?(Input::B) && defaultValue >=0
        if dw.busy?
          pbPlayDecisionSE() if dw.pausing?
          dw.resume
        else
          cw.dispose
          dw.text=""
          return defaultValue
        end
      end
      if Input.trigger?(Input::C)
        if dw.busy?
          pbPlayDecisionSE() if dw.pausing?
          dw.resume
        else
          cw.dispose
          dw.text=""
          return cw.index
        end
      end
    end
  end
end
  