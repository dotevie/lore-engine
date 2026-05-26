package lore;

import flixel.math.FlxPoint;
import shadertoy.FlxShaderToyRuntimeShader;
import hscript.Parser;
import hscript.Interp;
import hscript.Expr;
import flixel.FlxG;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import #if html5 lime.utils.Assets; #else sys.io.File; #end
#if sys import flixel.system.macros.FlxMacroUtil; #end

using StringTools;

/**
 * This is where all of the hscript stuff that isn't for FunkinLua is.
 * 
 * You can find all of that stuff in FunkinLua.HScript.\
 * 
 * getExprFromString and the import code (as well as the inspiration for this file in general) is owed to YoshiCrafter29.
 * 
 * Feel free to add any lua callbacks I forgot, and merge them as PRs, ifzz you wish.
 * 
 * @see http://github.com/YoshiCrafter29/YoshiCrafterEngine
 */
 

class FunkinHX implements IFlxDestroyable {
    public static var supportedFileTypes(default, null):Array<String> = ["fnf" /* hi gray */, "hscript", "hsc", "hxs", "hx"]; // if multiple files exist, this list in reverse is the priority order
    private var interp:Interp;
    public var scriptName:String = "unknown";
    public var scriptType:HScriptType = NOEXEC;
    public var loaded:Bool = false;
    public var ignoreErrors:Bool = false;
    private var identifier:Null<String> = null;
    public static final println:String->Void = #if sys Sys.println #elseif js js.Browser.console.log #end;
    
    public static function inlineCast<T>(v:Dynamic, t:Class<T>) {
        var c:T = cast v;
        return c;
    }

    public function destroy():Void {
        interp = null;
        scriptName = null;
        loaded = false;
    }

    public function traace(text:String):Void {
        var posInfo = interp.posInfos();
        println(scriptName + ":" + posInfo.lineNumber + ": " + text);
    }

    public function interpVarExists(k:String):Bool {
        if (interp != null) {
            return interp.variables.exists(k);
        }
        return false;
    }
    public function set(k:String, v:Dynamic):Void {
        if (interp != null) interp.variables.set(k, v);
    }

    public function get(k:String):Dynamic {
        if (interp != null) return interp.variables.get(k);
        return null;
    }

    public function remove(k:String):Void {
        if (interp != null) interp.variables.remove(k);
    }

    private var __blocked:Bool = false;
    public function new(?f:String, ?primer:FunkinHX->Void = null, ?type:HScriptType = FILE):Void {
        scriptName = f;
        scriptType = type;
        var ttr:String = null;
        if (type == FILE) {
            ttr = #if sys File.getContent #else Assets.getText #end (f);
        } else if (type == STRING) {
            ttr = f;
        }
        var tempBuf = new StringBuf();
        var tempArray = ttr.split("\n");
        for (i in tempArray) tempBuf.add(i + "\n");
        ttr = tempBuf.toString();
        interp = new Interp();
            if (PlayState.inPlayState) {
                set('setScriptIdentifier', (s:String) -> identifier = s);
                set('getScriptFromIdentifier', (s:String) -> {
                    for (i in PlayState.instance.haxeArray) {
                        if (i.identifier == s && i.identifier != null) return i;
                    };
                    return null;
                });
            }
            set("async", (f:Void->Void) -> {
                #if sys
                sys.thread.Thread.create(f);
                #else
                FlxG.log.warn("Non-sys platform detected, function will run on main thread.");
                f();
                #end
            });
            set("DiscordClient", Discord.DiscordClient);
            set('preloadImage', function(s:String):Void { Paths.image(s); });
            set('preloadSound', function(s:String):Void { Paths.sound(s); });
            set('preloadMusic', function(s:String):Void { Paths.music(s); });
            set('FlxG', flixel.FlxG);
            set('FlxSprite', flixel.FlxSprite);
            set('FlxCamera', flixel.FlxCamera);
            set('FlxTimer', flixel.util.FlxTimer);
            set('FlxTween', flixel.tweens.FlxTween);
            set('FlxEase', flixel.tweens.FlxEase);
            set('FlxText', flixel.text.FlxText);
            set('PlayState', PlayState);
            set('game', PlayState.instance);
            set('Paths', Paths);
            set('Conductor', Conductor);
            set('ClientPrefs', ClientPrefs);
            set('Character', Character);
            set('Alphabet', Alphabet);
            set('PauseSubState', PauseSubState);
            set('Json', haxe.Json);
            set("curBeat", 0);
            set("curStep", 0);
            set("curSection", 0);
            #if !flash
            set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
            set('FlxShaderToyRuntimeShader', FlxShaderToyRuntimeShader);
            set('ShaderFilter', openfl.filters.ShaderFilter);
            #end
            set('StringTools', StringTools);
    
            set('setVar', function(name:String, value:Dynamic)
            {
                PlayState.instance.variables.set(name, value);
            });
            set('getVar', function(name:String)
            {
                var result:Dynamic = null;
                if(PlayState.instance.variables.exists(name)) result = PlayState.instance.variables.get(name);
                return result;
            });
            set('removeVar', function(name:String)
            {
                if(PlayState.instance.variables.exists(name))
                {
                    PlayState.instance.variables.remove(name);
                    return true;
                }
                return false;
            });
            set("Sys", Sys);
            set("Math", Math);
            set("Type", Type);
            set("Std", Std);
            if (PlayState.inPlayState && PlayState.instance != null) {
                set("add", PlayState.instance.add);
                set("addBehindDad", PlayState.instance.addBehindDad);
                set("addBehindGF", PlayState.instance.addBehindGF);
                set("addBehindBF", PlayState.instance.addBehindBF);
                set("remove", PlayState.instance.remove);
                set("insert", PlayState.instance.insert);
                set("indexOf", PlayState.instance.members.indexOf);
                set("openSubState", PlayState.instance.openSubState);
            }
            set("create", function() {});
            set("createPost", function() {});
            set("update", function(elapsed:Float) {});
            set("updatePost", function(elapsed:Float) {});
            set("startCountdown", function() {});
            set("onCountdownStarted", function() {});
            set("onCountdownTick", function(tick:Int) {});
            set("onUpdateScore", function(miss:Bool) {});
            set("onNextDialogue", function(counter:Int) {});
            set("onSkipDialogue", function() {});
            set("onSongStart", function() {});
            set("eventEarlyTrigger", function(eventName:String) {});
            set("onResume", function() {});
            set("onPause", function() {});
            set("onSpawnNote", function(note:Note) {});
            set("onGameOver", function() {});
            set("onEvent", function(name:String, val1:Dynamic, val2:Dynamic) {});
            set("onMoveCamera", function(char:String) {});
            set("onEndSong", function() {});
            set("onGhostTap", function(key:Int) {});
            set("onKeyPress", function(key:Int) {});
            set("onKeyRelease", function(key:Int) {});
            set("noteMiss", function(note:Note) {});
            set("noteMissPress", function(direction:Int) {});
            set("opponentNoteHit", function(note:Note) {});
            set("goodNoteHit", function(note:Note) {});
            set("noteHit", function(note:Note) {});
            set("stepHit", function() {});
            set("beatHit", function() {});
            set("sectionHit", function() {});
            set("onRecalculateRating", function() {});
            set("Function_Stop", FunkinLua.Function_Stop);
            set("Function_StopScript", FunkinLua.Function_StopLua);
            set("Function_StopLua", FunkinLua.Function_StopLua); // just in case
            set("onIconUpdate", function(p:String) {});
            set("onHeadBop", function(name:String) {});
            set("onGameOverStart", function() {});
            set("onGameOverConfirm", function() {});
            set("onPauseMenuSelect", function(name:String) {});
            set("onOpenPauseMenu", function() {});
            set("onChangeCharacter", function(name:String, charObject:Character) {});
            set("Std", Std);
            set("WinAPI", WinAPI);
            set("script", this);
            set("destroy", function() {});
            set("Note", Note);
            set("trace", traace);
            set("X", flixel.util.FlxAxes.X);
            set("Y", flixel.util.FlxAxes.Y);
            set("XY", flixel.util.FlxAxes.XY);
            set("switchState", MusicBeatState.switchState);
            set("ModdedState", ModdedState);
            set("ModdedSubState", ModdedSubState);
            set("FlxAxes", MacroTools.getAbstract(flixel.util.FlxAxes));
            set("FlxColor", MacroTools.getAbstract(flixel.util.FlxColor));
            set("FlxKey", MacroTools.getAbstract(flixel.input.keyboard.FlxKey));
            set("FlxPoint", flixel.math.FlxPoint.FlxBasePoint);
            set("HScriptType", MacroTools.getAbstract(HScriptType));
            set("cast", inlineCast);
            set("CoolUtil", CoolUtil);
            if (primer != null) primer(this);

            if (ttr != null) try {
                interp.execute(getExprFromString(ttr, true));
                trace("haxe file loaded successfully: " + f);
                loaded = true;
            } catch (e:Dynamic) traace('$e');
    }


    public static function getExprFromString(code:String, critical:Bool = false, ?path:String):Expr
        {
            if (code == null)
                return null;
            var parser = new hscript.Parser();
            parser.allowTypes = parser.allowMetadata = true;
            var ast:Expr = null;
            try
            {
                ast = parser.parseString(code);
            }
            catch (ex)
            {
                trace(ex);
                var exThingy = Std.string(ex);
                var line = parser.line;
                if (path != null)
                {
                    if (!openfl.Lib.application.window.fullscreen && critical)
                        openfl.Lib.application.window.alert('Failed to parse the file located at "$path".\r\n$exThingy at $line');
                    trace('Failed to parse the file located at "$path".\r\n$exThingy at $line');
                }
                else
                {
                    if (!openfl.Lib.application.window.fullscreen && critical)
                        openfl.Lib.application.window.alert('Failed to parse the given code.\r\n$exThingy at $line');
                    trace('Failed to parse the given code.\r\n$exThingy at $line');
                    if (!critical)
                        throw new haxe.Exception('Failed to parse the given code.\r\n$exThingy at $line');
                }
            }
            return ast;
        }

        public var lastReturn:Dynamic = null;

        public function runFunc(f:String, ?args:Array<Dynamic>):Any {
            if (!loaded) {
                lastReturn = null;
                return null;
            }
            if (args == null) args = [];
            try {
                lastReturn = interp.callMethod(f, args);
                return lastReturn;
            } catch (e:Dynamic) {
                if (!ignoreErrors) {
                    if ((ClientPrefs.devMode && !FlxG.keys.pressed.SHIFT && !__blocked) || !(FlxG.state is PlayState)) {
                        openfl.Lib.application.window.alert('Error with script: ' + scriptName + ' at line ' + interp.posInfos().lineNumber + ":\n" + Std.string(e).split('hscript:${interp.posInfos().lineNumber}: ')[1] + '\n\nHold SHIFT to bypass the error if it\'s blocking gameplay.', 'Haxe script error');
                        sys.thread.Thread.create(() -> {
                            __blocked = true;
                            inline CoolUtil.blockExecution(0.125);
                            __blocked = false;
                        });
                    }
                    else if (FlxG.state is PlayState) {
                        PlayState.instance.addTextToDebug('$scriptName:${interp.posInfos().lineNumber}: ${Std.string(e).split('hscript:${interp.posInfos().lineNumber}: ')[1]}', 0xffff0000);
                    }
                }
                lastReturn = null;
                return null;
            }
            lastReturn = null;
            return null;
        }

        public function execute(code:String):Any {
            if (!loaded) return null;
            try {
                return interp.execute(getExprFromString(code, true));
            } catch (e:Dynamic) trace('$e');
            return null;
        }
    
}

enum abstract HScriptType(Int) from Int to Int {
    var FILE = 0;
    var STRING = 1;
    var NOEXEC = 2;
}
