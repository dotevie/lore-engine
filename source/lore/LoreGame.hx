package lore;

import flixel.addons.transition.FlxTransitionableState;
import haxe.Exception;
import flixel.FlxG;

class LoreGame extends flixel.FlxGame {
    private static function crashGame() {
		(cast(null, flixel.FlxSprite)).draw(); // null object reference instead of null access
	}

	override function create(_):Void {
		try
			super.create(_)
		catch (e:Exception)
			onCrash(e);
	}

	override function onFocus(_):Void {
		try
			super.onFocus(_)
		catch (e:Exception)
			onCrash(e);
	}

	override function onFocusLost(_):Void {
		try
			super.onFocusLost(_)
		catch (e:Exception)
			onCrash(e);
	}

	override function onEnterFrame(_):Void {
		try
			super.onEnterFrame(_)
		catch (e:Exception)
			onCrash(e);
	}

	override function update():Void {
		#if CRASH_TEST
		if (FlxG.keys.justPressed.F9 && !(FlxG.state is CrashState))
			crashGame();
		#end
		try
			super.update()
		catch (e:Exception)
			onCrash(e);
	}

	override function draw():Void {
		try
			super.draw()
		catch (e:Exception)
			onCrash(e);
	}

    private static function onCrash(e:Exception) {
		if (PlayState.inPlayState) PlayState.instance?.endSong();
        FlxG.sound?.music?.stop();
        for (i in FlxG.sound.list.members) i?.stop();
		FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
		FlxG.switchState(new CrashState(e));
    }
}