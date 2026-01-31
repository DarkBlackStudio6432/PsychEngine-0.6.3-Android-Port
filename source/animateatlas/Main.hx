package animateatlas;

import animateatlas.JSONData.AtlasData;
import animateatlas.JSONData.AnimationData;
import animateatlas.HelperEnums.LoopMode;
import animateatlas.tilecontainer.TileAnimationLibrary;
import animateatlas.tilecontainer.TileContainerMovieClip;
import animateatlas.displayobject.SpriteAnimationLibrary;
import animateatlas.displayobject.SpriteMovieClip;

import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Assets;
import haxe.Json;
import Math;

class AnimateAtlasTestAuto extends Sprite {
    var aa:TileAnimationLibrary;
    var ss:SpriteAnimationLibrary;

    var tileSymbols:Array<TileContainerMovieClip>;
    var spriteSymbols:Array<SpriteMovieClip>;

    var renderer:Sprite;

    public function new() {
        super();

        // Fundo cinza
        graphics.beginFill(0x333333);
        graphics.drawRect(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);

        // Carrega JSON e bitmap (substitua pelos seus assets)
        var animationData:AnimationData = Json.parse(Assets.getText("assets/TEST/Animation.json"));
        var atlasData:AtlasData = Json.parse(Assets.getText("assets/TEST/spritemap.json"));
        var bitmapData:BitmapData = Assets.getBitmapData("assets/TEST/spritemap.png");

        aa = new TileAnimationLibrary(animationData, atlasData, bitmapData);
        ss = new SpriteAnimationLibrary(animationData, atlasData, bitmapData);

        renderer = new Sprite();
        addChild(renderer);

        tileSymbols = [];
        spriteSymbols = [];

        // Começar spawn automático de animações
        addEventListener(Event.ENTER_FRAME, update);
        spawnTimer = 0;
    }

    var prev:Int = 0;
    var dt:Int = 0;
    var curr:Int = 0;

    var spawnTimer:Float = 0;
    var spawnInterval:Float = 500; // spawn a cada 500ms

    public function update(e:Event):Void {
        curr = Lib.getTimer();
        dt = curr - prev;
        prev = curr;

        spawnTimer += dt;
        if (spawnTimer >= spawnInterval) {
            spawnTileAnimation();
            spawnSpriteAnimation();
            spawnTimer = 0;
        }

        for (symbol in tileSymbols)
            symbol.update(dt);
        for (symbol in spriteSymbols)
            symbol.update(dt);
    }

    function spawnTileAnimation():Void {
        var t = aa.createAnimation();
        t.x = Math.random() * Lib.current.stage.stageWidth;
        t.y = Math.random() * Lib.current.stage.stageHeight;

        renderer.addChild(t);
        t.loopMode = LoopMode.LOOP;
        tileSymbols.push(t);
    }

    function spawnSpriteAnimation():Void {
        var s = ss.createAnimation();
        s.x = Math.random() * Lib.current.stage.stageWidth;
        s.y = Math.random() * Lib.current.stage.stageHeight;

        addChild(s);
        s.loopMode = LoopMode.LOOP;
        spriteSymbols.push(s);
    }
}