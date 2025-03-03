//-----------------------------------------------------------------------------
// name: ezscoreplayer.ck
// desc: this example shows off some of the features of the ezScorePlayer
//
// author: Kiran Bhat (https://ccrma.stanford.edu/~kvbhat/)
//-----------------------------------------------------------------------------
@import "smuck"

// Create instrument(s) for playback
class myInstrument extends ezInstrument
{
    // how many voices our instrument has (for polyphony)
    10 => n_voices;
    setVoices(n_voices);
    SinOsc oscs[n_voices];
    Gain g => outlet;                       // outlet lets us connect our instrument to any output we want for playback!
    g.gain(0.1);
    for (0 => int i; i < n_voices; i++)
    {
        oscs[i].gain(0);          // we want each osc to be silent before a note is played
        oscs[i] => g;
    }
    
    // what our instrument does when a note is played
    fun void noteOn(ezNote note, int voice)
    {
        Std.mtof(note.pitch) => oscs[voice].freq;
        note.velocity => oscs[voice].gain; // ezNote velocities are float values 0.0-1.0 !
    }

    // what our instrument does when a note is released
    fun void noteOff(ezNote note,int voice)
    {
        0 => oscs[voice].gain;
    }
}

// create simple score
ezPart part0("a b c d e f g a");
ezPart part1("c d e f g a b c");
ezScore score();
score.addPart(part0);
score.addPart(part1);

// create our instruments (1 for each part)
myInstrument bass => dac;
myInstrument treble => dac;

// play the score with our instruments
ezScorePlayer player(score);
player.setInstrument([bass, treble]);
true => player.loop;        // enable looping of the score
player.play();
5::second => now;

// dynamically adjust the rate of playback
repeat(20)
{
    player.rate + 0.2 => player.rate;
    200::ms => now;
}

// pause the player
player.pause();
3::second => now;

// reverse playback and resume
-2 => player.rate;
player.play();
10::second => now;

// stop the player
player.stop();
3::second => now;
