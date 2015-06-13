SAVE_SWITCH = 10

def pbAutoSave(safesave=false)
	$game_switches[SAVE_SWITCH] = false
	if $game_variables[99]>1
			savename="Game_"+$game_variables[99].to_s+"_autosave.rxdata"
	else
			savename="Game_autosave.rxdata"
	end
	begin
		File.open(RTP.getSaveFileName(savename),"wb"){|f|
			Marshal.dump($Trainer,f)
			Marshal.dump(Graphics.frame_count,f)
			if $data_system.respond_to?("magic_number")
				$game_system.magic_number = $data_system.magic_number
			else
				$game_system.magic_number = $data_system.version_id
			end
			$game_system.save_count+=1
			Marshal.dump($game_system,f)
			Marshal.dump($PokemonSystem,f)
			Marshal.dump($game_map.map_id,f)
			Marshal.dump($game_switches,f)
			Marshal.dump($game_variables,f)
			Marshal.dump($game_self_switches,f)
			Marshal.dump($game_screen,f)
			Marshal.dump($MapFactory,f)
			Marshal.dump($game_player,f)
			$PokemonGlobal.safesave=safesave
			Marshal.dump($PokemonGlobal,f)
			Marshal.dump($PokemonMap,f)
			Marshal.dump($PokemonBag,f)
			Marshal.dump($PokemonStorage,f)
		}
		Graphics.frame_reset
	rescue
		return false
	end
	pbStoredLastPlayed($game_variables[99],true)
	return true
end

def pbSave(safesave=false)
	$Trainer.metaID=$PokemonGlobal.playerID
	$game_switches[SAVE_SWITCH] = false
	if $game_variables[99]>1
		savename="Game_"+$game_variables[99].to_s+".rxdata"
	else
		savename="Game.rxdata"
	end
	begin  
		File.open(RTP.getSaveFileName(savename),"wb"){|f|
			Marshal.dump($Trainer,f)
			Marshal.dump(Graphics.frame_count,f)
			if $data_system.respond_to?("magic_number")
				$game_system.magic_number = $data_system.magic_number
			else
				$game_system.magic_number = $data_system.version_id
			end
			$game_system.save_count+=1
			Marshal.dump($game_system,f)
			Marshal.dump($PokemonSystem,f)
			Marshal.dump($game_map.map_id,f)
			Marshal.dump($game_switches,f)
			Marshal.dump($game_variables,f)
			Marshal.dump($game_self_switches,f)
			Marshal.dump($game_screen,f)
			Marshal.dump($MapFactory,f)
			Marshal.dump($game_player,f)
			$PokemonGlobal.safesave=safesave
			Marshal.dump($PokemonGlobal,f)
			Marshal.dump($PokemonMap,f)
			Marshal.dump($PokemonBag,f)
			Marshal.dump($PokemonStorage,f)
		}
		Graphics.frame_reset
	 rescue
		return false
	end
	pbStoredLastPlayed($game_variables[99],nil)
	return true
end