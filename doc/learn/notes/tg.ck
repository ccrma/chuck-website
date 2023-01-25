// name: tg.ck
// desc: TimeGrid class; basic timing operations abbreviated
// author: Graham Coleman
public class TimeGrid
{
    dur beat;
    dur meas;
    dur sect;

    int nbeat;
    int nmeas;

    // phase and magnitude of offset
    float measPhase;
    dur measOffset;

    fun void set(dur mybeat, int nb, int nm) {
        mybeat => beat;
        nb => nbeat;
        beat*nbeat => meas;
        nm => nmeas;
        meas*nmeas => sect;
    }

    // sync to beat
    fun void sync() {
        beat - (now % beat) => now;
    }

    fun void sync(dur T) {
        T - (now % T) => now;
    }

    // how long to sync to this duration
    fun dur syncDur(dur T) {
	return (T - (now % T));
    }

    // minimum time
    fun dur tmin(dur a, dur b) {
	return (a < b) ? a : b;
    }

    // get beat in relation to section
    fun int guess() {
        // this approach would not count sections
        // return ((now % sect) / beat) $ int;

        //this approach is completely global
        return (now / beat) $ int;
    }

    // get the mod rhythm
    fun int bmod(int r) {
        return (r%nbeat);
    }

    fun int mmod(int r) {
        return (r/nbeat%nmeas);
    }

    fun int smod(int r) {
        return (r/nbeat/nmeas);
    }

    // section markers
    int g;
    int b;
    int m;
    int s;
    int i;
    int j; // for anything, really

    int c; // counter in measure
    int d; // counter in section

    // events for stuff
    Event newMeas;
    Event newSect;
    
    // update markers
    fun int up() {
        guess() => g;

        // experimental
        if( b-bmod(g)>0 ) { // if b decreases
            0=>c;
            newMeas.broadcast(); 
        }
        else c++;
        
        // TODO: make a c but for the measure
        
        if( m-mmod(g)>0 ) { // if m decreases
            0 => d;
            newSect.broadcast();
        }
        else d++;
        
        bmod(g) => b;
        mmod(g) => m;
        smod(g) => s;
        i++;
        return true;
    }

    // update the markers of another timeGrid
    fun int up( TimeGrid tg )
    {
        this.up();

        b => tg.b;
        m => tg.m;
        s => tg.s;
        g => tg.g;
        c => tg.c;
        i => tg.i;
        j => tg.j;

        return true;
    }

    // pause: make shred wait until input low
    // ill-concieved, really!, because it can't monitor a changing input
    /*
    fun void pause( int a ) {
        while ( a ) {
            beat=>now;
            sync();
        }
    }
    */
}
