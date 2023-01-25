// name: fade.ck
// desc: UGen fader class (feel free to adapt)
// author: Graham Coleman
public class Fade
{
    fun void fade( UGen u, float start, float end, dur time, int div )
    {
        for (0=>int i; i<=div; i++)
        {
            (i $ float) / div => float p;
            start+(end-start)*p => u.gain;
            time/div => now;
        }
    }

    fun void fade20Hz( UGen u, float start, float end, dur time )
    { fade(u, start, end, time, (time / 50::ms) $ int); }

    fun void fadeIn( UGen u, float end, dur time )
    { fade20Hz(u, 0, end, time); }

    fun void fadeOutExit(UGen u, dur time, Shred s)
    {
        fade20Hz(u, u.gain(), 0, time);
        // give the signal time to fade
        5::second => now;
        // stop the shred
        s.exit();
    }

    fun void fadeOutAfter(UGen u, dur time, Shred s, dur wait)
    {
        wait => now; // wait the wait time
        fadeOutExit(u, time, s);
    }

    fun void fadeDefaults( UGen inst )
    {
        spork ~ fadeIn( inst, 0.4, 5::second );
        spork ~ fadeOutAfter( inst, 5::second, me, 1::minute);
    }
}
//end of class Fade
