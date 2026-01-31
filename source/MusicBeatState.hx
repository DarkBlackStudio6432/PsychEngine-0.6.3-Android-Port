package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;

import backend.Paths;
import backend.ClientPrefs;
import backend.Conductor;
import backend.Highscore;

#if mobile
import mobile.objects.MobilePad;
import mobile.backend.StorageUtil;
import mobile.backend.PsychJNI;
import mobile.controls.MobileControls as Controls; // mobile
#else
import backend.Controls; // desktop
#end

class MusicBeatState extends FlxState
{
    private var curSection:Int = 0;
    private var stepsToDo:Int = 0;
    private var curStep:Int = 0;
    private var curBeat:Int = 0;
    private var curDecStep:Float = 0;
    private var curDecBeat:Float = 0;

    private var controls(get, never):Controls;

    public static var camBeat:FlxCamera;

    #if TOUCH_CONTROLS
    public static var checkHitbox:Bool = false;
    public var mobilePad:MobilePad;
    public static var mobilec:MobileControls;

    var trackedinputsUI:Array<FlxActionInput> = [];
    var trackedinputsNOTES:Array<FlxActionInput> = [];
    #end

    public function new()
    {
        super();
        // Inicializa controls
        controls = Controls.getInstance(); 
    }

    inline function get_controls():Controls
        return controls;

    #if TOUCH_CONTROLS
    public function addMobilePad(?DPad:String, ?Action:String) {
        if (mobilePad != null) removeMobilePad();

        mobilePad = new MobilePad(DPad, Action);
        add(mobilePad);

        controls.setMobilePadUI(mobilePad, DPad, Action);
        trackedinputsUI = controls.trackedInputsUI;
        controls.trackedInputsUI = [];
        mobilePad.alpha = ClientPrefs.mobilePadAlpha;
    }

    public function removeMobilePad() {
        if (trackedinputsUI.length > 0) controls.removeVirtualControlsInput(trackedinputsUI);
        if (mobilePad != null) remove(mobilePad);
    }

    public function removeMobileControls() {
        if (trackedinputsNOTES.length > 0) controls.removeVirtualControlsInput(trackedinputsNOTES);
        if (mobilec != null) remove(mobilec);
    }

    public function addMobileControls(?customControllerValue:Int, ?mode:String, ?action:String) {
        mobilec = new MobileControls(customControllerValue, mode, action);

        switch (MobileControls.mode)
        {
            case MOBILEPAD_RIGHT | MOBILEPAD_LEFT | MOBILEPAD_CUSTOM:
                controls.setMobilePadNOTES(mobilec.vpad, "FULL", "NONE");
                MusicBeatState.checkHitbox = false;
            case DUO:
                controls.setMobilePadNOTES(mobilec.vpad, "DUO", "NONE");
                MusicBeatState.checkHitbox = false;
            case HITBOX:
                controls.setHitBox(mobilec.newhbox, mobilec.hbox);
                MusicBeatState.checkHitbox = true;
            default:
        }

        trackedinputsNOTES = controls.trackedInputsNOTES;
        controls.trackedInputsNOTES = [];

        var camcontrol = new FlxCamera();
        FlxG.cameras.add(camcontrol, false);
        camcontrol.bgColor.alpha = 0;
        mobilec.cameras = [camcontrol];

        add(mobilec);
    }

    public function addMobilePadCamera() {
        var camcontrol = new FlxCamera();
        camcontrol.bgColor.alpha = 0;
        FlxG.cameras.add(camcontrol, false);
        mobilePad.cameras = [camcontrol];
    }

    override function destroy() {
        if (trackedinputsNOTES.length > 0) controls.removeVirtualControlsInput(trackedinputsNOTES);
        if (trackedinputsUI.length > 0) controls.removeVirtualControlsInput(trackedinputsUI);

        super.destroy();

        if (mobilePad != null) mobilePad = FlxDestroyUtil.destroy(mobilePad);
        if (mobilec != null) mobilec = FlxDestroyUtil.destroy(mobilec);
    }
    #end

    override function create() {
        camBeat = FlxG.camera;
        super.create();
    }

    override function update(elapsed:Float) {
        var oldStep:Int = curStep;

        updateCurStep();
        updateBeat();

        if (oldStep != curStep) {
            if(curStep > 0) stepHit();

            if(PlayState.SONG != null) {
                if (oldStep < curStep) updateSection();
                else rollbackSection();
            }
        }

        super.update(elapsed);
    }

    private function updateSection():Void {
        if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
        while(curStep >= stepsToDo) {
            curSection++;
            stepsToDo += Math.round(getBeatsOnSection() * 4);
            sectionHit();
        }
    }

    private function rollbackSection():Void {
        if(curStep < 0) return;

        var lastSection:Int = curSection;
        curSection = 0;
        stepsToDo = 0;

        for (i in 0...PlayState.SONG.notes.length) {
            if (PlayState.SONG.notes[i] != null) {
                stepsToDo += Math.round(getBeatsOnSection() * 4);
                if(stepsToDo > curStep) break;
                curSection++;
            }
        }

        if(curSection > lastSection) sectionHit();
    }

    private function updateBeat():Void {
        curBeat = Math.floor(curStep / 4);
        curDecBeat = curDecStep / 4;
    }

    private function updateCurStep():Void {
        var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);
        var offseted = (Conductor.songPosition - ClientPrefs.noteOffset);
        var shit = (offseted - lastChange.songTime) / lastChange.stepCrochet;
        curDecStep = lastChange.stepTime + shit;
        curStep = lastChange.stepTime + Math.floor(shit);
    }

    public function stepHit():Void {
        if (curStep % 4 == 0) beatHit();
    }

    public function beatHit():Void {}

    public function sectionHit():Void {}

    function getBeatsOnSection():Float {
        var val:Float = 4;
        if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) 
            val = PlayState.SONG.notes[curSection].sectionBeats;
        return val;
    }
}