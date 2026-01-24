package;

#if desktop
import Discord.DiscordClient;
#end

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.effects.FlxFlicker;

import lime.app.Application;

import options.OptionsState;

#if mobile
import mobile.MobilePad;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
    // OBRIGATÓRIO NA 0.6.3
    public static var psychEngineVersion:String = "0.6.3";
    public static var curSelected:Int = 0;

    var menuItems:FlxTypedGroup<FlxSprite>;
    var camFollow:FlxObject;
    var selectedSomethin:Bool = false;

    var optionShit:Array<String> = [
        'story_mode',
        'freeplay',
        'credits',
        'options'
    ];

    #if mobile
    var mobilePad:MobilePad;
    #end

    override function create()
    {
        #if desktop
        DiscordClient.changePresence("In the Menus", null);
        #end

        persistentUpdate = persistentDraw = true;

        // FUNDO
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
        bg.screenCenter();
        bg.antialiasing = ClientPrefs.data.antialiasing;
        add(bg);

        camFollow = new FlxObject(0, 0, 1, 1);
        add(camFollow);

        menuItems = new FlxTypedGroup<FlxSprite>();
        add(menuItems);

        for (i in 0...optionShit.length)
        {
            var offset:Float = 200;
            var menuItem:FlxSprite = new FlxSprite(0, offset + (i * 140));
            menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
            menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
            menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
            menuItem.animation.play('idle');
            menuItem.ID = i;
            menuItem.antialiasing = ClientPrefs.data.antialiasing;
            menuItem.screenCenter(X);
            menuItems.add(menuItem);
        }

        changeItem();

        FlxG.camera.follow(camFollow, null, 9);

        // VERSÃO NO CANTO
        var verText:FlxText = new FlxText(12, FlxG.height - 24, 0,
            "Psych Engine v" + psychEngineVersion, 16);
        verText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(verText);

        #if mobile
        mobilePad = new MobilePad(UP_DOWN, A_B);
        add(mobilePad);
        controls.setVirtualPad(mobilePad);
        #end

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (!selectedSomethin)
        {
            if (controls.UI_UP_P)
                changeItem(-1);

            if (controls.UI_DOWN_P)
                changeItem(1);

            if (controls.BACK)
            {
                selectedSomethin = true;
                MusicBeatState.switchState(new TitleState());
            }

            if (controls.ACCEPT)
                selectItem();
        }

        super.update(elapsed);
    }

    function changeItem(huh:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'));

        menuItems.members[curSelected].animation.play('idle');

        curSelected += huh;

        if (curSelected < 0)
            curSelected = menuItems.length - 1;
        if (curSelected >= menuItems.length)
            curSelected = 0;

        var item = menuItems.members[curSelected];
        item.animation.play('selected');
        item.centerOffsets();
        item.screenCenter(X);

        camFollow.setPosition(
            item.getGraphicMidpoint().x,
            item.getGraphicMidpoint().y
        );
    }

    function selectItem()
    {
        selectedSomethin = true;
        FlxG.sound.play(Paths.sound('confirmMenu'));

        var item = menuItems.members[curSelected];

        FlxFlicker.flicker(item, 1, 0.06, false, false, function(_)
        {
            switch (optionShit[curSelected])
            {
                case 'story_mode':
                    MusicBeatState.switchState(new StoryMenuState());

                case 'freeplay':
                    MusicBeatState.switchState(new FreeplayState());

                case 'credits':
                    MusicBeatState.switchState(new CreditsState());

                case 'options':
                    MusicBeatState.switchState(new OptionsState());
            }
        });
    }
}