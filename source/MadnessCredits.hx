package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;

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
        {name: 'vamazotz', quote: 'i fuckingf love hank j wimbleton', role: 'co-director, artist', link: 'https://x.com/vamazotz'},
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
        {name: 'mr krinkles', quote: 'thank u for making amdness combat', role: 'made madness combat', link: 'https://x.com/MRKrinkels'},
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

    // Touch
    var isDragging:Bool = false;
    var lastTouchY:Float = 0;

    override function create() {
        persistentUpdate = true;
        super.create();

        FlxG.camera.scroll.set(0, 0);

        glow = new FlxSprite('madnessmenu/credits/glows');
        glow.alpha = 0.7;
        add(glow);

        creditText = new FlxGroup();
        add(creditText);

        arrow = new FlxSprite('madnessmenu/credits/arrow');
        add(arrow);

        for (k in 0...credits.length) {
            var txt = new FlxText(20, 0, Std.int(FlxG.width), credits[k].name.toUpperCase(), 61);
            txt.font = Paths.font('impact.ttf');
            txt.color = FlxColor.RED;
            txt.y = (txt.height + 25) * k;
            creditText.add(txt);
        }

        rim = new FlxSprite(Paths.image('madnessmenu/credits/grey'));
        rim.scale.set(1.1, 1.1);
        rim.updateHitbox();
        add(rim);
        rim.scrollFactor.set();

        everyoneButInfry = new FlxSprite(Paths.image('madnessmenu/credits/creditChar'));
        everyoneButInfry.antialiasing = true;
        everyoneButInfry.scrollFactor.set();
        add(everyoneButInfry);

        character = new FlxSprite(Paths.image('madnessmenu/credits/infry'));
        character.animation.addByPrefix('infry','infry',24,false);
        character.scrollFactor.set();
        add(character);

        var spotlight = new FlxSprite(FlxG.width - rim.width - 25, Paths.image('madnessmenu/credits/light'));
        spotlight.scale.copyFrom(rim.scale);
        spotlight.updateHitbox();
        spotlight.scrollFactor.set();
        add(spotlight);

        rim.y = spotlight.y + spotlight.height + 10;
        rim.x = spotlight.x + (spotlight.width - rim.width) / 2;

        displayedRole = new FlxText(0, 0, FlxG.width - 25, '', 60);
        displayedRole.alignment = "right"; // CORRIGIDO
        displayedRole.font = Paths.font('BebasNeue-Regular.ttf');
        displayedRole.scale.y = 1.5;
        displayedRole.updateHitbox();
        displayedRole.scrollFactor.set();
        add(displayedRole);

        displayedQuote = new FlxText(0, 0, FlxG.width, '', 40);
        displayedQuote.font = Paths.font('impact.ttf');
        displayedQuote.color = FlxColor.RED;
        displayedQuote.scrollFactor.set();
        displayedQuote.y = rim.y + rim.height;
        add(displayedQuote);

        changeSel();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        // Scroll com teclado
        if (FlxG.keys.pressed.UP) changeSel(-1);
        if (FlxG.keys.pressed.DOWN) changeSel(1);

        // Scroll com mouse wheel
        if (FlxG.mouse.wheel != 0) {
            changeSel(-FlxG.mouse.wheel);
        }

        // Scroll touch
        #if mobile
        if (FlxG.touches.getNumActive() > 0) {
            var t = FlxG.touches.getTouch(0);
            if (!isDragging) {
                isDragging = true;
                lastTouchY = t.screenY;
            } else {
                var delta = lastTouchY - t.screenY;
                scrollLerp += delta;
                lastTouchY = t.screenY;
            }
        } else isDragging = false;
        #end

        if (FlxG.keys.justPressed.ESCAPE || controls.BACK) MusicBeatState.switchState(new MadnessMenu());
        if (FlxG.mouse.justPressed) CoolUtil.browserLoad(credits[curSel].link);

        FlxG.camera.scroll.y = lerp(FlxG.camera.scroll.y, scrollLerp, 0.4 * 60 * elapsed);

        for (i in creditText.members) {
            if (i == null) continue;
            var pos = i == creditText.members[curSel] ? 150 : 20;
            i.x = lerp(i.x, pos, 0.4 * 60 * elapsed);
            var alpha = remap(Math.abs(creditText.members.indexOf(i) - curSel), 4, 0, 0, 1);
            i.alpha = lerp(i.alpha, alpha, 0.4 * 60 * elapsed);
        }
    }

    function changeSel(s:Int = 0) {
        if (s != 0) FlxG.sound.play(Paths.sound('madness/beep'));

        curSel = FlxMath.wrap(curSel + s, 0, credits.length - 1);

        var curText = creditText.members[curSel];

        displayedQuote.text = '"' + credits[curSel].quote.toUpperCase() + '"';
        displayedRole.text = credits[curSel].role.toUpperCase();
        scrollLerp = (curText.y + curText.height/2) - (FlxG.height/2);

        displayedQuote.x = rim.x + (rim.width - displayedQuote.width)/2;

        arrow.x = curText.x + curText.width + 10;
        arrow.y = curText.y + (curText.height - arrow.height)/2;

        glow.x = curText.x + (curText.width - glow.width)/2;
        glow.y = curText.y + (curText.height - glow.height)/2;
        glow.makeGraphic(Std.int(curText.width + 25), Std.int(curText.height), 0xFFFFFFFF);

        if (credits[curSel].name == 'infry') {
            character.visible = true;
            everyoneButInfry.visible = false;
            character.animation.play('infry', true);
            character.x = rim.x + (rim.width - character.width)/2 - 100;
            character.y = rim.y - character.height + rim.height/2 + 35;
        } else {
            character.visible = false;
            everyoneButInfry.visible = true;
        }
    }

    function lerp(a:Float, b:Float, t:Float):Float return a + (b-a)*t;
    function remap(value:Float, fromMax:Float, fromMin:Float, toMin:Float, toMax:Float):Float
        return ((value-fromMin)/(fromMax-fromMin))*(toMax-toMin)+toMin;
}