################################################################################
# * Day and night system
################################################################################
def pbGetTimeNow
  return Time.now
end



module PBDayNight
  HourlyTones=[
     Tone.new(-142.5,-142.5,-22.5,68),     # Midnight
     Tone.new(-135.5,-135.5,-24,  68),
     Tone.new(-127.5,-127.5,-25.5,68),
     Tone.new(-127.5,-127.5,-25.5,68),
     Tone.new(-119,  -96.3, -45.3,45.3),
     Tone.new(-51,   -73.7, -73.7,22.7),
     Tone.new(17,    -51,   -102, 0),      # 6AM
     Tone.new(14.2,  -42.5, -85,  0),
     Tone.new(11.3,  -34,   -68,  0),
     Tone.new(8.5,   -25.5, -51,  0),
     Tone.new(5.7,   -17,   -34,  0),
     Tone.new(2.8,   -8.5,  -17,  0),
     Tone.new(0,     0,     0,    0),      # Noon
     Tone.new(0,     0,     0,    0),
     Tone.new(0,     0,     0,    0),
     Tone.new(0,     0,     0,    0),
     Tone.new(-3,    -7,    -2,   0),
     Tone.new(-10,   -18,   -5,   0),
     Tone.new(-36,   -75,   -13,  0),      # 6PM
     Tone.new(-72,   -136,  -34,  3),
     Tone.new(-88.5, -133,  -31,  34),
     Tone.new(-108.5,-129,  -28,  68),
     Tone.new(-127.5,-127.5,-25.5,68),
     Tone.new(-142.5,-142.5,-22.5,68)
  ]
  @cachedTone=nil
  @dayNightToneLastUpdate=nil

# Returns true if it's day.
  def self.isDay?(time)
    return (time.hour>=6 && time.hour<20)
  end

# Returns true if it's night.
  def self.isNight?(time)
    return (time.hour>=20 || time.hour<6)
  end

# Returns true if it's morning.
  def self.isMorning?(time)
    return (time.hour>=6 && time.hour<12)
  end

# Returns true if it's the afternoon.
  def self.isAfternoon?(time)
    return (time.hour>=12 && time.hour<20)
  end

# Returns true if it's the evening.
  def self.isEvening?(time)
    return (time.hour>=17 && time.hour<20)
  end

# Gets a number representing the amount of daylight (0=full night, 255=full day).
  def self.getShade
    time=pbGetDayNightMinutes
    time=(24*60)-time if time>(12*60)
    shade=255*time/(12*60)
  end

# Gets a Tone object representing a suggested shading
# tone for the current time of day.
  def self.getTone()
    return Tone.new(0,0,0) if !ENABLESHADING
    if !@cachedTone
      @cachedTone=Tone.new(0,0,0)
    end
    if !@dayNightToneLastUpdate || @dayNightToneLastUpdate!=Graphics.frame_count       
      @cachedTone=getToneInternal()
      @dayNightToneLastUpdate=Graphics.frame_count
    end
    return @cachedTone
  end

  def self.pbGetDayNightMinutes
    now=pbGetTimeNow   # Get the current in-game time
    return (now.hour*60)+now.min
  end

  private

# Internal function

  def self.getToneInternal()
    # Calculates the tone for the current frame, used for day/night effects
    realMinutes=pbGetDayNightMinutes
    hour=realMinutes/60
    minute=realMinutes%60
    tone=PBDayNight::HourlyTones[hour]
    nexthourtone=PBDayNight::HourlyTones[(hour+1)%24]
    # Calculate current tint according to current and next hour's tint and
    # depending on current minute
    return Tone.new(
       ((nexthourtone.red-tone.red)*minute/60.0)+tone.red,
       ((nexthourtone.green-tone.green)*minute/60.0)+tone.green,
       ((nexthourtone.blue-tone.blue)*minute/60.0)+tone.blue,
       ((nexthourtone.gray-tone.gray)*minute/60.0)+tone.gray
    )
  end
end



def pbDayNightTint(object)
  if !$scene.is_a?(Scene_Map)
    return
  else
    if ENABLESHADING && $game_map && pbGetMetadata($game_map.map_id,MetadataOutdoor)
      tone=PBDayNight.getTone()
      object.tone.set(tone.red,tone.green,tone.blue,tone.gray)
    else
      object.tone.set(0,0,0,0)  
    end
  end  
end



################################################################################
# * Zodiac and day/month checks
################################################################################
# Calculates the phase of the moon.
# 0 - New Moon
# 1 - Waxing Crescent
# 2 - First Quarter
# 3 - Waxing Gibbous
# 4 - Full Moon
# 5 - Waning Gibbous
# 6 - Last Quarter
# 7 - Waning Crescent
def moonphase(time) # in UTC
  transitions=[
     1.8456618033125,
     5.5369854099375,
     9.2283090165625,
     12.9196326231875,
     16.6109562298125,
     20.3022798364375,
     23.9936034430625,
     27.6849270496875]
  yy=time.year-((12-time.mon)/10.0).floor
  j=(365.25*(4712+yy)).floor + (((time.mon+9)%12)*30.6+0.5).floor + time.day+59
  j-=(((yy/100.0)+49).floor*0.75).floor-38 if j>2299160
  j+=(((time.hour*60)+time.min*60)+time.sec)/86400.0
  v=(j-2451550.1)/29.530588853
  v=((v-v.floor)+(v<0 ? 1 : 0))
  ag=v*29.53
  for i in 0...transitions.length
    return i if ag<=transitions[i]
  end
  return 0
end

#=======================================================================================
#  New Birthsigns
#
# If you want to modify the date ranges for each Birthsign:
#-The first number on each line corresponds to the month that Birthsign begins.
#-The second number on each line corresponds to the day of the given month that the Birthsign begins.
#-The third number on each line corresponds to the month that the Birthsign ends.
#-The fourth number on each line corresponds to the day of the given month that the Birthsign ends.
#
#If you change the date ranges for any of the Birthsigns, make sure to reflect these changes in the
#Birthsign Page text in PScreen_Summary
#=======================================================================================
def zodiac(month,day)
  time=[
    1,1,1,31,    # The Apprentice
    2,1,2,28,    # The Companion
    3,1,3,31,    # The Beacon
    4,1,4,30,    # The Savage
    5,1,5,31,    # The Prodigy
    6,1,6,30,    # The Martyr
    7,1,7,31,    # The Maiden
    8,1,8,31,    # The Gladiator
    9,1,9,30,    # The Voyager
    10,1,10,31,  # The Thief
    11,1,11,30,  # The Glutton
    12,1,12,31    # The Wishmaker
  ]
  for i in 0...12
    return i if month==time[i*4] && day>=time[i*4+1]
    return i if month==time[i*4+2] && day<=time[i*4+2]
  end
  return 0
end
#=======================================
 
# Returns the opposite of the given zodiac sign.
# 0 is Aries, 11 is Pisces.
def zodiacOpposite(sign)
  return (sign+6)%12
end

# 0 is Aries, 11 is Pisces.
def zodiacPartners(sign)
  return [(sign+4)%12,(sign+8)%12]
end

# 0 is Aries, 11 is Pisces.
def zodiacComplements(sign)
  return [(sign+1)%12,(sign+11)%12]
end

#===============================================================================
#  Birthsigns - Names & Descriptions
#
#If you choose to change the names of 'The Beacon', 'The Martyr', or 'The Voyager', you will also
#need to change the text in PScreen_Party & PScreen_Summary to match your new names.
#
#If you choose to change the names of any of the other Birthsigns, you will  need to change the
#text in PScreen_EggHatching & PScreen_Summary to match your new names.
#
#If you choose to change the description text for any of the Birthsigns, your next text may no
#longer fit on the page and may require new positioning in PScreen_Summary, and may
#also need changes to the 'summaryzboarder' graphic.
#===============================================================================
def zodiacValue(sign)
  return (sign)%12
end

def pbGetZodiacName(sign)
  return [_INTL(""),
          _INTL("'The Apprentice'"),
          _INTL("'The Companion'"),
          _INTL("'The Beacon'"),
          _INTL("'The Savage'"),
          _INTL("'The Prodigy'"),
          _INTL("'The Martyr'"),
          _INTL("'The Maiden'"),
          _INTL("'The Gladiator'"),
          _INTL("'The Voyager'"),
          _INTL("'The Thief'"),
          _INTL("'The Glutton'"),
          _INTL("'The Wishmaker'")][sign]
        end
        
def pbGetZodiacDesc(sign)
  return [_INTL(""),
          _INTL("The Pokémon is born cured of Pokérus."), 
          _INTL("The Pokémon is born with max happiness."),
          _INTL("The Pokémon can use Flash without the move."),
          _INTL("The Pokémon has max IV's in offense & Speed, but 0 HP."),
          _INTL("The Pokémon is born with its Hidden Ability."),
          _INTL("The Pokémon can use Soft-Boiled without the move."),
          _INTL("The Pokémon is always born female, if able."),
          _INTL("The Pokémon is born with 100 EV's in Atk & Sp.Atk."),
          _INTL("The Pokémon can use Teleport without the move."),
          _INTL("The Pokémon is born with max EV's in Speed."),
          _INTL("The Pokémon has max IV's in defenses & HP, but 0 Speed."),
          _INTL("The Pokémon is always born shiny.")][sign]
        end        
#===============================================================================

def pbIsWeekday(wdayVariable,*arg)
  timenow=pbGetTimeNow
  wday=timenow.wday
  ret=false
  for wd in arg
    ret=true if wd==wday
  end
  if wdayVariable>0
    $game_variables[wdayVariable]=[ 
       _INTL("Sunday"),
       _INTL("Monday"),
       _INTL("Tuesday"),
       _INTL("Wednesday"),
       _INTL("Thursday"),
       _INTL("Friday"),
       _INTL("Saturday")
    ][wday] 
    $game_map.need_refresh = true if $game_map
  end
  return ret
end

def pbIsMonth(wdayVariable,*arg)
  timenow=pbGetTimeNow
  wday=timenow.mon
  ret=false
  for wd in arg
    ret=true if wd==wday
  end
  if wdayVariable>0
    $game_variables[wdayVariable]=[ 
       _INTL("January"),
       _INTL("February"),
       _INTL("March"),
       _INTL("April"),
       _INTL("May"),
       _INTL("June"),
       _INTL("July"),
       _INTL("August"),
       _INTL("September"),
       _INTL("October"),
       _INTL("November"),
       _INTL("December")
    ][wday-1] 
    $game_map.need_refresh = true if $game_map
  end
  return ret
end

def pbGetAbbrevMonthName(month)
  return [_INTL(""),
          _INTL("Jan."),
          _INTL("Feb."),
          _INTL("Mar."),
          _INTL("Apr."),
          _INTL("May"),
          _INTL("Jun."),
          _INTL("Jul."),
          _INTL("Aug."),
          _INTL("Sep."),
          _INTL("Oct."),
          _INTL("Nov."),
          _INTL("Dec.")][month]
end