package;

import backend.Highscore;
import flixel.addons.display.FlxTiledSprite;
import options.OptionsState;
import flixel.math.FlxRect;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import openfl.display.BitmapData;
import flixel.input.keyboard.FlxKey;

enum Hovering {
    OPTIONS;
    ANYTHINGELSE;
}

class MadnessMenu extends MusicBeatState {

    public var hoverMode:Hovering = ANYTHINGELSE;

    public static var mouseGraphic:BitmapData = BitmapData.fromFile('assets/shared/images/madnessmenu/mouse.png'); // Ainda pode ignorar no mobile
    var uniScale:Float;

    var currentSel:Int = 0;
    var baseButtons:FlxSpriteGroup<FlxSprite>;
    var optionsButton:FlxSprite;

    var circles:FlxSpriteGroup;

    var storyButton:FlxSprite;
    var storyDropDown:StorySubMenu;

    var dropdownCooldown:Bool = false;

    override function create() {

        FlxG.camera.antialiasing = ClientPrefs.data.antialiasing;
        persistentUpdate = true;

        // Backdrop
        var back = new FlxSprite(Paths.image('madnessmenu/back'));
        back.setGraphicSize(FlxG.width);
        back.updateHitbox();
        back.screenCenter(Y);
        back.y += 100;
        add(back);

        uniScale = back.scale.x;

        // Silhuetas
        var silh = new FlxBackdrop(Paths.image('madnessmenu/siloets'), X, 20);
        silh.setScale(uniScale);
        silh.y = 300;
        silh.velocity.x = -50;
        silh.alpha = 0.3;
        add(silh);

        // Random character
        var charOpt = [['hank','idle','100,300'],['gf','girlfriend','100,180'],['bf','bf','100,300']];
        final opt = FlxG.random.getObject(charOpt);

        var pos = [];
        for (i in opt[2].split(',')) pos.push(Std.parseFloat(i));

        var char = new FlxAnimate(pos[0], pos[1], 'assets/shared/images/madnessmenu/${opt[0]}');
        char.antialiasing = true;
        char.showPivot = false;
        char.anim.addBySymbol('i', opt[1], 24, true);
        char.anim.play('i');
        char.scale.set(0.6,0.6);
        char.updateHitbox();
        add(char);

        // Story dropdown
        storyDropDown = new StorySubMenu();
        add(storyDropDown);

        // Buttons
        baseButtons = new FlxSpriteGroup<FlxSprite>();
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

        // Top & bottom bars
        var topBar = new FlxSprite(Paths.image('madnessmenu/top bar'));
        topBar.setScale(uniScale);
        add(topBar);

        var bottomBar = new FlxSprite(Paths.image('madnessmenu/bottom bar'));
        bottomBar.setScale(uniScale);
        bottomBar.y = FlxG.height - bottomBar.height + 100;
        add(bottomBar);

        // Circles
        circles = new FlxSpriteGroup();
        add(circles);

        var scrollingNums = new FlxBackdrop(Paths.image('madnessmenu/numbers'), Y);
        scrollingNums.setScale(2);
        scrollingNums.x = FlxG.width - scrollingNums.width - 100;
        add(scrollingNums);
        scrollingNums.velocity.y = 75;
        scrollingNums.alpha = 0.15;

        // Logo
        var logo = new FlxSprite(0, 86 * uniScale, Paths.image('madnessmenu/logo temp'));
        logo.setGraphicSize(820 * uniScale);
        logo.updateHitbox();
        logo.screenCenter(X);
        add(logo);

        // Watermarks / credits
        var version = new FlxSprite(0, 20, Paths.image('madnessmenu/version2'));
        version.setScale(uniScale);
        version.x = FlxG.width - version.width - 20;
        add(version);

        // Trophy
        Difficulty.resetList();
        var trophyKey = Highscore.getRating('expurgation', 1) == 1.0 ? 'Trophy2' : 'trophy';
        var trophy = new FlxSprite().loadGraphic(Paths.image('madnessmenu/$trophyKey'));
        add(trophy);
        trophy.scale.set(0.4,0.4);
        trophy.updateHitbox();
        trophy.visible = FlxG.save.data.beatExpurgation;
        trophy.y = FlxG.height - trophy.height;
        trophy.screenCenter(X);

        if (trophyKey == 'Trophy2') {
            var anim = new FlxAnimate(300,90,'assets/shared/images/madnessmenu/gruny');
            anim.anim.addBySymbol('i','idle move',24);
            anim.anim.play('i');
            add(anim);
            anim.scale.set(0.5,0.5);
            anim.updateHitbox();
        }

        super.create();
        changeSel();

        // Circle spawn
        new FlxTimer().start(5,function(timer){
            spawnCircle();
            timer.reset(FlxG.random.float(6,13));
        });

    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        // Navigation with VirtualPad
        if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && hoverMode != OPTIONS) {
            hoverMode = ANYTHINGELSE;
            if (!storyDropDown.open) changeSel(controls.UI_LEFT_P ? -1 : 1);
        }

        if (controls.ACCEPT) {
            if (storyDropDown.open)
                storyDropDown.confirm();
            else
                confirmSel();
        }

        if (controls.UI_DOWN_P || controls.UI_UP_P) {
            if (storyDropDown.open)
                storyDropDown.changeSelection(controls.UI_DOWN ? 1 : -1);
            else {
                hoverMode = (hoverMode == OPTIONS) ? ANYTHINGELSE : OPTIONS;
                changeSel(0,true);
            }
        }

        if (controls.BACK && storyDropDown.open) closeStoryDropdown();
    }

    function confirmSel() {
        FlxG.sound.play(Paths.sound('madness/select'));
        var button = hoverMode == OPTIONS ? optionsButton : baseButtons.members[currentSel];
        button.animation.play('confirm');

        if (hoverMode == OPTIONS) {
            MusicBeatState.switchState(new OptionsState());
            OptionsState.onPlayState = false;
            if (PlayState.SONG != null) {
                PlayState.SONG.arrowSkin = null;
                PlayState.SONG.splashSkin = null;
                PlayState.stageUI = 'normal';
            }
        } else {
            switch (currentSel) {
                case 0: openStoryDropdown();
                case 1: MusicBeatState.switchState(new MadnessCredits());
            }
        }
    }

    function openStoryDropdown() {
        if (dropdownCooldown) return;
        dropdownCooldown = true;

        storyButton.animation.play("confirm");
        storyDropDown.open = true;

        FlxTween.tween(storyDropDown, {y:storyButton.y}, 0.4, {ease:FlxEase.cubeOut, onComplete: function(_) {
            dropdownCooldown = false;
        }});
    }

    function closeStoryDropdown() {
        if (dropdownCooldown) return;
        dropdownCooldown = true;
        storyButton.animation.play("select");

        FlxTween.tween(storyDropDown, {y:storyButton.y - 320}, 0.4, {ease:FlxEase.cubeOut, onComplete:function(_) {
            dropdownCooldown = false;
            storyDropDown.open = false;
        }});
    }

    var _prevSel:Int = 0;
    function changeSel(v:Int = 0, forceSound:Bool = false) {
        FlxG.sound.play(Paths.sound('madness/beep'));

        for (i in baseButtons.members.concat([optionsButton]))
            i.animation.play('i');

        currentSel = FlxMath.wrap(currentSel + v, 0, baseButtons.length - 1);

        var obj = switch(hoverMode) {
            case OPTIONS: optionsButton;
            case ANYTHINGELSE: baseButtons.members[currentSel];
        }
        obj.animation.play('select');
    }

    function makeButton(path:String):FlxSprite {
        var spr = new FlxSprite();
        spr.frames = Paths.getSparrowAtlas("madnessmenu/" + path);
        spr.animation.addByPrefix('i', path + '0');
        spr.animation.addByPrefix('confirm', path + ' confirm');
        spr.animation.addByPrefix('select', path + ' select');
        spr.animation.play('i');
        spr.setScale(uniScale + 0.2);
        return spr;
    }

    function spawnCircle() {
        var circle = circles.recycle(FlxSprite);
        circle.setPosition(FlxG.random.int(200,900), FlxG.random.int(100,500));
        circle.loadGraphic(Paths.image('madnessmenu/circle'));
        circle.setScale(uniScale * 0.2);
        circle.antialiasing = ClientPrefs.data.antialiasing;
        circle.alpha = 0.08;
        circles.add(circle);

        var scaleTime = FlxG.random.float(7,12);
        FlxTween.tween(circle.scale, {x:2, y:2, alpha:0}, scaleTime, {onComplete:function(_) { circle.kill(); }});
    }
}

// ---------------------------------------------------
// StorySubMenu adaptado para mobile
// ---------------------------------------------------

class StorySubMenu extends FlxSpriteGroup {

    var options:Array<String> = ["HANK","???","COMING SOON"];
    public var curSelected:Int = 0;
    public var confirmed:Bool = false;
    public var open:Bool = false;

    var texts:FlxSpriteGroup;
    var lTextCorner:FlxSprite;
    var rTextCorner:FlxSprite;

    var elapsedTime:Float = 0;
    var cornerSpeed:Float = 12;

    public function new() {
        super();
        texts = new FlxSpriteGroup();
        add(texts);

        for (i in 0...options.length) {
            var option = options[i];
            if (option == '???' && FlxG.save.data.beatExpurgation != null) {
                option = 'EXPURGATION';
                options[i] = 'EXPURGATION';
            }
            var text = new FlxText();
            text.setFormat(Paths.font("impact.ttf"), 30, FlxColor.WHITE);
            text.text = option;
            text.ID = i;
            text.x -= text.width * 1.2;

            switch (option) {
                case "HANK": text.y = 82;
                case "???" | 'EXPURGATION': text.y = 147;
                case "COMING SOON": text.y = 261;
            }

            texts.add(text);
        }

        // Corners
        lTextCorner = new FlxSprite().loadGraphic(Paths.image("madnessmenu/textCorners"));
        add(lTextCorner);
        rTextCorner = lTextCorner.clone();
        rTextCorner.flipX = true;
        add(rTextCorner);

        changeSelection(0,false,false);
    }

    public function confirm() {
        if (confirmed || !open) return;
        FlxG.sound.play(Paths.sound('madness/select'));

        switch (options[curSelected]) {
            case "HANK": confirmed = true; loadSong('assassination');
            case "???" | 'EXPURGATION': #if !debug if (FlxG.save.data.beatAssasin == null) return; #end confirmed = true; loadSong('expurgation');
            case "COMING SOON": FlxG.sound.play(Paths.sound("coming soon"));
        }
    }

    function loadSong(name:String) {
        Difficulty.resetList();
        FlxG.state.persistentUpdate = false;

        try {
            PlayState.SONG = backend.Song.loadFromJson(backend.Highscore.formatSong(Paths.formatToSongPath(name), 1), Paths.formatToSongPath(name));
            PlayState.isStoryMode = false;
            PlayState.storyDifficulty = 1;
        } catch(e:Dynamic) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            return;
        }

        LoadingState.loadAndSwitchState(new PlayState());
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        var curTxt:FlxText = cast texts.members[curSelected];
        elapsedTime += elapsed * 1.5;
        curTxt.angle = ((curTxt.text == '???' || curTxt.text.toLowerCase() == 'expurgation') && Math.round(elapsedTime) % 2 == 0) ? FlxG.random.float(-3,3) : 0;
    }

    public function changeSelection(change:Int = 0, ?mouse:Bool = false, ?playSound:Bool = true) {
        curSelected = FlxMath.wrap(curSelected + change,0,options.length-1);
        if (playSound) FlxG.sound.play(Paths.sound('madness/beep'));
    }
}
