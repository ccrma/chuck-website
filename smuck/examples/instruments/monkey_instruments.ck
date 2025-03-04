// ------------------------------------------------------------------------------
// name: monkey_instruments.ck
// desc: a collection of instruments used for monkey.ck 
//
// author: kvbhat, alexhan
// date: Fall 2024
// ------------------------------------------------------------------------------
@import "smuck"

public class SawOscInst extends ezInstrument
{
    // define sound chain
    8 => int n_voices;
    setVoices(n_voices);

    SawOsc oscs[n_voices];
    ADSR envs[n_voices]; 
    Gain g => LPF lpf => outlet;
    8000 => lpf.freq;
    g.gain(.1);
    for(int i; i < n_voices; i++)
    {
        oscs[i] => envs[i] => g;
        envs[i].set(4::ms, 7000::ms, 0.0, 50::ms);
    }

    fun void noteOn(ezNote note, int voice)
    {
        Std.mtof(note.pitch()) => oscs[voice].freq;
        note.velocity() => oscs[voice].gain;
        envs[voice].keyOn();
    }

    fun void noteOff(int voice)
    {
        envs[voice].keyOff();
    }
}


public class TriOscInst extends ezInstrument
{
    // define sound chain
    8 => int n_voices;
    setVoices(n_voices);
    TriOsc oscs[n_voices];
    ADSR envs[n_voices]; 
    Gain g => outlet;
    g.gain(.2);
    for(int i; i < n_voices; i++)
    {
        oscs[i] => envs[i] => g;
        envs[i].set(4::ms, 7000::ms, 0.0, 50::ms);
    }

    fun void noteOn(ezNote note, int voice)
    {
        Std.mtof(note.pitch()) => oscs[voice].freq;
        note.velocity() => oscs[voice].gain;
        envs[voice].keyOn();
    }

    fun void noteOff(int voice)
    {
        envs[voice].keyOff();
    }
}


public class FrencHrnInst extends ezInstrument
{
    // define sound chain
    8 => int n_voices;
    setVoices(n_voices);
    FrencHrn hrn[n_voices]; 
    Gain g => NRev rev => outlet;
    g.gain(.2);
    rev.mix(.01);
    for(int i; i < n_voices; i++)
    {
        hrn[i] => g;
    }

    fun void noteOn(ezNote note, int voice)
    {
        Std.mtof(note.pitch()) => hrn[voice].freq;
        note.velocity() => hrn[voice].noteOn;
    }

    fun void noteOff(int voice)
    {
        hrn[voice].noteOff(0.5);
    }
}


public class DrumsInst extends ezInstrument
{
    // define sound chain
    6 => int n_voices;
    setVoices(n_voices);
    SndBuf bufs[n_voices];
    Gain g => outlet;
    g.gain(0.6);
    for(int i; i < n_voices; i++)
    {
        bufs[i] => g;
    }

    // mapping midi numbers to drum sounds
    54+12 => int HIHAT;    
    41+12 => int RIDE_BELL;
    39+12 => int RIDE_TIP;
    27+12 => int SNARE;
    46+12 => int CRASH_1_EDGE;
    48+12 => int KICK;


    fun void noteOn(ezNote note, int voice)
    {
        note.pitch() => int drum_sound;
        note.velocity() => float drum_volume;

        // identify which drum sound
        string wav_file_name;
        if (drum_sound == HIHAT)
        {
            "../data/audio/drum_wavs/hihat.wav" => wav_file_name;
        }
        else if (drum_sound == RIDE_BELL)
        {
            "../data/audio/drum_wavs/ride_bell.wav" => wav_file_name;
        }
        else if (drum_sound == RIDE_TIP)
        {
            "../data/audio/drum_wavs/ride_tip.wav" => wav_file_name;
        }
        else if (drum_sound == SNARE)
        {
            "../data/audio/drum_wavs/snare.wav" => wav_file_name;
        }
        else if (drum_sound == KICK)
        {
            "../data/audio/drum_wavs/kick.wav" => wav_file_name;
        }
        else if (drum_sound == CRASH_1_EDGE)
        {
            "../data/audio/drum_wavs/crash_1_edge.wav" => wav_file_name;
        }
        else
        {
            <<< "DrumsVoice.ck: error, received invalid midi number for drums:", drum_sound >>>;
            "../data/audio/drum_wavs/crash_1_edge.wav" => wav_file_name;
        }

        // play drum sound file
        bufs[voice].read(wav_file_name);
        drum_volume => bufs[voice].gain;
    }

    fun void noteOff(int voice)
    {
        // Unused
    }
}