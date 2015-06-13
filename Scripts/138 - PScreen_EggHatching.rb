#===============================================================================
# * Egg Hatch Animation - by FL (Credits will be apreciated)
#                         Tweaked by Maruno
#===============================================================================
# This script is for Pokémon Essentials. It's an egg hatch animation that
# works even with special eggs like Manaphy egg.
#===============================================================================
# To this script works, put it above Main and put a picture (a 5 frames
# sprite sheet) with egg sprite height and 5 times the egg sprite width at
# Graphics/Battlers/eggCracks.
#===============================================================================
class PokemonEggHatchScene
  def pbStartScene(pokemon)
    @sprites={}
    @pokemon=pokemon
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @pokemon.eggsteps=1 # Just for drawing the egg
    addBackgroundOrColoredPlane(@sprites,"background","hatchbg",
       Color.new(248,248,248),@viewport)
    @sprites["pokemon"]=PokemonSprite.new(@viewport)
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["pokemon"].x=Graphics.width/2-@sprites["pokemon"].bitmap.width/2
    @sprites["pokemon"].y=48+Graphics.height/2-@sprites["pokemon"].bitmap.height/2
    @sprites["hatch"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"].z=200
    @sprites["overlay"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    @sprites["overlay"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,
        Color.new(255,255,255))
    @sprites["overlay"].opacity=0
    @pokemon.eggsteps=0 # Correct egg steps again
    pbFadeInAndShow(@sprites)
  end

  def pbMain
    crackfilename=sprintf("Graphics/Battlers/%seggCracks",getConstantName(PBSpecies,@pokemon.species)) rescue nil
    if !pbResolveBitmap(crackfilename)
      crackfilename=sprintf("Graphics/Battlers/%03deggCracks",@pokemon.species)
      if !pbResolveBitmap(crackfilename)
        crackfilename=sprintf("Graphics/Battlers/eggCracks")
      end
    end
    crackfilename=pbResolveBitmap(crackfilename)
    hatchSheet=AnimatedBitmap.new(crackfilename)
    pbBGMPlay("evolv")
    # Egg animation
    updateScene(60)
    pbPositionHatchMask(hatchSheet,0)
    pbSEPlay("ballshake")
    swingEgg(2)
    updateScene(8)
    pbPositionHatchMask(hatchSheet,1)
    pbSEPlay("ballshake")
    swingEgg(2)
    updateScene(16)
    pbPositionHatchMask(hatchSheet,2)
    pbSEPlay("ballshake")
    swingEgg(4,2)
    updateScene(16)
    pbPositionHatchMask(hatchSheet,3)
    pbSEPlay("ballshake")
    swingEgg(8,4)
    updateScene(8)
    pbPositionHatchMask(hatchSheet,4)
    pbSEPlay("recall")
    # Fade and change the sprite
    fadeSpeed=15
    for i in 1..(255/fadeSpeed)
      @sprites["pokemon"].tone=Tone.new(i*fadeSpeed,i*fadeSpeed,i*fadeSpeed)
      @sprites["overlay"].opacity=i*fadeSpeed
      updateScene
    end
    updateScene(30)
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["hatch"].visible=false
    for i in 1..(255/fadeSpeed)
      @sprites["pokemon"].tone=Tone.new(255-i*fadeSpeed,255-i*fadeSpeed,255-i*fadeSpeed)
      @sprites["overlay"].opacity=255-i*fadeSpeed
      updateScene
    end
    @sprites["pokemon"].tone=Tone.new(0,0,0)
    @sprites["overlay"].opacity=0
    # Finish scene
    frames=pbCryFrameLength(@pokemon.species)
    pbBGMStop()
    pbPlayCry(@pokemon)
    frames.times do
      Graphics.update
    end
    pbMEPlay("004-Victory04")
    Kernel.pbMessage(_INTL("\\se[]{1} hatched from the Egg!\\wt[80]",@pokemon.name))
    if Kernel.pbConfirmMessage(
        _INTL("Would you like to nickname the newly hatched {1}?",@pokemon.name))
      nickname=pbEnterPokemonName(_INTL("{1}'s nickname?",@pokemon.name),0,10,"",@pokemon)
      @pokemon.name=nickname if nickname!=""
    end
  end

  def pbPositionHatchMask(hatchSheet,index)
    @sprites["hatch"].bitmap.clear
    frames = 5
    frameWidth = hatchSheet.width/frames
    rect = Rect.new(frameWidth*index,0,frameWidth,hatchSheet.height)
    @sprites["hatch"].bitmap.blt(@sprites["pokemon"].x,@sprites["pokemon"].y,
        hatchSheet.bitmap,rect)
  end

  def swingEgg(speed,swingTimes=1) # Only accepts 2, 4 or 8 for speed.
    limit = 8
    targets = [@sprites["pokemon"].x-limit,@sprites["pokemon"].x+limit,
        @sprites["pokemon"].x]
    swingTimes.times do
      usedSpeed=speed
      for target in targets
        usedSpeed*=-1
        while target!=@sprites["pokemon"].x
          @sprites["pokemon"].x+=usedSpeed
          @sprites["hatch"].x+=usedSpeed
          updateScene
        end
      end
    end
  end

  def updateScene(frames=1) # Can be used for "wait" effect
    frames.times do
      Graphics.update
      Input.update
      self.update
    end
  end  

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonEggHatchScreen
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(pokemon)
    @scene.pbStartScene(pokemon)
    @scene.pbMain
    @scene.pbEndScene
  end
end



def pbHatchAnimation(pokemon)
  Kernel.pbMessage(_INTL("Huh?\1"))
  pbFadeOutInWithMusic(99999) {
     scene=PokemonEggHatchScene.new
     screen=PokemonEggHatchScreen.new(scene)
     screen.pbStartScreen(pokemon)
  }
  return true
end

def pbHatch(pokemon)
  speciesname=PBSpecies.getName(pokemon.species)
  pokemon.name=speciesname
  pokemon.trainerID=$Trainer.id
  pokemon.ot=$Trainer.name
  pokemon.happiness=120
  pokemon.timeEggHatched=pbGetTimeNow
  pokemon.obtainMode=1 # hatched from egg
  pokemon.hatchedMap=$game_map.map_id
  #=================================================
  #  Applies Birthsign Effects
  #
  #If you changed any Birthsign names in PField_Time, you must
  #also change the names below to match your changes.
  #Changes will also need to be made in PScreen_Summary and
  #PScreen_Party
  #=================================================
    if pokemon.birthsign==_INTL("'The Apprentice'") 
      pokemon.pokerus=16 #Gives cured Pokerus
    end
    if pokemon.birthsign==_INTL("'The Companion'")
      #Happiness ranges from 0-255. 
      #You can change the value to whatever you want.
      pokemon.happiness=255 #Gives max happiness
    end
    if pokemon.birthsign==_INTL("'The Savage'")
      #The number in brackets next to "iv" corresponds to the 6 stats.
      #0=HP, 1=Atk, 2=Def, 3=Speed, 4=Sp.Atk, 5=Sp.Def
      #The number after the '=' sign is the value that will be given to the 
      #IV of that stat.
      pokemon.iv[0]=0  #HP
      pokemon.iv[1]=31 #ATK
      pokemon.iv[3]=31 #SPEED
      pokemon.iv[4]=31 #SPATK
    end
    if pokemon.birthsign==_INTL("'The Prodigy'")
      #abilityflag=0 or =1 will yield either the first or second
      #natural abilities, respectively.
      pokemon.abilityflag=2 #Gives Hidden Ability
    end
    if pokemon.birthsign==_INTL("'The Maiden'")
      #setGender(0) will make them male, instead.
      pokemon.setGender(1) #Makes female
    end
    if pokemon.birthsign==_INTL("'The Gladiator'")
      #The numbers in brackets next to 'ev' correspond to the 6 stats,
      #exactly how the IV example works.
      pokemon.ev[1]=100 #ATK
      pokemon.ev[4]=100 #SPATK
    end
    if pokemon.birthsign==_INTL("'The Thief'") 
      pokemon.ev[3]=252 #SPEED
    end
    if pokemon.birthsign==_INTL("'The Glutton'") 
      pokemon.iv[0]=31 #HP
      pokemon.iv[2]=31 #DEF
      pokemon.iv[3]=0  #SPEED
      pokemon.iv[5]=31 #SPDEF
    end
    if pokemon.birthsign==_INTL("'The Wishmaker'") 
      pokemon.shinyflag=true #Makes shiny
    end
  #=================================================
  $Trainer.seen[pokemon.species]=true
  $Trainer.owned[pokemon.species]=true
  pbSeenForm(pokemon)
  pokemon.pbRecordFirstMoves
  if !pbHatchAnimation(pokemon)
    Kernel.pbMessage(_INTL("Huh?\1"))
    Kernel.pbMessage(_INTL("...\1"))
    Kernel.pbMessage(_INTL("... .... .....\1"))
    Kernel.pbMessage(_INTL("{1} hatched from the Egg!",speciesname))
    if Kernel.pbConfirmMessage(_INTL("Would you like to nickname the newly hatched {1}?",speciesname))
      species=PBSpecies.getName(pokemon.species)
      nickname=pbEnterPokemonName(_INTL("{1}'s nickname?",speciesname),0,10,"",pokemon)
      pokemon.name=nickname if nickname!=""
    end
  end
end

Events.onStepTaken+=proc {|sender,e|
   next if !$Trainer
   for egg in $Trainer.party
     if egg.eggsteps>0
       egg.eggsteps-=1
       for i in $Trainer.party
         if !i.isEgg? && (isConst?(i.ability,PBAbilities,:FLAMEBODY) ||
                          isConst?(i.ability,PBAbilities,:MAGMAARMOR))
           egg.eggsteps-=1
           break
         end
       end
       if egg.eggsteps<=0
         egg.eggsteps=0
         pbHatch(egg)
       end
     end
   end
}