import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

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
    var lastYTouch:Float = 0;

    override function create() {
        persistentUpdate = true;
        super.create();

        FlxG.camera.scroll.set(0,0);

        glow = new FlxSprite('madnessmenu/credits/glows');
        glow.alpha = 0.7;
        glow.scrollFactor.set();
        add(glow);

        creditText = new FlxGroup();
        add(creditText);

        arrow = new FlxSprite('madnessmenu/credits/arrow');
        arrow.scrollFactor.set();
        add(arrow);

        for (k => i in credits) {
            var text = new FlxText(20, k * 100, 0, i.name.toUpperCase(), 61);
            text.font = Paths.font('impact.ttf');
            text.color = FlxColor.RED;
            creditText.add(text);
        }

        rim = new FlxSprite(Paths.image('madnessmenu/credits/grey'));
        rim.scale.set(1.1,1.1);
        rim.updateHitbox();
        rim.scrollFactor.set();
        add(rim);

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
        rim.x = spotlight.x + Std.int((spotlight.width - rim.width)/2);

        displayedRole = new FlxText(0,0,Std.int(FlxG.width - 25),'',60);
        displayedRole.alignment = "right";
        displayedRole.font = Paths.font('BebasNeue-Regular.ttf');
        displayedRole.scale.y = 1.5;
        displayedRole.scrollFactor.set();
        add(displayedRole);

        displayedQuote = new FlxText(0,0,0,'',40);
        displayedQuote.font = Paths.font('impact.ttf');
        displayedQuote.color = FlxColor.RED;
        displayedQuote.scrollFactor.set();
        displayedQuote.y = rim.y + rim.height;
        add(displayedQuote);

        changeSel();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        // Mobile touch scroll
        #if mobile
        if(FlxG.touches.activeTouches.length > 0) {
            var touch = FlxG.touches.activeTouches[0];
            if(touch.justPressed) lastYTouch = touch.y;
            var deltaY = touch.y - lastYTouch;
            scrollLerp -= deltaY;
            lastYTouch = touch.y;
            scrollLerp = clamp(scrollLerp, 0, (credits.length -1) * 100);
        }
        #end

        // Keyboard / Mouse
        if (FlxG.keys.pressed.UP || FlxG.keys.pressed.W) changeSel(-1);
        if (FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S) changeSel(1);
        if (FlxG.mouse.wheel != 0) changeSel(-FlxG.mouse.wheel);
        if (FlxG.keys.justPressed.ESCAPE) MusicBeatState.switchState(new MadnessMenu());

        FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, scrollLerp, 0.4 * 60 * elapsed);

        for (k => i in creditText.members) {
            if(i == null) continue;
            var posX = (k == curSel) ? 150 : 20;
            (cast i:FlxText).x = FlxMath.lerp((cast i:FlxText).x, posX, 0.4*60*elapsed);
            var alpha = Math.abs(remap(Math.abs(k-curSel),4,0,0,1));
            (cast i:FlxText).alpha = FlxMath.lerp((cast i:FlxText).alpha, alpha, 0.4*60*elapsed);
        }
    }

    function changeSel(s:Int = 0) {
        curSel = FlxMath.wrap(curSel + s,0,credits.length-1);

        var curText:FlxText = cast creditText.members[curSel];

        displayedQuote.text = '"' + credits[curSel].quote.toUpperCase() + '"';
        displayedRole.text = credits[curSel].role.toUpperCase();

        scrollLerp = (curText.y + curText.height/2) - FlxG.height/2;

        arrow.x = curText.x + curText.width + 10;
        arrow.y = curText.y + (curText.height - arrow.height)/2;

        glow.x = curText.x + (curText.width - glow.width)/2;
        glow.y = curText.y + (curText.height - glow.height)/2;
        glow.makeGraphic(Std.int(curText.width + 25), Std.int(curText.height), 0xFFFFFFFF);

        if(credits[curSel].name == "infry") {
            character.visible = true;
            everyoneButInfry.visible = false;
            character.animation.play("infry",true);
            character.x = rim.x + Std.int((rim.width - character.width)/2) - 100;
            character.y = rim.y - character.height + Std.int(rim.height/2) + 35;
        } else {
            character.visible = false;
            everyoneButInfry.visible = true;
        }
    }

    function clamp(value:Float, min:Float, max:Float):Float {
        return Math.max(min, Math.min(max, value));
    }

    function remap(value:Float, from1:Float, to1:Float, from2:Float, to2:Float):Float {
        return from2 + (value - from1) * (to2 - from2) / (to1 - from1);
    }
}