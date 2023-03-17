MidiOut mout;
// open a MIDI device for output
if( !mout.open(1) ) me.exit();

while(true)
{
    MidiMsg msg;
    
    0x90 => msg.data1;
    60 => msg.data2;
    127 => msg.data3;
    mout.send(msg);

    1::second => now;
    
    0x80 => msg.data1;
    60 => msg.data2;
    0 => msg.data3;
    mout.send(msg);
    
    1::second => now;
}
