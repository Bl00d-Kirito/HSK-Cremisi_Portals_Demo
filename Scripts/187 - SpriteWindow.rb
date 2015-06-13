class SpriteWindow < Window
	def loadSkinFile(file)
    if (self.windowskin.width==80 || self.windowskin.width==96) &&
       self.windowskin.height==48
      # Body = X, Y, width, height of body rectangle within windowskin
      @skinrect.set(32,16,16,16)
      # Trim = X, Y, width, height of trim rectangle within windowskin
      @trim=[32,16,16,16]
    elsif self.windowskin.width==80 && self.windowskin.height==80
      @skinrect.set(32,32,16,16)
      @trim=[24,32,24,16]
    end
  end
end