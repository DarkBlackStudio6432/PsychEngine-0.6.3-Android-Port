package backend;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxRect;

import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;
import openfl.geom.Rectangle;

import lime.utils.Assets;
import flash.media.Sound;

#if MODS_ALLOWED
import backend.Mods;
import sys.io.File;
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
    public static var dumpExclusions:Array<String> = ['assets/shared/music/freakyMenu.$SOUND_EXT'];

    // --------------------------
    // LEVEL & PATH HELPERS
    // --------------------------
    public static function setCurrentLevel(name:String) {
        currentLevel = name.toLowerCase();
    }

    public static function getPath(file:String, ?type:AssetType = TEXT, ?library:Null<String> = null, ?modsAllowed:Bool = false):String
    {
        #if MODS_ALLOWED
        if(modsAllowed)
        {
            var modFile:String = (library != null) ? '$library/$file' : file;
            var modded:String = modFolders(modFile);
            if(FileSystem.exists(modded)) return modded;
        }
        #end

        if(library != null) return getLibraryPath(file, library);

        if(currentLevel != null && currentLevel != 'shared')
        {
            var lvlPath:String = getLibraryPathForce(file, 'week_assets', currentLevel);
            if(OpenFlAssets.exists(lvlPath, type)) return lvlPath;
        }

        return getSharedPath(file);
    }

    static public function getLibraryPath(file:String, library = "shared") {
        return (library == "shared") ? getSharedPath(file) : getLibraryPathForce(file, library);
    }

    inline static function getLibraryPathForce(file:String, library:String, ?level:String) {
        if(level == null) level = library;
        return '$library:assets/$level/$file';
    }

    inline public static function getSharedPath(file:String = '') {
        return 'assets/shared/$file';
    }

    // --------------------------
    // FILE HELPERS
    // --------------------------
    inline public static function txt(key:String, ?library:String) { return getPath('data/$key.txt', TEXT, library); }
    inline public static function xml(key:String, ?library:String) { return getPath('data/$key.xml', TEXT, library); }
    inline public static function json(key:String, ?library:String) { return getPath('data/$key.json', TEXT, library); }
    inline public static function lua(key:String, ?library:String) { return getPath('$key.lua', TEXT, library); }
    inline public static function shaderFragment(key:String, ?library:String) { return getPath('shaders/$key.frag', TEXT, library); }
    inline public static function shaderVertex(key:String, ?library:String) { return getPath('shaders/$key.vert', TEXT, library); }

    static public function video(key:String) {
        #if MODS_ALLOWED
        var file:String = modsVideo(key);
        if(FileSystem.exists(file)) return file;
        #end
        return 'assets/videos/$key.$VIDEO_EXT';
    }

    // --------------------------
    // AUDIO HELPERS
    // --------------------------
    static public function sound(key:String, ?library:String):Sound {
        return returnSound('sounds', key, library);
    }

    inline static public function music(key:String, ?library:String):Sound {
        return returnSound('music', key, library);
    }

    inline static public function voices(song:String, postfix:String = null):Sound {
        var songKey = '${formatToSongPath(song)}/Voices';
        if(postfix != null) songKey += '-' + postfix;
        return returnSound(null, songKey, 'songs');
    }

    inline static public function inst(song:String):Sound {
        var songKey = '${formatToSongPath(song)}/Inst';
        return returnSound(null, songKey, 'songs');
    }

    public static function returnSound(path:Null<String>, key:String, ?library:String):Sound {
        #if MODS_ALLOWED
        var modLibPath:String = '';
        if(library != null) modLibPath = '$library/';
        if(path != null) modLibPath += '$path';

        var file:String = modsSounds(modLibPath, key);
        if(FileSystem.exists(file))
        {
            if(!currentTrackedSounds.exists(file)) currentTrackedSounds.set(file, Sound.fromFile(file));
            localTrackedAssets.push(file);
            return currentTrackedSounds.get(file);
        }
        #end

        var gottenPath:String = '$key.$SOUND_EXT';
        if(path != null) gottenPath = '$path/$gottenPath';
        gottenPath = getPath(gottenPath, SOUND, library);
        gottenPath = gottenPath.substring(Math.max(gottenPath.indexOf(':') + 1,0), gottenPath.length);

        if(!currentTrackedSounds.exists(gottenPath))
        {
            var retKey:String = (path != null) ? '$path/$key' : key;
            retKey = ((path == 'songs') ? 'songs:' : '') + getPath('$retKey.$SOUND_EXT', SOUND, library);
            if(OpenFlAssets.exists(retKey, SOUND)) currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(retKey));
        }

        localTrackedAssets.push(gottenPath);
        return currentTrackedSounds.get(gottenPath);
    }

    // --------------------------
    // IMAGE HELPERS
    // --------------------------
    static public function image(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxGraphic
    {
        var bitmap:BitmapData = null;
        var file:String = null;

        #if MODS_ALLOWED
        file = modsImages(key);
        if(currentTrackedAssets.exists(file)) { localTrackedAssets.push(file); return currentTrackedAssets.get(file); }
        else if(FileSystem.exists(file)) bitmap = BitmapData.fromFile(file);
        else
        #end
        {
            file = getPath('images/$key.png', IMAGE, library);
            if(currentTrackedAssets.exists(file)) { localTrackedAssets.push(file); return currentTrackedAssets.get(file); }
            else if(FileSystem.exists(file)) bitmap = BitmapData.fromFile(file);
            else if(OpenFlAssets.exists(file, IMAGE)) bitmap = OpenFlAssets.getBitmapData(file);
        }

        if(bitmap != null) return cacheBitmap(file, bitmap, allowGPU);
        trace('oh no its returning null NOOOO ($file)');
        return null;
    }

    static public function cacheBitmap(file:String, ?bitmap:BitmapData = null, ?allowGPU:Bool = true):FlxGraphic
    {
        if(bitmap == null)
        {
            #if MODS_ALLOWED
            if(FileSystem.exists(file)) bitmap = BitmapData.fromFile(file);
            else
            #end
            if(OpenFlAssets.exists(file, IMAGE)) bitmap = OpenFlAssets.getBitmapData(file);
            if(bitmap == null) return null;
        }

        localTrackedAssets.push(file);

        if(allowGPU && ClientPrefs.data != null && ClientPrefs.data.cacheOnGPU)
        {
            var texture:RectangleTexture = FlxG.stage.context3D.createRectangleTexture(bitmap.width, bitmap.height, BGRA, true);
            texture.uploadFromBitmapData(bitmap);
            bitmap.image.data = null;
            bitmap.dispose();
            bitmap.disposeImage();
            bitmap = BitmapData.fromTexture(texture);
        }

        var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
        newGraphic.persist = true;
        newGraphic.destroyOnNoUse = false;
        currentTrackedAssets.set(file, newGraphic);
        return newGraphic;
    }

    // --------------------------
    // ATLAS HELPERS
    // --------------------------
    static public function getAtlas(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxAtlasFrames {
        var img:FlxGraphic = image(key, library, allowGPU);
        if(img == null) return null;

        var xml:String = getPath('images/$key.xml', TEXT, library, true);
        if(OpenFlAssets.exists(xml)) return FlxAtlasFrames.fromSparrow(img, xml);

        var json:String = getPath('images/$key.json', TEXT, library, true);
        if(OpenFlAssets.exists(json)) return FlxAtlasFrames.fromTexturePackerJson(img, json);

        return getPackerAtlas(key, library);
    }

    inline static public function getPackerAtlas(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxAtlasFrames {
        return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library, allowGPU), getPath('images/$key.txt', library));
    }

    inline static public function formatToSongPath(path:String):String {
        var invalidChars = ~/[~&\\;:<>#]/;
        var hideChars = ~/[.,'"%?!]/;
        var p = invalidChars.split(path.replace(' ', '-')).join("-");
        return hideChars.split(p).join("").toLowerCase();
    }

    // --------------------------
    // MOD HELPERS
    // --------------------------
    #if MODS_ALLOWED
    inline static public function mods(key:String = '') { return 'mods/' + key; }
    inline static public function modsImages(key:String) { return modFolders('images/' + key + '.png'); }
    inline static public function modsSounds(path:String, key:String) { return modFolders(path + '/' + key + '.' + SOUND_EXT); }
    inline static public function modsVideo(key:String) { return modFolders('videos/' + key + '.' + VIDEO_EXT); }
    inline static public function modsFont(key:String) { return modFolders('fonts/' + key); }

    static public function modFolders(key:String):String {
        if(Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
        {
            var fileToCheck:String = mods(Mods.currentModDirectory + '/' + key);
            if(FileSystem.exists(fileToCheck)) return fileToCheck;
        }
        for(mod in Mods.getGlobalMods())
        {
            var fileToCheck:String = mods(mod + '/' + key);
            if(FileSystem.exists(fileToCheck)) return fileToCheck;
        }
        return 'mods/' + key;
    }
    #end

    // --------------------------
    // MEMORY MANAGEMENT
    // --------------------------
    public static function clearUnusedMemory() {
        for(key in currentTrackedAssets.keys()) {
            if(!localTrackedAssets.contains(key) && !dumpExclusions.contains(key)) {
                var obj = currentTrackedAssets.get(key);
                if(obj != null) { obj.destroy(); currentTrackedAssets.remove(key); }
            }
        }
        System.gc();
    }

    public static function clearStoredMemory() {
        for(key in currentTrackedSounds.keys()) {
            var asset = currentTrackedSounds.get(key);
            if(!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && asset != null) {
                Assets.cache.clear(key);
                currentTrackedSounds.remove(key);
            }
        }
        localTrackedAssets = [];
    }
}