package;

import Highscore;
import flixel.addons.display.FlxTiledSprite;
import options.OptionsState;
import flixel.math.FlxRect;
import openfl.display.BitmapData;
import flixel.addons.display.FlxBackdrop;
//import flixel.input.mouse.FlxMouseEvent;

//really jank way of handling this
//couldve done way better but whatever
//yeah this sucks
enum Hovering {
    OPTIONS;
    ANYTHINGELSE;
}

class MadnessMenu extends MusicBeatState
{
    var hoverMode:Hovering = ANYTHINGELSE;

    public static var mouseGraphic:BitmapData = BitmapData.fromFile('assets/shared/images/madnessmenu/mouse.png');
    var uniScale:Float;

    var currentSel:Int = 0;
    var baseButtons:FlxTypedGroup<FlxSprite>;
    var optionsButton:FlxSprite;

    var circles:FlxSpriteGroup;
    var storyButton:FlxSprite;
    var storyDropDown:StorySubMenu;

    override function create() {
        super.create();

        var test:FlxText = new FlxText(0, 0, 0, "MADNESS MENU OK", 32);
        test.screenCenter();
        add(test);

        Paths.sound("coming soon");
        FlxG.mouse.visible = true;
        FlxG.mouse.load(mouseGraphic, 0.5);

        FlxG.camera.antialiasing = ClientPrefs.data.antialiasing;
        persistentUpdate = true;

        var back = new FlxSprite(Paths.image('madnessmenu/back'));
        back.setGraphicSize(FlxG.width);
        back.updateHitbox();
        back.screenCenter(Y);
        back.y += 100;
        add(back);

        uniScale = back.scale.x;

        var silh = new FlxBackdrop(Paths.image('madnessmenu/siloets'), X, 20);
        SpriteHelper.setScale(silh, uniScale);
        silh.y = 300;
        silh.velocity.x = -50;
        silh.alpha = 0.3;
        add(silh);

        var fuck = [['hank','idle','100,300'],['gf','girlfriend','100,180'],['bf','bf','100,300']];
        final opt = FlxG.random.getObject(fuck);

        var pos = [];
        for (i in opt[2].split(',')) pos.push(Std.parseFloat(i));

        var char = new FlxAnimate(pos[0], pos[1], 'assets/shared/images/madnessmenu/${opt[0]}');
        char.antialiasing = true;
        char.showPivot = false;
        char.anim.addBySymbol('i', opt[1], 24, true);
        char.anim.play('i');
        SpriteHelper.setScale(char, 0.6);
        char.updateHitbox();
        add(char);

        storyDropDown = new StorySubMenu();
        add(storyDropDown);

        baseButtons = new FlxTypedGroup<FlxSprite>();
        add(baseButtons);

        storyButton = makeButton('storymode');
        storyButton.setPosition(1169 * uniScale, 405 * uniScale);
        baseButtons.add(storyButton);

        storyDropDown.setPosition(storyButton.x + 40, storyButton.y - 320);

        var freeplayButton = makeButton('freeplay');
        freeplayButton.setPosition(storyButton.x + storyButton.width + 10, storyButton.y);
        baseButtons.add(freeplayButton);

        optionsButton = makeButton('options');
        optionsButton.setPosition(storyButton.x + storyButton.width + 10, 760 * uniScale);
        add(optionsButton);

        var topBar = new FlxSprite(Paths.image('madnessmenu/top bar'));
        SpriteHelper.setScale(topBar, uniScale);
        add(topBar);

        new FlxTimer().start(FlxG.random.float(0.5, 1.5), moveSquare, 3);

        var bottomBar = new FlxSprite(Paths.image('madnessmenu/bottom bar'));
        SpriteHelper.setScale(bottomBar, uniScale);
        bottomBar.y = FlxG.height - bottomBar.height + 100;
        add(bottomBar);

        circles = new FlxSpriteGroup();
        add(circles);

        var scrollingNums = new FlxBackdrop(Paths.image('madnessmenu/numbers'), Y);
        SpriteHelper.setScale(scrollingNums, 2);
        scrollingNums.x = FlxG.width - scrollingNums.width - 100;
        add(scrollingNums);
        scrollingNums.velocity.y = 75;
        scrollingNums.alpha = 0.15;

        var logo = new FlxSprite(0, 86 * uniScale, Paths.image('madnessmenu/logo temp'));
        SpriteHelper.setScale(logo, uniScale);
        logo.setGraphicSize(820 * uniScale);
        logo.updateHitbox();
        logo.screenCenter(X);
        add(logo);

        var version = new FlxSprite(0, 20, Paths.image('madnessmenu/version2'));
        SpriteHelper.setScale(version, uniScale);
        version.x = FlxG.width - version.width - 20;
        add(version);

        var ngPresents = new FlxSprite();
        ngPresents.frames = Paths.getSparrowAtlas('madnessmenu/ng');
        ngPresents.animation.addByPrefix('i','ng',24,false);
        ngPresents.animation.play('i');
        ngPresents.animation.finish(); 
        SpriteHelper.setScale(ngPresents, uniScale - 0.1);
        add(ngPresents);
        ngPresents.x = FlxG.width - ngPresents.width - 20;
        ngPresents.y = FlxG.height - ngPresents.height - 20;

        var byDevsR = new FlxSprite(20).loadFrames('madnessmenu/created');
        byDevsR.animation.addByPrefix('i','created');
        byDevsR.animation.addByPrefix('vam','vam');
        byDevsR.animation.addByPrefix('grave','grave');
        byDevsR.animation.play('i');
        SpriteHelper.setScale(byDevsR, uniScale - 0.1);
        add(byDevsR);
        byDevsR.y = FlxG.height - byDevsR.height - 20;

        var graveBox = new FlxSprite(byDevsR.x, byDevsR.y + (23 * uniScale));
        SpriteHelper.makeScaledGraphic(graveBox, 96 * uniScale, 36 * uniScale);
        FlxMouseEvent.add(graveBox, 
            (o)->{ CoolUtil.browserLoad('https://x.com/konn_artist'); }, 
            null, 
            (o)->byDevsR.animation.play('grave'), 
            (o)->byDevsR.animation.play('i'), 
            false, true, false
        );

        var vamBox = new FlxSprite(byDevsR.x + (121 * uniScale), byDevsR.y + (23 * uniScale));
        SpriteHelper.makeScaledGraphic(vamBox, 164 * uniScale, 36 * uniScale);
        FlxMouseEvent.add(vamBox, 
            (o)->{ CoolUtil.browserLoad('https://x.com/vamazotz'); }, 
            null, 
            (o)->byDevsR.animation.play('vam'), 
            (o)->byDevsR.animation.play('i'), 
            false, true, false
        );

        Difficulty.resetList();
        var trophyKey = Highscore.getRating('expurgation',1) == 1.0 ? 'Trophy2' : 'trophy';

        var trophy = new FlxSprite().loadGraphic(Paths.image('madnessmenu/$trophyKey'));
        SpriteHelper.setScale(trophy, 0.4);
        trophy.updateHitbox();
        trophy.visible = FlxG.save.data.beatExpurgation;
        trophy.y = FlxG.height - trophy.height;
        trophy.screenCenter(X);

        if (trophyKey == 'Trophy2') {
            var anim = new FlxAnimate(300, 90, 'assets/shared/images/madnessmenu/gruny');
            anim.anim.addBySymbol('i','idle move',24);
            anim.anim.play('i');
            add(anim);
            SpriteHelper.setScale(anim, 0.5);
            anim.updateHitbox();
        }

        super.create();
        changeSel();

        new FlxTimer().start(5, function(timer) {
            var circle = circles.recycle(FlxSprite);
            circle.setPosition(FlxG.random.int(200,900), FlxG.random.int(100,500));
            circle.loadGraphic(Paths.image('madnessmenu/circle'));
            SpriteHelper.setScale(circle, uniScale * 0.2);
            circle.antialiasing = ClientPrefs.data.antialiasing;
            circle.alpha = 0.08;
            circles.add(circle);
            var scaleTime = FlxG.random.float(7,12);
            FlxTween.tween(circle.scale, {x:2, y:2}, scaleTime, {onComplete: function(_) { circle.kill(); }});
            FlxTween.tween(circle, {alpha:0}, scaleTime * 0.3, {ease:FlxEase.cubeIn, startDelay: scaleTime * 0.7});
            FlxTween.tween(circle, {alpha:0.15}, 1.4, {ease:FlxEase.cubeOut});
            timer.reset(FlxG.random.float(6,13));
        });
    }

    // restante dos métodos do MadnessMenu permanecem iguais...
    // makeButton(), moveSquare(), changeSel(), update(), etc.
}