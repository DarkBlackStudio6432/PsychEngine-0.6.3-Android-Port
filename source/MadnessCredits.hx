import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.input.touch.FlxTouch;

@:structInit
class Credit {
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
    var lastTouchY:Float = 0;

    override function create() {
        persistentUpdate = true;
        super.create();

        #if mobile
        FlxG.mouse.visible = false;
        #end

        // Glow
        glow = new FlxSprite('madnessmenu/credits/glows');
        glow.alpha = 0.7;
        add(glow);

        // Credits
        creditText = new FlxTypedGroup<FlxText>();
        add(creditText);

        for (k => i in credits) {
            var text = new FlxText(20, 0, 0, i.name.toUpperCase(), 61);
            text.y = (text.height + 25) * k;
            text.font = Paths.font('impact.ttf');
            text.color = FlxColor.RED;
            creditText.add(text);
        }

        // Rim
        rim = new FlxSprite(Paths.image('madnessmenu/credits/grey'));
        rim.scale.set(1.1, 1.1);
        rim.updateHitbox();
        rim.scrollFactor.set();
        add(rim);

        // Characters
        everyoneButInfry = new FlxSprite(Paths.image('madnessmenu/credits/creditChar'));
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
        rim.x = spotlight.x + (spotlight.width - rim.width) / 2;

        // Quote & Role
        displayedRole = new FlxText(0, 0, Std.int(FlxG.width - 25), '', 60);
        displayedRole.alignment = "right";
        displayedRole.font = Paths.font('BebasNeue-Regular.ttf');
        displayedRole.scale.y = 1.5;
        displayedRole.scrollFactor.set();
        add(displayedRole);

        displayedQuote = new FlxText(0, rim.y + rim.height, 0, '', 40);
        displayedQuote.font = Paths.font('impact.ttf');
        displayedQuote.color = FlxColor.RED;
        displayedQuote.scrollFactor.set();
        add(displayedQuote);

        changeSel();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        // Back button
        if (controls.BACK) MusicBeatState.switchState(new MadnessMenu());
        if (controls.ACCEPT || FlxG.mouse.justPressed) CoolUtil.browserLoad(credits[curSel].link);

        // Scroll with arrows or wheel
        if (controls.UI_DOWN_P || controls.UI_UP_P || FlxG.mouse.wheel != 0) {
            holdTime = 0;
            changeSel(FlxG.mouse.wheel == 0 ? (controls.UI_DOWN_P ? 1 : -1) : -FlxG.mouse.wheel);
        }

        // Hold arrows
        if (controls.UI_DOWN || controls.UI_UP) {
            var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
            holdTime += elapsed;
            var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
            if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
                changeSel((checkNewHold - checkLastHold) * (controls.UI_UP ? -1 : 1));
        }

        // Touch scrolling
        #if mobile
        if (FlxG.touches.length > 0) {
            var t:FlxTouch = FlxG.touches[0];
            if (t.justPressed) lastTouchY = t.y;
            else {
                var deltaY = t.y - lastTouchY;
                scrollLerp = FlxMath.clamp(scrollLerp - deltaY, 0, (creditText.members[creditText.length-1].y));
                lastTouchY = t.y;
            }
        }
        #end

        // Camera lerp
        FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, scrollLerp, 0.4 * 60 * elapsed);

        // Animate credits
        for (k => i in creditText.members) {
            if (i == null) continue;
            var pos = (k == curSel) ? 150 : 20;
            i.x = FlxMath.lerp(i.x, pos, 0.4 * 60 * elapsed);
            var alpha = Math.abs(FlxMath.remapToRange(Math.abs(k - curSel), 4, 0, 0, 1));
            i.alpha = FlxMath.lerp(i.alpha, alpha, 0.4 * 60 * elapsed);
        }
    }

    function changeSel(s:Int = 0) {
        if (s != 0) FlxG.sound.play(Paths.sound('madness/beep'));

        curSel = FlxMath.wrap(curSel + s, 0, credits.length - 1);
        var curText = creditText.members[curSel];

        displayedQuote.text = '"' + credits[curSel].quote.toUpperCase() + '"';
        displayedRole.text = credits[curSel].role.toUpperCase();

        scrollLerp = (curText.y + curText.height / 2) - (FlxG.height / 2);
        displayedQuote.x = rim.x + (rim.width - displayedQuote.width) / 2;

        glow.x = curText.x + (curText.width - glow.width) / 2;
        glow.y = curText.y + (curText.height - glow.height) / 2;
        glow.makeGraphic(curText.width + 25, curText.height, FlxColor.WHITE);

        arrow.x = curText.x + curText.width + 10;
        arrow.y = curText.y + (curText.height - arrow.height) / 2;

        if (credits[curSel].name == 'infry') {
            character.visible = true;
            everyoneButInfry.visible = false;
            character.x = rim.x + (rim.width - character.width) / 2 - 100;
            character.y = rim.y - character.height + rim.height / 2 + 35;
        } else {
            character.visible = false;
            everyoneButInfry.visible = true;
        }
    }
}