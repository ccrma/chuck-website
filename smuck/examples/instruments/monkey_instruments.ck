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
    8 => n_voices;
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

    fun void noteOn(ezNote theNote, int which)
    {
        Std.mtof(theNote.pitch) => oscs[which].freq;
        (theNote.velocity / 127.0) => oscs[which].gain;
        envs[which].keyOn();
    }

    fun void noteOff(int which)
    {
        envs[which].keyOff();
    }
}


public class TriOscInst extends ezInstrument
{
    // define sound chain
    8 => n_voices;
    TriOsc oscs[n_voices];
    ADSR envs[n_voices]; 
    Gain g => outlet;
    g.gain(.2);
    for(int i; i < n_voices; i++)
    {
        oscs[i] => envs[i] => g;
        envs[i].set(4::ms, 7000::ms, 0.0, 50::ms);
    }

    fun void noteOn(ezNote theNote, int which)
    {
        Std.mtof(theNote.pitch) => oscs[which].freq;
        (theNote.velocity / 127.0) / 2 => oscs[which].gain;
        envs[which].keyOn();
    }

    fun void noteOff(int which)
    {
        envs[which].keyOff();
    }
}


public class FrencHrnInst extends ezInstrument
{
    // define sound chain
    8 => n_voices;
    FrencHrn hrn[n_voices]; 
    Gain g => NRev rev => outlet;
    g.gain(.2);
    rev.mix(.01);
    for(int i; i < n_voices; i++)
    {
        hrn[i] => g;
    }

    fun void noteOn(ezNote theNote, int which)
    {
        Std.mtof(theNote.pitch) => hrn[which].freq;
        (theNote.velocity / 127.0) => hrn[which].noteOn;
    }

    fun void noteOff(int which)
    {
        hrn[which].noteOff(0.5);
    }
}


public class DrumsInst extends ezInstrument
{
    // define sound chain
    6 => n_voices;
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


    fun void noteOn(ezNote theNote, int which)
    {
        theNote.pitch => int drum_sound;
        // theNote.velocity / 127.0 => float drum_volume;
        1 => float drum_volume;

        // identify which drum sound
        string wav_file_name;
        if (drum_sound == HIHAT)
        {
            "../data/samples/drum_wavs/hihat.wav" => wav_file_name;
        }
        else if (drum_sound == RIDE_BELL)
        {
            "../data/samples/drum_wavs/ride_bell.wav" => wav_file_name;
        }
        else if (drum_sound == RIDE_TIP)
        {
            "../data/samples/drum_wavs/ride_tip.wav" => wav_file_name;
        }
        else if (drum_sound == SNARE)
        {
            "../data/samples/drum_wavs/snare.wav" => wav_file_name;
        }
        else if (drum_sound == KICK)
        {
            "../data/samples/drum_wavs/kick.wav" => wav_file_name;
        }
        else if (drum_sound == CRASH_1_EDGE)
        {
            "../data/samples/drum_wavs/crash_1_edge.wav" => wav_file_name;
        }
        else
        {
            <<< "DrumsVoice.ck: error, received invalid midi number for drums:", drum_sound >>>;
            "../data/samples/drum_wavs/crash_1_edge.wav" => wav_file_name;
        }

        // play drum sound file
        bufs[which].read(wav_file_name);
        drum_volume => bufs[which].gain;
    }

    fun void noteOff(int which)
    {
        // 0 => bufs[which].gain;
    }
}


public class ChoirInst extends ezInstrument
{
    // define sound chain
    4 => n_voices;
    SndBuf bufs[n_voices];
    Gain g => outlet;
    g.gain(1);
    for(int i; i < n_voices; i++)
    {
        bufs[i] => g;
    }

    // mapping midi numbers to drum sounds
    55 => int G2;
    57 => int A2;
    58 => int Bb2;
    59 => int B2;

    62 => int D3;
    G2+12 => int G3;
    A2+12 => int A3;
    Bb2+12 => int Bb3;
    B2+12 => int B3;

    D3+12 => int D4;


    fun void noteOn(ezNote theNote, int which)
    {
        theNote.pitch => int pitch;
        // theNote.velocity / 127.0 => float choir_volume;
        1 => float choir_volume;

        // identify which drum sound
        string wav_file_name;
        if (pitch == G2)
        {
            "../data/samples/choir_wavs/G2.wav" => wav_file_name;
        }
        else if (pitch == A2)
        {
            "../data/samples/choir_wavs/A2.wav" => wav_file_name;
        }
        else if (pitch == Bb2)
        {
            "../data/samples/choir_wavs/Bb2.wav" => wav_file_name;
        }
        else if (pitch == B2)
        {
            "../data/samples/choir_wavs/B2.wav" => wav_file_name;
        }
        else if (pitch == D3)
        {
            "../data/samples/choir_wavs/D3.wav" => wav_file_name;
        }
        else if (pitch == G3)
        {
            "../data/samples/choir_wavs/G3.wav" => wav_file_name;
        }
        else if (pitch == A3)
        {
            "../data/samples/choir_wavs/A3.wav" => wav_file_name;
        }
        else if (pitch == Bb3)
        {
            "../data/samples/choir_wavs/Bb3.wav" => wav_file_name;
        }
        else if (pitch == B3)
        {
            "../data/samples/choir_wavs/B3.wav" => wav_file_name;
        }
        else if (pitch == D4)
        {
            "../data/samples/choir_wavs/D4.wav" => wav_file_name;
        }
        else
        {
            <<< "ChoirVoice.ck: error, received invalid midi number for choir:", pitch >>>;
            "../data/samples/choir_wavs/A2.wav" => wav_file_name;
        }

        // play drum sound file
        bufs[which].read(wav_file_name);
        choir_volume => bufs[which].gain;
    }

    fun void noteOff(int which)
    {
        // 0 => bufs[which].gain;
    }
}