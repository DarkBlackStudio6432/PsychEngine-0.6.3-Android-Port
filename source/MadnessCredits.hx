package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxTypedGroup;
import MusicBeatState;

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
        {name: 'grave',quote: 'this mod is a disease',role: 'director, artist',link: 'https://x.com/konn_artist'},
        {name: 'vamazotz',quote: 'i fuckingf love hank j wimbleton',role: 'co-director, artist',link: 'https://x.com/vamazotz'},
        {name: 'jads',quote: 'get a bunch of bikes, and ride em around with your friends',role: 'composer',link: 'https://x.com/Aw3somejds'},
        {name: 'cval',quote: 'well hello everyone',role: 'charter, composer',link: 'https://x.com/cval_brown'},
        {name: 'punkett',quote: 'made everything',role: 'composer',link: 'https://x.com/_punkett'},
        {name: 'marstarbro',quote: "They just threw me in a group chat and 3 hours later, here's a pause theme",role: 'composer',link: 'https://x.com/MarstarMain'},
        {name: 'river',quote: 'hold the crust',role: 'composer',link: 'https://x.com/rivermusic_'},
        {name: 'shayreyez',quote: 'i need to plap thick booba mmm futa porn',role: 'artist',link: 'https://x.com/ShayReyZed'},
        {name: 'yabo',quote: 'i really rwally like gruntfriend',role: 'charter, artist',link: 'https://x.com/yaboigp'},
        {name: 'data5',quote: 'well',role: 'coder',link: 'https://x.com/_data5'},
        {name: 'smokey5',quote: 'fuck data fuuuuuuuuuuuuuuuuuuuck help me think of a quote',role: 'coder',link: 'https://x.com/Smokey_5_'},
        {name: 'jayythunder',quote: 'NOTHING BUT BANGERS, AND I KNOW BANGERS',role: 'chromatic',link: 'https://x.com/ThunderJayy'},
        {name: 'laeko',quote: 'I love my ladies like I looove burgers! Ahaha i just lov burgre ahahahahahahaha Ok wait where are u guys going',role: 'artist',link: 'https://x.com/LaekoGah'},
        {name: 'infry',quote: 'my belly is so big and round, also credit to suitman he wanted credit for genuinely nothign',role: 'saved the god damned mod',link: 'https://x.com/Infry20'},
        {name: 'mr krinkles',quote: 'thank u for making amdness combat',role: 'made madness combat',link: 'https://x.com/MRKrinkels'},
    ];

    var displayedQuote:FlxText;
    var displayedRole:FlxText;

    var rim:FlxSprite;
    var arrow:FlxSprite;
    var glow:FlxSprite;

    var everyoneButInfry:FlxSprite;
    var character:FlxSprite;

    var holdTime:Float = 0;
    var scrollLerp:Float = 0;

    // Para touch scroll
    var lastTouchY:Float = 0;
    var isDragging:Bool = false;

    // Limites de scroll
    var minScroll:Float = 0;
    var maxScroll:Float = 0;

    // Fade top/bottom
    var fadeTop:FlxSprite;
    var fadeBottom:FlxSprite;

    override function create()
    {
        persistentUpdate = true;
        super.create();

        // Glow
        glow = new FlxSprite(Paths.image('madnessmenu/credits/glows'));
        glow.alpha = 0.7;
        glow.scrollFactor.set();
        add(glow);

        // Credits text
        creditText = new FlxTypedGroup<FlxText>();
        add(creditText);

        // Arrow
        arrow = new FlxSprite(Paths.image('madnessmenu/credits/arrow'));
        arrow.scrollFactor.set();
        add(arrow);

        for (k in 0...credits.length)
        {
            var text = new FlxText(20, (text.height + 25) * k, Std.int(FlxG.width), credits[k].name.toUpperCase(), 61);
            text.font = Paths.font('impact.ttf');
            text.color = FlxColor.RED;
            creditText.add(text);
        }

        // Rim/back
        rim = new FlxSprite(Paths.image('madnessmenu/credits/grey'));
        rim.scale.set(1.1,1.1);
        rim.updateHitbox();
        rim.scrollFactor.set();
        add(rim);

        // Characters
        everyoneButInfry = new FlxSprite(Paths.image('madnessmenu/credits/creditChar'));
        everyoneButInfry.antialiasing = true;
        everyoneButInfry.scrollFactor.set();
        add(everyoneButInfry);

        character = new FlxSprite(Paths.image('madnessmenu/credits/infry'));
        character.scrollFactor.set();
        add(character);

        // Spotlight
        var spotlight = new FlxSprite(FlxG.width - rim.width - 25, Paths.image('madnessmenu/credits/light'));
        spotlight.scale.copyFrom(rim.scale);
        spotlight.updateHitbox();
        spotlight.scrollFactor.set();
        add(spotlight);

        rim.y = spotlight.y + spotlight.height + 10;
        rim.x = spotlight.x + (spotlight.width - rim.width)/2;

        // Displayed texts
        displayedRole = new FlxText(0, 0, Std.int(FlxG.width - 25), '', 60);
        displayedRole.alignment = "right";
        displayedRole.font = Paths.font('BebasNeue-Regular.ttf');
        displayedRole.scale.y = 1.5;
        displayedRole.scrollFactor.set();
        add(displayedRole);

        displayedQuote = new FlxText(0, 0, Std.int(FlxG.width - 25), '', 40);
        displayedQuote.font = Paths.font('impact.ttf');
        displayedQuote.color = FlxColor.RED;
        displayedQuote.scrollFactor.set();
        displayedQuote.y = rim.y + rim.height;
        add(displayedQuote);

        // Calcula limites de scroll
        minScroll = 0;
        var lastTxt = creditText.members[credits.length - 1];
        maxScroll = (lastTxt.y + lastTxt.height) - FlxG.height;
        if (maxScroll < 0) maxScroll = 0;

        // Cria fades
        fadeTop = new FlxSprite();
        fadeTop.makeGraphic(FlxG.width, 150, 0x000000);
        fadeTop.scrollFactor.set();
        fadeTop.set_alpha(0.7);
        add(fadeTop);

        fadeBottom = new FlxSprite();
        fadeBottom.makeGraphic(FlxG.width, 150, 0x000000);
        fadeBottom.y = FlxG.height - 150;
        fadeBottom.scrollFactor.set();
        fadeBottom.set_alpha(0.7);
        add(fadeBottom);

        changeSel();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        // Touch scrolling
        #if mobile
        if (FlxG.touches.length > 0)
        {
            var t = FlxG.touches[0];
            if (!isDragging)
            {
                isDragging = true;
                lastTouchY = t.screenY;
            }
            else
            {
                var delta = lastTouchY - t.screenY;
                scrollLerp += delta;
                lastTouchY = t.screenY;
            }
        }
        else
        {
            isDragging = false;
        }
        #end

        // Mantém scroll dentro dos limites
        scrollLerp = FlxMath.clamp(scrollLerp, minScroll, maxScroll);

        // Scroll com teclado ou mouse wheel
        if (controls.UI_DOWN_P || controls.UI_UP_P || FlxG.mouse.wheel != 0)
        {
            holdTime = 0;
            changeSel(FlxG.mouse.wheel == 0 ? (controls.UI_DOWN_P ? 1 : -1) : -FlxG.mouse.wheel);
        }

        if (controls.BACK) MusicBeatState.switchState(new MadnessMenu());
        if (controls.ACCEPT || FlxG.mouse.justPressed) CoolUtil.browserLoad(credits[curSel].link);

        if(controls.UI_DOWN || controls.UI_UP)
        {
            var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
            holdTime += elapsed;
            var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

            if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
                changeSel((checkNewHold - checkLastHold) * (controls.UI_UP ? -1 : 1));
        }

        FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, scrollLerp, 0.4 * 60 * elapsed);

        for (k in 0...creditText.length)
        {
            var i = creditText.members[k];
            var pos = (k == curSel) ? 150 : 20;
            i.x = FlxMath.lerp(i.x, pos, 0.4 * 60 * elapsed);

            // Fade effect
            var distY = i.y - FlxG.camera.scroll.y;
            var alpha = 1.0;
            if (distY < 150) alpha = distY / 150;
            if ((FlxG.height - distY) < 150) alpha = (FlxG.height - distY) / 150;
            i.alpha = FlxMath.clamp(alpha, 0, 1);
        }
    }

    function changeSel(s:Int = 0)
    {
        if (s != 0) FlxG.sound.play(Paths.sound('madness/beep'));

        curSel = FlxMath.wrap(curSel + s, 0, credits.length - 1);

        var curText = creditText.members[curSel];

        displayedQuote.text = '"' + credits[curSel].quote.toUpperCase() + '"';
        displayedRole.text = credits[curSel].role.toUpperCase();

        scrollLerp = FlxMath.clamp(
            (curText.y + curText.height/2) - FlxG.height/2,
            minScroll, maxScroll
        );

        displayedQuote.x = rim.x + (rim.width - displayedQuote.width)/2;
        arrow.x = curText.x + curText.width + 10;
        arrow.y = curText.y + (curText.height - arrow.height)/2;
        glow.x = curText.x + (curText.width - glow.width)/2;
        glow.y = curText.y + (curText.height - glow.height)/2;
    }
}