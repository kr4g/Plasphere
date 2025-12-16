(
s.newBusAllocators;

~amps = Dictionary.newFrom([
	"water", 8.dbamp,
	"land", 2.dbamp,
	"humans", -6.dbamp,
	"machines", -8.dbamp,
]);

~durs = Dictionary.newFrom([
	"water", (min: 0.5, max: 2),
	"land", (min: 0.5, max: 1),
	"humans", (min: 0.5, max: 1),
	"machines", (min: 0.75, max: 1),
]);


~waterBus1 = Bus.audio(s, 1);
~waterBus2 = Bus.audio(s, 1);
~waterAmpBus1 = Bus.audio(s, 1);
~waterAmpBus2 = Bus.audio(s, 1);
~waterXFade1 = Bus.audio(s, ~nChans);
~waterXFade2 = Bus.audio(s, ~nChans);
~waterPvBus = Bus.audio(s, 1);

~boatCptBus = Bus.audio(s, 1);
~boatCptAmpBus = Bus.audio(s, 1);

~landPlayBus = Bus.audio(s, 1);
~landPlayAmpBus = Bus.audio(s, 1);
~landAmpStereoBus = Bus.audio(s, 1);
~landGranBus = Bus.audio(s, ~nChans);
~landGranAmpBus = Bus.audio(s, ~nChans);
~landGranDelayBus = Bus.audio(s, 1);
~landPlayXFaderBus = Bus.audio(s, ~nChans);
~landXFaderBus = Bus.audio(s, 1);
~landPvBus = Bus.audio(s, 1);

~humansPlayBus = Bus.audio(s, 1);
~humansGranBus = Bus.audio(s, 1);
~humansPlayAmpBus = Bus.audio(s, 1);
~humansAmpStereoBus = Bus.audio(s, 1);
~humansGranAmpBus = Bus.audio(s, 1);
~humansXFaderBus = Bus.audio(s, 1);
~humansPvBus = Bus.audio(s, 1);

~machinesPlayBus = Bus.audio(s, 1);
~machinesPlayAmpBus = Bus.audio(s, 1);
~machinesPvBus = Bus.audio(s, 1);

~streamsBus = Bus.audio(s, ~nChans);
~streamsAmpBus = Bus.audio(s, ~nChans);

~grainMorph1 = Bus.audio(s, 1);
~grainMorph2 = Bus.audio(s, 1);
~grainMorph = Bus.audio(s, 1);
~grainSlicer = Bus.audio(s, 1);

~synths = Dictionary.new();

// s.record(path:"/Users/ryanmillett/Downloads/Plas_Test.wav", numChannels: ~nOuts);

fork {
	s.sync;

	// WATER
	Synth(\ampModMono, [in: ~waterBus1, minAmp: 0.5, out: ~waterAmpBus1], s, \addToTail);
	Synth(\ampModMono, [in: ~waterBus2, minAmp: 0.5, out: ~waterAmpBus2], s, \addToTail);
	Synth(\resoMorph, [in: ~waterAmpBus1, out: ~waterXFade1, depth: 1, innerRate: 0.01, outerRate: 0.005, minLfoRate: 0.02, maxLfoRate: 0.2], s, \addToTail);
	Synth(\resoGrains, [in: ~waterAmpBus2, out: ~waterXFade2, depth: 1, innerRate: 0.01, outerRate: 0.005, minLfoRate: 0.02, maxLfoRate: 0.2], s, \addToTail);

	Synth(\xFaderStereo, [in1: ~waterXFade1, in2: ~waterXFade2, depth: 1, out: 0], s, \addToTail);

	Synth(\eqMorph, [in: ~waterPvBus, out: 0], s, \addToTail);


	// BOAT CAPTAIN
	Synth(\ampModMono, [in: ~boatCptBus, minAmp: 0.0, outerRate: 0.02, out: ~boatCptAmpBus], s, \addToTail);
	Synth(\eqMorph, [in: ~boatCptAmpBus, out: 0], s, \addToTail);


	// LAND
	Synth(\ampModMono, [in: ~landPlayBus, minAmp: 0.25, outerRate: 0.02, out: ~landPlayAmpBus], s, \addToTail);
	Synth(\eqMorph, [in: ~landPlayAmpBus, wet: 1, out: ~landPlayXFaderBus], s, \addToTail);
	Synth(\ampModStereo, [in: ~landGranBus, minAmp: 0.7, outerRate: 0.005, curve: 5, out: ~landGranAmpBus], s, \addToTail);
	Synth(\xFaderStereo, [in1: ~landPlayXFaderBus, in2: ~landGranAmpBus, innerRate: 0.005, minRate: 0.01, maxRate: 0.1, depth: 1, out: 0], s, \addToTail);

	Synth(\eqMorph, [in: ~landPvBus, out: 0], s, \addToTail);


	// HUMANS
	Synth(\ampModMono, [in: ~humansPlayBus, minAmp: 0.0, outerRate: 0.03, out: ~humansPlayAmpBus], s, \addToTail);
	// Synth(\specFx, [in: ~humansPlayAmpBus, out: 0, innerRate: 0.03, minLfoRate: 0.08, maxLfoRate: 0.1], s, \addToTail);
	Synth(\resoGrains, [in: ~humansPlayAmpBus, out: 0], s, \addToTail);

	Synth(\eqMorph, [in: ~humansPvBus, out: 0], s, \addToTail);


	// MACHINES
	Synth(\ampModMono, [in: ~machinesPlayBus, minAmp: 0.15, outerRate: 0.03, out: ~machinesPlayAmpBus], s, \addToTail);
	Synth(\specFx, [in: ~machinesPlayAmpBus, out: 0, innerRate: 0.01, minLfoRate: 0.05, maxLfoRate: 0.1], s, \addToTail);

	Synth(\eqMorph, [in: ~machinesPvBus, out: 0], s, \addToTail);


	// GRAIN STREAMS
	Synth(\ampModStereo, [in: ~streamsBus, minAmp: 0.7, out: 0], s, \addToTail);


	// GRAIN MORPHS
	// Synth(\specMorph, [in1: ~grainMorph1, in2: ~grainMorph2, out: ~grainMorph], s, \addToTail);
	Synth(\eqMorph, [in: ~grainMorph, out: 0], s, \addToTail);

	~mainSynth = Synth.tail(nil, \main, [amp: 0.2, ampSub: 0.2, out: 0, outSub: ~nChans]);

	s.sync;

	fork { ~waterRoutine.reset.play; };

	fork {
		rrand(15.0, 90).wait;
		~landRoutine.reset.play;
	};

	fork {
		inf.do{
			rrand(30.0, 120).wait;
			if (rand(1.0) < 0.5) {
				if (rand(1.0) < 0.75) {
					~humansRoutine.reset.play;
				} {
					~boatCptRoutine.reset.play;
				};
			} {
				~machinesRoutine.reset.play;
			};
		};
	};

	fork {
		inf.do{
			rrand(15.0, 90).wait;
			if (rand(1.0) < 0.5) {
				~grainStreamsRoutine.reset.play;
			} {
				~grainMorphsRoutine.reset.play;
				rrand(15.0, 30).wait;
			};
		};
	};
};
)

~mainSynth.set(\amp, 0.2, \ampSub, 0.2);