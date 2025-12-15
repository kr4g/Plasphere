(
SynthDef(\ampModMono, {
	var sig = In.ar(\in.kr(0), 1);
	var minAmp = \minAmp.kr(0);

	sig = sig * SinOsc.ar(SinOsc.kr(\innerRate.kr(0.01), Rand(-3pi/2, 3pi/2)).exprange(0.1, 0.15), Rand(-3pi/2, 3pi/2)).range(0.67, 1);
	sig = sig * SinOsc.ar(SinOsc.kr(\outerRate.kr(0.01), Rand(-3pi/2, 3pi/2)).exprange(0.05, 0.1), Rand(-3pi/2, 3pi/2)).range(minAmp, 1).lincurve(minAmp, 1, minAmp, 1, \curve.kr(0));

	Out.ar(\out.kr(0), sig * 3.dbamp * \amp.kr(1, \lag.kr(5)));
}).add;

SynthDef(\ampModStereo, {
	var sig = In.ar(\in.kr(0), ~nChans);
	var minAmp = \minAmp.kr(0);

	sig = sig * SinOsc.ar(SinOsc.kr(\innerRate.kr(0.01), Rand(-3pi/2, 3pi/2)).exprange(0.1, 0.15), Rand(-3pi/2, 3pi/2)).range(0.67, 1);
	sig = sig * SinOsc.ar(SinOsc.kr(\outerRate.kr(0.01), Rand(-3pi/2, 3pi/2)).exprange(0.05, 0.1), Rand(-3pi/2, 3pi/2)).range(minAmp, 1).lincurve(minAmp, 1, minAmp, 1, \curve.kr(0));

	Out.ar(\out.kr(0), sig * 0.dbamp * \amp.kr(1, \lag.kr(5)));
}).add;

SynthDef(\eqMorph, {
	var sig, hi, low;
	var dry = In.ar(\in.kr(0), 1);

	low = LPF.ar(dry, 350) * SinOsc.ar(ExpRand(0.05, 0.1), Rand(-3pi/2, 3pi/2)).range(0, 1);
	low = PanAz.ar(~nChans, low, LFNoise1.ar(ExpRand(0.05, 0.1)), width: 1);

	hi = HPF.ar(dry, 1500) * SinOsc.ar(ExpRand(0.05, 0.1), Rand(-3pi/2, 3pi/2)).range(0, 1);
	hi = PanAz.ar(~nChans, hi, LFNoise1.ar(ExpRand(0.05, 0.1)), width: 1);

	sig = Mix.fill(8, { |i|
		var snd = BPF.ar(dry, i.linexp(0, 7, 350, 1500), \rq.kr(0.4), \mul.kr(1));
		snd = snd * SinOsc.ar(ExpRand(0.05, 0.1), Rand(-3pi/2, 3pi/2)).range(0, 1);
		snd = PanAz.ar(~nChans, snd, LFNoise1.ar(ExpRand(0.05, 0.1)), width: 1);
		snd;
	});

	sig = low + sig + hi;

	sig = XFade2.ar(dry * -12.dbamp, sig, \wet.kr(1) * 2 - 1);

	sig = sig * \amp.kr(1);

	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\resoMorph, {
	var sig, low, hi, med;
	var dry = In.ar(\in.kr(0), 1);
	var lfoMod = SinOsc.kr(freq: \innerRate.kr(0.0005), phase: Rand(-3pi/2, 3pi/2)).exprange(\minLfoRate.kr(0.001), \maxLfoRate.kr(0.05));
	var dryWetLFO = SinOsc.kr(freq: lfoMod, phase: Rand(-3pi/2, 3pi/2)).range(0, \depth.kr(1)).lincurve(0, \depth.kr, 0, \depth.kr, \curve.kr(3));
	var minFreq = \minFreq.kr(50);
	var maxFreq = \maxFreq.kr(700);
	var rqMin = \rqMin.kr(0.01);
	var rqMax = \rqMax.kr(0.0001);
	var ratio = \ratio.kr(1) * LFNoise1.kr(0.01).range(0.9, 1.3);
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
		ps = DelayL.ar(ps, 1, Rand(0.5, 1));

		ps = PanAz.ar(~nChans, ps, LFNoise1.ar(SinOsc.kr(0.1, Rand(-3pi/2, 3pi/2)).exprange(0.1, 0.8)), width: 1);
		snd = PanAz.ar(~nChans, snd, LFNoise1.ar(SinOsc.kr(0.1, Rand(-3pi/2, 3pi/2)).exprange(0.1, 0.8)), width: 1);

		ps = ps * SinOsc.ar(SinOsc.kr(0.2, Rand(-3pi/2, 3pi/2)).exprange(0.25, 0.5)).range(0.5, 1);//.lincurve(0, 1, 0, 1, Rand(0.0, 2));
		snd = snd * SinOsc.ar(SinOsc.kr(0.1, Rand(-3pi/2, 3pi/2)).exprange(0.1, 0.25)).range(0.5, 1);//.lincurve(0, 1, 0, 1, Rand(0.0, 2));

		snd = snd + ps;
		snd;
	});

	sig = FreeVerb.ar(sig, \verbMix.kr(0.33), 0.9, 0.01, 3.dbamp);


	low = LPF.ar(dry, 250);// * SinOsc.ar(ExpRand(0.05, 0.1), Rand(-3pi/2, 3pi/2)).range(0.5, 1);
	low = PanAz.ar(~nChans, low, LFNoise1.ar(0.05), width: 1);

	med = LPF.ar(HPF.ar(dry, 250), 1100);
	med = PanAz.ar(~nChans, med, LFNoise1.ar(0.08), width: 1);

	hi = HPF.ar(dry, 1100);// * SinOsc.ar(ExpRand(0.05, 0.1), Rand(-3pi/2, 3pi/2)).range(0.15, 0.5);
	hi = PanAz.ar(~nChans, hi, LFNoise1.ar(0.13), width: 1);

	dry = low + med + hi;

	dry = LPF.ar(dry, dryWetLFO.pow(2).linexp(1, 0, 500, 20000));
	sig = HPF.ar(sig, dryWetLFO.pow(2).linexp(1, 0, 50, 1500));
	sig = XFade2.ar(dry, sig * 2.dbamp, dryWetLFO * 2 - 1);

	Out.ar(\out.kr(0), sig * \amp.kr(1, lag));
}).add;

SynthDef(\resoGrains, {
	var sig, low, hi, med;
	var dry = In.ar(\in.kr(0), 1);
	var lfoMod = SinOsc.kr(freq: \innerRate.kr(0.0005), phase: Rand(-3pi/2, 3pi/2)).exprange(\minLfoRate.kr(0.001), \maxLfoRate.kr(0.05));
	var dryWetLFO = SinOsc.kr(freq: lfoMod, phase: Rand(-3pi/2, 3pi/2)).range(0, \depth.kr(1)).lincurve(0, \depth.kr, 0, \depth.kr, \curve.kr(-3));
	var minFreq = \minFreq.kr(90);
	var maxFreq = \maxFreq.kr(1800);
	var ratio = \ratio.kr(1) * LFNoise1.kr(0.01).range(0.7, 1.1);
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
		snd = PanAz.ar(~nChans, snd, LFNoise1.ar(SinOsc.kr(0.06, Rand(-3pi/2, 3pi/2)).exprange(0.1, 0.9)), width: 1);
		snd = snd * SinOsc.ar(SinOsc.kr(0.05, Rand(-3pi/2, 3pi/2)).exprange(0.1, 0.3), 3pi/2).range(0, 1);
		snd;
	});

	// sig = LPF.ar(sig, 1500);

	low = LPF.ar(dry, 250);// * SinOsc.ar(ExpRand(0.05, 0.1), Rand(-3pi/2, 3pi/2)).range(0.5, 1);
	low = PanAz.ar(~nChans, low, LFNoise1.ar(0.05), width: 1);

	med = LPF.ar(HPF.ar(dry, 250), 1100);
	med = PanAz.ar(~nChans, med, LFNoise1.ar(0.08), width: 1);

	hi = HPF.ar(dry, 1100);// * SinOsc.ar(ExpRand(0.05, 0.1), Rand(-3pi/2, 3pi/2)).range(0.15, 0.5);
	hi = PanAz.ar(~nChans, hi, LFNoise1.ar(0.13), width: 1);

	dry = low + med + hi;

	dry = LPF.ar(dry, dryWetLFO.pow(2).linexp(1, 0, 500, 20000));
	sig = HPF.ar(sig, dryWetLFO.pow(2).linexp(1, 0, 50, 3500));
	sig = XFade2.ar(dry, sig * 3.dbamp, dryWetLFO * 2 - 1);

	Out.ar(\out.kr(0), sig * \amp.kr(1, lag));
}).add;

SynthDef(\specFx, {
	var low, hi, med;
	var lfoMod = SinOsc.kr(freq: \innerRate.kr(0.0005), phase: Rand(-3pi/2, 3pi/2)).exprange(\minLfoRate.kr(0.001), \maxLfoRate.kr(0.05));
	var dryWetLFO = SinOsc.kr(freq: lfoMod, phase: Rand(-3pi/2, 3pi/2)).range(0, \depth.kr(1));

	var fb, chain, shift, smear, smooth, scramble, comf, wipe, resyn, modL, modR, l, r, sig;
	var src = In.ar(\in.kr(0), 1);

	chain = FFT(LocalBuf(2048), src);

	shift = PV_BinShift(chain, LFNoise1.kr(0.1 * SinOsc.kr(0.03).exprange(0.5, 2)).exprange(0.25, 4), LFNoise1.kr(0.01 * SinOsc.kr(0.02).exprange(0.5, 2)).range(-32, 32), 1);
	scramble = PV_BinScramble(chain, LFNoise1.kr(0.2).range(0.1, 0.25), LFNoise1.kr(0.32).range(0.05, 0.1), Dust.kr(0.1));


	wipe = PV_BinWipe(shift, scramble, LFNoise1.kr(0.3));
	// wipe = PV_MagBelow(wipe, LFNoise1.kr(0.5).range(0.5, 1));
	// comf = PV_ConformalMap(wipe, LFNoise1.kr(0.2).range(-0.5,0.5), LFNoise1.kr(0.3).range(-0.5,0.5));

	chain = wipe;
	resyn = IFFT(chain);

	// l = resyn;
	// r = DelayL.ar(resyn, 0.3, LFNoise1.kr(0.03).range(0.01, 0.2));

	// l = PanAz.ar(~nChans, l, LFNoise1.kr(0.7));
	// r = PanAz.ar(~nChans, r, LFNoise1.kr(0.8));

	// sig = [l, r];

	low = LPF.ar(resyn, 250);// * SinOsc.ar(ExpRand(0.05, 0.1), Rand(-3pi/2, 3pi/2)).range(0, 0.7);
	low = PanAz.ar(~nChans, low, LFNoise1.ar(0.08), width: 1);

	hi = HPF.ar(resyn, 1100);// * SinOsc.ar(ExpRand(0.05, 0.1), Rand(-3pi/2, 3pi/2)).range(0, 0.25);
	hi = PanAz.ar(~nChans, hi, LFNoise1.ar(0.13), width: 1);

	med = LPF.ar(HPF.ar(resyn, 250), 1100);
	med = PanAz.ar(~nChans, med, LFNoise1.ar(0.21), width: 1);

	sig = low + med + hi;
	//
	// sig = XFade2.ar(sig, resyn * 2.dbamp, dryWetLFO * 2 - 1);

	Out.ar(\out.kr(0), sig * 0.dbamp * \amp.kr(1));
}).add;

SynthDef(\xFaderMono, {
	var in1, in2, chain1, chain2, resyn, sig;
	in1 = In.ar(\in1.kr(0), 1);
	in2 = In.ar(\in2.kr(0), 1);

	// chain1 = FFT(LocalBuf(2048), in1);
	// chain2 = FFT(LocalBuf(2048), in2);

	// resyn = PV_Morph(chain1, chain2, LFNoise1.kr(SinOsc.kr(\innerRate.kr(0.01)).exprange(\minRate.kr(0.05), \maxRate.kr(0.25)), mul: \depth.kr(1)).range(0, 1));
	// sig = IFFT(resyn);

	sig = XFade2.ar(in1, in2, LFNoise1.kr(SinOsc.kr(\innerRate.kr(0.01), Rand(-3pi/2, 3pi/2)).exprange(\minRate.kr(0.05), \maxRate.kr(0.25)), mul: \depth.kr(1)));

	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\xFaderStereo, {
	var in1, in2, sig;
	in1 = In.ar(\in1.kr(0), ~nChans);
	in2 = In.ar(\in2.kr(0), ~nChans);

	sig = XFade2.ar(in1, in2, LFNoise1.kr(SinOsc.kr(\innerRate.kr(0.01), Rand(-3pi/2, 3pi/2)).exprange(\minRate.kr(0.05), \maxRate.kr(0.25)), mul: \depth.kr(1)));

	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\verbStereo, {
	var sig = In.ar(\in.kr(0), ~nChans);
	// sig = FreeVerb.ar(sig, \mix.kr(0.33), \room.kr(0.5), \damp.kr(0.5));
	// sig = GVerb.ar(sig, roomsize: \roomsize.kr(250), revtime: \revtime.kr(5), damping: \damping.kr(0.5), drylevel: \drylevel.kr(0.5));
	Out.ar(\out.kr(0), sig * 0.dbamp);
}).add;
)