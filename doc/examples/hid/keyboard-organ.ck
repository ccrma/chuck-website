//-----------------------------------------------------------------------------
// name: keyboard-organ.ck
// desc: play your computer keyboard like an organ
//
// note: select between keyboards by specifying the device number;
//       to see a list of devices and their numbers, either...
//       1) view the Device Browser window in miniAudicle (select
//          "Human Interface Devices" in the drop-down menu)
//       OR 2) from the command line:
//          > chuck --probe
//
// author: Ge Wang (https://ccrma.stanford.edu/~ge/)
//-----------------------------------------------------------------------------

// HID input and HID message
Hid hi;
HidMsg msg;

// which keyboard
0 => int device;
// get from command line
if( me.args() ) me.arg(0) => Std.atoi => device;

// open keyboard (get device number from command line)
if( !hi.openKeyboard( device ) ) me.exit();
<<< "keyboard '" + hi.name() + "' ready", "" >>>;

// patch
BeeThree organ => JCRev r => Echo e => Echo e2 => dac;
r => dac;

// set delays
240::ms => e.max => e.delay;
480::ms => e2.max => e2.delay;
// set gains
.6 => e.gain;
.3 => e2.gain;
.05 => r.mix;
0 => organ.gain;

// infinite event loop
while( true )
{
    // wait for event
    hi => now;

    // get message
    while( hi.recv( msg ) )
    {
        // check
        if( msg.isButtonDown() )
        {
            Std.mtof( msg.which + 45 ) => float freq;
            if( freq > 20000 ) continue;

            freq => organ.freq;
            .5 => organ.gain;
            1 => organ.noteOn;

            80::ms => now;
        }
        else
        {
            0 => organ.noteOff;
        }
    }
}
