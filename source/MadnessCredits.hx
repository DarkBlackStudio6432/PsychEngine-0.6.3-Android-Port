import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.input.touch.FlxTouch;
import options.OptionsState;

@:structInit class Credit {
    public var name:String = '';
    public var quote:String = '';
    public var role:String = '';
    public var link:String = '';
}

class MadnessCredits extends MusicBeatState
{
    var curSel:Int = 0;

    var creditText:FlxGroup;
    var credits:Array<Credit> = [
        {name: 'grave', quote: 'this mod is a disease', role: 'director, artist', link: 'https://x.com/konn_artist'},
        {name: 'vamazotz', quote: 'i fucking love hank j wimbleton', role: 'co-director, artist', link: 'https://x.com/vamazotz'},
        {name: 'jads', quote: 'get a bunch of bikes, and ride em around with your friends', role: 'composer', link: 'https://x.com/Aw3somejds'},
        {name: 'cval', quote: 'well hello everyone', role: 'charter, composer', link: 'https://x.com/cval_brown'},
        {name: 'punkett', quote: 'made everything', role: 'composer', link: 'https://x.com/_punkett'},
        {name: 'marstarbro', quote: "They just threw me in a group chat and 3 hours later, here's a pause theme", role: 'composer', link: 'https://x.com/MarstarMain'},
        {name: 'river', quote: 'hold the crust', role: 'composer', link: 'https://x.com/rivermusic_'},
        {name: 'shayreyez', quote: 'i need to plap thick booba mmm futa porn', role: 'artist', link: 'https://x.com/ShayReyZed'},
        {name: 'yabo', quote: 'i really rwally like gruntfriend', role: 'charter, artist', link: 'https://x.com/yaboigp'},
        {name: 'data5', quote: 'well', role: 'coder', link: 'https://x.com/_data5'},
        {name: 'smokey5', quote: 'fuck data fuuuuuuuuuuuuuuuuuuuck help me think of a quote', role: 'coder', link: 'https://x.com/Smokey_5_'},
        {name: 'jayythunder', quote: 'NOTHING BUT BANGERS, AND I KNOW BANGERS', role: 'chromatic', link: 'https://x.com/ThunderJayy'},
        {name: 'laeko', quote: 'I love my ladies like I looove burgers! Ahaha i just lov burgre ahahahahahahaha Ok wait where are u guys going', role: 'artist', link: 'https://x.com/LaekoGah'},
        {name: 'infry', quote: 'my belly is so big and round, also credit to suitman he wanted credit for genuinely nothign', role: 'saved the god damned mod', link: 'https://x.com/Infry20'},
        {name: 'mr krinkles', quote: 'thank u for making amdness combat', role: 'made madness combat', link: 'https://x.com/MRKrinkels'}
    ];

    var displayedQuote:FlxText;
    var displayedRole:FlxText;

    var rim:FlxSprite;
    var arrow:FlxSprite;
    var glow:FlxSprite;

    var everyoneButInfry:FlxSprite;
    var character:FlxSprite;

    var scrollLerp:Float = 0;
    var holdTime:Float = 0;
    var lastYTouch:Float = 0;

    override function create() {
        persistentUpdate = true;
        super.create();

        // glow
        glow = new FlxSprite(Paths.image('madnessmenu/credits/glows'));
        glow.alpha = 0.7;
        add(glow);

        // creditText group
        creditText = new FlxGroup();
        add(creditText);

        // arrow
        arrow = new FlxSprite(Paths.image('madnessmenu/credits/arrow'));
        add(arrow);

        // credits text
        for (k => i in credits) {
            var text:FlxText = new FlxText(20, 0, 0, i.name.toUpperCase(), 61);
            text.y = (text.height + 25) * k;
            text.font = Paths.font('impact.ttf');
            text.color = FlxColor.RED;
            creditText.add(text);
        }

        // rim
        rim = new FlxSprite(Paths.image('madnessmenu/credits/grey'));
        rim.scale.set(1.1, 1.1);
        rim.updateHitbox();
        add(rim);

        // characters
        everyoneButInfry = new FlxSprite(Paths.image('madnessmenu/credits/creditChar'));
        add(everyoneButInfry);

        character = new FlxSprite(Paths.image('madnessmenu/credits/infry'));
        add(character);

        // spotlight
        var spotlight = new FlxSprite(FlxG.width - rim.width - 25, Paths.image('madnessmenu/credits/light'));
        spotlight.scale.copyFrom(rim.scale);
        spotlight.updateHitbox();
        add(spotlight);

        rim.y = spotlight.y + spotlight.height + 10;
        rim.x = spotlight.x + (spotlight.width - rim.width)/2;

        // displayed texts
        displayedRole = new FlxText(0, 0, FlxG.width - 25, '', 60);
        displayedRole.alignment = "right";
        displayedRole.font = Paths.font('BebasNeue-Regular.ttf');
        add(displayedRole);

        displayedQuote = new FlxText(0, 0, 0, '', 40);
        displayedQuote.font = Paths.font('impact.ttf');
        displayedQuote.scrollFactor.set();
        add(displayedQuote);
        displayedQuote.y = rim.y + rim.height;
        displayedQuote.color = FlxColor.RED;

        changeSel();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        // keyboard / mouse scroll
        if (controls.UI_DOWN_P || controls.UI_UP_P || FlxG.mouse.wheel != 0) {
            holdTime = 0;
            changeSel(FlxG.mouse.wheel == 0 ? controls.UI_DOWN_P ? 1 : -1 : -FlxG.mouse.wheel);
        }

        if (controls.BACK) MusicBeatState.switchState(new MadnessMenu());

        if (controls.ACCEPT || FlxG.mouse.justPressed) {
            CoolUtil.browserLoad(credits[curSel].link);
        }

        if (controls.UI_DOWN || controls.UI_UP) {
            var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
            holdTime += elapsed;
            var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
            if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
                changeSel((checkNewHold - checkLastHold) * (controls.UI_UP ? -1 : 1));
        }

        // smooth camera scroll
        FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, scrollLerp, 0.4 * 60 * elapsed);

        // text position/alpha
        for (k => i in creditText.members) {
            var pos = k == curSel ? 150 : 20;
            (cast i:FlxText).x = FlxMath.lerp((cast i:FlxText).x, pos, 0.4 * 60 * elapsed);

            var alpha = Math.abs(FlxMath.remapToRange(Math.abs(k - curSel), 4, 0, 0, 1));
            (cast i:FlxText).alpha = FlxMath.lerp((cast i:FlxText).alpha, alpha, 0.4 * 60 * elapsed);
        }

        // touch scroll for mobile
        #if mobile
        for (i in 0...FlxG.touches.getNumActive()) {
            var touch:FlxTouch = FlxG.touches.getTouch(i);
            if (touch != null) {
                if (touch.justPressed) lastYTouch = touch.screenY;
                var deltaY = touch.screenY - lastYTouch;
                scrollLerp -= deltaY;
                lastYTouch = touch.screenY;
                scrollLerp = clamp(scrollLerp, 0, (credits.length - 1) * 100);
            }
        }
        #end
    }

    function changeSel(s:Int = 0) {
        if (s != 0) FlxG.sound.play(Paths.sound('madness/beep'));

        curSel = FlxMath.wrap(curSel + s, 0, credits.length - 1);

        var curText:FlxText = cast creditText.members[curSel];

        displayedQuote.text = '"' + credits[curSel].quote.toUpperCase() + '"';
        displayedRole.text = credits[curSel].role.toUpperCase();
        scrollLerp = (curText.y + (curText.height / 2)) - (FlxG.height / 2);

        displayedQuote.x = rim.x + (rim.width - displayedQuote.width) / 2;

        arrow.x = curText.x + curText.width + 10;
        arrow.y = curText.y + (curText.height - arrow.height) / 2;

        glow.x = curText.x + (curText.width - glow.width) / 2;
        glow.y = curText.y + (curText.height - glow.height) / 2;
        glow.width = curText.width + 25;
        glow.height = curText.height;

        if (credits[curSel].name == 'infry') {
            character.visible = true;
            everyoneButInfry.visible = false;
            character.x = rim.x + (rim.width - character.width)/2 - 100;
            character.y = rim.y - character.height + rim.height/2 + 35;
        } else {
            character.visible = false;
            everyoneButInfry.visible = true;
        }
    }

    function clamp(value:Float, min:Float, max:Float):Float {
        return value < min ? min : (value > max ? max : value);
    }
}