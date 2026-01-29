package;

import MusicBeatState;
import CoolUtil;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

import Character;
import AttachedSprite;

#if mobile
import mobile.objects.MobileControls;
#end

@:structInit class Credit {
    public var name:String = '';
    public var quote:String = '';
    public var role:String = '';
    public var link:String = '';
}

class MadnessCredits extends MusicBeatState
{
    var curSel:Int = 0;

    var creditText:FlxTypedGroup<FlxText>;
    var credits:Array<Credit> = [
        {name:'grave', quote:'this mod is a disease', role:'director, artist', link:'https://x.com/konn_artist'},
        {name:'vamazotz', quote:'i fucking love hank j wimbleton', role:'co-director, artist', link:'https://x.com/vamazotz'},
        {name:'jads', quote:'get a bunch of bikes, and ride em around with your friends', role:'composer', link:'https://x.com/Aw3somejds'},
        {name:'cval', quote:'well hello everyone', role:'charter, composer', link:'https://x.com/cval_brown'},
        {name:'punkett', quote:'made everything', role:'composer', link:'https://x.com/_punkett'},
        {name:'marstarbro', quote:'they just threw me in a group chat', role:'composer', link:'https://x.com/MarstarMain'},
        {name:'river', quote:'hold the crust', role:'composer', link:'https://x.com/rivermusic_'},
        {name:'shayreyez', quote:'artist moment', role:'artist', link:'https://x.com/ShayReyZed'},
        {name:'yabo', quote:'gruntfriend enjoyer', role:'charter, artist', link:'https://x.com/yaboigp'},
        {name:'data5', quote:'well', role:'coder', link:'https://x.com/_data5'},
        {name:'smokey5', quote:'fuck data', role:'coder', link:'https://x.com/Smokey_5_'},
        {name:'jayythunder', quote:'NOTHING BUT BANGERS', role:'chromatic', link:'https://x.com/ThunderJayy'},
        {name:'laeko', quote:'i love burgers', role:'artist', link:'https://x.com/LaekoGah'},
        {name:'infry', quote:'saved the god damned mod', role:'savior', link:'https://x.com/Infry20'},
        {name:'mr krinkles', quote:'thank u for making madness combat', role:'madness combat', link:'https://x.com/MRKrinkels'}
    ];

    var displayedQuote:FlxText;
    var displayedRole:FlxText;

    var arrow:AttachedSprite;
    var glow:AttachedSprite;

    var everyoneButInfry:Character;
    var infryChar:FlxSprite;

    var scrollLerp:Float = 0;
    var holdTime:Float = 0;

    var mobileScale:Float = 1;

    #if mobile
    var mobileControls:MobileControls;
    #end

    override function create()
    {
        persistentUpdate = true;
        super.create();

        // ======================
        // ESCALA AUTOMÁTICA
        // ======================
        #if mobile
        mobileScale = Math.min(FlxG.width / 1280, FlxG.height / 720);
        #else
        mobileScale = 1;
        #end

        creditText = new FlxTypedGroup<FlxText>();
        add(creditText);

        for (k => c in credits)
        {
            var t = new FlxText(
                20 * mobileScale,
                (k * (80 * mobileScale)),
                0,
                c.name.toUpperCase(),
                Std.int(60 * mobileScale)
            );
            t.font = Paths.font('impact.ttf');
            t.color = FlxColor.RED;
            creditText.add(t);
        }

        arrow = new AttachedSprite('madnessmenu/credits/arrow');
        add(arrow);

        glow = new AttachedSprite('madnessmenu/credits/glows');
        glow.alpha = 0.6;
        add(glow);

        everyoneButInfry = new Character(650, 140, 'creditChar');
        add(everyoneButInfry);

        infryChar = new FlxSprite();
        infryChar.frames = Paths.getSparrowAtlas('madnessmenu/credits/infry');
        infryChar.animation.addByPrefix('idle', 'infry', 24, false);
        infryChar.visible = false;
        add(infryChar);

        displayedRole = new FlxText(0, 0, FlxG.width, '', Std.int(48 * mobileScale));
        displayedRole.font = Paths.font('BebasNeue-Regular.ttf');
        displayedRole.alignment = RIGHT;
        add(displayedRole);

        displayedQuote = new FlxText(0, 0, FlxG.width, '', Std.int(36 * mobileScale));
        displayedQuote.font = Paths.font('impact.ttf');
        displayedQuote.color = FlxColor.RED;
        add(displayedQuote);

        changeSel();

        #if mobile
        mobileControls = new MobileControls();
        mobileControls.scrollFactor.set();
        add(mobileControls);
        #end
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        #if mobile
        // BACK
        if (mobileControls.current.buttonExtra2 != null
            && mobileControls.current.buttonExtra2.justPressed)
        {
            FlxG.sound.play(Paths.sound('madness/cancel'));
            MusicBeatState.switchState(new MadnessMenu());
            return;
        }

        // UP / DOWN
        if (mobileControls.current.buttonUp != null
            && mobileControls.current.buttonUp.justPressed)
            changeSel(-1);

        if (mobileControls.current.buttonDown != null
            && mobileControls.current.buttonDown.justPressed)
            changeSel(1);

        // ACCEPT
        if (mobileControls.current.buttonExtra1 != null
            && mobileControls.current.buttonExtra1.justPressed)
            CoolUtil.browserLoad(credits[curSel].link);
        #end

        FlxG.camera.scroll.y = FlxMath.lerp(
            FlxG.camera.scroll.y,
            scrollLerp,
            0.4 * 60 * elapsed
        );

        for (k => t in creditText)
        {
            var targetX = (k == curSel) ? 150 * mobileScale : 20 * mobileScale;
            t.x = FlxMath.lerp(t.x, targetX, 0.4 * 60 * elapsed);

            var a = Math.abs(FlxMath.remapToRange(Math.abs(k - curSel), 4, 0, 0, 1));
            t.alpha = FlxMath.lerp(t.alpha, a, 0.4 * 60 * elapsed);
        }
    }

    function changeSel(v:Int = 0)
    {
        if (v != 0)
            FlxG.sound.play(Paths.sound('madness/beep'));

        curSel = FlxMath.wrap(curSel + v, 0, credits.length - 1);

        var curText = creditText.members[curSel];
        scrollLerp = (curText.y + curText.height / 2) - FlxG.height / 2;

        displayedQuote.text = '"' + credits[curSel].quote.toUpperCase() + '"';
        displayedRole.text = credits[curSel].role.toUpperCase();

        arrow.sprTracker = curText;
        arrow.xAdd = curText.width + 10;
        arrow.yAdd = (curText.height - arrow.height) / 2;

        glow.sprTracker = curText;
        glow.setGraphicSize(curText.width + 25, curText.height);
        glow.updateHitbox();
        glow.xAdd = (curText.width - glow.width) / 2;
        glow.yAdd = (curText.height - glow.height) / 2;

        if (credits[curSel].name == 'infry')
        {
            infryChar.visible = true;
            everyoneButInfry.visible = false;
            infryChar.animation.play('idle', true);
        }
        else
        {
            infryChar.visible = false;
            everyoneButInfry.visible = true;
            everyoneButInfry.playAnim(credits[curSel].name + '1', true);
        }
    }
}