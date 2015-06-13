=begin
module Audio
  def Audio.bgm_fade(time)
    return if @me_playing or !FMod::bgm_playing?
    @bgm_fading_out = true
    time = time * 1.0
    @bgm_fade_decrement = FMod::bgm_volume / (time * Graphics.frame_rate)
  end
end

def pbBGMPlay(param,volume=100,pitch=nil)
  return if !param
  param=pbResolveAudioFile(param,volume,pitch)
  
  first=getPlayTime("Audio/BGM/"+param.name+"_intro second=getPlayTime("Audio/BGM/"+param.name)
    
  FMod.bgm_play("Audio/BGM/"+param.name,volume,param.pitch)
  FMod.bgm_set_loop_points(first*1000, second*1000)
end

def pbCueBGM(bgm,seconds=1.0,volume=100,pitch=nil)
  return if !bgm
  bgm=pbResolveAudioFile(bgm,volume,pitch)
  playingBGM=FMod.bgm_name
  return if bgm.name==playingBGM
  if playingBGM && FMod.bgm_volume>0
    Audio.bgm_fade(seconds/8)
    if !$PokemonTemp.cueFrames
      $PokemonTemp.cueFrames=(seconds*Graphics.frame_rate)+2
    end
    $PokemonTemp.cueBGM=bgm
  else
    pbBGMPlay(bgm)
  end
end
=end