(
// Water
~waterRoutine = Routine({
	2.do{ |i|
		fork{
			inf.do{
				var file = PathName(~paths[\buffers] ++ "Audio/Sources/water").files.choose.fileName;
				var playSynth, pvSynth, dur, buf;

				("[water] " ++ file).postln;

				buf = ~audioBufs[file];
				// f = ~specBufs[file.replace(".wav", "_spec.wav")];

				dur = rrand(buf.duration * ~durs["water"].min, buf.duration * ~durs["water"].max);

				playSynth = Synth(\player, [buf: buf, amp: ~amps["water"], releaseTime: dur * 0.5, out: [~waterBus1, ~waterBus2][i]], s, \addToHead);

				(dur * 0.75).wait;

				if (rand(1.0) < 0.5) {
					pvSynth = Synth(\pvAmb, [buf: ~specBufs[file.replace(".wav", "_spec.wav")], amp: ~amps["water"] * rrand(0.15, 0.5), maxRate: rrand(0.05, 0.1), releaseTime: 20, out: ~waterPvBus], s, \addToHead);
				};

				playSynth.release;

				if (pvSynth.isNil.not) {
					10.wait;
					pvSynth.release;
				};
			};
		};
	};
});

~boatCptRoutine = Routine({
	inf.do{
		var file = PathName(~paths[\buffers] ++ "Audio/Sources/humans/-033.wav").fileName;
		var playSynth, pvSynth, dur, buf;


		// ("[water] " ++ file).postln;

		buf = ~audioBufs[file];
		// f = ~specBufs[file.replace(".wav", "_spec.wav")];

		dur = rrand(buf.duration * 0.5, buf.duration);

		("Starting boat cpt layer for " ++ dur.round(0.1) ++ " seconds").postln;

		playSynth = Synth(\player, [buf: buf, amp: rrand(-25.dbamp, -19.dbamp), startPos: rrand(0.0, 0.5), releaseTime: dur * 0.25, out: ~boatCptBus], s, \addToHead);

		(dur * 0.75).wait;

		if (rand(1.0) < 0.25) {
			pvSynth = Synth(\pvAmb, [buf: ~specBufs[file.replace(".wav", "_spec.wav")], amp: rrand(-11.0, -6).dbamp, maxRate: rrand(0.05, 0.1), releaseTime: 20, out: ~waterPvBus], s, \addToHead);
		};

		playSynth.release;

		if (pvSynth.isNil.not) {
			10.wait;
			pvSynth.release;
		};
		rrand(60 * 3.0, 60 * 5.0).wait;
	};
});

// Land
~landRoutine = Routine({
	inf.do{
		var duration = rrand(30.0, 60);
		var endTime, synths = Dictionary.new();

		// ~synths["waterFx"].set(\lag, duration * 0.3, \amp, -22.dbamp);

		endTime = Main.elapsedTime + duration;
		("Starting land layer for " ++ duration.round(0.1) ++ " seconds").postln;

		fork {
			while { Main.elapsedTime < endTime } {
				var file = PathName(~paths[\buffers] ++ "Audio/Sources/land").files.choose.fileName;

				var playSynth, granSynth, dur, buf;

				("[land] " ++ file).postln;
				// ("[land] " ++ file2).postln;

				buf = ~audioBufs[file];

				dur = rrand(buf.duration * ~durs["land"].min, buf.duration * ~durs["land"].max);

				playSynth = Synth(\player, [buf: buf, amp: ~amps["land"], rate: rrand(0.9, 1.1), startPos: rrand(0.0, 0.5), releaseTime: dur * 0.5, out: ~landPlayBus], s, \addToHead);

				8.do{ |i|
					var gBuf = PathName(~paths[\buffers] ++ "Audio/Sources/land").files.choose.fileName;
					synths[i] = Synth(\grainTrigs, [buf: gBuf, amp: ~amps["land"] * 2.dbamp, minRate: rrand(0.5, 1), maxRate: rrand(20.0, 60), attackTime: rrand(dur * 0.1, dur * 0.25), releaseTime: dur * 0.5, out: ~landGranBus], s, \addToHead);
				};

				(dur * 0.5).wait;

				playSynth.release;
				8.do{ |i| synths[i].release; };
				// granSynth.release;
			};

			// End of routine - activate pvAmb
			("Ending land layer.").postln;
			fork {
				var file = PathName(~paths[\buffers] ++ "Audio/Sources/land").files.choose.fileName;
				var pvSynth, spec = ~specBufs[file.replace(".wav", "_spec.wav")];
				// file.replace(".wav", "_spec.wav").postln;

				// f = ~specBufs[file.replace(".wav", "_spec.wav")];
				pvSynth = Synth(\pvAmb, [buf: spec, amp: ~amps["land"] * rrand(0.15, 0.5), maxRate: exprand(0.1, 0.2), offset: 0, releaseTime: 20, out: ~landPvBus], s, \addToHead);

				// ~synths["waterFx"].set(\lag, 15, \amp, 0.dbamp);

				10.wait;
				pvSynth.release;
			};
		};
		duration.wait;
		rrand(duration * 2, duration * 4).wait;
	};
});

// Humans
~humansRoutine = Routine({

	inf.do{
		var layer = ["humans"].choose;
		var file = PathName(~paths[\buffers] ++ "Audio/Sources/" ++ layer).files.choose.fileName;
		var buf = ~audioBufs[file], spec = ~specBufs[file.replace(".wav", "_spec.wav")];
		var duration = buf.duration;
		var endTime;
		var playSynth, granSynth, pvSynth;
		// ~synths["waterFx"].set(\lag, duration * 0.3, \amp, -22.dbamp);

		endTime = Main.elapsedTime + duration;
		("Starting % layer for ".format(layer) ++ duration.round(0.1) ++ " seconds").postln;
		("[%] ".format(layer) ++ file).postln;

		playSynth = Synth(\player, [buf: buf, amp: ~amps[layer], rate: rrand(0.99, 1.01), startPos: rrand(0.0, 0.5), releaseTime: duration * 0.25, out: ~humansPlayBus], s, \addToHead);
		// granSynth = Synth(\grainBuzz, [buf: buf, amp: ~amps[layer] * -3.dbamp, maxRate: rrand(20.0, 60), releaseTime: duration * 0.25, out: ~humansGranBus], s, \addToHead);

		(duration * 0.75).wait;

		("Ending % layer.".format(layer)).postln;
		pvSynth = Synth(\pvAmb, [buf: spec, amp: ~amps[layer] * rrand(0.15, 0.5), maxRate: exprand(0.1, 0.2), offset: 0, releaseTime: 20, out: ~humansPvBus], s, \addToHead);

		playSynth.release;
		// granSynth.release;

		// ~synths["waterFx"].set(\lag, duration * 0.25, \amp, 0.dbamp);

		10.wait;
		pvSynth.release;
		rrand(duration * 2, duration * 4).wait;
	};
});

// Machines
~machinesRoutine = Routine({

	inf.do{
		var layer = ["machines"].choose;
		var file = PathName(~paths[\buffers] ++ "Audio/Sources/" ++ layer).files.choose.fileName;
		var buf = ~audioBufs[file], spec = ~specBufs[file.replace(".wav", "_spec.wav")];
		var duration = buf.duration;
		var endTime;
		var playSynth, granSynth, pvSynth;
		// ~synths["waterFx"].set(\lag, duration * 0.3, \amp, -22.dbamp);

		endTime = Main.elapsedTime + duration;
		("Starting % layer for ".format(layer) ++ duration.round(0.1) ++ " seconds").postln;
		("[%] ".format(layer) ++ file).postln;

		playSynth = Synth(\player, [buf: buf, amp: ~amps[layer], rate: rrand(0.99, 1.01), startPos: rrand(0.0, 0.5), releaseTime: duration * 0.25, out: ~machinesPlayBus], s, \addToHead);
		// granSynth = Synth(\grainBuzz, [buf: buf, amp: ~amps[layer] * -3.dbamp, maxRate: rrand(20.0, 60), releaseTime: duration * 0.25, out: ~humansGranBus], s, \addToHead);

		(duration * 0.75).wait;

		("Ending % layer".format(layer)).postln;
		pvSynth = Synth(\pvAmb, [buf: spec, amp: ~amps[layer] * rrand(0.15, 0.5), maxRate: exprand(0.1, 0.2), offset: 0, releaseTime: 20, out: ~machinesPvBus], s, \addToHead);

		playSynth.release;
		// granSynth.release;

		// ~synths["waterFx"].set(\lag, duration * 0.25, \amp, 0.dbamp);

		10.wait;
		pvSynth.release;
		rrand(duration * 2, duration * 4).wait;
	};
});

// Random Textures
// ~grainBuzzRoutin = Routine({
// 	inf.do{
// 		var busses = Dictionary.new();
// 		var duration = rrand(30.0, 90);
// 		var granSynths = Dictionary.new();
// 		var busSynths = Dictionary.new();
// 		var layer = ~layers.choose;
// 		var repeats = rrand(3, 8);
// 		// "Grain Buzz".postln;
// 		repeats.do{ |i|
// 			var buf = ~audioBufs[PathName(~paths[\buffers] ++ "Audio/Sources/" ++ layer).files.choose.fileName];
// 			busses[i] = Dictionary.newFrom([\ampMod, Bus.audio(s, 1)]);
// 			busses[i] = Dictionary.newFrom([\eqMorph, Bus.audio(s, 1)]);
// 			s.sync;
// 			busSynths[i] = Dictionary.newFrom([\ampModMono, Synth(\ampModMono, [in: busses[i][\ampMod], out: busses[i][\eqMorph]], s, \addToTail)]);
// 			busSynths[i] = Dictionary.newFrom([\eqMorph, Synth(\eqMorph, [in: busses[i][\eqMorph], out: 0], s, \addToTail)]);
// 			// busSynths[i] = Dictionary.newFrom([\ampModMono, Synth.before(~verbSynth, \ampModMono, [in: busses[i][\ampMod], out: busses[i][\eqMorph]])]);
// 			// busSynths[i] = Dictionary.newFrom([\eqMorph, Synth.before(~verbSynth, \eqMorph, [in: busses[i][\eqMorph], out: 0])]);
// 			s.sync;
// 			granSynths[i] = Synth(\grainBuzz, [buf: buf, amp: ~amps[layer] * -12.dbamp, maxRate: rrand(20.0, 40), releaseTime: duration * 0.25, out: busses[i][\ampMod]], s, \addToHead);
// 		};
// 		rrand(10.0, 30).wait;
// 		repeats.do{ |i|
// 			granSynths[i].release;
// 			20.wait;
// 			busSynths[i][\ampModMono].free;
// 			busSynths[i][\eqMorph].free;
// 			busses[i][\ampMod].free;
// 			busses[i][\eqMorph].free;
// 		};
// 		// rrand(0, 20).wait;
// 		rrand(60.0, 90);
// 	};
// });

~grainStreamRoutine = Routine({
	inf.do{
		var busses = Dictionary.new();
		// var startDelay = rrand(30.0, 60);
		var duration = rrand(10.0, 30);
		var granSynths = Dictionary.new();
		var busSynths = Dictionary.new();
		var repeats = rrand(3, 8);
		("Starting Grain Streams layer for " ++ duration.round(0.1) ++ " seconds").postln;
		repeats.do{ |i|
			var layer = ~layers.choose;
			var buf = ~audioBufs[PathName(~paths[\buffers] ++ "Audio/Sources/" ++ layer).files.choose.fileName];
			// buf.postln;
			// busses[i] = Dictionary.newFrom([\ampMod, Bus.audio(s, 1)]);
			busses[i] = Dictionary.newFrom([\eqMorph, Bus.audio(s, 1)]);
			s.sync;
			// busSynths[i] = Dictionary.newFrom([\ampModMono, Synth(\ampModMono, [in: busses[i][\ampMod], out: busses[i][\eqMorph]], s, \addToTail)]);
			// busSynths[i] = Dictionary.newFrom([\eqMorph, Synth(\eqMorph, [in: busses[i][\eqMorph], out: 0], s, \addToTail)]);
			// busSynths[i] = Dictionary.newFrom([\ampModMono, Synth.before(~verbSynth, \ampModMono, [in: busses[i][\ampMod], out: busses[i][\eqMorph]])]);
			// busSynths[i] = Dictionary.newFrom([\eqMorph, Synth.before(~verbSynth, \eqMorph, [in: busses[i][\eqMorph], out: 0])]);
			s.sync;

			Synth(\granStorm, [buf: buf, amp: ~amps[layer] * rrand(0.25, 0.75), maxRate: rrand(20.0, 50), duration: rrand(10.0, 30), out: 20], s, \addToHead);
			rrand(5.0, 10).wait;
		};

		// repeats.do{ |i|
		// 	// busSynths[i][\ampModMono].free;
		// 	// busSynths[i][\eqMorph].free;
		// 	// busses[i][\ampMod].free;
		// 	// busses[i][\eqMorph].free;
		// };
		rrand(duration * 2, duration * 4).wait;
	};
});
)