import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.input.touch.FlxTouch;

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
        {name: 'grave', quote: 'this mod is a disease', role: 'director, artist', link: ''},
        {name: 'vamazotz', quote: 'i fucking love hank j wimbleton', role: 'co-director, artist', link: ''},
        {name: 'jads', quote: 'get a bunch of bikes, and ride em around with your friends', role: 'composer', link: ''},
        {name: 'cval', quote: 'well hello everyone', role: 'charter, composer', link: ''},
        {name: 'punkett', quote: 'made everything', role: 'composer', link: ''},
        {name: 'marstarbro', quote: "They just threw me in a group chat and 3 hours later, here's a pause theme", role: 'composer', link: ''}
    ];

    var displayedQuote:FlxText;
    var displayedRole:FlxText;

    var scrollLerp:Float = 0;
    var lastYTouch:Float = 0;

    override function create() {
        persistentUpdate = true;
        super.create();

        // Grupo de textos
        creditText = new FlxGroup();
        add(creditText);

        // Criar textos
        for (k => i in credits) {
            var text:FlxText = new FlxText(20, 0, FlxG.width - 40, i.name.toUpperCase() + " - " + i.role.toUpperCase() + "\n\"" + i.quote.toUpperCase() + "\"");
            text.size = 20;
            text.alignment = "center";
            text.color = FlxColor.RED;
            creditText.add(text);
        }

        // Texto destacado (opcional)
        displayedQuote = new FlxText(0, 0, FlxG.width, '', 24);
        displayedQuote.alignment = "center";
        add(displayedQuote);

        displayedRole = new FlxText(0, 0, FlxG.width, '', 18);
        displayedRole.alignment = "center";
        add(displayedRole);

        changeSel();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        // Scroll com teclado / mouse
        if (controls.UI_DOWN_P) changeSel(1);
        if (controls.UI_UP_P) changeSel(-1);

        if (controls.BACK) MusicBeatState.switchState(new MadnessMenu());

        // Scroll suave
        for (k => i in creditText.members) {
            var t:FlxText = cast i;
            var targetY:Float = (k - curSel) * 100 + (FlxG.height/2 - 50);
            t.y = FlxMath.lerp(t.y, targetY, 0.2 * 60 * elapsed);
        }

        // Scroll touch para mobile
        #if mobile
        for (i in 0...FlxG.touches._activeTouches.length) {
            var touch:FlxTouch = FlxG.touches._activeTouches[i];
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
        curSel = FlxMath.wrap(curSel + s, 0, credits.length - 1);

        var curText:FlxText = cast creditText.members[curSel];
        displayedQuote.text = '"' + credits[curSel].quote.toUpperCase() + '"';
        displayedRole.text = credits[curSel].role.toUpperCase();

        // Posicionar textos destacados
        displayedQuote.y = curText.y + curText.height + 10;
        displayedRole.y = displayedQuote.y + displayedQuote.height + 5;
    }

    function clamp(value:Float, min:Float, max:Float):Float {
        return value < min ? min : (value > max ? max : value);
    }
}