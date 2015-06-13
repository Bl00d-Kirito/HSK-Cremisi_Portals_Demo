=begin
class UnownRiddles

BackgroundFile = "UnownBackground" # Background of the Unown (EG a stone tablet)
FilePrefix = "Unown" # The prefix of the Unown characters (EG if the prefix
# is "Unown_" then it will look for "Unown_A",
# "Unown_B", "Unown_C", ect.)

# THESE OPTIONS ARE MEASURED IN PIXELS!
UnownStartX = 32 # The Starting X (per line) on which a Unown character is shown
UnownStartY = 32 # The Starting Y point on which Unown is shown
UnownNewLineAt = Graphics.width - UnownStartX # The maximum X before we go to
# a new line

# THESE OPTIONS ARE MEASURED IN PIXELS!
UnownPaddingX = 10 # Padding between each Unown character (Left to Right)
UnownPaddingY = 10 # Padding between each Unown character (Top to Bottom)

def self.show(text)
scene = Unown.new(text)
scene.main
end

def initialize(text)
@text = unownAlphabetString(text)
@exit = false
end

# Converts a normal string into an unown alphabetical string
# Removes all uneeded characters, converts numbers into the correct format
# ect.
def unownAlphabetString(input)
input[/([A-Za-z0-9# ]*)/]
input = $1
output = ""
char = "A"
for i in 0...input.length
prev_char = char
charI = input[i]
char = " "
char[0] = charI

# Check to see if we are at the start of an integer
if (char == "0" || char.to_i != 0) &&
(prev_char != "0" && prev_char.to_i == 0 && prev_char != "#")
output += "#" # Add a number sign to the start of numbers
end

# Convert each integer into a letter, because this is how it is in Unown
if char == "1"
output += "A"
elsif char == "2"
output += "B"
elsif char == "3"
output += "C"
elsif char == "4"
output += "D"
elsif char == "5"
output += "E"
elsif char == "6"
output += "F"
elsif char == "7"
output += "G"
elsif char == "8"
output += "H"
elsif char == "9"
output += "I"
elsif char == "0"
output += "J"
else # If it's not a letter, just add the character.
output += char
end
end
return output
end

def create_spriteset
@sprites = {}
@sprites["background"] = IconSprite.new
@sprites["background"].setBitmap("Graphics/Pictures/" + BackgroundFile)
x = UnownStartX + UnownPaddingX
y = UnownStartY + UnownPaddingY
for i in 0...@text.length
file = "Graphics/Pictures/" + FilePrefix + "A"
t = @text[i]
if t == "#"[0]
t = "NS"
elsif t == " "[0]
t = "Space"
end
file[file.length - 1] = t
if FileTest.image_exist?(file)
@sprites["letter#{i}"] = IconSprite.new(x, y)
@sprites["letter#{i}"].setBitmap(file)
x += @sprites["letter#{i}"].bitmap.width + UnownPaddingX
if x >= UnownNewLineAt - UnownPaddingX
x = UnownStartX + UnownPaddingX
y += @sprites["letter#{i}"].bitmap.height + UnownPaddingX
end
else
c = "A"
c[0] = @text[i]
c = c.upcase
t = "Could not find the file Unown file for the character: #{c}!"
raise t
end
end
end

def main
create_spriteset
loop do
Graphics.update
Input.update
update
break if @exit
end
pbDisposeSpriteHash(@sprites)
end


def update
pbUpdateSpriteHash(@sprites)
if Input.trigger?(Input::C) || Input.trigger?(Input::B)
@exit = true
end
end
end
  
	def pbEntry
    ret=""
    loop do
      Graphics.update
      Input.update
      if Input.triggerex?(0x1B) && @minlength==0
        ret=""
        break
      end
      if Input.triggerex?(13) && @sprites["entry"].text.length>=@minlength
        ret=@sprites["entry"].text
        break
      end
      @sprites["entry"].update
    end
    Input.update
    return ret
  end
	
end
=end