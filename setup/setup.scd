(
~layers = ["water", "land", "humans", "machines"];
~fftsize = 8192;
~hop = 0.25;
~win = 0;
~audioBufs = Dictionary.new;
~specBufs  = Dictionary.new;

Routine({
	var specPath, specFiles;

	"Loading audio buffers...".postln;
	~layers.do { |layer|
		var audioPath = ~paths[\buffers] ++ "Audio/Sources/" ++ layer;
		var audioFiles = PathName(audioPath).files.select({ |f| f.fileName.endsWith(".wav") });

		("===== " ++ layer ++ " =====").postln;
		audioFiles.do { |file|
			var buf = Buffer.read(s, file.fullPath);
			s.sync;
			~audioBufs[file.fileName] = buf;
			("  Loaded audio: " ++ file.fileName).postln;
		};
	};

	"Loading spectral buffers...".postln;
	specPath = ~paths[\buffers] ++ "Data/FFT/";
	specFiles = PathName(specPath).files.select({ |f| f.fileName.endsWith(".wav") });

	specFiles.do { |file|
		var buf = Buffer.read(s, file.fullPath);
		s.sync;
		~specBufs[file.fileName] = buf;
		("  Loaded spectrum: " ++ file.fileName).postln;
	};

	("===== " ++ "=====" ++ " =====").postln;
	"All buffers loaded.".postln;
	("Audio buffers: " ++ ~audioBufs.size).postln;
	("Spectral buffers: " ++ ~specBufs.size).postln;
}).play;
)