#---------------------------------------------------------------------
# Help-14's Gen-V Receive Item Scene script, Please give him credits if you are
# using this script. 
# Dont forget to credit Help-14
# Slightly edited by Black Eternity & Mustafa505 
#---------------------------------------------------------------------
def pbReceiveItemPop(item)
        item=getID(PBItems,item) if !item.is_a?(Integer)
        itemname=PBItems.getName(item)
        Kernel.pbMessage(_INTL("{1} obtained the {2}!",$Trainer.name,itemname))
        if $PokemonBag.pbStoreItem(item)
                bg=Sprite.new
                bg.bitmap= BitmapCache.load_bitmap("Graphics/Pictures/ReceiveItem1")
                bg.x=(Graphics.width-bg.bitmap.width)/2
                bg.y=(Graphics.height-bg.bitmap.height)/2
                bg.opacity=200
                item= Sprite.new()
                item.bitmap= BitmapCache.load_bitmap(sprintf("Graphics/Icons/item%03d.png",$ItemData[item][0]))
                item.x=Graphics.width/2
                item.y=Graphics.height/2
                item.zoom_x=2
                item.zoom_y=2
                item.ox=(item.bitmap.width)/2
                item.oy=(item.bitmap.height)/2
                2.times do
                        5.times do
                                item.angle+=10
                                pbWait(2)
                        end
                        10.times do
                                item.angle-=10
                                pbWait(2)
                        end
                        5.times do
                                item.angle+=10
                                pbWait(2)
                        end
                end
                pbWait(5)
                item.dispose
                bg.dispose
                case $ItemData[item][ITEMPOCKET]
                        when 1
                                Kernel.pbMessage(_INTL("{1} put the {2} in the Items Pocket.",$Trainer.name,itemname))
                        when 2
                                Kernel.pbMessage(_INTL("{1} put the {2} in the Medicine Pocket.",$Trainer.name,itemname))
                        when 3
                                Kernel.pbMessage(_INTL("{1} put the {2} in the Poke Balls Pocket.",$Trainer.name,itemname))
                        when 4
                                Kernel.pbMessage(_INTL("{1} put the {2} in the TMs/HMs Pocket.",$Trainer.name,itemname))
                        when 5
                                Kernel.pbMessage(_INTL("{1} put the {2} in the Berries Pocket.",$Trainer.name,itemname))
                        when 6
                                Kernel.pbMessage(_INTL("{1} put the {2} in the Mail Pocket.",$Trainer.name,itemname))
                        when 7
                                Kernel.pbMessage(_INTL("{1} put the {2} in the Battle Items Pocket.",$Trainer.name,itemname))
                        when 8
                                Kernel.pbMessage(_INTL("{1} put the {2} in the Key Items Pocket.",$Trainer.name,itemname))
                end
                return true
        else
                return false
        end
end