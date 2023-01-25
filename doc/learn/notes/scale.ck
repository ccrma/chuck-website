// name: scale.ck
// desc: collection of musical scales, code and data
// author: Graham Coleman
//
// updates by Ge Wang and Matt Wright (2021)
public class Scale
{
    // minor scales
    [0, 2, 3, 5, 7, 8, 10] @=> int min[]; // minor mode
    [0, 2, 3, 5, 7, 8, 11] @=> int har[]; // harmonic minor
    [0, 2, 3, 5, 7, 9, 11] @=> int asc[]; // ascending melodic minor
    [0, 1, 3, 5, 7, 8, 10] @=> int nea[]; // make 2nd degree neapolitain
    
    // other church modes
    [0, 2, 4, 5, 7, 9, 11] @=> int maj[]; // major scale
    [0, 2, 4, 5, 7, 8, 10] @=> int mixo[]; // church mixolydian
    [0, 2, 3, 5, 7, 9, 10] @=> int dor[]; // church dorian
    [0, 2, 4, 6, 7, 9, 11] @=> int lyd[]; // church lydian
    
    [0, 2, 4, 7, 9] @=> int pent[]; // major pentatonic
    [0, 2, 4, 6, 8, 10] @=> int whole_tone[]; // the whole tone scale
    [0, 2, 3, 5, 6, 8, 9, 11] @=> int dim[]; // diminished scale
    [0, 1, 4, 5, 7, 8, 10] @=> int hijaz[]; // phrygian dominant, resembles Arabic hijaz / Turkish humayun, scale of "Hava Negila"
    [0, 2, 3, 6, 7, 8, 11] @=> int hijazkar[]; // like hijaz but again the same hijaz intervals from the fifth.  Scale of "Misirlou"
    [0, 1, 4, 5, 7, 8, 11] @=> int hung_min[]; // "Hungarian minor": harmonic minor with sharp fourth; resembles Arabic Nawa Athar or Turkish Nev'eser
                                               // (prominent in Liszt's "Hungarian Rhapsody" No. 2)

    // new psuedo indian lydian mode
    [0, 2, 4, 6, 7, 9, 10] @=> int ind[];
    
    // convenience for minor keys
    fun int[] minor(int deg) {
        if (deg == 4) return asc; // ascending
        else return min;
    }
    
    fun int[] neap(int deg) {
        if (deg == 4) return asc;
        else if (deg == 1) return nea;
        else return min;
    }   
    
    // two-sided scale degrees
    fun int scale(int note, int sc[])
    {
        sc.cap() => int len;
        (note / len) => int oct;
        (note % len) => int off;
        while (off < 0) {
            len +=> off;
            1 -=> oct;
        }
        return oct * 12 + sc[off];
    }
    
    // do the octave and chrom and conversion stuff too
    fun float scaleFreq(int note, int sc[], int oct, int chrom) {
        return Std.mtof(oct*12+scale(note, sc)+chrom);
    }
    
    // simple arpeggiation
    fun int arp(int a) { 
        a/3 => int o;
        return (a%3)*2+7*o;
    } // simple arpeggiate
    
    fun int arp(int a, int osteps, int deg[]) {
        a/deg.cap() => int o;
        a => int i; // wrap negative, two sided
        while( i<0 ) osteps +=> i;
        return deg[i%deg.cap()] + osteps*o;
    } // generalized arp
    
    // bass-independant arpeggiation
    // preserve the general contour while staying in right scales
    
    // variables for avoiding doubling
    100 => int ARP_STEPS;
    int arp_used[ARP_STEPS];
    
    // reset the doubling tracking array
    fun void arp_reset() {
        for (0=>int i; i<ARP_STEPS; i++) 0 => arp_used[i];
    }
    
    // convenience versions of iarp
    fun int iarp(int a, int b, int osteps, int deg[]) {
        return iarp(a, b, osteps, deg, 0, 0); // no drag, doubles
    } // bass invariant arp
    
    fun int iarp(int a, int b, int deg[]) {
        // normal scales, no drag, doubles
        return iarp(a, b, 7, deg, 0, 0);
    }
    
    fun int iarp(int a, int b, int osteps, int deg[], float drag, int nd)
    {
        // n is the note in bass-deg-0
        arp(a, osteps, deg) => int n;
        
        // drag the target note by some factor of bass
        (drag * b) $ int +=> n;
        
        // avoid scanning too much, jump down octaves
        0 => int ojump;
        while( ojump + b + arp(0, osteps, deg) > n ) 
            osteps -=> ojump; // go down an octave
        
        // find the closest one in a shifted scale
        // shifted scale is b+deg[i...], or b+arp(i)
        // scale must start out lower to compensate
        0=>int cl;
        for (0=>int i; i<ARP_STEPS; i++)
        {
            ojump+b+arp(i, osteps, deg) => cl; // cantidate
            if ( nd && arp_used[i] ) continue; // skip doubles
            if ( cl >= n ) {
                1 => arp_used[i]; // mark used
                break; // found it
            }
        }
        
        return cl;
    } // bass invariant arp, with drag and nodouble
    
    // convenience versions of charp
    fun int charp(int a, int chrb, int deg[], int sc[]) {
        return charp(a, chrb, 7, deg, sc, 0, 0);
    }
    
    // chromatic bass-independent arpeggiation
    fun int charp( int a, int chrb, int osteps, int deg[], int sc[],
    float drag, int nd )
    {
        // render the note in chromatic bass 0 (C)
        // render it to a chromatic number
        arp(a, osteps, deg) => int n;
        // the scale will change, but maybe not a big deal
        scale(n, sc) => int nc;
        
        // drag, add it to the target
        (drag * chrb) $ int +=> nc;
        
        // to scan, make first cantidate less than the target
        0 => int ojump;
        while( ojump+chrb+scale( arp( 0, osteps, deg ), sc ) > nc )
            12 -=> ojump; // go down chromatic octave
        
        0=>int cl;
        for (0=>int i; i<ARP_STEPS; i++) {
            ojump+chrb+scale( arp(i, osteps, deg ), sc ) => cl; // cantidate
            
            // skip if already used
            if ( nd && arp_used[i] ) continue;
            
            if ( cl >= n ) { // found it
                1 => arp_used[i];
                break;
            }
        }
        
        return cl;
    }
    
    // the NEW WAY OF doing stuff
    // the abstraction, wrap an array
    // ([0,2,4],7) => [..., -7,-5,-3, 0,2,4, 7,9,11, ...]
    fun int wrap_array(int a, int ker[], int jump) {
        ker.cap() => int len;
        a/len => int j; // number of jumps
        a%len => int s; // steps within kernel
        
        if ( s<0 ) { // the negative border case
            s+len => s; // move s to positive range 
            j-1 => j; // one more negative jump
        }
        
        return ker[s]+j*jump; // kernel scale + jumps
    } // end of wrap_array
    
    // fun int scale(int note, int sc[])
    // { return wrap_array(note, sc, 12) }
    
    // fun int arp(int a, int osteps, int deg[])
    // swap inputs here, or change convention
    // { return wrap_array(a, deg, osteps) }
    
    // strategy: compute the arp shift for note-0 in bass b
    // then jump up the scale depending on what you need
    // arguments are ordered by importance
    fun int iarpB(int a, int b, int deg[], float drag, int osteps)
    {
        deg.cap() => int len;
        
        // initial jump down the scale, in arp-steps
        ((b/osteps)+1)*-len => int s0; // arp deg
        
        // find the first translated one geq to zero-bass scale[0]
        until ( b+wrap_array(s0,deg,osteps) >= deg[0] ) { s0++; } // inc until found
        
        // the real shift is the zero-shift for this bass plus how far up
        // drag is applied by reversing the direction of s0 by multiplying the float
        ((s0 * drag) $ int) + a => int s;
        
        // maybe should change meaning of drag
        
        // whether this calls arp or wrap_array is a style point
        return b+wrap_array(s,deg,osteps);
    }
    
    // a function that can also take in a chromatic melody
    // but c cannot be chromatic now, just scale degrees
    fun int iarpC(int c, int a, int b, int deg[], float drag, int osteps)
    {
        deg.cap() => int len;
        
        // initial jump down the scale, in arp-steps
        ((b/osteps)+1)*-len => int s0; // arp deg
        
        // find the match for the note
        until ( b+wrap_array(s0,deg,osteps) >= c ) { s0++; } // inc until found
        
        // drag is the amount of compensation in the direction of melody
        ((c * drag) $ int) + a => int s;
        
        return a==0 ? c : b+wrap_array(s, deg, osteps);
    }
    
    // convenience iarpC
    fun int iarpC(int c, int a, int b, int deg[], float drag) {
        return iarpC(c, a, b, deg, drag, 7);
    }
    
    fun int iarpC(int c, int a, int b, int deg[]) {
        return iarpC(c, a, b, deg, 1.0);
    }
    
    // convenience versions of iarpB
    fun int iarpB(int a, int b, int deg[], float drag) {
        return iarpB(a, b, deg, drag, 7);
    }
    
    fun int iarpB(int a, int b, int deg[]) {
        return iarpB(a, b, deg, 0, 7);
    }
    
    fun int iarpB(int a, int b) {
        return iarpB(a, b, [0,2,4], 0, 7);
    }
    
    fun int iarpB(int a) {
        return iarpB(a, 0, [0,2,4], 0, 7);
    }
    
    // globals, a hack
    static int gint;
    
} // end class
