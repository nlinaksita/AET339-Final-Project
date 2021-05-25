////SUPERCOLLIDER FINAL PROJECT////


//GENERAL PARAMETERS
/*

Create a piece (at least 1.5 minutes in length) of MUSIC or ABSTRACT SOUND DESIGN. It should include the following at a minimum:

(1) Two sound SynthDefs you have designed; you're free to use PlayBuf for recorded sounds for one of them if you would like.
(2) Two audio effect SynthDefs with stereo input; alternatively, output sound to a DAW and add effects (at least two; use a virtual audio cable like SoundFlower).
(3) A Dictionary which contains at least 4 “events” (patterns or one-shots [a one-shot could be an iterative Routine, for example]).
(4) Screen capture a performance of your full piece and setup. Use OBS or your capture software of choice. You can use SuperCollider to record your piece. Make sure that the final audio output is high-quality stereo.

*/
s.quit;
ServerOptions.inDevices;
ServerOptions.outDevices;

(
//1. Server config
s = Server.local;

s.options.inDevice_();
s.options.outDevice_();

s.options.sampleRate_(48000);

// Removes any preexisting functions (cleanup to start)
ServerBoot.removeAll;
ServerQuit.removeAll;
ServerTree.removeAll;


//2. Initialize global variables
~out = 0;
~path = PathName(thisProcess.nowExecutingPath).parentPath;

//3. Define functions for the piece (for loading buffers, events, MIDIdef, GUI, etc.)
Buffer.freeAll;
~makeBuffers = {
	~piano = Buffer.read(s, ~path ++ "sounds/mid_overtone_bf_mono.wav");
	~bass_strings = Buffer.read(s, ~path ++ "sounds/bass_strings_mono.wav");
	~pluck = Buffer.read(s, ~path ++ "sounds/mid_pluck_f_mono.wav");
	~strum = Buffer.read(s, ~path ++ "sounds/high_strum_mono.wav");
};

~makeBusses = {
	~reverbBus = Bus.audio(s,2);
	~delayBus = Bus.audio(s,2);
	// add other busses here below...
	// e.g. delay bus
};

~makeEvents = {
	e = Dictionary.new;
	//Events
	e.add(\event1 -> {
		Pbindef(\pianoPhase1,
			\instrument, \bufPlayerBpf,
			\buf, ~piano,
			\rate, Pseq([0,2,3,7,14,10].midiratio,inf),
			\dur, 0.25,
			\amp, Pseq([Pseg([0,0.3],10),Pexprand(0.3,0.4,inf)]),
			\spos, Pwhite((~piano.numFrames * 0.07), (~piano.numFrames * 0.2)),
			\pan, Pwhite(-1.0,-0.5,inf),
			\out, ~out,
			\group, ~synthGrp,
		).play(quant:8);

		Pbindef(\pianoPhase2,
			\instrument, \bufPlayerBpf,
			\buf, ~piano,
			\rate, Pseq([0,2,3,7,14,10].midiratio,inf),
			\dur, 0.249,
			\amp, Pseq([Pseg([0,0.3],10),Pexprand(0.3,0.4,inf)]),
			\spos, Pwhite((~piano.numFrames * 0.07), (~piano.numFrames * 0.2)),
			\pan, Pwhite(0.5,1.0,inf),
			\out, ~out,
			\group, ~synthGrp,
		).play(quant:8);

		"This is event 1 - Piano phase fade in".postln;
	});

	e.add(\event2 -> {
		Pbindef(\bufStrum,
			\instrument, \bufPlayerBpf,
			\buf, ~strum,
			\rate, Pwhite(0.08,0.15),
			//\scale, Scale.minor,
			//\degree, Prand((0..7),inf),
			\dur, Prand([4,8],inf),
			\amp, Pexprand(0.9,1.0,inf),
			//\spos, Prand([(~piano.numFrames * 0.001),(~piano.numFrames * 0.3)], inf),
			\pan, Pwhite(-1.0,1.0,inf),
			\freq, Pxrand((Scale.minorPentatonic.degrees+46).midicps,inf),
			\rqLoMax, 0.01,
			\rqLoMin, 0.0001,
			\rqHiMax, 0.3,
			\rqHiMin, 0.05,
			\out, ~reverbBus,
			\group, ~synthGrp,
		).play(quant:8);

		"This is event 2 - Add spooky strumming".postln;
	});

	e.add(\event3 -> {
		Pbindef(\bufStrings,
			\instrument, \bufPlayerBpf,
			\buf, ~bass_strings,
			\dur, Prand([2,3,4],inf),//Pexprand(1.0,8.0,inf),
			\amp, Pexprand(0.7,1.0,inf),
			\pan, Pwhite(-1.0,1.0,inf),
			\freq, Pxrand((Scale.minorPentatonic.degrees+70).midicps,inf),
			\rqLoMax, 0.005,
			\rqLoMin, 0.0001,
			\rqHiMax, 0.1,
			\rqHiMin, 0.008,
			\out, ~delayBus,
			\group, ~synthGrp,
		).play(quant:8);

		"This is event 3 - Add bass string hits".postln;
	});

	e.add(\event4 -> {
		Pbindef(\bufPluck,
			\instrument, \bufPlayerBpf,
			\buf, ~pluck,
			\rate, Prand([
				Prand([-19,-14,-12,-11,-9,-7,-5,-4,-2,0,3,7].midiratio * 4),
				Prand([-19,-14,-12,-11,-9,-7,-5,-4,-2,0,3,7].midiratio * 2),
			],inf),
			\dur, Pexprand(0.5,3.0),
			\amp, Pexprand(0.05,0.1,inf),
			\spos, Pwhite((~pluck.numFrames * 0.001), (~pluck.numFrames * 0.2)),
			\pan, Pwhite(-1.0,1.0,inf),
			\out, ~reverbBus,
			\group, ~synthGrp,
		).play(quant:8);

		"This is event 4 - Add string plucks".postln;
	});

	e.add(\event5 -> {
		Pbindef(\blipPad,
			\instrument, \blippy,
			\midinote, Pxrand([
				[34,46,49,51,53,56,60],
				[30,42,46,49,53,56],
				[27,39,42,46,49,53],
			], inf),
			\dur, 8,
			\atk, 1,
			\dec, 0.5,
			\susL, 0.5,
			\susT, 5,
			\rel, 6,
			\fatk, 4,
			\fdec, 3,
			\frel, 6,
			\fMinFreq, 100,
			\fMaxFreq, 2000,
			\nharm, 4,
			\out, ~out,
			\group, ~synthGrp,
		).play(quant:8);

		Pbindef(\blipPulse,
			\instrument, \blippy,
			\scale, Scale.minor,
			\degree, Pxrand([
				Pseq([0,3,4,8],16),
				Pseq([-3,1,2,4],16),
				Pseq([-4,-1,0,2],16),
			], inf),
			\root, -2,
			\octave, 5,
			\dur, 0.125,
			\atk, 0.01,
			\dec, 0.05,
			\susL, 0.5,
			\susT, 0.1,
			\rel, 0.1,
			\fatk, 0.05,
			\fdec, 0.05,
			\frel, 0.5,
			\fMinFreq, 100,
			\fMaxFreq, 500,
			\nharm, Pseg(levels:[3,10,3],durs:3,curves:'sin',repeats:inf),
			\out, ~reverbBus,
			\amp, Pseg(levels:[0.01,0.08,0.01],durs:4,curves:'sin',repeats:inf),
			\pan, Pseg(levels:[-0.75,0.75,-0.75],durs:6,curves:'lin',repeats:inf),
			\group, ~synthGrp,
		).play(quant:8);

		Pbindef(\bufPluck,
			\amp, Pexprand(0.1,0.3,inf),
		).play;

		"This is event 5 - Add pad and pulse, louder plucks".postln;
	});

	e.add(\event6 -> {
		{
			Pbindef(\blipPad,
				\midinote, [27,39,42,46,49,53],
			).play;
			8.wait;
			Pbindef(\blipPad).stop;
			Pbindef(\bufStrum).stop;
			Pbindef(\blipPulse).stop;
			Pbindef(\bufPluck,
				\dur, Pexprand(0.25,1.0),
				\amp, Pexprand(0.2,0.4,inf),
			).play;
		}.fork;

		"This is event 6 - Remove pad, pulse, and strumming, busier plucking".postln;
	});

	e.add(\event7 -> {
		Pbindef(\blipPad,
			\midinote, Pxrand([
				[34,46,49,51,53,56,60],
				[30,42,46,49,53,56],
				[27,39,42,46,49,53],
			], inf),
			\amp, 0.2,
			\fMaxFreq, 5000,
			\nharm, 30,
		).play;
		Pbindef(\bufStrum,
			\dur, Prand([1,2,4,8],inf),
		).play;
		Pbindef(\blipPulse,
			\octave, Pxrand([5,6],inf),
			\amp, Pseg(levels:[0.01,0.2,0.01],durs:4,curves:'sin',repeats:inf),
		).play;
		Pbindef(\bufPluck,
			\dur, Pexprand(0.5,3.0),
			\amp, Pexprand(0.2,0.4,inf),
		).play;

		"This is event 7 - Brighter pad, more active strumming and pulses".postln;
	});

	e.add(\event8 -> {
		{
			Pbindef(\blipPulse).stop;
			Pbindef(\blipPad,
				\amp, 0.1,
				\fMaxFreq, 4000,
				\nharm, 10,
			).play;
			Pbindef(\bufPluck,
				\amp, Pseg([0.2,0],6),
			).play;
			10.wait;
			Pbindef(\bufPluck).stop;
		}.fork;
		"This is event 8 - Remove pulses, less bright pad, fade out plucking".postln;
	});

	e.add(\event9 -> {
		{
			Pbindef(\blipPad,
				\midinote, [34,46,49,51,53,56,60],
				\fMaxFreq, 2000,
				\nharm, 4,
			).play;
			10.wait;
			Pbindef(\blipPad).stop;
			Pbindef(\bufStrum).stop;
		}.fork;

		"This is event 9 - Resolve pad chords and stop, fade out strumming".postln;
	});

	e.add(\event10 -> {
		{
			Pbindef(\pianoPhase1,
				\rate, 0.midiratio,
				\dur, 10,
			).play;
			Pbindef(\pianoPhase2,
				\rate, 0.midiratio,
				\dur, 10,
			).play;
			Pbindef(\bufStrings).stop;
			10.wait;
			Pbindef(\pianoPhase1).stop;
			Pbindef(\pianoPhase2).stop;
		}.fork;

		"This is event 10 (end) - Piano phases end on Bflat single note, stop bufStrings".postln;
	});
};

~cleanup = {
	s.newBusAllocators;
	ServerBoot.removeAll;
	ServerQuit.removeAll;
	ServerTree.removeAll;
};

~makeNodes = {
	~synthGrp = Group.new;
	~fxGrp = Group.after(~synthGrp);
	~reverbSynth = Synth.new(\reverb,
		[
			\mix, 1.0,
			\room, 0.5,
			\damp, 0.8,
			\in, ~reverbBus,
			\out, ~out
		],
		~fxGrp);
	~delaySynth = Synth.new(\delay,
		[
			\in, ~delayBus,
			\out, ~out,
		],
		~fxGrp);
};

//4. Register the functions with ServerBoot, ServerQuit, ServerTree
ServerBoot.add(~makeBuffers);
ServerBoot.add(~makeBusses);
ServerQuit.add(~cleanup);

//5. Boot the server and load remaining elements
s.waitForBoot({
	s.sync; // wait until everything is done load, then move on to next thing

	//Load up synth defs
	//SynthDefs
//======== Instrument Synthdefs ========
	SynthDef(\blippy,{
		arg freq=440, amp=0.1, atk=0.1, dec=0.1, susL=0.3, susT=0.5, rel=0.5, pan=0, out=0,
		fatk=0.05, fdec=0.05, frel=0.2, fMinFreq=100, fMaxFreq=18000, fSusFreq=10000, nharm=50;
		var sig, env, filterEnv;

		// Envelope
		env = EnvGen.kr(Env.new([0,1,susL,susL,0],[atk,dec,susT,rel], curve:(-3.0)),doneAction:2);

		// Filter envelope
		filterEnv = EnvGen.kr(Env.new([fMinFreq,fMaxFreq,fSusFreq,fMinFreq],[fatk,fdec,frel], curve:'exp'),doneAction:2);

		// Signal
		sig = Blip.ar(freq, nharm);
		sig = LPF.ar(sig,filterEnv);
		sig = Pan2.ar(sig,pan);
		sig = sig * env * amp;
		Out.ar(out, sig);
	}).add;


	// Buffer player with bandpass filter
	SynthDef.new(\bufPlayerBpf, {
		arg buf=0, rate=1, amp=1, spos=0, pan=0, freq=4000, rqLoMax=10, rqLoMin=10, rqHiMax=10, rqHiMin=10, out=0;
		var sig, rq, rqLo, rqHi;
		rqLo = Line.kr(rqLoMin, rqLoMax, 5);
		rqHi = Line.kr(rqHiMax, rqHiMin, 5);
		rq = {LFNoise1.kr(1).range(rqLo, rqHi)}!2;

		sig = PlayBuf.ar(
			numChannels: 1,
			bufnum: buf,
			rate: BufRateScale.kr(buf) * rate,
			startPos: spos,
			doneAction: 2
		);
		sig = BPF.ar(sig,freq,rq);
		sig = Pan2.ar(sig, pan);
		sig = sig * amp;
		Out.ar(out, sig);
	}).add;


	//======== Effects Synthdefs ========

	// Reverb
	SynthDef.new(\reverb, {
		arg in, mix=0.5, room=0.5, damp=0.2, out=0;
		var sig;
		sig = In.ar(in, 2);
		sig = FreeVerb.ar(sig, mix, room, damp);
		Out.ar(out,sig);
	}).add;

	// Delay and ring mod
	SynthDef.new(\delay, {
		arg in=0, out=0, decay=3, mix=(-0.5), amp=1, delHz=0.25, delMin=0.1, delMax=0.4;
		var sig, delay;
		sig = In.ar(in,2) * amp;
		delay = CombL.ar(
			sig,
			0.5,
			SinOsc.kr([delHz, delHz*0.9]).exprange(delMin,delMax)
		);
		sig = XFade2.ar(sig, delay, mix);
		Out.ar(out, sig);
	}).add;

	// ======== End of synthdefs ========

	s.sync; // ensures synthdefs are loaded first, wait, go on to next thing

	ServerTree.add(~makeNodes);
	ServerTree.add(~makeEvents);
	s.freeAll; //get rid of any junk on the server

	s.sync;

	"Loading Complete".postln;
});

) // ================================================================ COMPILE EVERYTHING AT THIS BRACKET

// Test events
e[\event1].value;
e[\event2].value;
e[\event3].value;
e[\event4].value;
e[\event5].value;
e[\event6].value;
e[\event7].value;
e[\event8].value;
e[\event9].value;
e[\event10].value;
(
Pbindef(\bufStrum).stop;
Pbindef(\pianoPhase1).stop;
Pbindef(\pianoPhase2).stop;
Pbindef(\bufStrings).stop;
Pbindef(\bufPluck).stop;
Pbindef(\blipPad).stop;
Pbindef(\blipPulse).stop;
)

s.makeGui; //hit record in the GUI to begin recording stereo output from SC

//======================================================

// Buffers
~piano = Buffer.read(s, ~path ++ "sounds/mid_overtone_bf_mono.wav");
~bass_strings = Buffer.read(s, ~path ++ "sounds/bass_strings_mono.wav");
~pluck = Buffer.read(s, ~path ++ "sounds/mid_pluck_f_mono.wav");
~strum = Buffer.read(s, ~path ++ "sounds/high_strum_mono.wav");

// Events
// Use Pbindef
e = Dictionary.new;
(
e.add(\event1 -> {
	Pbindef(\pianoPhase1,
		\instrument, \bufPlayerBpf,
		\buf, ~piano,
		\rate, Pseq([0,2,3,7,14,10].midiratio,inf),
		\dur, 0.25,
		\amp, Pseq([Pseg([0,0.3],10),Pexprand(0.3,0.4,inf)]),
		\spos, Pwhite((~piano.numFrames * 0.07), (~piano.numFrames * 0.2)),
		\pan, Pwhite(-1.0,-0.5,inf),
		\out, ~out,
		\group, ~synthGrp,
	).play(quant:8);

	Pbindef(\pianoPhase2,
		\instrument, \bufPlayerBpf,
		\buf, ~piano,
		\rate, Pseq([0,2,3,7,14,10].midiratio,inf),
		\dur, 0.249,
		\amp, Pseq([Pseg([0,0.3],10),Pexprand(0.3,0.4,inf)]),
		\spos, Pwhite((~piano.numFrames * 0.07), (~piano.numFrames * 0.2)),
		\pan, Pwhite(0.5,1.0,inf),
		\out, ~out,
		\group, ~synthGrp,
	).play(quant:8);

	"This is event 1 - Piano phase fade in".postln;
});

e.add(\event2 -> {
	Pbindef(\bufStrum,
		\instrument, \bufPlayerBpf,
		\buf, ~strum,
		\rate, Pwhite(0.08,0.15),
		//\scale, Scale.minor,
		//\degree, Prand((0..7),inf),
		\dur, Prand([4,8],inf),
		\amp, Pexprand(0.9,1.0,inf),
		//\spos, Prand([(~piano.numFrames * 0.001),(~piano.numFrames * 0.3)], inf),
		\pan, Pwhite(-1.0,1.0,inf),
		\freq, Pxrand((Scale.minorPentatonic.degrees+46).midicps,inf),
		\rqLoMax, 0.01,
		\rqLoMin, 0.0001,
		\rqHiMax, 0.3,
		\rqHiMin, 0.05,
		\out, ~reverbBus,
		\group, ~synthGrp,
	).play(quant:8);

	"This is event 2 - Add spooky strumming".postln;
});

e.add(\event3 -> {
	Pbindef(\bufStrings,
		\instrument, \bufPlayerBpf,
		\buf, ~bass_strings,
		\dur, Prand([2,3,4],inf),//Pexprand(1.0,8.0,inf),
		\amp, Pexprand(0.7,1.0,inf),
		\pan, Pwhite(-1.0,1.0,inf),
		\freq, Pxrand((Scale.minorPentatonic.degrees+70).midicps,inf),
		\rqLoMax, 0.005,
		\rqLoMin, 0.0001,
		\rqHiMax, 0.1,
		\rqHiMin, 0.008,
		\out, ~delayBus,
		\group, ~synthGrp,
	).play(quant:8);

	"This is event 3 - Add bass string hits".postln;
});

e.add(\event4 -> {
	Pbindef(\bufPluck,
		\instrument, \bufPlayerBpf,
		\buf, ~pluck,
		\rate, Prand([
			Prand([-19,-14,-12,-11,-9,-7,-5,-4,-2,0,3,7].midiratio * 4),
			Prand([-19,-14,-12,-11,-9,-7,-5,-4,-2,0,3,7].midiratio * 2),
		],inf),
		\dur, Pexprand(0.5,3.0),
		\amp, Pexprand(0.05,0.1,inf),
		\spos, Pwhite((~pluck.numFrames * 0.001), (~pluck.numFrames * 0.2)),
		\pan, Pwhite(-1.0,1.0,inf),
		\out, ~reverbBus,
		\group, ~synthGrp,
	).play(quant:8);

	"This is event 4 - Add string plucks".postln;
});

e.add(\event5 -> {
	Pbindef(\blipPad,
		\instrument, \blippy,
		\midinote, Pxrand([
			[34,46,49,51,53,56,60],
			[30,42,46,49,53,56],
			[27,39,42,46,49,53],
		], inf),
		\dur, 8,
		\atk, 1,
		\dec, 0.5,
		\susL, 0.5,
		\susT, 5,
		\rel, 6,
		\fatk, 4,
		\fdec, 3,
		\frel, 6,
		\fMinFreq, 100,
		\fMaxFreq, 2000,
		\nharm, 4,
		\out, ~out,
		\group, ~synthGrp,
	).play(quant:8);

	Pbindef(\blipPulse,
		\instrument, \blippy,
		\scale, Scale.minor,
		\degree, Pxrand([
			Pseq([0,3,4,8],16),
			Pseq([-3,1,2,4],16),
			Pseq([-4,-1,0,2],16),
		], inf),
		\root, -2,
		\octave, 5,
		\dur, 0.125,
		\atk, 0.01,
		\dec, 0.05,
		\susL, 0.5,
		\susT, 0.1,
		\rel, 0.1,
		\fatk, 0.05,
		\fdec, 0.05,
		\frel, 0.5,
		\fMinFreq, 100,
		\fMaxFreq, 500,
		\nharm, Pseg(levels:[3,10,3],durs:3,curves:'sin',repeats:inf),
		\out, ~reverbBus,
		\amp, Pseg(levels:[0.01,0.04,0.01],durs:4,curves:'sin',repeats:inf),
		\pan, Pseg(levels:[-0.75,0.75,-0.75],durs:6,curves:'lin',repeats:inf),
		\group, ~synthGrp,
	).play(quant:8);

	Pbindef(\bufPluck,
		\amp, Pexprand(0.1,0.3,inf),
	).play;

	"This is event 5 - Add pad and pulse, louder plucks".postln;
});

e.add(\event6 -> {
	{
		Pbindef(\blipPad,
			\midinote, [27,39,42,46,49,53],
		).play;
		8.wait;
		Pbindef(\blipPad).stop;
		Pbindef(\bufStrum).stop;
		Pbindef(\blipPulse).stop;
		Pbindef(\bufPluck,
			\dur, Pexprand(0.25,1.0),
			\amp, Pexprand(0.2,0.4,inf),
		).play;
	}.fork;

	"This is event 6 - Remove pad, pulse, and strumming, busier plucking".postln;
});

e.add(\event7 -> {
	Pbindef(\blipPad,
		\midinote, Pxrand([
			[34,46,49,51,53,56,60],
			[30,42,46,49,53,56],
			[27,39,42,46,49,53],
		], inf),
		\amp, 0.2,
		\fMaxFreq, 5000,
		\nharm, 30,
	).play;
	Pbindef(\bufStrum,
		\dur, Prand([1,2,4,8],inf),
	).play;
	Pbindef(\blipPulse,
		\octave, Pxrand([5,6],inf),
		\amp, Pseg(levels:[0.01,0.08,0.01],durs:4,curves:'sin',repeats:inf),
	).play;
	Pbindef(\bufPluck,
		\dur, Pexprand(0.5,3.0),
		\amp, Pexprand(0.2,0.4,inf),
	).play;

	"This is event 7 - Brighter pad, more active strumming and pulses".postln;
});

e.add(\event8 -> {
	{
		Pbindef(\blipPulse).stop;
		Pbindef(\blipPad,
			\amp, 0.1,
			\fMaxFreq, 4000,
			\nharm, 10,
		).play;
		Pbindef(\bufPluck,
			\amp, Pseg([0.2,0],6),
		).play;
		10.wait;
		Pbindef(\bufPluck).stop;
	}.fork;
	"This is event 8 - Remove pulses, less bright pad, fade out plucking".postln;
});

e.add(\event9 -> {
	{
		Pbindef(\blipPad,
			\midinote, [34,46,49,51,53,56,60],
			\fMaxFreq, 2000,
			\nharm, 4,
		).play;
		10.wait;
		Pbindef(\blipPad).stop;
		Pbindef(\bufStrum).stop;
	}.fork;

	"This is event 9 - Resolve pad chords and stop, fade out strumming".postln;
});

e.add(\event10 -> {
	{
		Pbindef(\pianoPhase1,
			\rate, 0.midiratio,
			\dur, 10,
		).play;
		Pbindef(\pianoPhase2,
			\rate, 0.midiratio,
			\dur, 10,
		).play;
		Pbindef(\bufStrings).stop;
		10.wait;
		Pbindef(\pianoPhase1).stop;
		Pbindef(\pianoPhase2).stop;
	}.fork;

	"This is event 10 (end) - Piano phases end on Bflat single note, stop bufStrings".postln;
});

)
// ================================================= EVENTS ==========================================
e[\event1].value;
e[\event2].value;
e[\event3].value;
e[\event4].value;
e[\event5].value;
e[\event6].value;
e[\event7].value;
e[\event8].value;
e[\event9].value;
e[\event10].value;
(
Pbindef(\bufStrum).stop;
Pbindef(\pianoPhase1).stop;
Pbindef(\pianoPhase2).stop;
Pbindef(\bufStrings).stop;
Pbindef(\bufPluck).stop;
Pbindef(\blipPad).stop;
Pbindef(\blipPulse).stop;
)

//====================================================== TESTING STUFF ==========================================
//======== Instrument Synthdefs ========
SynthDef.clear;
(
SynthDef(\blippy,{
	arg freq=440, amp=0.1, atk=0.1, dec=0.1, susL=0.3, susT=0.5, rel=0.5, pan=0, out=0,
	fatk=0.05, fdec=0.05, frel=0.2, fMinFreq=100, fMaxFreq=18000, fSusFreq=10000, nharm=50;
	var sig, env, filterEnv;

	// Envelope
	env = EnvGen.kr(Env.new([0,1,susL,susL,0],[atk,dec,susT,rel], curve:(-3.0)),doneAction:2);

	// Filter envelope
	filterEnv = EnvGen.kr(Env.new([fMinFreq,fMaxFreq,fSusFreq,fMinFreq],[fatk,fdec,frel], curve:'exp'),doneAction:2);

	// Signal
	sig = Blip.ar(freq, nharm);
	sig = LPF.ar(sig,filterEnv);
	sig = Pan2.ar(sig,pan);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;


// Buffer player with bandpass filter

SynthDef.new(\bufPlayerBpf, {
	arg buf=0, rate=1, amp=1, spos=0, pan=0, freq=4000, rqLoMax=10, rqLoMin=10, rqHiMax=10, rqHiMin=10, out=0;
	var sig, rq, rqLo, rqHi;
	rqLo = Line.kr(rqLoMin, rqLoMax, 5);
	rqHi = Line.kr(rqHiMax, rqHiMin, 5);
	rq = {LFNoise1.kr(1).range(rqLo, rqHi)}!2;

	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: buf,
		rate: BufRateScale.kr(buf) * rate,
		startPos: spos,
		doneAction: 2
	);
	sig = BPF.ar(sig,freq,rq);
	sig = Pan2.ar(sig, pan);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;


//======== Effects Synthdefs ========

// Reverb
SynthDef.new(\reverb, {
	arg in, mix=0.5, room=0.5, damp=0.2, out=0;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig, mix, room, damp);
	Out.ar(out,sig);
}).add;

// Delay and ring mod
SynthDef.new(\delay, {
	arg in=0, out=0, decay=3, mix=(-0.5), amp=1, delHz=0.25, delMin=0.1, delMax=0.4;
	var sig, delay;
	sig = In.ar(in,2) * amp;
	delay = CombL.ar(
		sig,
		0.5,
		SinOsc.kr([delHz, delHz*0.9]).exprange(delMin,delMax)
	);
	sig = XFade2.ar(sig, delay, mix);
	Out.ar(out, sig);
}).add;
)

//======================================================
// Pbindefs
Pbindef.removeAll;
// Blip pad
(
Pbindef(\blipPad,
	\instrument, \blippy,
	\midinote, Pxrand([
		[34,46,49,51,53,56,60],
		[30,42,46,49,53,56],
		[27,39,42,46,49,53],
	], inf),
	\dur, 8,
	\atk, 1,
	\dec, 0.5,
	\susL, 0.5,
	\susT, 5,
	\rel, 6,
	\fatk, 4,
	\fdec, 3,
	\frel, 6,
	\fMinFreq, 100,
	\fMaxFreq, 2000,
	\nharm, 4,
	\out, 0,
).play(quant:8);
)
Pbindef(\blipPad).stop;

// Pulsing blip
(
Pbindef(\blipPulse,
	\instrument, \blippy,
	\scale, Scale.minor,
	\degree, Pxrand([
		Pseq([0,3,4,8],16),
		Pseq([-3,1,2,4],16),
		Pseq([-4,-1,0,2],16),
	], inf),
	\root, -2,
	\octave, Pxrand([4,5],inf),
	\dur, 0.125,
	\atk, 0.01,
	\dec, 0.05,
	\susL, 0.5,
	\susT, 0.1,
	\rel, 0.1,
	\fatk, 0.05,
	\fdec, 0.05,
	\frel, 0.5,
	\fMinFreq, 100,
	\fMaxFreq, 500,
	\nharm, Pseg(levels:[3,10,3],durs:3,curves:'sin',repeats:inf),
	\out, ~reverbBus,
	\amp, Pseg(levels:[0.01,0.04,0.01],durs:4,curves:'sin',repeats:inf),//Pwhite(0.05,0.1),
	\pan, Pseg(levels:[-0.75,0.75,-0.75],durs:6,curves:'lin',repeats:inf),
).play(quant:8);
)
Pbindef(\blipPulse).stop;

// Plucked strings
(
Pbindef(\bufPluck,
	\instrument, \bufPlayerBpf,
	\buf, ~pluck,
	\rate, Prand([
		/*
		Prand([-12,-7,-5,-4,-2,0,2,3,5,7,10,14].midiratio),
		Prand([-12,-7,-5,-4,-2,0,2,3,5,7,10,14].midiratio * 2),
		*/
		Prand([-19,-14,-12,-11,-9,-7,-5,-4,-2,0,3,7].midiratio * 4),
		Prand([-19,-14,-12,-11,-9,-7,-5,-4,-2,0,3,7].midiratio * 2),
	],inf),//([-12,-7,-5,-4,-2,0,2,3,5,7]+2).choose.midiratio * [1,2].choose,
	\dur, Pexprand(0.5,3.0),
	\amp, Pexprand(0.1,0.3,inf),
	\spos, Pwhite((~pluck.numFrames * 0.001), (~pluck.numFrames * 0.2)),
	//\spos, Prand([(~piano.numFrames * 0.001),(~piano.numFrames * 0.3)], inf),
	\pan, Pwhite(-1.0,1.0,inf),
	\out, ~reverbBus,
).play(quant:8);
)
Pbindef(\bufPluck).stop;

// Two pianos that phase
(
Pbindef(\pianoPhase1,
	\instrument, \bufPlayerBpf,
	\buf, ~piano,
	\rate, Pseq([0,2,3,7,14,10].midiratio,inf),/*
		Prand([0,2,3,7,14,10].midiratio),
		Prand([-12,-7,-5,-4,-2,0,2,3,5,7,10,14].midiratio * 2),
	],inf),//([-12,-7,-5,-4,-2,0,2,3,5,7]+2).choose.midiratio * [1,2].choose,
	*/
	\dur, 0.25,
	\amp, Pexprand(0.3,0.4,inf),
	\spos, Pwhite((~piano.numFrames * 0.07), (~piano.numFrames * 0.2)),
	//\spos, Prand([(~piano.numFrames * 0.001),(~piano.numFrames * 0.3)], inf),
	\pan, Pwhite(-1.0,-0.5,inf),
	\out, 0,

).play(quant:8);
)
Pbindef(\pianoPhase1).stop;

(
Pbindef(\pianoPhase2,
	\instrument, \bufPlayerBpf,
	\buf, ~piano,
	\rate, Pseq([0,2,3,7,14,10].midiratio,inf),/*
		Prand([0,2,3,7,14,10].midiratio),
		Prand([-12,-7,-5,-4,-2,0,2,3,5,7,10,14].midiratio * 2),
	],inf),//([-12,-7,-5,-4,-2,0,2,3,5,7]+2).choose.midiratio * [1,2].choose,
	*/
	\dur, 0.249,
	\amp, Pexprand(0.3,0.4,inf),
	\spos, Pwhite((~piano.numFrames * 0.07), (~piano.numFrames * 0.2)),
	//\spos, Prand([(~piano.numFrames * 0.001),(~piano.numFrames * 0.3)], inf),
	\pan, Pwhite(0.5,1.0,inf),
	\out, 0,
).play(quant:8);
)
Pbindef(\pianoPhase2).stop;

// Piano bass strings
(
Pbindef(\bufStrings,
	\instrument, \bufPlayerBpf,
	\buf, ~bass_strings,
	\dur, Prand([1,2,4],inf),//Pexprand(1.0,8.0,inf),
	\amp, Pexprand(0.7,1.0,inf),
	\pan, Pwhite(-1.0,1.0,inf),
	\freq, Pxrand((Scale.minorPentatonic.degrees+70).midicps,inf),
	\rqLoMax, 0.005,
	\rqLoMin, 0.0001,
	\rqHiMax, 0.1,
	\rqHiMin, 0.008,
	\out, ~delayBus,
).play(quant:8);
)
Pbindef(\bufStrings).stop;

// Piano high strum strings
(
Pbindef(\bufStrum,
	\instrument, \bufPlayerBpf,
	\buf, ~strum,
	\rate, Pwhite(0.08,0.15),
	//\scale, Scale.minor,
	//\degree, Prand((0..7),inf),
	\dur, Prand([4,8],inf),//Pexprand(1.0,8.0,inf),
	\amp, Pexprand(0.9,1.0,inf),
	//\spos, Prand([(~piano.numFrames * 0.001),(~piano.numFrames * 0.3)], inf),
	\pan, Pwhite(-1.0,1.0,inf),
	\freq, Pxrand((Scale.minorPentatonic.degrees+46).midicps,inf),
	\rqLoMax, 0.01,
	\rqLoMin, 0.0001,
	\rqHiMax, 0.3,
	\rqHiMin, 0.05,
	\out, ~reverbBus,
).play(quant:8);
)
Pbindef(\bufStrum).stop;

s.makeGui; //hit record in the GUI to begin recording stereo output from SC

