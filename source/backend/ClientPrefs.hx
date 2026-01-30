package backend;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxRect;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;
import lime.utils.Assets;
import flash.media.Sound;

#if MODS_ALLOWED
import backend.Mods;
#end

class Paths
{
    inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
    inline public static var VIDEO_EXT = "mp4";

    public static var localTrackedAssets:Array<String> = [];
    public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
    public static var currentTrackedSounds:Map<String, Sound> = [];

    public static var currentLevel:String;

    public static function setCurrentLevel(name:String)
    {
        currentLevel = name.toLowerCase();
    }

    public static function getPath(file:String, ?type:AssetType = TEXT, ?library:String = null, ?modsAllowed:Bool = false):String
    {
        #if MODS_ALLOWED
        if(modsAllowed)
        {
            var modFile:String = if(library != null) '$library/$file' else file;
            var modded:String = modFolders(modFile);
            if(sys.FileSystem.exists(modded)) return modded;
        }
        #end

        if(library != null)
            return getLibraryPath(file, library);

        if(currentLevel != null && currentLevel != "shared")
        {
            var levelPath:String = getLibraryPathForce(file, "week_assets", currentLevel);
            if(OpenFlAssets.exists(levelPath, type)) return levelPath;
        }

        return getSharedPath(file);
    }

    public static function getLibraryPath(file:String, library:String = "shared"):String
    {
        return if(library == "shared") getSharedPath(file) else getLibraryPathForce(file, library);
    }

    inline static function getLibraryPathForce(file:String, library:String, ?level:String = null):String
    {
        if(level == null) level = library;
        return '$library:assets/$level/$file';
    }

    inline static public function getSharedPath(file:String = ''):String
    {
        return 'assets/shared/$file';
    }

    // TEXT FILES
    inline static public function txt(key:String, ?library:String) return getPath('data/$key.txt', TEXT, library);
    inline static public function xml(key:String, ?library:String) return getPath('data/$key.xml', TEXT, library);
    inline static public function json(key:String, ?library:String) return getPath('data/$key.json', TEXT, library);
    inline static public function lua(key:String, ?library:String) return getPath('$key.lua', TEXT, library);

    // GRAPHICS
    public static function image(key:String, ?library:String = null):FlxGraphic
    {
        var file:String = getPath('images/$key.png', IMAGE, library);
        if(currentTrackedAssets.exists(file))
        {
            localTrackedAssets.push(file);
            return currentTrackedAssets.get(file);
        }

        var bitmap:BitmapData = null;
        #if MODS_ALLOWED
        var modFile:String = modsImages(key);
        if(sys.FileSystem.exists(modFile)) bitmap = BitmapData.fromFile(modFile);
        #end

        if(bitmap == null)
        {
            if(sys.FileSystem.exists(file)) bitmap = BitmapData.fromFile(file);
            else if(OpenFlAssets.exists(file, IMAGE)) bitmap = OpenFlAssets.getBitmapData(file);
        }

        if(bitmap != null)
        {
            localTrackedAssets.push(file);
            var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
            graphic.persist = true;
            currentTrackedAssets.set(file, graphic);
            return graphic;
        }

        trace('Paths.image: returning null ($file)');
        return null;
    }

    // SOUND
    public static function sound(key:String, ?library:String):Sound
    {
        return returnSound('sounds', key, library);
    }

    public static function music(key:String, ?library:String):Sound
    {
        return returnSound('music', key, library);
    }

    public static function voices(song:String):Sound
    {
        return returnSound('songs', '${formatToSongPath(song)}/Voices', 'songs');
    }

    public static function inst(song:String):Sound
    {
        return returnSound('songs', '${formatToSongPath(song)}/Inst', 'songs');
    }

    public static function returnSound(path:String, key:String, ?library:String):Sound
    {
        var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
        if(!currentTrackedSounds.exists(gottenPath) && OpenFlAssets.exists(gottenPath, SOUND))
        {
            currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(gottenPath));
        }
        localTrackedAssets.push(gottenPath);
        return currentTrackedSounds.get(gottenPath);
    }

    // VIDEO
    public static function video(key:String):String
    {
        #if MODS_ALLOWED
        var file:String = modsVideo(key);
        if(sys.FileSystem.exists(file)) return file;
        #end
        return 'assets/videos/$key.$VIDEO_EXT';
    }

    // HELPERS
    inline static public function formatToSongPath(path:String):String
    {
        var invalidChars = ~/[~&\\;:<>#]/;
        var hideChars = ~/[.,'"%?!]/;
        var path2 = invalidChars.split(path.replace(' ', '-')).join("-");
        return hideChars.split(path2).join("").toLowerCase();
    }

    #if MODS_ALLOWED
    inline static public function mods(key:String = '') return 'mods/' + key;
    inline static public function modsImages(key:String) return modFolders('images/' + key + '.png');
    inline static public function modsVideo(key:String) return modFolders('videos/' + key + '.' + VIDEO_EXT);
    inline static public function modFolders(key:String):String
    {
        if(Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
        {
            var file:String = mods(Mods.currentModDirectory + '/' + key);
            if(sys.FileSystem.exists(file)) return file;
        }

        for(mod in Mods.getGlobalMods())
        {
            var file:String = mods(mod + '/' + key);
            if(sys.FileSystem.exists(file)) return file;
        }

        return 'mods/' + key;
    }
    #end
}