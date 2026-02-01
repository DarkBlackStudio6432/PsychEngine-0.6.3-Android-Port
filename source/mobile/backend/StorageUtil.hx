package mobile.backend;

import lime.system.System as LimeSystem;
import haxe.io.Path;
import haxe.Exception;
#if android
import cpp.Lib;
#end

/**
 * A storage class for mobile.
 */
class StorageUtil
{
    #if sys
    public static final rootDir:String = LimeSystem.applicationStorageDirectory;

    public static function getStorageDirectory(?force:Bool = false):String
    {
        var daPath:String = '';
        #if android
        if (!FileSystem.exists(rootDir + 'storagetype.txt'))
            File.saveContent(rootDir + 'storagetype.txt', ClientPrefs.storageType);
        var curStorageType:String = File.getContent(rootDir + 'storagetype.txt');
        daPath = force ? StorageType.fromStrForce(curStorageType) : StorageType.fromStr(curStorageType);
        daPath = Path.addTrailingSlash(daPath);
        #elseif ios
        daPath = LimeSystem.documentsDirectory;
        #else
        daPath = Sys.getCwd();
        #end

        return daPath;
    }

    public static function createDirectories(directory:String):Void
    {
        try
        {
            if (FileSystem.exists(directory) && FileSystem.isDirectory(directory))
                return;
        }
        catch (e:haxe.Exception)
        {
            trace('Something went wrong while looking at directory. (${e.message})');
        }

        var total:String = '';
        if (directory.substr(0, 1) == '/')
            total = '/';

        var parts:Array<String> = directory.split('/');
        if (parts.length > 0 && parts[0].indexOf(':') > -1)
            parts.shift();

        for (part in parts)
        {
            if (part != '.' && part != '')
            {
                if (total != '' && total != '/')
                    total += '/';

                total += part;

                try
                {
                    if (!FileSystem.exists(total))
                        FileSystem.createDirectory(total);
                }
                catch (e:Exception)
                {
                    trace('Error while creating directory. (${e.message})');
                }
            }
        }
    }

    #if !FILE_DIALOG_FOR_MOBILE
    public static function saveContent(fileName:String, fileData:String, ?alert:Bool = true):Void
    {
        try
        {
            if (!FileSystem.exists('saves'))
                FileSystem.createDirectory('saves');

            File.saveContent('saves/$fileName', fileData);
            if (alert)
                CoolUtil.showPopUp('$fileName has been saved.', "Success!");
        }
        catch (e:Exception)
        {
            if (alert)
                CoolUtil.showPopUp('$fileName couldn\'t be saved.\n(${e.message})', "Error!");
            else
                trace('$fileName couldn\'t be saved. (${e.message})');
        }
    }
    #end

    #if android
    public static function requestPermissions():Void
    {
        var sdk = Lib.load("android", "getSDKInt", 0)();

        if (sdk >= 33) // TIRAMISU
            Lib.load("android", "requestPermissions", 1)([
                "READ_MEDIA_IMAGES", "READ_MEDIA_VIDEO", "READ_MEDIA_AUDIO", "READ_MEDIA_VISUAL_USER_SELECTED"
            ]);
        else
            Lib.load("android", "requestPermissions", 1)([
                "READ_EXTERNAL_STORAGE", "WRITE_EXTERNAL_STORAGE"
            ]);

        var isManager:Bool = Lib.load("android", "isExternalStorageManager", 0)();
        if (!isManager)
        {
            if (sdk >= 31) // S
                Lib.load("android", "requestSetting", 1)("REQUEST_MANAGE_MEDIA");
            Lib.load("android", "requestSetting", 1)("MANAGE_APP_ALL_FILES_ACCESS_PERMISSION");
        }

        try
        {
            if (!FileSystem.exists(StorageUtil.getStorageDirectory()))
                createDirectories(StorageUtil.getStorageDirectory());
        }
        catch (e:Dynamic)
        {
            CoolUtil.showPopUp('Please create directory to\n' + StorageUtil.getStorageDirectory(true) + '\nPress OK to close the game', 'Error!');
            LimeSystem.exit(1);
        }
    }

    public static function checkExternalPaths(?splitStorage = false):Array<String>
    {
        var process = new Process('grep -o "/storage/....-...." /proc/mounts | paste -sd \',\'');
        var paths:String = process.stdout.readAll().toString();
        if (splitStorage)
            paths = paths.replace('/storage/', '');
        return paths.split(',');
    }

    public static function getExternalDirectory(externalDir:String):String
    {
        var daPath:String = '';
        for (path in checkExternalPaths())
            if (path.contains(externalDir))
                daPath = path;

        daPath = haxe.io.Path.addTrailingSlash(daPath.endsWith("\n") ? daPath.substr(0, daPath.length - 1) : daPath);
        return daPath;
    }
    #end
    #end
}

#if android
@:runtimeValue
enum abstract StorageType(String) from String to String
{
    final forcedPath = '/storage/emulated/0/';
    final packageNameLocal = 'com.kraloyuncu.psychengine063';
    final fileLocalONLINE = 'PsychOnline';
    final fileLocal = 'PsychEngine';
    final fileLocalNF = 'NF Engine';
    final fileLocalEX = 'Psych Extended'; 

    var EXTERNAL_DATA = "EXTERNAL_DATA";
    var EXTERNAL_OBB = "EXTERNAL_OBB";
    var EXTERNAL_MEDIA = "EXTERNAL_MEDIA";
    var EXTERNAL = "EXTERNAL";
    var EXTERNAL_ONLINE = "EXTERNAL_ONLINE";
    var EXTERNAL_NF = "EXTERNAL_NF";
    var EXTERNAL_EX = "EXTERNAL_EX";
    var EXTERNAL_PE = "EXTERNAL_PE";

    public static function fromStr(str:String):StorageType
    {
        final EXTERNAL_DATA = Lib.load("android", "getExternalFilesDir", 0)();
        final EXTERNAL_OBB = Lib.load("android", "getObbDir", 0)();
        final EXTERNAL_MEDIA = Lib.load("android", "getExternalStorageDirectory", 0)() + '/Android/media/' + lime.app.Application.current.meta.get('packageName');
        final EXTERNAL = Lib.load("android", "getExternalStorageDirectory", 0)() + '/.' + fileLocal;
        final EXTERNAL_NF = Lib.load("android", "getExternalStorageDirectory", 0)() + '/.' + fileLocalNF;
        final EXTERNAL_EX = Lib.load("android", "getExternalStorageDirectory", 0)() + '/.' + lime.app.Application.current.meta.get('file');
        final EXTERNAL_ONLINE = Lib.load("android", "getExternalStorageDirectory", 0)() + '/.' + fileLocalONLINE;

        return switch (str)
        {
            case "EXTERNAL_DATA": EXTERNAL_DATA;
            case "EXTERNAL_OBB": EXTERNAL_OBB;
            case "EXTERNAL_MEDIA": EXTERNAL_MEDIA;
            case "EXTERNAL": EXTERNAL;
            case "EXTERNAL_NF": EXTERNAL_NF;
            case "EXTERNAL_EX": EXTERNAL_EX;
            case "EXTERNAL_ONLINE": EXTERNAL_ONLINE;
            default: StorageUtil.getExternalDirectory(str) + '.' + fileLocal;
        }
    }

    public static function fromStrForce(str:String):StorageType
    {
        final EXTERNAL_DATA = forcedPath + 'Android/data/' + packageNameLocal + '/files';
        final EXTERNAL_OBB = forcedPath + 'Android/obb/' + packageNameLocal;
        final EXTERNAL_MEDIA = forcedPath + 'Android/media/' + packageNameLocal;
        final EXTERNAL_ONLINE = forcedPath + '.' + fileLocalONLINE;
        final EXTERNAL = forcedPath + '.' + fileLocal;
        final EXTERNAL_NF = forcedPath + '.' + fileLocalNF;
        final EXTERNAL_EX = forcedPath + '.' + fileLocalEX;

        return switch (str)
        {
            case "EXTERNAL_DATA": EXTERNAL_DATA;
            case "EXTERNAL_OBB": EXTERNAL_OBB;
            case "EXTERNAL_MEDIA": EXTERNAL_MEDIA;
            case "EXTERNAL": EXTERNAL;
            case "EXTERNAL_NF": EXTERNAL_NF;
            case "EXTERNAL_EX": EXTERNAL_EX;
            case "EXTERNAL_ONLINE": EXTERNAL_ONLINE;
            default: StorageUtil.getExternalDirectory(str) + '.' + fileLocal;
        }
    }
}
#end