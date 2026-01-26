package;

import MusicBeatState;
import StoryMenuState;
import CreditsState;
import ClientPrefs;
import Paths;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;

class MadnessMenu extends MusicBeatState
{
    var uniScale:Float = 1;
    var currentSel:Int = 0;

    var baseButtons:FlxTypedGroup<FlxSprite>;
    var circles:FlxSpriteGroup;
    var storyButton:FlxSprite;

    override function create()
    {
        super.create(); // 🔥 TEM QUE SER PRIMEIRO

trace("MADNESS MENU ABERTO");
FlxG.camera.bgColor = FlxColor.RED;

		var bg:FlxSprite = new FlxSprite()
			.makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
		add(bg);

        persistentUpdate = true;

        // BACKGROUND
        var back = new FlxSprite().loadGraphic(
            Paths.image('madnessmenu/back')
        );
        back.setGraphicSize(FlxG.width);
        back.updateHitbox();
        back.screenCenter(FlxAxes.Y);
        back.y += 100;
        add(back);

        uniScale = back.scale.x;

        // SILHUETAS
        //var silh = new FlxBackdrop(
           // Paths.image('madnessmenu/siloets'),
          //  0,
           // 20
       // );
       // silh.scale.set(uniScale, uniScale);
        //silh.y = 300;
        //silh.velocity.x = -50;
        //silh.alpha = 0.3;
        //add(silh);

        // BOTÕES
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