package lore;

class ScriptableSubState extends MusicBeatSubstate {
    public var script:FunkinHX = null;
    public var scriptName:String;
    var temp:FunkinHX->Void;
    override public function new(name:String, ?directory:String = "substates", ?primer:FunkinHX->Void = null) {
        if (primer == null) {
            primer = this.primer;
        } else {
            temp = primer;
            primer = (f:FunkinHX) -> {
                this.primer(f);
                temp(f);
            }
        }
        for (i in FunkinHX.supportedFileTypes) {
            var scriptName:String = '${directory}/${name}.${i}';
            #if MODS_ALLOWED if (#if sys sys.FileSystem.exists #else lime.utils.Assets.exists #end (Paths.modFolders(scriptName))) {
                script = new FunkinHX(Paths.modFolders(scriptName), primer);
            } else #end if (#if sys sys.FileSystem.exists #else lime.utils.Assets.exists #end (Paths.getPreloadPath(scriptName))) {
                script = new FunkinHX(Paths.getPreloadPath(scriptName), primer);
            }
        }
        super();
        cameras = [flixel.FlxG.cameras.list[flixel.FlxG.cameras.list.length - 1]];
    }
    private function primer(script:FunkinHX):Void {
        script.remove("game");
        script.remove("add");
        script.remove("remove");
        script.remove("insert");
        script.remove("indexOf");
        script.remove("addBehindBF");
        script.remove("addBehindGF");
        script.remove("addBehindDad");
        script.remove("PlayState");
        script.set("subState", this);
        script.set("state", this);
        script.set("primaryState", flixel.FlxG.state);
        script.set("close", close);
        //script.set("controls", controls);
        script.set("add", add);
        script.set("remove", remove);
        script.set("insert", insert);
        script.set("indexOf", (item) -> members.indexOf(item));
    }
    public override function create():Void {
        if (script != null) script.runFunc("create", []);
        super.create();
    }
    public function createPost():Void {
        if (script != null) script.runFunc("createPost", []);
    }
    public override function update(elapsed:Float):Void {
        if (ClientPrefs.devMode && flixel.FlxG.keys.justPressed.F8) close();
        if (script != null) script.runFunc("update", [elapsed]);
        super.update(elapsed);
    }
    public function updatePost(elapsed:Float):Void {
        if (script != null) script.runFunc("updatePost", [elapsed]);
    }
    public override function stepHit():Void {
        if (script != null) script.set("curStep", curStep);
        if (script != null) script.runFunc("stepHit", []);
        super.stepHit();
    }
    public override function beatHit():Void {
        if (script != null) script.set("curBeat", curBeat);
        if (script != null) script.runFunc("beatHit", []);
        super.beatHit();
    }
    public override function sectionHit():Void {
        if (script != null) script.set("curSection", curSection);
        if (script != null) script.runFunc("sectionHit", []);
        super.sectionHit();
    }
    public override function destroy():Void {
        if (script != null) script.runFunc("destroy", []);
        if (script != null) script.destroy();
        super.destroy();
    }
}

