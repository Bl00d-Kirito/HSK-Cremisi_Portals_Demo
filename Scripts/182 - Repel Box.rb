def pbRepelStepsActual
	@window = Sprite.new
	@window.bitmap = Cache.picture("RepelWindow").dup
	@window.x = (Graphics.width-@window.bitmap.width)/2
	@imageText = Sprite.new
  @imageText.bitmap = Bitmap.new(DEFAULTSCREENHEIGHT,DEFAULTSCREENWIDTH)
	@imageText.bitmap.draw_text(0,@window.bitmap.height-12, DEFAULTSCREENWIDTH, 24,($PokemonGlobal.repel-1).to_s,1)
end
