package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.transition.FlxTransitionableState;
import MusicBeatState;
import options.OptionsState;
using StringTools;

class MainMenuMadness extends MusicBeatState
{
    public static var curSelected:Int = 0;
    
    var menuItems:FlxTypedGroup<FlxSprite>;
    var hoverMode:Hovering = ANYTHINGELSE;
    var currentSel:Int = 0;

    var baseButtons:FlxTypedGroup<FlxSprite>;
    var optionsButton:FlxSprite;

    var texts:FlxTypedGroup<FlxText>;

    var dropdownOpen:Bool = false;

    enum Hovering { OPTIONS; ANYTHINGELSE; }

    override function create()
    {
        super.create();

        FlxG.mouse.visible = true;

        // Menu Background
        var bg:FlxSprite = new FlxSprite(0,0,Paths.image("madnessmenu/back"));
        bg.setGraphicSize(FlxG.width, FlxG.height);
        bg.updateHitbox();
        add(bg);

        // Base buttons group
        baseButtons = new FlxTypedGroup<FlxSprite>();
        add(baseButtons);

        optionsButton = makeButton("options");
        optionsButton.setPosition(FlxG.width - 200, FlxG.height - 100);
        add(optionsButton);

        // Story button
        var storyButton = makeButton("storymode");
        storyButton.setPosition(200, 200);
        baseButtons.add(storyButton);

        var freeplayButton = makeButton("freeplay");
        freeplayButton.setPosition(storyButton.x + 300, storyButton.y);
        baseButtons.add(freeplayButton);

        // Dropdown texts
        texts = new FlxTypedGroup<FlxText>();
        add(texts);
        var options:Array<String> = ["HANK","???","COMING SOON"];
        for (i in 0...options.length)
        {
            var t = new FlxText(0,0,200, options[i]);
            t.ID = i;
            t.color = FlxG.WHITE;
            texts.add(t);
            t.visible = false;
        }

        changeSel();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        // Mouse over buttons
        for (btn in baseButtons)
        {
            if (FlxG.mouse.overlaps(btn) && FlxG.mouse.justPressed)
            {
                currentSel = baseButtons.members.indexOf(btn);
                confirmSel();
            }
        }

        // Options button
        if (FlxG.mouse.overlaps(optionsButton) && FlxG.mouse.justPressed)
        {
            MusicBeatState.switchState(new OptionsState());
        }

        // Keyboard controls
        if (FlxG.keys.justPressed.UP) changeSel(-1);
        if (FlxG.keys.justPressed.DOWN) changeSel(1);
        if (FlxG.keys.justPressed.ENTER) confirmSel();
    }

    function changeSel(change:Int = 0)
    {
        currentSel = FlxMath.wrap(currentSel + change, 0, baseButtons.length - 1);

        // Play select sound
        FlxG.sound.play(Paths.sound("madness/beep"));

        for (btn in baseButtons) btn.animation.play("i");
        baseButtons.members[currentSel].animation.play("select");
    }

    function confirmSel()
    {
        var btn = baseButtons.members[currentSel];
        btn.animation.play("confirm");

        switch (currentSel)
        {
            case 0: openStoryDropdown();
            case 1: FlxG.switchState(new TitleState()); // freeplay ou outro
        }
    }

    function openStoryDropdown()
    {
        dropdownOpen = true;

        for (i in texts)
        {
            i.visible = true;
            i.x = 200;
            i.y = 250 + i.ID * 50;
        }
    }

    function makeButton(name:String):FlxSprite
    {
        var spr = new FlxSprite();
        spr.frames = Paths.getSparrowAtlas("madnessmenu/" + name);
        spr.animation.addByPrefix("i", name + "0");
        spr.animation.addByPrefix("select", name + " select");
        spr.animation.addByPrefix("confirm", name + " confirm");
        spr.animation.play("i");
        spr.updateHitbox();
        return spr;
    }
}