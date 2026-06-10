package lore;

import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.FlxG;
import openfl.Lib;
import openfl.system.System;
import flixel.math.FlxMath;

using StringTools;

// Credits to OpenFL repository for the original code
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;
	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;
	@:isVar public var visibility(get, set):Bool = true;
	public function get_visibility():Bool {
		return visible;
	}
	public function set_visibility(value:Bool):Bool {
		return set_visible(value);
	}
	public override function set_visible(val:Bool):Bool {
		super.set_visible(val);
		for (i in borders) i.visible = val;
		return val;
	}
	private final borders:Array<TextField> = new Array<TextField>();
	private var borderSize:Int = 2;

	public var rainbowEnabled(default, set):Bool = false;
	public function set_rainbowEnabled(v:Bool):Bool {
		if (!v) textColor = 0xffffffff;
		return rainbowEnabled = v;
	}

	private var templateText:String = "";
	
	public function new(?x:Float = 3, ?y:Float = 3, ?color:Int = 0xFFFFFFFF)
	{
		super();

		var defText = "0";

		this.x = x;
		width = FlxG.width;
		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("VCR OSD Mono", 16, color);
		text = defText;

		for (i in 0...8) {
			borders.push(new TextField());
			if ([0, 3, 5].contains(i)) borders[i].x = x - borderSize;
			else if ([2, 4, 7].contains(i)) borders[i].x = x + borderSize;
			else borders[i].x = x;
			borders[i].width = FlxG.width;
			borders[i].selectable = false;
			borders[i].mouseEnabled = false;
			borders[i].defaultTextFormat = new TextFormat("VCR OSD Mono", 16, 0xff000000);
			borders[i].text = defText;
			Main.instance.addChild(borders[i]);
		}

		cacheCount = 0;
		currentTime = 0;
		times = [];
		updateFromPrefs();
	}

	// Event Handlers
	@:noCompletion
	private override function __enterFrame(deltaTime:Float):Void
	{
		if (rainbowEnabled) doRainbowThing();
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);
		#if !html5 if (currentFPS > ClientPrefs.framerate) currentFPS = ClientPrefs.framerate; #end

		if (currentCount != cacheCount /*&& visible*/)
		{
			text = ((templateText.replace("{fps}", '${currentFPS}')).replace("{memory}", formatMemory(#if cpp Memory.getCurrentUsage() #else System.totalMemory #end)));
			for (i in borders) i.text = text;
		}

		cacheCount = currentCount;
	}

	public static function formatMemory(Bytes:Float, Precision:Int = 2):String {
		var units:Array<String> = ["B", "KB", "MB", "GB", "TB", "PB"];
		var divisor:Int = ClientPrefs.displayMiB ? { units = ["B", "KiB", "MiB", "GiB", "TiB", "PiB"]; 1024; } : 1000; // i am so sorry
		var curUnit = 0;
		while (Bytes >= divisor && curUnit < units.length - 1) {
			Bytes /= divisor;
			curUnit++;
		}
		return FlxMath.roundDecimal(Bytes, Precision) + ' ${units[curUnit]}';
	}

	public function updateFromPrefs():Void {
		templateText = "";
		var fpsThing:String = " FPS";
		var memThing:String = "Memory: ";
		var loreThing:String = "Lore v";
		if (ClientPrefs.compactFPS) {
			fpsThing = "";
			memThing = "";
			loreThing = "v";
		}
		if (ClientPrefs.showFPSNum) { templateText += '{fps}${fpsThing}'; if (ClientPrefs.showMem || ClientPrefs.showLore) templateText += "\n"; }
		if (ClientPrefs.showMem) { templateText += '${memThing}{memory}'; if (ClientPrefs.showLore) templateText += "\n"; }
		if (ClientPrefs.showLore) { templateText += '${loreThing}${(MainMenuState.loreEngineVersion.endsWith(".0") ? MainMenuState.loreEngineVersion.substr(0, MainMenuState.loreEngineVersion.length - 2) : MainMenuState.loreEngineVersion) } ${MainMenuState.versionSuffix}'; }
		#if debug if (templateText != "") templateText += ' (debug)'; #end
		#if !HIDE_HASH if (MainMenuState.isNotFinal && MainMenuState.commitHash != "") { if (templateText != "") templateText += " "; templateText += '(${MainMenuState.commitHash.substr(0, 6)})'; } #end
		visible = ClientPrefs.showFPS;
		rainbowEnabled = ClientPrefs.rainbowFPS;
		updatePosition();
	}

	public override function set_x(value:Float):Float {
		super.set_x(value);
		for (i in 0...borders.length) {
			if ([0, 3, 5].contains(i)) borders[i].x = value - borderSize;
			else if ([2, 4, 7].contains(i)) borders[i].x = value + borderSize;
			else borders[i].x = value;
		}
		return value;
	}

	public override function set_y(value:Float):Float {
		super.set_y(value);
		for (i in 0...borders.length) {
			if ([0, 1, 2].contains(i)) borders[i].y = value - borderSize;
			else if ([5, 6, 7].contains(i)) borders[i].y = value + borderSize;
			else borders[i].y = value;
		}
		return value;
	}

	public function updatePosition():Void {
		var mod:Int = (templateText.split("\n").length == 2) ? 39 : (templateText.split("\n").length == 3) ? 53 : 22;
		if (ClientPrefs.fpsPosition == "TOP LEFT") y = 3 
		else y = Lib.application.window.height - mod;

	}

	private var hue:Float = 0;

	private function doRainbowThing():Void {
		textColor = fromHSL({hue = (hue + (FlxG.elapsed * 100)) % 360; hue;}, 1, 0.8);
	}

	// in: HSL from 0-360, 0-1, 0-1, out: RGB 0xAARRGGBB
	private static inline function fromHSL(h:Float, s:Float, l:Float) {
		h /= 360;
		var r:Float, g:Float, b:Float;
		if (s == 0.0) {
			r = g = b = l;
		} else {
			var q:Float = l < 0.5 ? l * (1.0 + s) : l + s - l * s;
			var p:Float = 2.0 * l - q;
			r = hue2rgb(p, q, h + 1.0 / 3.0);
			g = hue2rgb(p, q, h);
			b = hue2rgb(p, q, h - 1.0 / 3.0);
		}
		return (Math.round(r * 255) << 16) + (Math.round(g * 255) << 8) + Math.round(b * 255);
	}

	// hue2rgb function
	private static inline function hue2rgb(p:Float, q:Float, h:Float) {
		if (h < 0.0) h += 1.0;
		if (h > 1.0) h -= 1.0;
		if (6.0 * h < 1.0) return p + (q - p) * 6.0 * h;
		if (2.0 * h < 1.0) return q;
		if (3.0 * h < 2.0) return p + (q - p) * ((2.0 / 3.0) - h) * 6.0;
		return p;
	}
	
}

#if cpp
/**
 * Memory class to properly get accurate memory counts
 * for the program.
 * @author Leather128 (Haxe) - David Robert Nadeau (Original C Header)
 */
@:buildXml('<include name="../../../../source/lore/external_stuff/build-memory.xml" />')
@:include("memory.h")
extern class Memory {
	/**
	 * Returns the peak (maximum so far) resident set size (physical
	 * memory use) measured in bytes, or zero if the value cannot be
	 * determined on this OS.
	 */
	@:native("getPeakRSS")
	public static function getPeakUsage():Float;

	/**
	 * Returns the current resident set size (physical memory use) measured
	 * in bytes, or zero if the value cannot be determined on this OS.
	 */
	@:native("getCurrentRSS")
	public static function getCurrentUsage():Float;
}
#else
/**
 * If you are not running on a CPP Platform, the code just will not work properly, sorry!
 * @author Leather128
 */
class Memory {
	/**
	 * (Non cpp platform)
	 * Returns 0.
	 */
	public static function getPeakUsage():Float
		return 0.0;

	/**
	 * (Non cpp platform)
	 * Returns 0.
	 */
	public static function getCurrentUsage():Float
		return 0.0;
}
#end

