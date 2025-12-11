package lore;

import flixel.FlxG;

class InitState extends MusicBeatState {
    public override function create() {
        super.create();
        #if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();
        FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];
		Highscore.load();
        if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
        if (FlxG.save.data.weekCompleted != null)
            {
                StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
            }
        
        FlxG.mouse.visible = false;
        Locale.init();
		var sm:Class<flixel.system.scaleModes.BaseScaleMode> = Type.createInstance(CoolUtil.scaleModes[ClientPrefs.scaleMode] ?? flixel.system.scaleModes.RatioScaleMode, []);
		if (sm != null) {
			FlxG.scaleMode = sm;
		}
        if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			flixel.addons.transition.FlxTransitionableState.skipNextTransIn = true;
			flixel.addons.transition.FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			MusicBeatState.switchState(new TitleState());
		}
    }
}