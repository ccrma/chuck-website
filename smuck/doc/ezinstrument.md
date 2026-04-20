# ezInstrument design

*(This page is a placeholder. More detailed tutorials to come!)*

---

`ezInstruments` are used with `ezScorePlayer`to render `ezScore` data. Create custom instruments by extending the base class `ezInstrument` and implement `noteOn` and `noteOff`. Optionally override `cc()` to handle MIDI control messages. 

Here are some examples showing various `ezInstrument` behaviors:

- [basic-instrument.ck](../examples/basic/basic-instrument.ck) - basic additive/subtractive (SinOsc, SawOsc, filters, ADSR)
- [samplerInstrument.ck](../examples/instruments/samplerInstrument.ck) - SndBuf repitching: sample playback with repitching
- [ezcc-basic.ck](../examples/basic/ezcc-basic.ck) — CC handling
- [ezFluidInst.ck](../examples/instruments/ezFluidInst.ck) - FluidSynth: SoundFont playback
- [ezMidiInst.ck](../examples/instruments/ezMidiInst.ck) - MIDI playback

More detailed tips and tutorials to come!

