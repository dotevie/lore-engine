package;

import Conductor.BPMChangeEvent;
import flixel.FlxSubState;
import lore.ControlGlyphsGroup;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var curSection:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var curDecSection:Float = 0;

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();
		updateSection();

		if (oldStep != curStep && curStep > 0)
			stepHit();


		super.update(elapsed);
	}

	private function updateSection():Void
	{
		curSection = Math.floor(curBeat / 4);
		curDecSection = curDecBeat/4;
	}
	
	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		if (curBeat % 4 == 0)
			sectionHit();
	}

	public function sectionHit():Void {}

	private var glyphs:Array<ControlGlyphsGroup> = [];
	private var glyphBox:FlxSprite = null;
	private var glyphCamera:FlxCamera;
	// [name, (keyboard glyphs (comma separated), gamepad glyphs (comma separated)]
	public function createControlGlyphs(destinationCamera:FlxCamera, options:Array<Array<String>>, ?drawBox:Bool = true) {
		if (!ClientPrefs.showGlyphs) return;
		glyphCamera = destinationCamera;
		for (i in glyphs) {
			glyphs.remove(i);
			i.destroy();
			if (glyphBox != null) {
				remove(glyphBox);
				glyphBox.destroy();
				glyphBox = null;
			}
		}
		var startY:Float = FlxG.height;
		var startIndex:Int = options.length - 1;
		while (startIndex >= 0) {
			var curArr:Array<String> = options[startIndex];
			if (curArr[2] == "" && ClientPrefs.controllerMode) {
				startIndex--;
				continue; // Skip if no gamepad glyphs are provided and controller mode is enabled
			}
			var glyph = new ControlGlyphsGroup(curArr[0], curArr[1].split(','), curArr[2].split(','));
			glyph.x = FlxG.width - 16 - glyph.width;
			glyph.y = startY - glyph.height - 16;
			glyph.scrollFactor.set();
			glyph.camera = destinationCamera;
			glyphs.push(glyph);
			add(glyph);
			startY = glyph.y;
			startIndex--;
		}
		if (drawBox) drawBoxUnderControlGlyphs();
	}

	public function createDefaultControlGlyphs(?cam:FlxCamera) {
		createControlGlyphs(cam ?? camera, [["Navigate", "ui_up,ui_down", "DPAD_UP,DPAD_DOWN"], ["Select", "accept", #if !switch "A" #else "B" #end], ["Back", "back", #if !switch "B" #else "A" #end]], true);
	}

	public function drawBoxUnderControlGlyphs(?color:FlxColor = 0xff000000, ?alpha:Float = 0.6, ?padding:Int = 10) {
		if (glyphs.length == 0) {
			trace("drawBoxUnderControlGlyphs: no glyphs");
			return;
		}
		var index = members.indexOf(glyphs[0]);
		var startY = glyphs[glyphs.length - 1].y - padding;
		var startX:Float = 100000;
		for (i in glyphs) {
			if (i.x < startX) startX = i.x;
		}
		startX = startX - padding;
		glyphBox = new FlxSprite(startX, startY).makeGraphic(Math.ceil(FlxG.width - startX), Math.ceil(FlxG.height - startY), color);
		glyphBox.alpha = alpha;
		glyphBox.camera = glyphCamera;
		glyphBox.scrollFactor.set();
		insert(index, glyphBox);
	}
}
