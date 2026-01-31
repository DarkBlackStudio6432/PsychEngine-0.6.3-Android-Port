package backend;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;

import lime.utils.Assets;

#if MODS_ALLOWED
import backend.Mods;
import sys.FileSystem;
#end

class Paths
{
    inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
    inline public static var VIDEO_EXT = "mp4";

    public static var currentLevel:String;
    public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
    public static var currentTrackedSounds:Map<String, Sound> = [];
    public static var localTrackedAssets:Array<String> = [];

    public static function setCurrentLevel(name:String):Void
    {
        currentLevel = name.toLowerCase();
    }

    public static function getSharedPath(file:String = ''):String
    {
        return 'assets/shared/$file';
    }

    public static function image(key:String, ?library:String = null):FlxGraphic
    {
        var path = getSharedPath('images/$key.png');

        if (currentTrackedAssets.exists(path))
            return currentTrackedAssets.get(path);

        if (OpenFlAssets.exists(path, IMAGE))
        {
            var bmp = OpenFlAssets.getBitmapData(path);
            var gfx = FlxGraphic.fromBitmapData(bmp, false, path);
            gfx.persist = true;
            currentTrackedAssets.set(path, gfx);
            return gfx;
        }

        return null;
    }

    public static function sound(key:String):Sound
    {
        var path = getSharedPath('sounds/$key.$SOUND_EXT');

        if (currentTrackedSounds.exists(path))
            return currentTrackedSounds.get(path);

        if (OpenFlAssets.exists(path, SOUND))
        {
            var snd = OpenFlAssets.getSound(path);
            currentTrackedSounds.set(path, snd);
            return snd;
        }

        return null;
    }

    public static function clearUnusedMemory():Void
    {
        System.gc();
    }
}