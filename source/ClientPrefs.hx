package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import Controls;

class ClientPrefs {
	@:allow(Option) private static var rawMemoryFormat(default, set):String = "MB";
	@:allow(Option) private static function set_rawMemoryFormat(value:String):String {
		if (value == "MB") {
			displayMiB = false;
		} else if (value == "MiB") {
			displayMiB = true;
		}
		return rawMemoryFormat = value;
	}
	public static var decenterStrums:Bool = false;
	public static var devMode:Bool = false;
	public static var showGlyphs:Bool = true;
	public static var scaleMode:String = "LINEAR";
	public static var psychCam:Bool = false;
	public static var psychSustain:Bool = false;
	public static var disableMarv:Bool = false;
	public static var displayMiB:Bool = false;
	public static var aspectRatio:String = '16:9';
	public static var rainbowFPS:Bool = false;
	public static var downScroll:Bool = false;
	public static var showLore:Bool = false;
	public static var showMem:Bool = true;
	public static var persistentCaching:Bool = false;
	public static var ratingScale:Float = 1;
	public static var middleScroll:Bool = false;
	public static var opponentStrums:Bool = true;
	public static var showFPS:Bool = true;
	public static var flashing:Bool = true;
	public static var hitsoundVolume:Float = 1;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var lowQuality:Bool = false;
	public static var shaders:Bool = true;
	public static var framerate:Int = 60;
	public static var underlayAlpha:Float = 0;
	public static var hitSounds:String = "OFF";
	public static var optimization(get, null):Bool = false;
	// realizing now this fucked up more than it fixed and i don't wanna go through all of the code and change it
	public static function get_optimization():Bool {
		return false;
	}
	public static var ignoreSkin:Bool = false;
	public static var fpsPosition:String = "BOTTOM LEFT";
	public static var ratingPosition:String = "HUD";
	public static var showScoreBar:Bool = true;
	public static var bopStyle:String = "LORE";
	public static var colorblindFilter:String = "OFF";
	public static var tinyIcons:Bool = false;
	public static var monoNotes:Bool = false;
	public static var cursing:Bool = true;
	public static var violence:Bool = true;
	public static var camZooms:Bool = true;
	public static var hideHud:Bool = false;
	public static var noteOffset:Int = 0;
	public static var smJudges:Bool = false;
	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public static var pauseOnFocusLost:Bool = true;
	public static var ghostTapping:Bool = true;
	public static var timeBarType:String = 'Time Elapsed / Total';
	public static var locale:String = "en-US";
	public static var scoreZoom:Bool = true;
	public static var noReset:Bool = false;
	public static var healthBarAlpha:Float = 1;
	public static var controllerMode:Bool = false;
	public static var pauseMusic:String = 'Tea Time';
	public static var newTimeBar:Bool = true;
	@:isVar public static var psychTimeBar(get, set):Bool;
	public static function get_psychTimeBar() {
		return !newTimeBar;
	}
	public static function set_psychTimeBar(val:Bool) {
		return newTimeBar = !val;
	}
	public static var showMS:Bool = true;
	public static var checkForUpdates:Bool = true;

	public static var compactFPS:Bool = false;
	public static var showFPSNum:Bool = true;
	public static var skipTransitions:Bool = false;
	public static var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative', 
		// anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
		// an amod example would be chartSpeed * multiplier
		// cmod would just be constantSpeed = chartSpeed
		// and xmod basically works by basing the speed on the bpm.
		// iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
		// bps is calculated by bpm / 60
		// oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
		// just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
		// oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false
	];

	public static var comboOffset:Array<Int> = [0, 0, 0, 0, 0, 0];
	public static var ratingOffset:Int = 0;
	public static var marvWindow:Int = 15;
	public static var sickWindow:Int = 45;
	public static var goodWindow:Int = 90;
	public static var badWindow:Int = 135;
	public static var safeFrames:Float = 10;
	public static var showNoteTimeHitbox:Bool = false;

	//Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_up'		=> [W, UP],
		'note_right'	=> [D, RIGHT],
		
		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_up'			=> [W, UP],
		'ui_right'		=> [D, RIGHT],
		
		'accept'		=> [ENTER, SPACE],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		'reset'			=> [R, NONE],
		
		'volume_mute'	=> [ZERO, NONE],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],
		
		'debug_1'		=> [SEVEN, NONE],
		'debug_2'		=> [EIGHT, NONE]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys() {
		defaultKeys = keyBinds.copy();
		//trace(defaultKeys);
	}

	public static function saveSettings() {
		FlxG.save.data.decenterStrums = decenterStrums;
		FlxG.save.data.devMode = devMode;
		FlxG.save.data.showGlyphs = showGlyphs;
		FlxG.save.data.psychCam = psychCam;
		FlxG.save.data.psychSustain = psychSustain;
		FlxG.save.data.scaleMode = scaleMode;
		FlxG.save.data.disableMarv = disableMarv;
		FlxG.save.data.displayMiB = displayMiB;
		FlxG.save.data.rawMemoryFormat = rawMemoryFormat;
		FlxG.save.data.skipTransitions = skipTransitions;
		FlxG.save.data.aspectRatio = aspectRatio;
		FlxG.save.data.locale = locale;
		FlxG.save.data.ratingPosition = ratingPosition;
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.showMS = showMS;
		FlxG.save.data.showLore = showLore;
		FlxG.save.data.bopStyle = bopStyle;
		FlxG.save.data.colorblindFilter = colorblindFilter;
		FlxG.save.data.middleScroll = middleScroll;
		FlxG.save.data.opponentStrums = opponentStrums;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.showMem = showMem;
		FlxG.save.data.persistentCaching = persistentCaching;
		FlxG.save.data.ratingScale = ratingScale;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.globalAntialiasing = globalAntialiasing;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.tinyIcons = tinyIcons;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.compactFPS = compactFPS;
		FlxG.save.data.showFPSNum = showFPSNum;
		FlxG.save.data.shaders = shaders;
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.hitSounds = hitSounds;
		FlxG.save.data.hitsoundVolume = hitsoundVolume;
		FlxG.save.data.showScoreBar = showScoreBar;
		FlxG.save.data.pauseOnFocusLost = pauseOnFocusLost;
		FlxG.save.data.ignoreSkin = ignoreSkin;
		FlxG.save.data.fpsPosition = fpsPosition;
		FlxG.save.data.monoNotes = monoNotes;
		FlxG.save.data.rainbowFPS = rainbowFPS;
		//FlxG.save.data.cursing = cursing;
		//FlxG.save.data.violence = violence;
		FlxG.save.data.camZooms = camZooms;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.hideHud = hideHud;
		FlxG.save.data.newTimeBar = newTimeBar;
		FlxG.save.data.arrowHSV = arrowHSV;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.timeBarType = timeBarType;
		FlxG.save.data.scoreZoom = scoreZoom;
		FlxG.save.data.noReset = noReset;
		FlxG.save.data.healthBarAlpha = healthBarAlpha;
		FlxG.save.data.comboOffset = comboOffset;
		FlxG.save.data.achievementsMap = Achievements.achievementsMap;
		FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;

		FlxG.save.data.ratingOffset = ratingOffset;
		FlxG.save.data.sickWindow = sickWindow;
		FlxG.save.data.underlayAlpha = underlayAlpha;
		FlxG.save.data.goodWindow = goodWindow;
		FlxG.save.data.badWindow = badWindow;
		FlxG.save.data.safeFrames = safeFrames;
		FlxG.save.data.gameplaySettings = gameplaySettings;
		FlxG.save.data.controllerMode = controllerMode;
		FlxG.save.data.pauseMusic = pauseMusic;
		FlxG.save.data.smJudges = smJudges;
		FlxG.save.data.showNoteTimeHitbox = showNoteTimeHitbox;
		FlxG.save.data.checkForUpdates = checkForUpdates;
	
		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', CoolUtil.getSavePath()); //Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		if (FlxG.save.data.decenterStrums != null) {
			decenterStrums = FlxG.save.data.decenterStrums;
		}
		if (FlxG.save.data.devMode != null) {
			devMode = FlxG.save.data.devMode;
		}
		if(FlxG.save.data.showGlyphs != null) {
			showGlyphs = FlxG.save.data.showGlyphs;
		}
		if(FlxG.save.data.psychCam != null) {
			psychCam = FlxG.save.data.psychCam;
		}
		if(FlxG.save.data.psychSustain != null) {
			psychSustain = FlxG.save.data.psychSustain;
		}
		if(FlxG.save.data.scaleMode != null) {
			scaleMode = FlxG.save.data.scaleMode;
		}
		if(FlxG.save.data.disableMarv != null) {
			disableMarv = FlxG.save.data.disableMarv;
		}
		if(FlxG.save.data.aspectRatio != null) {
			aspectRatio = FlxG.save.data.aspectRatio;
		}
		if(FlxG.save.data.downScroll != null) {
			downScroll = FlxG.save.data.downScroll;
		}
		if(FlxG.save.data.skipTransitions != null) {
			skipTransitions = FlxG.save.data.skipTransitions;
		}
		if(FlxG.save.data.ratingPosition != null) {
			ratingPosition = FlxG.save.data.ratingPosition;
		}
		if(FlxG.save.data.showLore != null) {
			showLore = FlxG.save.data.showLore;
		}
		if(FlxG.save.data.showMS != null) {
			showMS = FlxG.save.data.showMS;
		}
		if(FlxG.save.data.showMem != null) {
			showMem = FlxG.save.data.showMem;
		}
		if(FlxG.save.data.persistentCaching != null) {
			persistentCaching = FlxG.save.data.persistentCaching;
		}
		if(FlxG.save.data.ratingScale != null) {
			ratingScale = FlxG.save.data.ratingScale;
		}
		if(FlxG.save.data.compactFPS != null) {
			compactFPS = FlxG.save.data.compactFPS;
		}
		if(FlxG.save.data.rawMemoryFormat != null) {
			rawMemoryFormat = FlxG.save.data.rawMemoryFormat;
		}
		if(FlxG.save.data.displayMiB != null) {
			displayMiB = FlxG.save.data.displayMiB;
		}
		if(FlxG.save.data.showFPSNum != null) {
			showFPSNum = FlxG.save.data.showFPSNum;
		}
		if(FlxG.save.data.bopStyle != null) {
			bopStyle = FlxG.save.data.bopStyle;
		}
		if(FlxG.save.data.rainbowFPS != null) {
			rainbowFPS = FlxG.save.data.rainbowFPS;
		}
		if(FlxG.save.data.showNoteTimeHitbox != null) {
			showNoteTimeHitbox = FlxG.save.data.showNoteTimeHitbox;
		}
		if(FlxG.save.data.newTimeBar != null) {
			newTimeBar = FlxG.save.data.newTimeBar;
		}
		if(FlxG.save.data.locale != null) {
			locale = FlxG.save.data.locale;
		}
		if(FlxG.save.data.pauseOnFocusLost != null) {
			pauseOnFocusLost = FlxG.save.data.pauseOnFocusLost;
		}
		if(FlxG.save.data.hitsoundVolume != null) {
			hitsoundVolume = FlxG.save.data.hitsoundVolume;
		}
		if(FlxG.save.data.colorblindFilter != null) {
			colorblindFilter = FlxG.save.data.colorblindFilter;
		}
		if(FlxG.save.data.hitSounds != null) {
			hitSounds = FlxG.save.data.hitSounds;
		}
		if(FlxG.save.data.tinyIcons != null) {
			tinyIcons = FlxG.save.data.tinyIcons;
		}
		if(FlxG.save.data.ignoreSkin != null) {
			ignoreSkin = FlxG.save.data.ignoreSkin;
		}
		if(FlxG.save.data.fpsPosition != null) {
			fpsPosition = FlxG.save.data.fpsPosition;
		}
		if(FlxG.save.data.middleScroll != null) {
			middleScroll = FlxG.save.data.middleScroll;
		}
		if(FlxG.save.data.showScoreBar != null) {
			showScoreBar = FlxG.save.data.showScoreBar;
		}
		if(FlxG.save.data.opponentStrums != null) {
			opponentStrums = FlxG.save.data.opponentStrums;
		}
		if(FlxG.save.data.showFPS != null) {
			showFPS = FlxG.save.data.showFPS;
			if(Main.fpsVar != null) {
				Main.fpsVar.set_visibility(showFPS);
			}
		}
		if(FlxG.save.data.flashing != null) {
			flashing = FlxG.save.data.flashing;
		}
		if(FlxG.save.data.smJudges != null) {
			smJudges = FlxG.save.data.smJudges;
		}
		if(FlxG.save.data.globalAntialiasing != null) {
			globalAntialiasing = FlxG.save.data.globalAntialiasing;
		}
		if(FlxG.save.data.noteSplashes != null) {
			noteSplashes = FlxG.save.data.noteSplashes;
		}
		if(FlxG.save.data.lowQuality != null) {
			lowQuality = FlxG.save.data.lowQuality;
		}
		if(FlxG.save.data.shaders != null) {
			shaders = FlxG.save.data.shaders;
		}
		if(FlxG.save.data.framerate != null) {
			framerate = FlxG.save.data.framerate;
			if (Main.gameInitialized) { // prevent crash on startup
				if(framerate > FlxG.drawFramerate) {
					FlxG.updateFramerate = framerate;
					FlxG.drawFramerate = framerate;
				} else {
					FlxG.drawFramerate = framerate;
					FlxG.updateFramerate = framerate;
				}
			}
		}
		/*if(FlxG.save.data.cursing != null) {
			cursing = FlxG.save.data.cursing;
		}
		if(FlxG.save.data.violence != null) {
			violence = FlxG.save.data.violence;
		}*/
		if(FlxG.save.data.camZooms != null) {
			camZooms = FlxG.save.data.camZooms;
		}
		if(FlxG.save.data.hideHud != null) {
			hideHud = FlxG.save.data.hideHud;
		}
		if(FlxG.save.data.noteOffset != null) {
			noteOffset = FlxG.save.data.noteOffset;
		}
		if(FlxG.save.data.arrowHSV != null) {
			arrowHSV = FlxG.save.data.arrowHSV;
		}
		if(FlxG.save.data.ghostTapping != null) {
			ghostTapping = FlxG.save.data.ghostTapping;
		}
		if(FlxG.save.data.timeBarType != null) {
			timeBarType = FlxG.save.data.timeBarType;
		}
		if(FlxG.save.data.scoreZoom != null) {
			scoreZoom = FlxG.save.data.scoreZoom;
		}
		if(FlxG.save.data.noReset != null) {
			noReset = FlxG.save.data.noReset;
		}
		if(FlxG.save.data.healthBarAlpha != null) {
			healthBarAlpha = FlxG.save.data.healthBarAlpha;
		}
		if(FlxG.save.data.comboOffset != null) {
			comboOffset = FlxG.save.data.comboOffset;
		}
		
		if(FlxG.save.data.ratingOffset != null) {
			ratingOffset = FlxG.save.data.ratingOffset;
		}
		if(FlxG.save.data.sickWindow != null) {
			sickWindow = FlxG.save.data.sickWindow;
		}
		if(FlxG.save.data.goodWindow != null) {
			goodWindow = FlxG.save.data.goodWindow;
		}
		if(FlxG.save.data.underlayAlpha != null) {
			underlayAlpha = FlxG.save.data.underlayAlpha;
		}
		if(FlxG.save.data.monoNotes != null) {
			monoNotes = FlxG.save.data.monoNotes;
		}
		if(FlxG.save.data.badWindow != null) {
			badWindow = FlxG.save.data.badWindow;
		}
		if(FlxG.save.data.safeFrames != null) {
			safeFrames = FlxG.save.data.safeFrames;
		}
		if(FlxG.save.data.controllerMode != null) {
			controllerMode = FlxG.save.data.controllerMode;
		}
		if(FlxG.save.data.pauseMusic != null) {
			pauseMusic = FlxG.save.data.pauseMusic;
		}
		if(FlxG.save.data.gameplaySettings != null)
		{
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap)
			{
				gameplaySettings.set(name, value);
			}
		}
		
		if (Main.gameInitialized) {
			// flixel automatically saves your volume!
			if(FlxG.save.data.volume != null)
			{
				FlxG.sound.volume = FlxG.save.data.volume;
			}
			if (FlxG.save.data.mute != null)
			{
				FlxG.sound.muted = FlxG.save.data.mute;
			}
			if (FlxG.save.data.checkForUpdates != null)
			{
				checkForUpdates = FlxG.save.data.checkForUpdates;
			}
			var save:FlxSave = new FlxSave();
			save.bind('controls_v2', CoolUtil.getSavePath());
			if(save != null && save.data.customControls != null) {
				var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
				for (control => keys in loadedControls) {
					keyBinds.set(control, keys);
				}
				reloadControls();
			}
		}
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic):Dynamic {
		return /*PlayState.isStoryMode ? defaultValue : */ (gameplaySettings.exists(name) ? gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		TitleState.muteKeys = copyKey(keyBinds.get('volume_mute'));
		TitleState.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		TitleState.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
	}
	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey> {
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len) {
			if(copiedArray[i] == NONE) {
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}
