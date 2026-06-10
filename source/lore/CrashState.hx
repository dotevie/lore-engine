package lore;

import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class CrashState extends MusicBeatState {
    var error:haxe.Exception;
    #if (flixel_addons < "3.0.0")
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Free_Checker'), 0.2, 0.2, true, true);
	#else
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Free_Checker'));
	#end

    private var canRestart:Bool = true;

    public function new(error:haxe.Exception) {
        super();
        this.error = error;
    }

    public override function create() {
        super.create();
        add({
            var s = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xff000000);
            s.alpha = 0;
            s;
        });
		checker.scrollFactor.set(0.07,0);
        checker.alpha = 0.5;
        add(checker);
        var topTitle:Alphabet = new Alphabet(25, 25, "Uncaught Error", true);
        add(topTitle);
        for (i in topTitle.members) i.color = 0xffff3333;
        var emsg:String = error.toString() + "\n\n";
		for (stackItem in haxe.CallStack.exceptionStack(true)) {
			switch (stackItem) {
				case FilePos(s, file, line, column):
					emsg += file + " (line " + line + ")\n";
				default:
					#if sys
					Sys.println(stackItem);
					#else
					trace(stackItem);
					#end
			}
		}
        #if desktop
        if (!sys.FileSystem.exists("./crash/"))
            sys.FileSystem.createDirectory("./crash/");
        var path:String = "./crash/" + "LoreEngine_" + Date.now().toString().replace(" ", "_").replace(":", "'") + ".txt";
        sys.io.File.saveContent(path, emsg + "\n");
        emsg += "\n\nA crash report has been saved to " + path + ".";
        #end
        emsg += "\n\nPlease report this error to the GitHub page: https://github.com/dotevie/lore-engine\n\nPress the ACCEPT button to restart the game.";
        var msg:FlxText = new FlxText(25, topTitle.members[0].height + 50, flixel.FlxG.width - 50, emsg).setFormat("VCR OSD Mono", 24, 0xffffffff, LEFT, OUTLINE, 0xff000000);
        msg.borderSize = 2;
        add(msg);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        checker.x -= 0.45 / (ClientPrefs.framerate / 60);
		checker.y -= 0.16 / (ClientPrefs.framerate / 60);
        if (controls.ACCEPT && canRestart) {
            canRestart = false;
            TitleState.initialized = false;
			TitleState.closedState = false;
            flixel.FlxG.sound?.play(Paths.sound('cancelMenu'));
            camera.fade(0xff000000, 0.5, false, flixel.FlxG.resetGame, false);
        }
    }
}