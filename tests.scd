(
var layer = "water";
var file = PathName("/Users/ryanmillett/Plasphere/Audio/Sources/" ++ layer).files.choose.fileName;
var sndBuf = ~audioBufs[file];
var specBuf = ~specBufs[file];

{
	var sig;
	var dry = PlayBuf.ar(1, sndBuf, loop: 1);
	// dry = Pan2.ar(dry, 0);
	var dryWetLFO = 1;//SinOsc.kr(SinOsc.kr(0.001, 3pi/2).exprange(0.002, 0.1), 3pi/2).range(0, 1);

	sig = Mix.fill(8, { |i|
		var snd = BPF.ar(dry, freq: i.linexp(0, 7, 250, 2500) * LFNoise1.ar(ExpRand(0.1, 0.2)).exprange(0.99, 1.01), rq: 0.01, mul: i.linlin(0, 7, 35, 12));
		snd = Pan2.ar(snd, LFNoise1.ar(SinOsc.kr(0.1, Rand(-3pi/2, 3pi/2)).exprange(0.3, 1.8)));
		snd = snd * SinOsc.ar(SinOsc.kr(0.1, Rand(-3pi/2, 3pi/2)).exprange(0.2, 0.6), 3pi/2).range(0, 1).lincurve(0, 1, 0, 1, Rand(1, 5));
		// snd = PitchShift.ar(snd, 0.2, LFNoise1.kr(ExpRand(0.5, 1.3)).exprange(0.9, 1.1), 0.001, 0.01);
		// snd = CombL.ar(snd, 0.2, Rand(0.15, 0.2), 1);
		snd = snd * SinOsc.ar(SinOsc.kr(ExpRand(0.1, 0.2), 3pi/2).exprange(3, 150)).range(0.25, 1);
		snd;
	});

	// sig = sig * SinOsc.ar(SinOsc.kr(ExpRand(0.1, 0.2), 3pi/2).exprange(3, 50)).range(0, 1);
	sig = FreeVerb.ar(sig, 0.12, 0.9, 0.01, 1.1);

	dry = LPF.ar(Pan2.ar(dry), dryWetLFO.linexp(0, 1, 20000, 100));

	sig = HPF.ar(sig, dryWetLFO.linexp(0, 1, 3500, 50));

	sig = XFade2.ar(dry, sig, dryWetLFO * 2 - 1);
	// sig = XFade2.ar(Pan2.ar(dry), sig, 1);

	sig;
}.play;
)

(
var layer = "land";
var file = PathName("/Users/ryanmillett/Plasphere/Audio/Sources/" ++ layer).files.choose.fileName;
var sndBuf = ~audioBufs[file];
var specBuf = ~specBufs[file];

{
	var sig = GrainBuf.ar(
		1,
		Impulse.kr(SinOsc.kr(0.01).exprange(15, 19)),
		LFNoise1.ar(SinOsc.kr(0.005, Rand(-3pi/2, 3pi/2)).exprange(0.01, 0.05)).range(0.05, 0.1),
		sndBuf,
		LFNoise1.kr(0.01).exprange(0.8, 1.2),
		pos: LFNoise1.ar(0.001).range(0.01, 0.99),
		envbufnum: \envBuf.kr(-1),
	);

	// sig = HPF.ar(sig, 750);

	sig = sig * SinOsc.ar(SinOsc.kr(0.01, 3pi/2).exprange(0.25, 2), 3pi/2).range(0.25, 1).lincurve(0.25, 1, 0.25, 1, 10);

	sig;
}.play;
)

// specFX
(
var layer = ["machines"].choose;
var file = PathName(~paths[\buffers] ++ "Audio/Sources/" ++ layer).files.choose.fileName;
var sndBuf = ~audioBufs[file];
"%, %".format(layer, file).postln;
{
	var src, fb, chain, shift, smear, smooth, filt, scramble, comf, wipe, resyn, modL, modR, l, r, sig;

	src = PlayBuf.ar(1, sndBuf, loop: 1);
	chain = FFT(LocalBuf(2048), src);

	shift = PV_BinShift(chain, LFNoise1.kr(0.1 * SinOsc.kr(0.03).exprange(0.5, 2)).exprange(0.25, 4), LFNoise1.kr(0.01 * SinOsc.kr(0.02).exprange(0.5, 2)).range(-32, 32), 1);
	scramble = PV_BinScramble(chain, LFNoise1.kr(0.2).range(0.1, 0.25), LFNoise1.kr(0.32).range(0.05, 0.1), Dust.kr(0.1));


	wipe = PV_BinWipe(shift, scramble, LFNoise1.kr(0.3));
	// wipe = PV_MagBelow(wipe, LFNoise1.kr(0.5).range(0.5, 1));
	// comf = PV_ConformalMap(wipe, LFNoise1.kr(0.2).range(-0.5,0.5), LFNoise1.kr(0.3).range(-0.5,0.5));

	chain = wipe;
	resyn = IFFT(chain);

	l = resyn;
	r = resyn;//DelayL.ar(resyn, 0.3, LFNoise1.kr(0.03).range(0.01, 0.2));

	sig = [l, r] * 0.6;

	sig;
}.play;
)

(
var layer = ~layers.choose;
var file = PathName(~paths[\buffers] ++ "Audio/Sources/" ++ layer).files.choose.fileName;
var sndBuf = ~audioBufs[file];
"%, %".format(layer, file).postln;
Synth(\grainBuzz, [buf: sndBuf, maxRate: rrand(10.0, 60), amp: -12.dbamp]);
)



(
var layer = "land";
var file = PathName(~paths[\buffers] ++ "Audio/Sources/" ++ layer).files.choose.fileName.postln;
var sndBuf = ~audioBufs[file];
// var specBuf = ~specBufs[file];

{
	var sig = Mix.fill(5, {
		var dur = \duration.kr(20);
		var minRate = \minRate.kr(15);
		var maxRate = \maxRate.kr(50);
		var rate = Rand(minRate, maxRate) * LFNoise1.kr(ExpRand(0.1, 0.3)).range(0.9, 1.1);
		var timeScale = Rand(dur * 0.5, dur);
		var snd = GrainBuf.ar(
			1,
			Impulse.kr(rate),
			rate.linlin(minRate * 0.9, maxRate * 1.1, 0.1, 0.01),
			sndBuf,
			Rand(0.9, 1.4),
			pos: Rand(0.1, 0.9),
			envbufnum: \envBuf.kr(-1),
		);
		snd = snd * SinOsc.ar(ExpRand(0.1, 0.5)).range(0.5, 1);
		snd = Pan2.ar(snd, SinOsc.ar(XLine.ar(0.1, 2, timeScale)));
		snd = snd * EnvGen.ar(
			Env.new(times: [0.5, 0.5], curve: [Rand(8.0, 16), Rand(-8.0, -4)]),
			1,
			timeScale: timeScale,
			doneAction: Done.none
		);
	});

	sig = sig * Env.perc(1, 20, curve: [-8, 8]).kr(Done.freeSelf);

	sig;
}.play;
)



(
// var layer = "water";
var file = PathName(~paths[\buffers] ++ "Audio/Sources/" ++ ["machines", "humans"].choose).files.choose.fileName.postln;
var sndBuf = ~audioBufs[file];
var file2 = PathName(~paths[\buffers] ++ "Audio/Sources/" ++ ["land", "water"].choose).files.choose.fileName.postln;
var sndBuf2 = ~audioBufs[file2];
var winenv;
// a custom envelope
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

{
	var chain1, chain2, chain, sig, fb;
	var sig1 = PlayBuf.ar(1, sndBuf, loop: 1);
	var sig2 = PlayBuf.ar(1, sndBuf2, loop: 1);

	chain1 = FFT(LocalBuf(2048*2), sig1);
	chain2 = FFT(LocalBuf(2048*2), sig2);

	// chain1 = PV_MagBelow(chain1, SinOsc.kr(0.05, 3pi/2).range(0.1, 0.9));
	// chain2 = PV_MagBelow(chain2, SinOsc.kr(0.05, 3pi/2).range(0.1, 0.9));

	// chain = PV_RandWipe(chain1, chain2, 0.5, Dust.kr(0.3));
	chain = PV_Morph(chain1, chain2, 0.5);
	// chain = PV_RandComb(chain, SinOsc.kr(0.1, 3pi/2).range(0, 1), Dust.kr(0.5));

	sig = IFFT(chain);

	// LocalOut.ar(sig);

	sig = Pan2.ar(sig);
	sig;
}.play;
)


(
var allFiles = ~layers.collect { |layer|
    PathName(~paths[\buffers] ++ "Audio/Sources/" ++ layer).files
}.flatten;
var selectedFiles = allFiles.scramble.keep(20.min(allFiles.size));
var sndBufs = selectedFiles.collect { |f|
    var buf = ~audioBufs[f.fileName];
    if(buf.notNil) {
        ("Using: " ++ f.fileName).postln;
    };
    buf;
}.select(_.notNil);

("Total files found: " ++ allFiles.size).postln;
("Using " ++ sndBufs.size ++ " buffers").postln;

{
    var sig = Mix.fill(sndBufs.size, { |i|
		// var rate = Rand(20, 50.0);
		var rate = LFNoise1.kr(ExpRand(0.01, 0.03)).exprange(10, 40.0);
        var trig = Impulse.ar(rate);
        var dur = rate.linlin(10, 40, 0.01, 0.001);
		// var posMod = SinOsc.kr(ExpRand(0.01, 0.02)).range(1, 5);
        var snd = GrainBuf.ar(1, trig, dur, sndBufs[i], rate: Rand(0.5, 2), pos: LFNoise1.ar(ExpRand(0.05, 0.5)).range(0, 1), envbufnum:-1, maxGrains: 64);
		// snd = PanAz.ar(~nChans, snd, TRand.ar(-1, 1, trig));
		snd = PanAz.ar(~nChans, snd, LFNoise1.ar(ExpRand(0.1, 0.7)));
        snd = snd * LFNoise1.ar(ExpRand(0.05, 0.1)).range(0, 1) * LFNoise1.ar(ExpRand(0.01, 0.03)).range(0.5, 1);
		snd;
    });

	// sig = sig * SinOsc.kr(ExpRand(0.01,0.05)).range(0, 1);
    sig * -18.dbamp;
}.play;
)




// ResoMorph
(
var layer = "water";
var file = PathName(~paths[\buffers] ++ "Audio/Sources/" ++ layer).files.choose.fileName.postln;
var sndBuf = ~audioBufs[file];

{
	var sig, low, hi, med;
	var dry = PlayBuf.ar(1, sndBuf, loop: 1);
	var lfoMod = SinOsc.kr(freq: \innerRate.kr(0.0005), phase: Rand(-3pi/2, 3pi/2)).exprange(\minLfoRate.kr(0.001), \maxLfoRate.kr(0.05));
	var dryWetLFO = SinOsc.kr(freq: lfoMod, phase: Rand(-3pi/2, 3pi/2)).range(0, \depth.kr(1));
	var minFreq = \minFreq.kr(50);
	var maxFreq = \maxFreq.kr(700);
	var rqMin = \rqMin.kr(0.01);
	var rqMax = \rqMax.kr(0.0001);
	var ratio = \ratio.kr(1);
	var lag = \lag.kr(5);
	var dryLPF = LPF.ar(dry, 2500);
	var nBands = 8;
	sig = Mix.fill(nBands, { |i|
		var src = PitchShift.ar((dryLPF * LFSaw.kr(ExpRand(0.1, 0.5)).exprange(1, Rand(8.0, 16))).tanh, 0.2, LFNoise1.kr(ExpRand(0.5, 1)).exprange(0.5, 1.5), 0.05, 0.05);
		// var src = (dryLPF * LFSaw.kr(ExpRand(0.1, 0.5)).exprange(1, Rand(8.0, 16))).tanh;

		var rqLFO = SinOsc.kr(ExpRand(0.1, 0.15), Rand(-3pi/2, 3pi/2)).range(0, 1);
		var rq = rqLFO.linexp(0, 1, rqMin, rqMax);
		var freq = i.linexp(0, nBands - 1, minFreq, maxFreq) * ratio;
		var mul = rq.linexp(rqMin, rqMax, 1, 4) * freq.explin(minFreq * ratio, maxFreq * ratio, 5, 0.25);
		// var mul = rq.linexp(rqMin, rqMax, 1, 2) * freq.explin(minFreq * ratio, maxFreq * ratio, 5, 0.1);

		var snd = BPF.ar(src, freq: freq, rq: rq, mul: mul);
		var ps = PitchShift.ar(snd, 0.2, LFNoise0.kr(ExpRand(0.1, 0.5)).exprange(0.5, 2), 0.01, 0.001, mul: 1);
		ps = DelayL.ar(ps, 1, ExpRand(0.5, 1));

		ps = PanAz.ar(~nChans, ps, LFNoise1.ar(SinOsc.kr(0.1, Rand(-3pi/2, 3pi/2)).exprange(0.3, 1.8)));
		snd = PanAz.ar(~nChans, snd, LFNoise1.ar(SinOsc.kr(0.1, Rand(-3pi/2, 3pi/2)).exprange(0.3, 1.8)));

		ps = ps * SinOsc.ar(SinOsc.kr(0.2, Rand(-3pi/2, 3pi/2)).exprange(0.25, 0.5)).range(0.25, 1);//.lincurve(0, 1, 0, 1, Rand(0.0, 2));
		snd = snd * SinOsc.ar(SinOsc.kr(0.1, Rand(-3pi/2, 3pi/2)).exprange(0.1, 0.25)).range(0.25, 1);//.lincurve(0, 1, 0, 1, Rand(0.0, 2));

		snd = snd + ps;
		snd;
	});

	// sig = PitchShift.ar(sig, 0.2, 0.667, 0.01, 0.001);

	sig = LPF.ar(sig, 1500);

	// sig = FreeVerb.ar(sig, \verbMix.kr(0.3, lag), 0.9, 0.01, 1.dbamp);


	low = LPF.ar(dry, 350) * SinOsc.ar(ExpRand(0.05, 0.1), Rand(-3pi/2, 3pi/2)).range(0, 0.7);
	low = PanAz.ar(~nChans, low, LFNoise1.ar(ExpRand(0.2, 0.5)));

	med = LPF.ar(HPF.ar(dry, 350), 5000);
	med = PanAz.ar(~nChans, med, LFNoise1.ar(ExpRand(0.2, 0.5)));

	hi = HPF.ar(dry, 5000) * SinOsc.ar(ExpRand(0.05, 0.1), Rand(-3pi/2, 3pi/2)).range(0, 0.25);
	hi = PanAz.ar(~nChans, hi, LFNoise1.ar(ExpRand(0.2, 0.5)));

	dry = low + med + hi;

	// dry = LPF.ar(dry, dryWetLFO.linexp(0, 1, 20000, 100));
	// sig = HPF.ar(sig, dryWetLFO.linexp(0, 1, 3500, 50));
	// sig = XFade2.ar(dry, sig * 0.dbamp, dryWetLFO * 2 - 1);

	sig * 6.dbamp;
}.play;
)

// ResoGrains
(
var layer = "water";
var file = PathName(~paths[\buffers] ++ "Audio/Sources/" ++ layer).files.choose.fileName.postln;
var sndBuf = ~audioBufs[file];

{
	var sig, low, hi, med;
	var dry = PlayBuf.ar(1, sndBuf, loop: 1);
	var lfoMod = SinOsc.kr(freq: \innerRate.kr(0.0005), phase: Rand(-3pi/2, 3pi/2)).exprange(\minLfoRate.kr(0.001), \maxLfoRate.kr(0.05));
	var dryWetLFO = SinOsc.kr(freq: lfoMod, phase: Rand(-3pi/2, 3pi/2)).range(0, \depth.kr(1));
	var minFreq = \minFreq.kr(90);
	var maxFreq = \maxFreq.kr(1800);
	var ratio = \ratio.kr(1);
	var minRate = \minRate.kr(5.0);
	var maxRate = \maxRate.kr(20.0);
	var lag = \lag.kr(5);
	var nBands = 16;
	// sig = (sig * 3).tanh;
	sig = Mix.fill(nBands, { |i|
		var freq = i.linexp(0, nBands - 1, minFreq, maxFreq) * ratio;
		var mul = freq.explin(minFreq * ratio, maxFreq * ratio, 4, 0.5);
		var snd = BPF.ar(dry, freq: freq, rq: 0.01, mul: mul);
		var rate = SinOsc.kr(ExpRand(0.05, 0.1)).exprange(minRate, maxRate);
		snd = GrainIn.ar(1, Impulse.ar(rate), rate.explin(minRate, maxRate, 0.03, 0.002), snd);
		// snd = DelayL.ar(snd, 3, Rand(0.5, 3));
		// snd = CombL.ar(snd, 0.5, Rand(0.1, 0.5), 1);
		snd = PanAz.ar(~nChans, snd, LFNoise1.ar(SinOsc.kr(0.06, Rand(-3pi/2, 3pi/2)).exprange(0.1, 0.9)));
		snd = snd * SinOsc.ar(SinOsc.kr(0.05, Rand(-3pi/2, 3pi/2)).exprange(0.1, 0.3), 3pi/2).range(0, 1);
		snd;
	});

	sig = LPF.ar(sig, 1500);

	// sig = FreeVerb.ar(sig, \verbMix.kr(0.3, lag), 0.7, 0.01, 1.dbamp);

	sig;
}.play;
)
