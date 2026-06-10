package;

import editors.WeekEditorState;
import editors.MasterEditorMenu;
import editors.DialogueCharacterEditorState;
import editors.DialogueEditorState;
import editors.CharacterEditorState;
import lore.ScriptableState;
import lore.ModdedState;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;
import flixel.FlxCamera;
import lore.ControlGlyphsGroup;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class MusicBeatState extends FlxUIState
{
	private static var __exists(default, null):String->Bool = #if sys sys.FileSystem.exists #else lime.utils.Assets.exists #end;
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	public static var camBeat:FlxCamera;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;


	override public function new() {
		super();
		PlayState.inPlayState = (Type.getClass(this) == PlayState);
	}

	override function destroy() {
		WinAPI.setCloseButtonEnabled(true);
		super.destroy();
	}

	override function create() {
		camBeat = FlxG.camera;
		var skip:Bool = FlxTransitionableState.skipNextTransOut || ClientPrefs.skipTransitions;
		super.create();

		if(!skip) {
			openSubState(new CustomFadeTransition(0.7, true));
		}
		FlxTransitionableState.skipNextTransOut = false;
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		if(FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
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
	
	public static function switchState(nextState:FlxState) {
		var className = Type.getClassName(Type.getClass(nextState));
		var stateIsNotOverrideable = false;
		for (i in StaticThingVSCWarningGetterArounder.deniedStates) if (Type.getClass(nextState) == i) stateIsNotOverrideable = true;
		var t = [ for (i in lore.FunkinHX.supportedFileTypes) __exists(Paths.modFolders('states/override/${className}.${i}')) ];
		if (t.contains(true) && !stateIsNotOverrideable) {
			nextState.destroy();
			__actualSwitchState(new lore.ScriptableState(className, 'states/override'));
		} else {
			__actualSwitchState(nextState);
		}
	}

	private static function __actualSwitchState(nextState:FlxState) {
		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		CoolUtil.lastState = Type.getClass(curState); // just to get rid of maybe loop yellow underline in vscode
		if(!FlxTransitionableState.skipNextTransIn && !ClientPrefs.skipTransitions) {
			leState.openSubState(new CustomFadeTransition(0.6, false));
			if(nextState == FlxG.state) {
				CustomFadeTransition.finishCallback = function() {
					FlxG.resetState();
				};
				//trace('resetted');
			} else {
				CustomFadeTransition.finishCallback = function() {
					FlxG.switchState(nextState);
				};
				//trace('changed state');
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState() {
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//trace('Beat: ' + curBeat);
	}

	public function sectionHit():Void
	{
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}

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
		createControlGlyphs(cam ?? FlxG.camera, [["Navigate", "ui_up,ui_down", "DPAD_UP,DPAD_DOWN"], ["Select", "accept", #if !switch "A" #else "B" #end], ["Back", "back", #if !switch "B" #else "A" #end]], true);
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

@:allow(MusicBeatState)
private class StaticThingVSCWarningGetterArounder {
	private static var deniedStates(default, null):Array<Class<FlxState>> = [
		ModdedState,
		ScriptableState,
		PlayState,
		options.OptionsState,
		ModsMenuState,
		CharacterEditorState,
		editors.ChartingState,
		DialogueEditorState,
		DialogueCharacterEditorState,
		MasterEditorMenu,
		WeekEditorState,
		WeekEditorFreeplayState,
		editors.EditorPlayState,
		//TitleState,
		lore.InitState,
		lore.CrashState
	];
}
