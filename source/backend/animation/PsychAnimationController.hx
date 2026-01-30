package backend.animation;

import flixel.animation.FlxAnimationController;
import flixel.FlxG;

class PsychAnimationController extends FlxAnimationController {

    // Usaremos uma variável própria para controlar se quer multiplicar pelo global speed
    public var useGlobalSpeed:Bool = true;

    public override function update(elapsed:Float):Void {
        if (_curAnim != null) {
            var speed:Float = timeScale;
            // Multiplica pelo FlxG.animationTimeScale apenas se nossa flag estiver ativa
            if (useGlobalSpeed) speed *= FlxG.animationTimeScale;
            _curAnim.update(elapsed * speed);
        }
        else if (_prerotated != null) {
            _prerotated.angle = _sprite.angle;
        }
    }
}