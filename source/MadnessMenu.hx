package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseEvent;

// ✅ 1️⃣ IMPORT DO VIRTUALPAD
import flixel.ui.FlxVirtualPad;

class MadnessMenu extends MusicBeatState
{
    var uniScale:Float = 1;

    var currentSel:Int = 0;
    var baseButtons:FlxSpriteGroup;
    var circles:FlxSpriteGroup;

    var storyButton:FlxSprite;
    var optionsButton:FlxSprite;

    // ✅ 2️⃣ VARIÁVEL DO VIRTUALPAD
    var virtualPad:FlxVirtualPad;

    override function create()
    {

        var bg = new FlxSprite(Paths.image('madnessmenu/back'));
        bg.setGraphicSize(FlxG.width);
        bg.updateHitbox();
        bg.screenCenter();
        bg.y += 100;
        add(bg);

        uniScale = bg.scale.x;

        var sil = new FlxBackdrop(Paths.image('madnessmenu/siloets'));
        sil.scale.set(uniScale, uniScale);
        sil.y = 300;
        sil.velocity.x = -50;
        sil.alpha = 0.3;
        add(sil);

        baseButtons = new FlxSpriteGroup();
        add(baseButtons);

        storyButton = makeButton('storymode');
        storyButton.setPosition(1169 * uniScale, 405 * uniScale);
        baseButtons.add(storyButton);

        var freeplayButton = makeButton('freeplay');
        freeplayButton.setPosition(
            storyButton.x + storyButton.width + 10,
            storyButton.y
        );
        baseButtons.add(freeplayButton);

        optionsButton = makeButton('options');
        optionsButton.setPosition(storyButton.x, 760 * uniScale);
        add(optionsButton);

        var topBar = new FlxSprite(Paths.image('madnessmenu/top bar'));
        topBar.scale.set(uniScale, uniScale);
        add(topBar);

        var bottomBar = new FlxSprite(Paths.image('madnessmenu/bottom bar'));
        bottomBar.scale.set(uniScale, uniScale);
        bottomBar.y = FlxG.height - bottomBar.height + 100;
        add(bottomBar);

        var logo = new FlxSprite(0, 86 * uniScale, Paths.image('madnessmenu/logo temp'));
        logo.setGraphicSize(Std.int(820 * uniScale));
        logo.updateHitbox();
        logo.screenCenter(X);
        add(logo);

        // ✅ TROPHY (Highscore removido)
        var trophyKey = (FlxG.save.data.beatExpurgation == true) ? 'Trophy2' : 'trophy';
        var trophy = new FlxSprite(Paths.image('madnessmenu/' + trophyKey));
        trophy.scale.set(0.4, 0.4);
        trophy.visible = FlxG.save.data.beatExpurgation == true;
        trophy.y = FlxG.height - trophy.height;
        trophy.screenCenter(X);
        add(trophy);

        circles = new FlxSpriteGroup();
        add(circles);

        spawnCircle();

        // ✅ 5️⃣ ESCONDER MOUSE NO MOBILE
        #if mobile
        FlxG.mouse.visible = false;
        #end

        // ✅ 3️⃣ CRIAR VIRTUALPAD (IGUAL MAINMENU MOBILE)
        #if mobile
virtualPad = new FlxVirtualPad(LEFT_RIGHT, A_B);
virtualPad.alpha = 0.75;

// 🔍 tamanho correto no mobile
virtualPad.scale.set(1.6, 1.6);
virtualPad.updateHitbox();

// 📌 fixa na tela
virtualPad.scrollFactor.set();

add(virtualPad);
#end

        super.create();
        changeSel();
    }

    function spawnCircle()
    {
        var circle = new FlxSprite(
            FlxG.random.int(200, 900),
            FlxG.random.int(100, 500),
            Paths.image('madnessmenu/circle')
        );
        circle.scale.set(uniScale * 0.2, uniScale * 0.2);
        circle.alpha = 0.15;
        circles.add(circle);

        // ✅ FlxTween removido
        new FlxTimer().start(5, function(t)
        {
            circle.kill();
        });
    }

    // ✅ 4️⃣ UPDATE COM VIRTUALPAD INTEGRADO
    override function update(elapsed:Float)
    {
        super.update(elapsed);

FlxG.camera.scroll.set(0, 0);

        var left = controls.UI_LEFT_P;
        var right = controls.UI_RIGHT_P;
        var accept = controls.ACCEPT;

        #if mobile
        if (virtualPad.buttonLeft.justPressed) left = true;
        if (virtualPad.buttonRight.justPressed) right = true;
        if (virtualPad.buttonA.justPressed) accept = true;
        #end

        if (left)
            changeSel(-1);

        if (right)
            changeSel(1);

        if (accept)
            confirmSel();
    }

    function confirmSel()
    {
        FlxG.sound.play(Paths.sound('madness/select'));

        if (currentSel == 0)
        {
            MusicBeatState.switchState(new StoryMenuState());
        }
        else
        {
            MusicBeatState.switchState(new MadnessCredits());
        }
    }

    function changeSel(v:Int = 0)
    {
        FlxG.sound.play(Paths.sound('madness/beep'));

        for (i in baseButtons.members)
            i.animation.play('i');

        currentSel = FlxMath.wrap(currentSel + v, 0, baseButtons.length - 1);
        baseButtons.members[currentSel].animation.play('select');
    }

    function makeButton(path:String):FlxSprite
    {
        var spr = new FlxSprite();
        spr.frames = Paths.getSparrowAtlas('madnessmenu/' + path);
        spr.animation.addByPrefix('i', path + '0');
        spr.animation.addByPrefix('select', path + ' select');
        spr.animation.addByPrefix('confirm', path + ' confirm');
        spr.animation.play('i');
        spr.scale.set(uniScale + 0.2, uniScale + 0.2);
        return spr;
    }
}