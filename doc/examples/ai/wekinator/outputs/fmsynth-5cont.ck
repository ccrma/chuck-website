//----------------------------------------------------------------------------
/*  5-parameter FM synth by Jeff Snyder
    wekinator mod by Rebecca Fiebrink (2009-2015)
    updated by Ge Wang (2023)
    
    USAGE: This example receives Wekinator "/wek/outputs/" messages
    over OSC and maps incoming parameters to musical parameters;
    This example is designed to run with a sender, which can be:
    1) the Wekinator application, OR
    2) another Chuck/ChAI program containing a Wekinator object
    
    This example expects to receive 5 continuous parameters in the
    range [0,1]; these parameters are mapped to musical parameters
    in map2sound().
	
    SOUND: this uses FM synthesis:
    * generates a sawtooth wave (carrier)
    * which is frequency-modulated by a sine wave (modulator)
    * which then gets put through a low-pass filter
    * and has an amplitude envelope

    This example is "always on" -- no note triggering with keyboard
    
    expected parameters for this class are:
    0 = midinote pitch of Sawtooth oscillator (carrier freq)
    1 = lowpass filter cutoff frequency
    2 = Master gain (carrier gain)
    3 = fm oscillator midinote pitch (modulator freq)
    4 = fm oscillator index (modulator index) */
//----------------------------------------------------------------------------

// create our OSC receiver
OscIn oscin;
// a thing to retrieve message contents
OscMsg msg;
// use port 12000 (default Wekinator output port)
12000 => oscin.port;

// listen for "/wek/output" message with 5 floats coming in
oscin.addAddress( "/wek/outputs, fffff" );
// print
<<< "listening for OSC message from Wekinator on port 12000...", "" >>>;
<<< " |- expecting \"/wek/outputs\" with 5 continuous parameters...", "" >>>; 

// synthesis patch
SinOsc fmosc => SawOsc s => LPF lpf => Envelope vol => dac;
// set to do FM synthesis
2 => s.sync;
// low pass filter param
2000 => lpf.freq;
// set envelope duration
5::ms => vol.duration;
// set carrier frequency
50 => Std.mtof => s.freq;

// expecting 5 output dimensions
5 => int NUM_PARAMS;
float myParams[NUM_PARAMS];

// envelopes for smoothing parameters
// (alternately, can use slewing interpolators; SEE:
// https://chuck.stanford.edu/doc/examples/vector/interpolate.ck)
Envelope envs[NUM_PARAMS];
for( 0 => int i; i < NUM_PARAMS; i++ )
{
    envs[i] => blackhole;
    .5 => envs[i].value;
    10::ms => envs[i].duration;
}

// set the latest parameters as targets
// NOTE: we rely on map2sound() to actually interpret these parameters musically
fun void setParams( float params[] )
{
    // make sure we have enough
    if( params.size() >= NUM_PARAMS )
    {		
        // adjust the synthesis accordingly
        0.0 => float x;
        for( 0 => int i; i < NUM_PARAMS; i++ )
        {
            // get value
            params[i] => x;
            // clamp it
            if( x < 0 ) 0 => x;
            if( x > 1 ) 1 => x;
            // set as target of envelope (for smoothing)
            x => envs[i].target;
            // remember
            x => myParams[i];
        }
    }
}

// function to map incoming parameters to musical parameters
fun void map2sound()
{
    // time loop
    while( true )
    {
        // FYI envs[i] are used for smoothing param values
        envs[0].value() * 100 + 20 => Std.mtof => s.freq;
        envs[1].value() * 10000 + 1 => lpf.freq;
        envs[2].value() * .5 => s.gain;
        envs[3].value() * 100 + 20 => Std.mtof => fmosc.freq;
        envs[4].value() * 400 => fmosc.gain;
        // time
        10::ms => now;
    }
}

// turn volume off!
fun void soundOff()
{
    vol.keyOff();
}

// turn volume on!
fun void soundOn()
{
    //<<< "SOUUUUUUUND">>>;
    vol.keyOn();
}	

fun void waitForEvent()
{
    // array to hold params
    float p[NUM_PARAMS];

    // infinite event loop
    while( true )
    {
        // wait for OSC message to arrive
        oscin => now;

        // grab the next message from the queue. 
        while( oscin.recv(msg) )
        {
            // print stuff
            cherr <= msg.address <= " ";
            
            // unpack our 5 floats into our array p
            for( int i; i < NUM_PARAMS; i++ )
            {
                // put into array
                msg.getFloat(i) => p[i];
                // print
                cherr <= p[i] <= " ";
            }
            
            // print
            cherr <= IO.newline();
            
            // set the parameters
            setParams( p );
        }
    }
}

// spork osc receiver loop
spork ~waitForEvent();
// spork mapping function
spork ~ map2sound();	
// turn on sound
soundOn();

// time loop to keep everything going
while( true ) 1::second => now;
