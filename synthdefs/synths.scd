(
// -------------------------------------- Pads -------------------------------------- //

SynthDef(\player, {
	var buf = \buf.kr(0);
	var rate = \rate.kr(1);
	var start = (\startPos.kr(0) * BufFrames.kr(buf).asInteger);
	var sig = PlayBuf.ar(1, buf, rate: BufRateScale.kr(buf) * rate, startPos: start, loop: 1);

	sig = sig * Env.linen(\attackTime.kr(5), \sustainTime.kr(10), \releaseTime.kr(5), curve: [2, -2]).kr(Done.freeSelf);

	Out.ar(\out.kr(0), sig * 1.dbamp * \amp.kr(1));
}).add;

SynthDef(\pvAmb, {
	var sig, chain, localbuf, rate;
	rate = SinOsc.ar(0.01, Rand(-3pi/2, 3pi/2)).range(0, \maxRate.kr(0.1));
	localbuf = LocalBuf.new(~fftsize);
	chain = PV_PlayBuf(localbuf, \buf.kr(0), rate: rate, offset: \offset.kr(0), loop: 1);

	sig = IFFT(chain, ~win);

	sig = FreeVerb.ar(sig, 0.33, 0.9, 0.25);

	sig = sig * Env.linen(\attackTime.kr(5), \sustainTime.kr(10), \releaseTime.kr(5), curve: [2, -2]).kr(Done.freeSelf);

	sig = sig * 3.dbamp * \amp.kr(1);

	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\grainBuzz, {
	var maxRate = \maxRate.kr(60);
	var rate = Rand(15.0, maxRate) * LFNoise1.kr(ExpRand(0.1, 0.3)).exprange(0.9, 1.1);
	var sig = GrainBuf.ar(
		1,
		Impulse.kr(rate),
		rate.linlin(15 * 0.9, maxRate * 1.1, 0.1, 0.05),
		\buf.kr(0),
		LFNoise1.kr(SinOsc.kr(0.07).exprange(0.1, 0.2)).exprange(0.9, 1.5),
		pos: LFNoise0.ar(0.01).range(0.01, 0.99).varlag(10),
		envbufnum: \envBuf.kr(-1),
	);

	sig = sig * SinOsc.ar(SinOsc.kr(0.01, Rand(-3pi/2, 3pi/2)).exprange(0.01, 0.5), 3pi/2).range(0.25, 1).lincurve(0.5, 1, 0.5, 1, 5);

	sig = sig * Env.linen(\attackTime.kr(5), \sustainTime.kr(10), \releaseTime.kr(5), curve: [2, -2]).kr(Done.freeSelf);

	Out.ar(\out.kr(0), sig * 1.dbamp * \amp.kr(1));
}).add;

SynthDef(\grainTrigs, {
	var buf = \buf.kr(0);
	var sig = Mix.fill(8, {
		var pos = LFNoise1.ar(ExpRand(0.001, 0.01)).range(0.0, BufDur.kr(buf));
		var dur = ExpRand(0.001, 0.05);
		var rate = LFNoise1.ar(0.01).exprange(\minRate.kr(0.5), \maxRate.kr(20));
		var trig = Impulse.ar(rate);
		var snd = PanAz.ar(~nChans, TGrains.ar(1, trig, buf, Rand(1.0, 3), pos, dur), LFNoise0.ar(ExpRand(0.2, 0.9)), width: 2);
		snd = snd * SinOsc.ar(ExpRand(0.1, 0.2)).range(0, 1).lincurve(0, 1, 0, 1, Rand(0.0, 5));
		snd;
	});

	sig = sig * Env.linen(\attackTime.kr(5), \sustainTime.kr(10), \releaseTime.kr(5), curve: [2, -2]).kr(Done.freeSelf);

	Out.ar(\out.kr(0), sig * 3.dbamp * \amp.kr(1));
}).add;

// --------------------------------------  One-Shots -------------------------------------- //

SynthDef(\granStorm, {
	var dur = \duration.kr(20);
	var sig = Mix.fill(4, {
		var minRate = \minRate.kr(15);
		var maxRate = \maxRate.kr(50);
		var rateScaleMin = \rateScaleMin.kr(0.9);
		var rateScaleMax = \rateScaleMax.kr(1.1);
		var rate = Rand(minRate, maxRate) * LFNoise1.kr(\rateModFreq.kr(0.1)).range(rateScaleMin, rateScaleMax);
		var timeScale = Rand(dur * 0.9, dur);
		var snd = GrainBuf.ar(
			1,
			Impulse.kr(rate),
			rate.linexp(minRate * rateScaleMin, maxRate * rateScaleMax, 0.1, 0.01),
			\buf.kr(0),
			ExpRand(0.9, 1.5),
			pos: LFNoise1.kr(ExpRand(0.01, 0.05)).range(0.1, 0.9),
			envbufnum: \envBuf.kr(-1),
		);
		// snd = snd * SinOsc.ar(ExpRand(0.01, 0.1)).range(0.75, 1);
		snd = PanAz.ar(~nChans, snd, Rand(-1.0, 1.0), width: 1);
		snd = snd * EnvGen.ar(
			Env.new(times: [0.95, 0.05], curve: [Rand(16.0, 32), 2]),
			1,
			timeScale: timeScale,
			doneAction: Done.none
		);
		snd;
	});
	sig = HPF.ar(sig, 550);
	sig = sig * Env.perc(0.01, dur + 3, curve: [-8, 4]).kr(Done.freeSelf);
	// sig = sig + CombC.ar(PitchShift.ar(sig, 0.2, 2, 0.01, 0.0001) * Env.perc(dur - 0.01, 0.01, curve: 64).kr(Done.none), 0.2, ExpRand(0.1, 0.2), 3);
	Out.ar(\out.kr(0), sig * 3.dbamp * \amp.kr(1));
}).add;
)