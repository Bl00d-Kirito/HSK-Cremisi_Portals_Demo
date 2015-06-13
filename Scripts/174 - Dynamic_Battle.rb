
#===============================================================================
#  Elite Battle system
#    by Luka S.J.
#  
#  BattleCore processing
#  aliasing and new def is called to account for several changes done to the
#  way Pokemon are initially sent into battle
#===============================================================================  
class PokeBattle_Battle
  attr_reader :midspeech
  attr_accessor :midspeech_done
  
  def endspeech=(msg)
    @midspeech=""
    @midspeech_done=false
    if msg.is_a?(Array)
      @endspeech=msg[0]
      @midspeech=msg[1]
    else
      @endspeech=msg
    end
  end
  
  alias pbStartBattleCore_old pbStartBattleCore
  def pbStartBattleCore(canlose)
    if !@fullparty1 && @party1.length > MAXPARTYSIZE
      raise ArgumentError.new(_INTL("Party 1 has more than {1} Pokémon.",MAXPARTYSIZE))
    end
    if !@fullparty2 && @party2.length > MAXPARTYSIZE
      raise ArgumentError.new(_INTL("Party 2 has more than {1} Pokémon.",MAXPARTYSIZE))
    end
    if !@opponent
    #========================
    # Initialize wild Pokémon
    #========================
      if @party2.length==1
        if @doublebattle
          raise _INTL("Only two wild Pokémon are allowed in double battles")
        end
        wildpoke=@party2[0]
        @battlers[1].pbInitialize(wildpoke,0,false)
        @peer.pbOnEnteringBattle(self,wildpoke)
        pbSetSeen(wildpoke)
        @scene.pbStartBattle(self)
        pbDisplayPaused(_INTL("Wild {1} appeared!",wildpoke.name))
      elsif @party2.length==2
        if !@doublebattle
          raise _INTL("Only one wild Pokémon is allowed in single battles")
        end
        @battlers[1].pbInitialize(@party2[0],0,false)
        @battlers[3].pbInitialize(@party2[1],0,false)
        @peer.pbOnEnteringBattle(self,@party2[0])
        @peer.pbOnEnteringBattle(self,@party2[1])
        pbSetSeen(@party2[0])
        pbSetSeen(@party2[1])
        @scene.pbStartBattle(self)
        pbDisplayPaused(_INTL("Wild {1} and\r\n{2} appeared!",
           @party2[0].name,@party2[1].name))
      else
        raise _INTL("Only one or two wild Pokémon are allowed")
      end
    elsif @doublebattle
    #=======================================
    # Initialize opponents in double battles
    #=======================================
      if @opponent.is_a?(Array)
        if @opponent.length==1
          @opponent=@opponent[0]
        elsif @opponent.length!=2
          raise _INTL("Opponents with zero or more than two people are not allowed")
        end
      end
      if @player.is_a?(Array)
        if @player.length==1
          @player=@player[0]
        elsif @player.length!=2
          raise _INTL("Player trainers with zero or more than two people are not allowed")
        end
      end
      @scene.pbStartBattle(self)
      if @opponent.is_a?(Array)
        pbDisplayPaused(_INTL("{1} and {2} want to battle!",@opponent[0].fullname,@opponent[1].fullname))
        sendout1=pbFindNextUnfainted(@party2,0,pbSecondPartyBegin(1))
        raise _INTL("Opponent 1 has no unfainted Pokémon") if sendout1 < 0
        sendout2=pbFindNextUnfainted(@party2,pbSecondPartyBegin(1))
        raise _INTL("Opponent 2 has no unfainted Pokémon") if sendout2 < 0
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}! {3} sent\r\nout {4}!",@opponent[0].fullname,@party2[sendout1].name,@opponent[1].fullname,@party2[sendout2].name))
        @battlers[1].pbInitialize(@party2[sendout1],sendout1,false)
        @battlers[3].pbInitialize(@party2[sendout2],sendout2,false)
        pbSendOut(1,@party2[sendout1])
      else
        pbDisplayPaused(_INTL("{1}\r\nwould like to battle!",@opponent.fullname))
        sendout1=pbFindNextUnfainted(@party2,0)
        sendout2=pbFindNextUnfainted(@party2,sendout1+1)
        if sendout1 < 0 || sendout2 < 0
          raise _INTL("Opponent doesn't have two unfainted Pokémon")
        end
        pbDisplayBrief(_INTL("{1} sent\r\nout {2} and {3}!",
           @opponent.fullname,@party2[sendout1].name,@party2[sendout2].name))
        @battlers[1].pbInitialize(@party2[sendout1],sendout1,false)
        @battlers[3].pbInitialize(@party2[sendout2],sendout2,false)
        pbSendOut(1,@party2[sendout1])
      end
    else
    #======================================
    # Initialize opponent in single battles
    #======================================
      sendout=pbFindNextUnfainted(@party2,0)
      raise _INTL("Trainer has no unfainted Pokémon") if sendout < 0
      if @opponent.is_a?(Array)
        raise _INTL("Opponent trainer must be only one person in single battles") if @opponent.length!=1
        @opponent=@opponent[0]
      end
      if @player.is_a?(Array)
        raise _INTL("Player trainer must be only one person in single battles") if @player.length!=1
        @player=@player[0]
      end
      trainerpoke=@party2[0]
      @scene.pbStartBattle(self)
      pbDisplayPaused(_INTL("{1}\r\nwould like to battle!",@opponent.fullname))
      pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent.fullname,trainerpoke.name))
      @battlers[1].pbInitialize(trainerpoke,sendout,false)
      pbSendOut(1,trainerpoke)
    end
    #=====================================
    # Initialize players in double battles
    #=====================================
    if @doublebattle
      if @player.is_a?(Array)
        sendout1=pbFindNextUnfainted(@party1,0,pbSecondPartyBegin(0))
        raise _INTL("Player 1 has no unfainted Pokémon") if sendout1 < 0
        sendout2=pbFindNextUnfainted(@party1,pbSecondPartyBegin(0))
        raise _INTL("Player 2 has no unfainted Pokémon") if sendout2 < 0
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!  Go! {3}!",
           @player[1].fullname,@party1[sendout2].name,@party1[sendout1].name))
        pbSetSeen(@party1[sendout1])
        pbSetSeen(@party1[sendout2])
      else
        sendout1=pbFindNextUnfainted(@party1,0)
        sendout2=pbFindNextUnfainted(@party1,sendout1+1)
        if sendout1 < 0 || sendout2 < 0
          raise _INTL("Player doesn't have two unfainted Pokémon")
        end
        pbDisplayBrief(_INTL("Go! {1} and {2}!",@party1[sendout1].name,@party1[sendout2].name))
      end
      @battlers[0].pbInitialize(@party1[sendout1],sendout1,false)
      @battlers[2].pbInitialize(@party1[sendout2],sendout2,false)
      pbSendOut(0,@party1[sendout1])
    else
    #====================================
    # Initialize player in single battles
    #====================================
      sendout=pbFindNextUnfainted(@party1,0)
      if sendout < 0
        raise _INTL("Player has no unfainted Pokémon")
      end
      playerpoke=@party1[sendout]
      pbDisplayBrief(_INTL("Go! {1}!",playerpoke.name))
      @battlers[0].pbInitialize(playerpoke,sendout,false)
      pbSendOut(0,playerpoke)
    end
    #==================
    # Initialize battle
    #==================
    if @weather==PBWeather::SUNNYDAY
      pbCommonAnimation("Sunny",nil,nil)
      pbDisplay(_INTL("The sunlight is strong."))
    elsif @weather==PBWeather::RAINDANCE
      pbCommonAnimation("Rain",nil,nil)
      pbDisplay(_INTL("It is raining."))
    elsif @weather==PBWeather::SANDSTORM
      pbCommonAnimation("Sandstorm",nil,nil)
      pbDisplay(_INTL("A sandstorm is raging."))
    elsif @weather==PBWeather::HAIL
      pbCommonAnimation("Hail",nil,nil)
      pbDisplay(_INTL("Hail is falling."))
    end
    pbOnActiveAll   # Abilities
    @turncount=0
    loop do   # Now begin the battle loop
      PBDebug.log("***Round #{@turncount+1}***") if $INTERNAL
      if @debug && @turncount >=100
        @decision=pbDecisionOnTime()
        PBDebug.log("***[Undecided after 100 rounds]")
        pbAbort
        break
      end
      PBDebug.logonerr{
         pbCommandPhase
      }
      break if @decision > 0
      PBDebug.logonerr{
         pbAttackPhase
      }
      break if @decision > 0
      PBDebug.logonerr{
         pbEndOfRoundPhase
      }
      break if @decision > 0
      @turncount+=1
    end
    return pbEndOfBattle(canlose)
  end
  
  alias pbCommandPhase_old pbCommandPhase
  def pbCommandPhase
    pbCommandPhase_old
    @scene.idleTimer=-1
  end

end