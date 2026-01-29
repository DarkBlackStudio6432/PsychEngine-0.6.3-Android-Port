package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.ui.FlxVirtualPad;
import MusicBeatState;
import backend.CoolUtil;
import objects.Character;
import objects.AttachedSprite;
import Paths;

@:structInit class Credit {
    public var name:String = '';
    public var quote:String = '';
    public var role:String = '';
    public var link:String = '';
}

class MadnessCredits extends MusicBeatState
{
    var curSel:Int = 0;
    var uniScale:Float = 1;

    var creditText:FlxTypedGroup<FlxText>;
    var credits:Array<Credit> = [
        {name:'grave',quote:'this mod is a disease',role:'director, artist',link:'https://x.com/konn_artist'},
        {name:'vamazotz',quote:'i fucking love hank j wimbleton',role:'co-director, artist',link:'https://x.com/vamazotz'},
        {name:'jads',quote:'get a bunch of bikes, and ride em around with your friends',role:'composer',link:'https://x.com/Aw3somejds'},
        {name:'cval',quote:'well hello everyone',role:'charter, composer',link:'https://x.com/cval_brown'},
        {name:'punkett',quote:'made everything',role:'composer',link:'https://x.com/_punkett'},
        {name:'river',quote:'hold the crust',role:'composer',link:'https://x.com/rivermusic_'},
        {name:'shayreyez',quote:'artist moment',role:'artist',link:'https://x.com/ShayReyZed'},
        {name:'data5',quote:'well',role:'coder',link:'https://x.com/_data5'},
        {name:'infry',quote:'saved the god damned mod',role:'savior',link:'https://x.com/Infry20'},
        {name:'mr krinkles',quote:'thank u for making madness combat',role:'madness creator',link:'https://x.com/MRKrinkels'},
    ];

    var displayedQuote:FlxText;
    var displayedRole:FlxText;

    var rim:FlxSprite;
    var arrow:AttachedSprite;
    var glow:AttachedSprite;

    var character:FlxSprite;
    var everyoneButInfry:Character;

    #if mobile
    var virtualPad:FlxVirtualPad;
    #end

    override function create()
    {
        persistentUpdate = true;
        super.create();

        #if mobile
        uniScale = FlxG.width / 1280;
        #end

        creditText = new FlxTypedGroup<FlxText>();
        add(creditText);

        for (k => c in credits)
        {
            var txt = new FlxText(
                20 * uniScale,
                0,
                0,
                c.name.toUpperCase(),
                Std.int(60 * uniScale)
            );
            txt.font = Paths.font('impact.ttf');
            txt.color = FlxColor.RED;
            txt.y = (txt.height + 25 * uniScale) * k;
            creditText.add(txt);
        }

        rim = new FlxSprite(Paths.image('madnessmenu/credits/grey'));
        rim.scale.set(1.1 * uniScale, 1.1 * uniScale);
        rim.updateHitbox();
        rim.scrollFactor.set();
        add(rim);

        rim.screenCenter(X);
        rim.y = 80 * uniScale;

        displayedRole = new FlxText(
            0,
            rim.y - 60 * uniScale,
            FlxG.width - 40 * uniScale,
            '',
            Std.int(50 * uniScale)
        );
        displayedRole.alignment = RIGHT;
        displayedRole.font = Paths.font('BebasNeue-Regular.ttf');
        displayedRole.scrollFactor.set();
        add(displayedRole);

        displayedQuote = new FlxText(
            0,
            rim.y + rim.height + 10 * uniScale,
            FlxG.width - 40 * uniScale,
            '',
            Std.int(36 * uniScale)
        );
        displayedQuote.font = Paths.font('impact.ttf');
        displayedQuote.color = FlxColor.RED;
        displayedQuote.scrollFactor.set();
        add(displayedQuote);

        arrow = new AttachedSprite('madnessmenu/credits/arrow');
        arrow.scale.set(uniScale, uniScale);
        arrow.updateHitbox();
        add(arrow);

        glow = new AttachedSprite('madnessmenu/credits/glows');
        glow.alpha = 0.7;
        glow.scale.set(uniScale, uniScale);
        glow.updateHitbox();
        add(glow);

        everyoneButInfry = new Character(0, 0, 'creditChar');
        everyoneButInfry.scrollFactor.set();
        add(everyoneButInfry);

        character = new FlxSprite();
        character.frames = Paths.getSparrowAtlas('madnessmenu/credits/infry');
        character.animation.addByPrefix('infry', 'infry', 24, true);
        character.scrollFactor.set();
        add(character);

        #if mobile
        virtualPad = new FlxVirtualPad(UP_DOWN, A_B);
        virtualPad.alpha = 0.75;
        add(virtualPad);
        #end

        changeSel();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.UI_DOWN_P) changeSel(1);
        if (controls.UI_UP_P) changeSel(-1);

        if (controls.ACCEPT)
            CoolUtil.browserLoad(credits[curSel].link);

        if (controls.BACK)
            MusicBeatState.switchState(new MadnessMenu());

        #if mobile
        if (virtualPad.buttonUp.justPressed) changeSel(-1);
        if (virtualPad.buttonDown.justPressed) changeSel(1);
        if (virtualPad.buttonA.justPressed)
            CoolUtil.browserLoad(credits[curSel].link);
        if (virtualPad.buttonB.justPressed)
            MusicBeatState.switchState(new MadnessMenu());
        #end
    }

    function changeSel(v:Int = 0)
    {
        curSel = FlxMath.wrap(curSel + v, 0, credits.length - 1);

        var cur = creditText.members[curSel];
        displayedQuote.text = '"' + credits[curSel].quote.toUpperCase() + '"';
        displayedRole.text = credits[curSel].role.toUpperCase();

        arrow.sprTracker = cur;
        arrow.xAdd = cur.width + 10 * uniScale;
        arrow.yAdd = (cur.height - arrow.height) / 2;

        glow.sprTracker = cur;
        glow.xAdd = -10 * uniScale;
        glow.yAdd = (cur.height - glow.height) / 2;
    }
}