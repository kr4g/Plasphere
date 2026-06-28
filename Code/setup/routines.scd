(
// WATER
~waterRoutine = Routine({
	2.do{ |i|
		fork{
			inf.do{
				var file = PathName(~paths[\buffers] ++ "Audio/Sources/water").files.choose.fileName;
				var playSynth, pvSynth, dur, buf;

				// ("[water] " ++ file).postln;

				buf = ~audioBufs[file];
				// f = ~specBufs[file.replace(".wav", "_spec.wav")];

				dur = rrand(buf.duration * ~durs["water"].min, buf.duration * ~durs["water"].max);

				playSynth = Synth(\player, [
					buf: buf,
					amp: ~amps["water"],
					attackTime: dur * 0.25,
					sustainTim: dur * 0.75,
					releaseTime: dur * 0.25,
					rate: rrand(0.9, 1),
					out: [~waterBus1, ~waterBus2][i]],
				s, \addToHead);

				if (rand(1.0) < 0.5) {
					pvSynth = Synth(\pvAmb, [
						buf: ~specBufs[file.replace(".wav", "_spec.wav")],
						amp: ~amps["water"] * rrand(0.05, 0.1),
						maxRate: rrand(0.05, 0.1),
						attackTime: dur * 0.5,
						sustainTim: dur * 0.25,
						releaseTime: dur * 0.5,
						out: ~waterPvBus],
					s, \addToHead);
				};

				(dur * 0.5).wait;
			};
		};
	};
});

// LAND
~landRoutine = Routine({
	inf.do{
		var duration = rrand(30.0, 60);
		var endTime, synths = Dictionary.new();

		// ~synths["waterFx"].set(\lag, duration * 0.3, \amp, -22.dbamp);

		endTime = Main.elapsedTime + duration;
		// ("Starting land layer for " ++ duration.round(0.1) ++ " seconds").postln;

		fork {
			while { Main.elapsedTime < endTime } {
				var file = PathName(~paths[\buffers] ++ "Audio/Sources/land").files.choose.fileName;

				var playSynth, granSynth, dur, buf;

				// ("[land] " ++ file).postln;
				// ("[land] " ++ file2).postln;

				buf = ~audioBufs[file];

				dur = rrand(buf.duration * ~durs["land"].min, buf.duration * ~durs["land"].max);

				playSynth = Synth(\player, [
					buf: buf,
					amp: ~amps["land"] * -3.dbamp,
					rate: rrand(0.8, 1),
					startPos: rrand(0.0, 0.5),
					attackTime: dur * 0.25,
					sustainTim: dur * 0.75,
					releaseTime: dur * 0.25,
					out: ~landPlayBus],
				s, \addToHead);

				fork{
					8.do{ |i|
						var gBuf = PathName(~paths[\buffers] ++ "Audio/Sources/land").files.choose.fileName;
						synths[i] = Synth(\grainTrigs, [
							buf: gBuf,
							amp: ~amps["land"] * 9.dbamp,
							minRate: rrand(0.5, 1),
							maxRate: rrand(20.0, 60),
							attackTime: rrand(dur * 0.1, dur * 0.25),
							sustainTim: dur * 0.75,
							releaseTime: dur * 0.25,
							out: ~landGranBus],
						s, \addToHead);
						rrand(0.5, 3).wait;
					};
				};

				(dur * 0.5).wait;
			};

			// End of routine - activate pvAmb
			fork {
				var file = PathName(~paths[\buffers] ++ "Audio/Sources/land").files.choose.fileName;
				var pvSynth, spec = ~specBufs[file.replace(".wav", "_spec.wav")];

				pvSynth = Synth(\pvAmb, [
					buf: spec,
					amp: ~amps["land"] * rrand(0.05, 0.15),
					maxRate: exprand(0.1, 0.2),
					offset: 0,
					attackTime: 10,
					sustainTime: 2,
					releaseTime: 10,
					out: ~landPvBus],
				s, \addToHead);

				10.wait;
			};
		};
		rrand(duration * 2, duration * 4).wait;
	};
});

// HUMANS
~humansRoutine = Routine({
	var layer = ["humans"].choose;
	var file = PathName(~paths[\buffers] ++ "Audio/Sources/" ++ layer).files.choose.fileName;
	var buf = ~audioBufs[file], spec = ~specBufs[file.replace(".wav", "_spec.wav")];
	var duration = buf.duration;
	var endTime;
	var playSynth, granSynth, pvSynth;
	// ~synths["waterFx"].set(\lag, duration * 0.3, \amp, -22.dbamp);

	endTime = Main.elapsedTime + duration;
	// ("Starting % layer for ".format(layer) ++ duration.round(0.1) ++ " seconds").postln;
	// ("[%] ".format(layer) ++ file).postln;

	playSynth = Synth(\player, [
		buf: buf,
		amp: ~amps[layer] * rrand(0.15, 0.5),
		rate: rrand(0.99, 1.01),
		startPos: rrand(0.0, 0.5),
		attackTime: duration * 0.25,
		sustainTime: duration * 0.5,
		releaseTime: duration * 0.25,
		out: ~humansPlayBus],
	s, \addToHead);

	(duration * 0.75).wait;

	if (rand(1.0) < 0.5) {
		pvSynth = Synth(\pvAmb, [
			buf: spec,
			amp: ~amps[layer] * rrand(0.1, 0.2),
			maxRate: exprand(0.1, 0.2),
			offset: 0,
			attackTime: 10,
			sustainTime: 2,
			releaseTime: 10,
			out: ~humansPvBus],
		s, \addToHead);
	};
});

// BOAT CAPTAIN
~boatCptRoutine = Routine({
	var file = PathName(~paths[\buffers] ++ "Audio/Sources/humans/-033.wav").fileName;
	var playSynth, pvSynth, dur, buf;

	buf = ~audioBufs[file];

	dur = rrand(buf.duration * 0.5, buf.duration);

	// ("Starting boat cpt layer for " ++ dur.round(0.1) ++ " seconds").postln;

	playSynth = Synth(\player, [
		buf: buf,
		amp: rrand(-25.dbamp, -19.dbamp),
		startPos: rrand(0.0, 0.5),
		attackTime: dur * 0.25,
		sustainTime: dur * 0.5,
		releaseTime: dur * 0.25,
		out: ~boatCptBus],
	s, \addToHead);
});

// MACHINES
~machinesRoutine = Routine({
	var layer = ["machines"].choose;
	var file = PathName(~paths[\buffers] ++ "Audio/Sources/" ++ layer).files.choose.fileName;
	var buf = ~audioBufs[file], spec = ~specBufs[file.replace(".wav", "_spec.wav")];
	var duration = buf.duration;
	var endTime;
	var playSynth, granSynth, pvSynth;
	// ~synths["waterFx"].set(\lag, duration * 0.3, \amp, -22.dbamp);

	endTime = Main.elapsedTime + duration;
	// ("Starting % layer for ".format(layer) ++ duration.round(0.1) ++ " seconds").postln;
	// ("[%] ".format(layer) ++ file).postln;

	if (rand(1.0) < 0.5) {
		playSynth = Synth(\player, [
			buf: buf,
			amp: ~amps[layer],
			rate: rrand(0.8, 1.1),
			startPos: rrand(0.0, 0.5),
			attackTime: duration * 0.25,
			sustainTime: duration * 0.5,
			releaseTime: duration * 0.25,
			out: ~machinesPlayBus],
		s, \addToHead);
	} {
		granSynth = Synth(\grainBuzz, [
			buf: buf,
			amp: ~amps[layer],
			attackTime: duration * 0.25,
			sustainTime: duration * 0.5,
			releaseTime: duration * 0.25,
			maxRate: rrand(20.0, 40),
			out: ~machinesPlayBus],
		s, \addToHead);
	};

	(duration * 0.75).wait;

	if (rand(1.0) < 0.25) {
		pvSynth = Synth(\pvAmb, [
			buf: spec,
			amp: ~amps[layer] * rrand(0.1, 0.25),
			maxRate: exprand(0.1, 0.2),
			offset: 0,
			attackTime: 10,
			sustainTime: 2,
			releaseTime: 10,
			out: ~machinesPvBus],
		s, \addToHead);
	};
});

// RANDOM GRAINS
~grainStreamsRoutine = Routine({
	12.do{
		var layer = ~layers.choose;
		var file = PathName(~paths[\buffers] ++ "Audio/Sources/" ++ layer).files.choose.fileName;
		var buf = ~audioBufs[file], spec = ~specBufs[file.replace(".wav", "_spec.wav")];
		Synth(\granStorm, [buf: buf, duration: rrand(10.0, 30), amp: rrand(-12, -1).dbamp, out: ~streamsBus]);
		rrand(0.5, 3).wait;
	};
});

// GRAIN MORPHS
~grainMorphsRoutine = Routine({
	8.do{ |i|
		var file1 = PathName(~paths[\buffers] ++ "Audio/Sources/" ++ ["humans", "machines"].choose).files.choose.fileName;
		var sndBuf1 = ~audioBufs[file1];
		var file2 = PathName(~paths[\buffers] ++ "Audio/Sources/" ++ ["water", "land"].choose).files.choose.fileName;
		var sndBuf2 = ~audioBufs[file2];

		var atk = rrand(5, 20);
		var rel = rrand(5, 20);
		var sus = rrand(atk + rel, atk + rel * 2);

		Synth(\grainMorpher, [
			buf1: sndBuf1,
			buf2: sndBuf2,
			attackTime: atk,
			sustatinTime: sus,
			releaseTime: rel,
			amp: rrand(-16, -1).dbamp,
			out: [~grainMorph1, ~grainMorph2][i % 2]
		]);
		// Synth(\grainBuzz, [
		// 	buf: sndBuf1,
		// 	attackTime: atk,
		// 	sustatinTime: sus,
		// 	releaseTime: rel,
		// 	out: ~grainMorph1
		// ]);
		//
		// Synth(\grainBuzz, [
		// 	buf: sndBuf2,
		// 	attackTime: atk,
		// 	sustatinTime: sus,
		// 	releaseTime: rel,
		// 	out: ~grainMorph2
		// ]);

		rrand(atk + rel, sus).wait;
	};
});
)