package objects;

import flixel.FlxSprite;
import flixel.FlxG;
import backend.ClientPrefs;
//import backend.Paths;

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

import openfl.utils.Assets;
import haxe.Json;

typedef MenuCharacterFile = {
    var image:String;
    var scale:Float;
    var position:Array<Int>;
    var idle_anim:String;
    var confirm_anim:String;
    var flipX:Bool;
}

class MenuCharacter extends FlxSprite
{
    public var character:String;
    public var hasConfirmAnimation:Bool = false;
    private static var DEFAULT_CHARACTER:String = "bf";

    public function new(x:Float, character:String = "bf")
    {
        super(x);

        // Antialiasing de acordo com as prefs
        antialiasing = ClientPrefs.data.antialiasing;

        changeCharacter(character);
    }

    public function changeCharacter(?character:String = "bf"):Void
    {
        if(character == null) character = "";
        if(character == this.character) return;

        this.character = character;
        visible = true;

        scale.set(1, 1);
        updateHitbox();
        hasConfirmAnimation = false;

        if(character == "")
        {
            visible = false;
            return;
        }

        // Caminho do JSON
        var characterPath:String = "images/menucharacters/" + character + ".json";
        var rawJson:String;

        #if MODS_ALLOWED
        var path:String = Paths.modFolders(characterPath);
        if(!FileSystem.exists(path))
            path = Paths.getSharedPath(characterPath);

        if(!FileSystem.exists(path))
            path = Paths.getSharedPath("images/menucharacters/" + DEFAULT_CHARACTER + ".json");

        rawJson = File.getContent(path);
        #else
        var path:String = Paths.getSharedPath(characterPath);
        if(!Assets.exists(path))
            path = Paths.getSharedPath("images/menucharacters/" + DEFAULT_CHARACTER + ".json");

        rawJson = Assets.getText(path);
        #end

        // Parse JSON
        var charFile:MenuCharacterFile = cast Json.parse(rawJson);

        // Carregar atlas
        frames = Paths.getSparrowAtlas("menucharacters/" + charFile.image);

        // Animações
        animation.addByPrefix("idle", charFile.idle_anim, 24);
        if(charFile.confirm_anim != null && charFile.confirm_anim != "" && charFile.confirm_anim != charFile.idle_anim)
        {
            animation.addByPrefix("confirm", charFile.confirm_anim, 24, false);
            if(animation.getByName("confirm") != null)
                hasConfirmAnimation = true;
        }

        flipX = (charFile.flipX == true);

        // Scale customizado
        if(charFile.scale != 1)
        {
            scale.set(charFile.scale, charFile.scale);
            updateHitbox();
        }

        // Offset
        offset.set(charFile.position[0], charFile.position[1]);

        // Play idle animation
        animation.play("idle");
    }
}