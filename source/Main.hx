package;

import flixel.util.typeLimit.OneOfTwo;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFLAssets;
import haxe.Json;
import flixel.math.FlxRandom;
import flixel.graphics.FlxGraphic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.media.Sound;
import flixel.util.FlxTimer;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
#if desktop
import sys.io.Process;
import sys.Http;
import sys.FileSystem;
import sys.io.File;
#end
class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = lore.InitState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fpsVar:lore.FPS;
	public static var instance:Main;
	public var game:lore.LoreGame;
	public static var gameInitialized:Bool = false;
	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	#if (flixel < "5.0.0")
	@:deprecated("Please update to the latest version of HaxeFlixel.")
	#end
	public function new()
	{
		instance = this;
		super();
		if (Sys.args()[0] == "--generate-version-json") {
			var verJson = {
				version: lore.macros.MacroTools.getEngineVersion(),
				gitHash: lore.macros.MacroTools.getGitCommitHash()
			};
			#if sys
			sys.io.File.saveContent('versionInfo.json', haxe.Json.stringify(verJson, "\t"));
			#end
			Sys.exit(0);
			return;
		}
		@:privateAccess Lib.application.window.onResize.add((w, h) -> {
			Main.fpsVar.updatePosition();
			@:privateAccess FlxG.game.soundTray._defaultScale = (w / FlxG.width) * 2;
		});
		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{

		#if desktop Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash); #end

		#if (flixel < "5.0.0")
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}
		#end
	
		ClientPrefs.loadDefaultKeys();
		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		ClientPrefs.loadPrefs();
		if (ClientPrefs.aspectRatio != '16:9') { // not a function to ensure you can't call it from the game
			var _height:Int;
			if (ClientPrefs.aspectRatio.indexOf(':') != -1) {
				var _ratioArray:Array<Int> = [ for (i in ClientPrefs.aspectRatio.split(':')) Std.parseInt(i) ];
				_height = Std.int((1280 / _ratioArray[0]) * _ratioArray[1]);
			}
			else if (ClientPrefs.aspectRatio == 'Device') {
				_height = Std.int((1280 / openfl.system.Capabilities.screenResolutionX) * openfl.system.Capabilities.screenResolutionY);
			}
			else _height = 720;
			gameHeight = _height;
			@:privateAccess Lib.current.stage.__setLogicalSize(gameWidth, gameHeight);
			Lib.application.window.resize(gameWidth, gameHeight);
			Lib.application.window.y -= Std.int((gameHeight - 720) / 2);
		}
		game = new lore.LoreGame(gameWidth, gameHeight, initialState, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash, startFullscreen);
		game.focusLostFramerate = 60;
		addChild(game);
		gameInitialized = true;
		PlayerSettings.init();
		ClientPrefs.loadPrefs();
		FlxG.autoPause = ClientPrefs.pauseOnFocusLost;
		FlxG.signals.gameResized.add(_onResize);

		#if !mobile
		addChild(fpsVar = new lore.FPS(3, 3, 0xffffffff));
		#end
		#if desktop Assets.getImage("assets/images/coconut.jpg"); #end
		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
	

		#if desktop
		if (!Discord.DiscordClient.isInitialized) {
			Discord.DiscordClient.initialize();
			Application.current.window.onClose.add(function() {
				Discord.DiscordClient.shutdown();
			});
		}
		#end
	}

	// fixes shader UV coordinates when the window is resized, thank you eggu.programming from the haxe discord
	private static inline function _onResize(_w, _h) {
		for (i in FlxG.cameras.list) __resetSpriteCache(i);
		__resetSpriteCache(FlxG.game);
	}

	private static inline function __resetSpriteCache(spr:OneOfTwo<Sprite, FlxCamera>):Void {
		if (spr == null) return;
		if (spr is FlxCamera) __resetSpriteCache((spr:FlxCamera).flashSprite);
		else {
			var sprite:Sprite = (spr:Sprite);
			sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	#if desktop
	private final function onCrash(e:UncaughtErrorEvent):Void
		{
			var errMsg:String = "";
			var path:String;
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);
			var dateNow:String = Date.now().toString();
	
			dateNow = StringTools.replace(dateNow, " ", "_");
			dateNow = StringTools.replace(dateNow, ":", "'");
	
			path = "./crash/" + "LoreEngine_" + dateNow + ".txt";
	
			for (stackItem in callStack)
			{
				switch (stackItem)
				{
					case FilePos(s, file, line, column):
						errMsg += file + " (line " + line + ")\n";
					default:
						Sys.println(stackItem);
				}
			}

			if (!FileSystem.exists("./crash/"))
				FileSystem.createDirectory("./crash/");


			errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/dotevie/lore-engine";

			File.saveContent(path, errMsg + "\n");
	
	
			Sys.println(errMsg);
			Sys.println("Crash dump saved in " + Path.normalize(path));
	
			var crashDialoguePath:String = "CrashDialog" #if windows + ".exe" #end;
	

			if (FileSystem.exists("./" + crashDialoguePath))
			{
				Sys.println("Found crash dialog: " + crashDialoguePath);

				#if linux
				crashDialoguePath = "./" + crashDialoguePath;
				#end
				new Process(crashDialoguePath, [path]);
			}
			else
			{
				// I had to do this or the stupid CI won't build :distress:
				Sys.println("No crash dialog found! Making a simple alert instead...");
				Application.current.window.alert(errMsg, "Error!");
			}
			Sys.exit(1);
	
		}
		#end
}
