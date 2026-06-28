ServerOptions.devices.do{ |device| device.postln; };
(
Server.killAll;
Buffer.freeAll;
~nChans = 3 - 1;
~nOuts = ~nChans + 1;
// ~sr = 48000;
~sr = 44100;

~paths = Dictionary.new();

s = Server.local;
s.options.outDevice_(
	// "Dante Virtual Soundcard"
	"MacBook Pro Speakers"
	// "External Headphones"
	// "ZoomAudioD"
	// "Audio Out"
	// "Ryan’s AirPods P"
	// "Scarlett 4i4 USB"
);
// s.options.inDevice_("Built-in Microph");
s.options.numInputBusChannels_(0);
s.options.numOutputBusChannels_(~nOuts);
s.options.memSize_(2.pow(20));
s.options.sampleRate_(~sr);
s.options.numWireBufs = 1024;
s.newBusAllocators;

s.waitForBoot({
	s.plotTree;
	s.meter;

	// thisProcess.openUDPPort(57121);
	// thisProcess.openPorts.postln;

	~paths[\project] = PathName.new(thisProcess.nowExecutingPath).parentPath;
	~paths[\setup] = PathName.new(~paths[\project]).parentPath ++ "Code/setup/";
	~paths[\buffers] = PathName(~paths[\project]).parentPath ++ "Buffers/";

	(~paths[\setup] ++ "/setup.scd").load;

	s.sync;

	(~paths[\setup] ++ "/routines.scd").load;

	s.sync;

	~paths[\synthdefs] = PathName(~paths[\project]).parentPath ++ "Code/synthdefs/";
	PathName(~paths[\synthdefs]).files.do { |file| (file.fullPath).load; };

	s.sync;

	"Done.".postln;
});
)