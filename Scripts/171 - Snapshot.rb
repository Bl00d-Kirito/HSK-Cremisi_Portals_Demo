#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:
# Screenshot
# Author: ForeverZer0
# Version: 1.0
# Date: 6.17.2012
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:
#
# Script for taking snapshots of the game screen and saving to a PNG file. 
# 
# Instructions:
#   
#   Use the following script call: Screen.snap(FILENAME, QUALITY)
#     FILENAME - Filename to save as excluding extension. If omitted, one
#                will be generated using configured values
#     QUALITY  - Quality of the image. 0 = High, 1 = Low. 
#                 If omiited, high quality will be used by default.
#
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:

module Screen
  
  # Define the directory for snapshots
  DIRECTORY = "Snapshots"
  
  # Define the basename for snapshots
  FILENAME = "snap"
  
  #-----------------------------------------------------------------------------
  # Takes a snapshot of the screen
  #   filename - Filename to save as excluding extension. 
  #              A name will be generated if this omitted
  #   quality  - Quality of the screenshot
  #              0 = High quality
  #              1 = Low Quality
  #-----------------------------------------------------------------------------
  def self.snap(filename = nil, quality = 0)
    title = "\0" * 256
    GetPrivateProfileString.call('Game', 'Title', '', title, 256, '.\\Game.ini')
    title.delete!("\0")
    window = FindWindow.call('RGSS Player', title)
    unless File.directory?(DIRECTORY)
      Dir.mkdir(DIRECTORY)
    end
    if filename == nil
      count = 0
      files = Dir.entries(DIRECTORY) - ['.', '..']
      files.collect! {|f| File.basename(f, File.extname(f)) }
      filename = "#{FILENAME}#{count}"
      while files.include?(filename)
        count += 1
        filename = "#{FILENAME}#{count}"
      end
      filename = "#{DIRECTORY}/#{filename}.png"
    end
    ScreenShot.call(0, 0, DEFAULTSCREENWIDTH, DEFAULTSCREENHEIGHT, filename, window, quality)
  end
  
  #-----------------------------------------------------------------------------
  # Private Constants - DO NOT EDIT
  #-----------------------------------------------------------------------------
  GetPrivateProfileString = 
    Win32API.new('kernel32', 'GetPrivateProfileString','PPPPLP', 'L')
  FindWindow = Win32API.new('user32', 'FindWindow', 'PP', 'I')
  ScreenShot = Win32API.new('screenshot.dll', 'Screenshot', 'LLLLPLL', '')
end