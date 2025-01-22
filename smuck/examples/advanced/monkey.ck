

@import "smuck";
@import "../instruments/monkey_instruments.ck"

// create score and import MIDI
ezScore score;
score.setTempo(166);
score.setTimeSig(4, 4);
score.importMIDI("../data/midi/monkey.mid");

// create score player
ezScorePlayer player(score);
5::ms => player.tick;              // lower playback resolution to prevent distortion (my computer can't handle default 1 ms resolution)

// create instruments
SawOscInst treble => Gain g1 => dac;
TriOscInst treble2 => Gain g2 => dac;
FrencHrnInst accent => Gain g3 => dac;
SawOscInst bass => Gain g4 => dac;
ChoirInst choir => Gain g5 => dac;
DrumsInst drums => Gain g6 => dac;
0.5 => g1.gain;
0.5 => g2.gain;
0.5 => g3.gain;
0.5 => g4.gain;
0.8 => g5.gain;
0.5 => g6.gain;

// set instruments and play
player.setInstrument([treble, treble2, accent, bass, choir, drums]);
player.play();




// ----------------- Keyboard controls ----------------------

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// keyboard listener
fun void kb_listener()
{
    Hid kb;
    HidMsg kb_msg;

    // which keyboard
    0 => int device;
    // get from command line
    if( me.args() ) me.arg(0) => Std.atoi => device;

    // open keyboard (get device number from command line)
    if( !kb.openKeyboard( device ) ) me.exit();
    <<< "keyboard '" + kb.name() + "' ready", "" >>>;
    while( true )
    {
        // wait on event
        kb => now;

        // get one or more messages
        while( kb.recv( kb_msg ) )
        {
            // check for action type
            if( kb_msg.isButtonDown() )
            {
                // <<< "down:", kb_msg.which, "(code)", kb_msg.key, "(usb key)", kb_msg.ascii, "(ascii)" >>>;
                kb_set_playhead(kb_msg.which);
                kb_set_rate(kb_msg.which);
            }
            
            else
            {
                //<<< "up:", msg.which, "(code)", msg.key, "(usb key)", msg.ascii, "(ascii)" >>>;
            }
        }
    }
}
spork ~ kb_listener();


fun void kb_set_playhead(int which)
{
    if (which == 39)    // 0 (number row) key
    {
        <<<"0 pressed">>>;
        player.pos(180.0);
    }
}

fun void kb_set_rate(int which)
{
    if(which == 29)     // z key
    {
        .1 -=> player.rate;
        <<<"rate:", player.rate>>>;
    }
    if(which == 27)     // x key
    {
        .1 +=> player.rate;
        <<<"rate:", player.rate>>>;
    }  
}


while(true)
{
    1::second => now;
}
