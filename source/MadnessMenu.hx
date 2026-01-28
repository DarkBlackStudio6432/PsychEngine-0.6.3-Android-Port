package;

import MusicBeatState;
import StoryMenuState;
import CreditsState;
import ClientPrefs;
import Paths;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;
import flixel.ui.FlxVirtualPad;

class MadnessMenu extends MusicBeatState
{
    var bottomBar:FlxSprite;
    var sil:FlxBackdrop;
    var uniScale:Float = 1;
    var currentSel:Int = 0;

    var baseButtons:FlxTypedGroup<FlxSprite>;
    var circles:FlxSpriteGroup;
    var storyButton:FlxSprite;

    // VirtualPad
    #if mobile
    var virtualPad:FlxVirtualPad;
    #end

    override function create()
    {
        persistentUpdate = true;
        persistentDraw = true;

        super.create();

        // ===============================
        // BACKGROUND
        // ===============================
        var bg = new FlxSprite(0, 0);
        bg.loadGraphic(Paths.image("madnessmenu/back"));
        bg.setGraphicSize(FlxG.width, FlxG.height);
        bg.updateHitbox();
        bg.scrollFactor.set(0, 0);
        add(bg);

        uniScale = bg.scale.x;

        // ===============================
        // SILHUETAS
        // ===============================
        sil = new FlxBackdrop(Paths.image('madnessmenu/siloets'), 1, 20);
        sil.scale.set(uniScale, uniScale);
        sil.y = 300;
        sil.velocity.x = -50;
        sil.alpha = 0.3;
        sil.scrollFactor.set(0, 0);
        add(sil);

        // ===============================
        // TOP BAR
        // ===============================
        var topBar = new FlxSprite(0, 0);
        topBar.loadGraphic(Paths.image('madnessmenu/top bar'));
        topBar.setGraphicSize(FlxG.width);
        topBar.updateHitbox();
        topBar.scrollFactor.set(0, 0);
        add(topBar);

        // ===============================
        // BOTTOM BAR
        // ===============================
        bottomBar = new FlxSprite(Paths.image('madnessmenu/bottom bar'));
        bottomBar.scale.set(uniScale, uniScale);
        bottomBar.updateHitbox();
        bottomBar.y = FlxG.height - bottomBar.height + (100 * uniScale);
        bottomBar.scrollFactor.set(0, 0);
        add(bottomBar);

        // ===============================
        // LOGO
        // ===============================
        var logo = new FlxSprite(0, 86 * uniScale);
        logo.loadGraphic(Paths.image('madnessmenu/logo temp'));
        logo.setGraphicSize(Std.int(820 * uniScale));
        logo.updateHitbox();
        logo.scrollFactor.set(0, 0);
        logo.screenCenter(X);
        add(logo);

        // ===============================
        // OPTIONS
        // ===============================
        var options = new FlxSprite();
        options.frames = Paths.getSparrowAtlas("madnessmenu/options");
        options.animation.addByPrefix("idle", "options idle", 24, true);
        options.animation.addByPrefix("select", "options select", 24, true);
        options.animation.play("idle");
        options.setGraphicSize(Std.int(options.width * uniScale));
        options.updateHitbox();
        options.x = FlxG.width - options.width - (40 * uniScale);
        options.y = bottomBar.y + (bottomBar.height / 2) - (options.height / 2);
        options.scrollFactor.set(0, 0);
        add(options);

        // ===============================
        // BOTÕES DO MENU
        // ===============================
        baseButtons = new FlxTypedGroup<FlxSprite>();
        add(baseButtons);

        storyButton = makeButton('storymode');
        storyButton.setPosition(1169 * uniScale, 405 * uniScale);
        baseButtons.add(storyButton);

        var freeplayButton = makeButton('freeplay');
        freeplayButton.setPosition(storyButton.x + storyButton.width + 10, storyButton.y);
        baseButtons.add(freeplayButton);

        circles = new FlxSpriteGroup();
        add(circles);

        changeSel();

        // ===============================
        // VIRTUALPAD MOBILE
        // ===============================
        #if mobile
        virtualPad = new FlxVirtualPad(LEFT_RIGHT, A_B);
        virtualPad.alpha = 0.75;
        virtualPad.scale.set(uniScale, uniScale); // escala proporcional
        virtualPad.scrollFactor.set(0, 0);       // fixa na tela
        add(virtualPad);

        // Ajuste manual dos botões
        virtualPad.buttonA.x = FlxG.width - 180 * uniScale;
        virtualPad.buttonA.y = FlxG.height - 150 * uniScale;

        virtualPad.buttonB.x = FlxG.width - 90 * uniScale;
        virtualPad.buttonB.y = FlxG.height - 150 * uniScale;

        virtualPad.buttonLeft.x = 50 * uniScale;
        virtualPad.buttonLeft.y = FlxG.height - 150 * uniScale;

        virtualPad.buttonRight.x = 140 * uniScale;
        virtualPad.buttonRight.y = FlxG.height - 150 * uniScale;
        #end
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

#if mobile
if (FlxG.mouse.justPressed()) {
    for (i in baseButtons.members) {
        if (i == null) continue;

        // verifica se o ponto do toque está sobre o sprite
        if (i.overlapsPoint(FlxG.mouse.screenX, FlxG.mouse.screenY)) {
            switch (i.frames.name) { // usa o nome do sprite carregado
                case "storymode":
                    MusicBeatState.switchState(new StoryMenuState());
                case "options":
                    MusicBeatState.switchState(new OptionsState());
                case "freeplay":
                    MusicBeatState.switchState(new MadnessCredits());
            }
        }
    }
}
#end

        #if mobile
        if (virtualPad.buttonLeft.justPressed) changeSel(-1);
        if (virtualPad.buttonRight.justPressed) changeSel(1);
        if (virtualPad.buttonA.justPressed) confirmSel();
        if (virtualPad.buttonB.justPressed) goBack();
        #end

        if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
            changeSel(controls.UI_LEFT_P ? -1 : 1);

        if (controls.ACCEPT)
            confirmSel();

    }

function goBack()
{
    FlxG.sound.play(Paths.sound('madness/cancel')); // som de cancelar
    MusicBeatState.switchState(new TitleState()); // volta para a tela de título
}

    function confirmSel()
    {
        FlxG.sound.play(Paths.sound('madness/select'));
        var button = baseButtons.members[currentSel];
        button.animation.play('confirm');

        switch (currentSel)
        {
            case 0:
                MusicBeatState.switchState(new StoryMenuState());
            case 1:
                MusicBeatState.switchState(new CreditsState());
            case 2:
            MusicBeatState.switchState(new MadnessCredits());    // Options
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
        spr.animation.addByPrefix('confirm', path + ' confirm');
        spr.animation.addByPrefix('select', path + ' select');
        spr.animation.play('i');
        spr.scale.set(uniScale + 0.2, uniScale + 0.2); // escala proporcional
        return spr;
    }
}