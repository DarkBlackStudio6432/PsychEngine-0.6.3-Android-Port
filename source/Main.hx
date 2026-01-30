package;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import flixel.FlxGame;
import flixel.FlxG;

import backend.ClientPrefs;
import backend.Paths;
import backend.Highscore;
import states.TitleState;
import backend.FPSCounter; // Certifique que esse arquivo existe no backend

#if mobile
import mobile.backend.CrashHandler;
import mobile.backend.StorageUtil;
#end
#if linux
import lime.graphics.Image;

@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
    #define GAMEMODE_AUTO
')
#end

class Main extends Sprite
{
    var game = {
        width: 1280,
        height: 720,
        initialState: TitleState,
        zoom: -1.0,
        framerate: 60,
        skipSplash: true,
        startFullscreen: false
    };

    public static var fpsVar:FPSCounter;

    public static final platform:String = #if mobile "Phones" #else "PCs" #end;

    public static function main():Void
    {
        Lib.current.addChild(new Main());
        #if cpp
        cpp.NativeGc.enable(true);
        #elseif hl
        hl.Gc.enable(true);
        #end
    }

    public function new()
    {
        super();

        #if mobile
        #if android
        StorageUtil.requestPermissions();
        #end
        Sys.setCwd(StorageUtil.getStorageDirectory());
        #end

        CrashHandler.init();

        if (stage != null)
            init();
        else
            addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(?E:Event):Void
    {
        if (hasEventListener(Event.ADDED_TO_STAGE))
            removeEventListener(Event.ADDED_TO_STAGE, init);

        setupGame();
    }

    private function setupGame():Void
    {
        if (game.zoom == -1.0)
            game.zoom = 1.0;

        ClientPrefs.loadDefaultKeys();

        addChild(new FlxGame(
            game.width,
            game.height,
            game.initialState,
            game.framerate,
            game.framerate,
            game.skipSplash,
            game.startFullscreen
        ));

        fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
        addChild(fpsVar);
        Lib.current.stage.align = "tl";
        Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
        fpsVar.visible = ClientPrefs.showFPS;

        #if linux
        var icon = Image.fromFile("icon.png");
        Lib.current.stage.window.setIcon(icon);
        #end
    }
}