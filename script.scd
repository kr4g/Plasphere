(
s.newBusAllocators;

~amps = Dictionary.newFrom([
	"water", 6.dbamp,
	"land", 4.dbamp,
	"humans", -3.dbamp,
	"machines", -1.dbamp,
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

~synths = Dictionary.new();

// ~time = 60 * 20;
// s.record("/Users/ryanmillett/Downloads/plas_demo_" ++ ~nChans ++ "ch_humans.wav", numChannels: ~nChans, duration: ~time);
// s.record("/Users/ryanmillett/Downloads/plas_demo_C_" ++ (~nOuts) ++ "_tracks.wav", numChannels: ~nOuts, duration: ~time);

// Water1:   0
// Water2:   4
// Land:     8
// Humans:   12
// Machines: 16
// Grains:   20
// Boat Cpt: 24
// PV Drone: 28

fork {
	s.sync;

	// Water
	Synth(\ampModMono, [in: ~waterBus1, minAmp: 0.5, out: ~waterAmpBus1], s, \addToTail);
	Synth(\ampModMono, [in: ~waterBus2, minAmp: 0.5, out: ~waterAmpBus2], s, \addToTail);
	Synth(\resoMorph, [in: ~waterAmpBus1, out: 0, depth: 1, innerRate: 0.03, minLfoRate: 0.05, maxLfoRate: 0.2], s, \addToTail);
	Synth(\resoGrains, [in: ~waterAmpBus2, out: 0, depth: 1, innerRate: 0.03, minLfoRate: 0.05, maxLfoRate: 0.2], s, \addToTail);

	Synth(\ampModMono, [in: ~boatCptBus, minAmp: 0.0, outerRate: 0.02, out: ~boatCptAmpBus], s, \addToTail);
	Synth(\eqMorph, [in: ~boatCptAmpBus, out: 0], s, \addToTail);

	Synth(\eqMorph, [in: ~waterPvBus, out: 0], s, \addToTail);


	// Land
	// Synth(\ampModMono, [in: ~landPlayBus, minAmp: 0.5, outerRate: 0.02, out: ~landPlayAmpBus], s, \addToTail);
	Synth(\eqMorph, [in: ~landPlayBus, wet: 1, out: ~landPlayXFaderBus], s, \addToTail);
	Synth(\ampModStereo, [in: ~landGranBus, minAmp: 0.7, outerRate: 0.05, curve: 5, out: ~landGranAmpBus], s, \addToTail);
	Synth(\xFaderStereo, [in1: ~landPlayXFaderBus, in2: ~landGranAmpBus, innerRate: 0.05, minRate: 0.1, maxRate: 0.25, depth: 1, out: 0], s, \addToTail);

	Synth(\eqMorph, [in: ~landPvBus, out: 0], s, \addToTail);


	// Humans
	Synth(\ampModMono, [in: ~humansPlayBus, minAmp: 0.0, outerRate: 0.03, out: ~humansPlayAmpBus], s, \addToTail);
	Synth(\specFx, [in: ~humansPlayAmpBus, out: 0, innerRate: 0.03, minLfoRate: 0.08, maxLfoRate: 0.1], s, \addToTail);

	Synth(\eqMorph, [in: ~humansPvBus, out: 0], s, \addToTail);


	// Machines
	Synth(\ampModMono, [in: ~machinesPlayBus, minAmp: 0.5, outerRate: 0.03, out: ~machinesPlayAmpBus], s, \addToTail);
	Synth(\specFx, [in: ~machinesPlayAmpBus, out: 0, innerRate: 0.01, minLfoRate: 0.05, maxLfoRate: 0.1], s, \addToTail);

	Synth(\eqMorph, [in: ~machinesPvBus, out: 0], s, \addToTail);

	s.sync;

	fork { ~waterRoutine.reset.play; };

	fork {
		rrand(10.0, 120).wait;
		~boatCptRoutine.reset.play;
	};

	fork {
		rrand(15.0, 30).wait;
		~landRoutine.reset.play;
	};

	fork {
		rrand(80.0, 120).wait;
		~humansRoutine.reset.play;
	};

	fork {
		rrand(120.0, 180).wait;
		~machinesRoutine.reset.play;
	};

	// fork {
	// 	rrand(10.0, 50).wait;
	// 	~grainStreamRoutine.reset.play;
	// };

	// (~time - 30).wait;
	// ~waterRoutine.stop;
	// ~boatCptRoutine.stop;
	// ~landRoutine.stop;
	// ~humansRoutine.stop;
	// ~machinesRoutine.stop;
	// ~grainStreamRoutine.stop;
	// s.defaultGroup.release;
};
)