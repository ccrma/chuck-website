//----------------------------------------------------------------------------
// name: wekinator-outputs.ck
// desc: demonstrates receiving Wekinator outputs over OSC
//       * listens for OSC message "/wek/output"
//       * prints out each message typetag and numArgs as it arrives
//       * NOTE: msg.numArgs() is the number of output dimension
//       * NOTE: this code can be modified to control synthesis
//----------------------------------------------------------------------------

// create our OSC receiver
OscIn oin;
// create our OSC message
OscMsg msg;
// use port 12000 (default Wekinator output port)
12000 => oin.port;

// create an address in the receiver, expect an int and a float
oin.addAddress( "/wek/outputs" );
// print
cherr <= "listening for \"/wek/outputs\" messages on port " <= oin.port()
      <= "..." <= IO.newline();

// infinite event loop
while( true )
{
    // wait for event to arrive
    oin => now;
    
    // grab the next message from the queue. 
    while( oin.recv(msg) )
    {         
        // print stuff
        cherr <= "received OSC message: \"" <= msg.address <= "\" "
              <= "typetag: \"" <= msg.typetag <= "\" "
              <= "arguments: " <= msg.numArgs() <= IO.newline();
        
        // iterate over
        for( int i; i < msg.numArgs(); i++ )
        {
            if( msg.typetag.charAt(i) == 'f' ) // float
            {
                cherr <= msg.getFloat(i) <= " ";
            }
            else if( msg.typetag.charAt(i) == 'i' ) // int
            {
                cherr <= msg.getInt(i) <= " ";
            }
            else if( msg.typetag.charAt(i) == 's' ) // string
            {
                cherr <= msg.getString(i) <= " ";
            }            
        }        
        // done with line
        cherr <= IO.newline();
    }
}
