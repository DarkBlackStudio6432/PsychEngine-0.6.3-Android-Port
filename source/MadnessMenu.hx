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
import flixel.util.FlxAxes;

class MadnessMenu extends MusicBeatState
{
    var bottomBar:FlxSprite;
    var sil:FlxBackdrop;
    var uniScale:Float = 1;
    var currentSel:Int = 0;

    var baseButtons:FlxTypedGroup<FlxSprite>;
    var circles:FlxSpriteGroup;
    var storyButton:FlxSprite;

    override function create()
    {
        // ===============================
        // CÂMERA (IGUAL MainMenuState)
        // ===============================
        var camGame = new FlxCamera();
        FlxG.cameras.reset(camGame);
        FlxG.cameras.setDefaultDrawTarget(camGame, true);

        transIn = transOut = null;

        persistentUpdate = true;
        persistentDraw = true;

        super.create();

        trace("MADNESS MENU ABERTO");

	var bg = new FlxSprite(0, 0);
bg.loadGraphic(Paths.image("madnessmenu/back"));
bg.setGraphicSize(FlxG.width, FlxG.height);
bg.updateHitbox();
bg.screenCenter(FlxAxes.Y);
bg.y += 100;
bg.scrollFactor.set(0, 0);
add(bg);

uniScale = bg.scale.x;

// SILHUETAS
sil = new FlxBackdrop(Paths.getPreloadPath('images/madnessmenu/siloets.png'));
sil.scrollFactor.set(0, 0);
sil.y = 300;
sil.velocity.x = -50;
sil.alpha = 0.3;
add(sil);

// BARRA SUPERIOR
var topBar = new FlxSprite(0, 0);
topBar.loadGraphic(Paths.image('madnessmenu/top bar'));
topBar.setGraphicSize(FlxG.width);
topBar.updateHitbox();

topBar.x = 0;
topBar.y = 0;

topBar.scrollFactor.set(0, 0);
topBar.antialiasing = true;
add(topBar);

// BOTTOM BAR
bottomBar = new FlxSprite();
bottomBar.loadGraphic(Paths.image('madnessmenu/bottom bar'));
bottomBar.setGraphicSize(FlxG.width);
bottomBar.updateHitbox();
bottomBar.x = 0;
bottomBar.y = FlxG.height - bottomBar.height;
bottomBar.scrollFactor.set(0, 0);
add(bottomBar);

// LOGO TEMP
var logo = new FlxSprite();
logo.loadGraphic(Paths.image('madnessmenu/logo temp'));
logo.setGraphicSize(Std.int(logo.width * uniScale));
logo.updateHitbox();

// posição (ajusta fino depois)
logo.x = 40 * uniScale;
logo.y = 20 * uniScale;

logo.scrollFactor.set(0, 0);
logo.antialiasing = true;
add(logo);

// OPTIONS
var options = new FlxSprite();
options.frames = Paths.getSparrowAtlas("madnessmenu/options");

// SOMENTE o que existe no XML
options.animation.addByPrefix("idle", "options idle", 24, true);
options.animation.addByPrefix("select", "options select", 24, true);

// começa idle
options.animation.play("idle");

options.setGraphicSize(Std.int(options.width * uniScale));
options.updateHitbox();

// posição (lado direito, acima do bottom bar)
options.x = FlxG.width - options.width - (40 * uniScale);
options.y = bottomBar.y + (bottomBar.height / 2) - (options.height / 2);

options.scrollFactor.set(0, 0);
options.antialiasing = true;
add(options);

        // ===============================
        // BOTÕES
        // ===============================
        baseButtons = new FlxTypedGroup<FlxSprite>();
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

        circles = new FlxSpriteGroup();
        add(circles);

        changeSel();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
            changeSel(controls.UI_LEFT_P ? -1 : 1);

        if (controls.ACCEPT)
            confirmSel();
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
        }
    }

    function changeSel(v:Int = 0)
    {
        FlxG.sound.play(Paths.sound('madness/beep'));

        for (i in baseButtons.members)
            i.animation.play('i');

        currentSel = FlxMath.wrap(
            currentSel + v,
            0,
            baseButtons.length - 1
        );

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
        spr.scale.set(uniScale + 0.2, uniScale + 0.2);
        return spr;
    }
}