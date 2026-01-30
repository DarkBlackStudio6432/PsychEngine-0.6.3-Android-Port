package backend;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

@:structInit
class SaveVariables {
    public var unfairGimmicks:Bool = true;
    public var trickyExperience:Bool = false;

    public var downScroll:Bool = false;
    public var middleScroll:Bool = false;
    public var opponentStrums:Bool = true;
    public var showFPS:Bool = true;
    public var flashing:Bool = true;
    public var autoPause:Bool = true;
    public var antialiasing:Bool = true;
    public var hitbox:Float = 1.0;
    public var noteSkin:String = "Default";
    public var splashSkin:String = "Psych";
    public var splashAlpha:Float = 0.6;
    public var lowQuality:Bool = false;
    public var shaders:Bool = true;
    public var cacheOnGPU:Bool = #if !switch false #else true #end;
    public var framerate:Int = 60;
    public var camZooms:Bool = true;
    public var hideHud:Bool = false;
    public var noteOffset:Int = 0;

    public var arrowRGB:Array<Array<FlxColor>> = [
        [0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
        [0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
        [0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
        [0xFFF9393F, 0xFFFFFFFF, 0xFF651038]
    ];
    public var arrowRGBPixel:Array<Array<FlxColor>> = [
        [0xFFE276FF, 0xFFFFF9FF, 0xFF60008D],
        [0xFF3DCAFF, 0xFFF4FFFF, 0xFF003060],
        [0xFF71E300, 0xFFF6FFE6, 0xFF003100],
        [0xFFFF884E, 0xFFFFFAF5, 0xFF6C0000]
    ];

    public var ghostTapping:Bool = true;
    public var timeBarType:String = "Time Left";
    public var scoreZoom:Bool = true;
    public var noReset:Bool = false;
    public var healthBarAlpha:Float = 1;
    public var hitsoundVolume:Float = 0;
    public var pauseMusic:String = "Tea Time";
    public var checkForUpdates:Bool = true;
    public var comboStacking:Bool = true;

    public var gameplaySettings:Map<String, Dynamic> = [
        "scrollspeed" => 1.0,
        "scrolltype" => "multiplicative",
        "songspeed" => 1.0,
        "healthgain" => 1.0,
        "healthloss" => 1.0,
        "instakill" => false,
        "practice" => false,
        "botplay" => false,
        "opponentplay" => false
    ];

    public var comboOffset:Array<Int> = [0,0,0,0];
    public var ratingOffset:Int = 0;
    public var sickWindow:Int = 45;
    public var goodWindow:Int = 90;
    public var badWindow:Int = 135;
    public var safeFrames:Float = 10;
    public var guitarHeroSustains:Bool = true;
    public var discordRPC:Bool = true;
}

class ClientPrefs {
    public static var data:SaveVariables = {};
    public static var defaultData:SaveVariables = {};

    public static var keyBinds:Map<String, Array<FlxKey>> = [
        "note_up" => [W, UP],
        "note_left" => [A, LEFT],
        "note_down" => [S, DOWN],
        "note_right" => [D, RIGHT],

        "ui_up" => [W, UP],
        "ui_left" => [A, LEFT],
        "ui_down" => [S, DOWN],
        "ui_right" => [D, RIGHT],

        "accept" => [SPACE, ENTER],
        "back" => [BACKSPACE, ESCAPE],
        "pause" => [ENTER, ESCAPE],
        "reset" => [R],

        "volume_mute" => [ZERO],
        "volume_up" => [NUMPADPLUS, PLUS],
        "volume_down" => [NUMPADMINUS, MINUS],

        "debug_1" => [SEVEN],
        "debug_2" => [EIGHT]
    ];

    public static var gamepadBinds:Map<String, Array<FlxGamepadInputID>> = [
        "note_up" => [DPAD_UP, Y],
        "note_left" => [DPAD_LEFT, X],
        "note_down" => [DPAD_DOWN, A],
        "note_right" => [DPAD_RIGHT, B],

        "ui_up" => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
        "ui_left" => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
        "ui_down" => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
        "ui_right" => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],

        "accept" => [A, START],
        "back" => [B],
        "pause" => [START],
        "reset" => [BACK]
    ];

    public static var defaultKeys:Map<String, Array<FlxKey>> = null;
    public static var defaultButtons:Map<String, Array<FlxGamepadInputID>> = null;

    public static function loadDefaultKeys() {
        defaultKeys = keyBinds.copy();
        defaultButtons = gamepadBinds.copy();
    }

    public static function resetKeys(controller:Null<Bool> = null) {
        if(controller != true)
            for (key in keyBinds.keys())
                if(defaultKeys.exists(key))
                    keyBinds.set(key, defaultKeys.get(key).copy());

        if(controller != false)
            for (button in gamepadBinds.keys())
                if(defaultButtons.exists(button))
                    gamepadBinds.set(button, defaultButtons.get(button).copy());
    }

    public static function loadPrefs():Void {
        var save:FlxSave = new FlxSave();
        if(save.bind("clientPrefs") && save.data != null) {
            data = save.data;
        } else {
            data = defaultData;
        }
    }

    public static function saveSettings():Void {
        var save:FlxSave = new FlxSave();
        if(save.bind("clientPrefs")) {
            save.data = data;
            save.flush();
        }
    }

    public static function getGameplaySetting(name:String, defaultValue:Dynamic = null):Dynamic {
        if(defaultValue == null) defaultValue = defaultData.gameplaySettings.get(name);
        return data.gameplaySettings.exists(name) ? data.gameplaySettings.get(name) : defaultValue;
    }
}