(
s.options.numOutputBusChannels_(22);  // channels 14-22 connect thru ADAT output to the Yamaha mixer
s.options.sampleRate_(48000);
s.options.device_("ASIO : ASIO Fireface USB");
)

(

MIDIIn.connectAll;

~whitOut = NetAddr("127.0.0.1", 48155);
~sunOut = NetAddr("127.0.0.1", 48170);
~sunOut1 = NetAddr("127.0.0.1", 48171);
~sunOut2 = NetAddr("127.0.0.1", 48172);
~sunOut3 = NetAddr("127.0.0.1", 48173);
~blackOut1 = NetAddr("127.0.0.1", 48162);
~blackOut2 = NetAddr("127.0.0.1", 48163);
~blackOut3 = NetAddr("127.0.0.1", 48164);
~blackOut4 = NetAddr("127.0.0.1", 48165);
~verbOut = NetAddr("127.0.0.1", 48190);

SynthDef(\whit,{|amp=0.4, freqw=10.0, length=1.0, gate=1, www=1.0, wchaos=2.0, modw=1.0|
	var modulator, carrier, filt, pan, level, trig;
	modulator = Mix(SinOsc.ar(modw*[200, 500, 900, 700], 0, 1).abs);
	carrier = Mix(SinOsc.ar(freqw*[200*modulator, 300*modulator, 500*modulator]), 0, modw*10.0);
	filt = RHPF.ar(1.0*carrier*Crackle.ar(wchaos)*EnvGen.kr(Env.asr(0.1, 0.5, 0.5), gate, doneAction:2));
	pan = Pan2.ar(filt, ClipNoise.ar(www/10+0.1)*0.5*SinOsc.ar(www*10+0.1, 0, www));
	level = amp*100*Amplitude.kr(pan);
	trig = SendTrig.kr(Impulse.kr(50), 0, level);
	Out.ar([14,15],pan*amp);
	Out.ar([2,3], pan*amp);
}).add;


SynthDef(\suns, {|amp=0.4, amodfreq=1.0, amodfreq2=1.0 fmodfreq=1.0, fmodamp=1.0, redfreq=100.0, yelfreq=200.0, blufreq=300.0, grefreq=400.0  gate=1, sunpan=0.0|
	var amod, fmod, red, yel, blu, gre, pred, pblu, pgre, pyel, car, pan, strig, strig1, strig2, strig3, slevel, slevel1, slevel2, slevel3;
	amod = SinOsc.ar(amodfreq, 0);
	fmod = LFSaw.ar(fmodamp);
	red = (Saw.ar(redfreq*fmodfreq, amod+(amodfreq2*redfreq*0.000007)))+(Saw.ar(redfreq*fmodfreq, fmod))*EnvGen.kr(Env.asr(0.1, 0.8, 0.1), gate, doneAction: 2);
	yel = (Pulse.ar(yelfreq*fmodfreq, 0.5, amod+(amodfreq2*yelfreq*0.000007)))+(Pulse.ar(yelfreq*fmodfreq, 0.5, fmod))*EnvGen.kr(Env.asr(0.1, 0.8, 0.1), gate, doneAction: 2);
	blu = (SinOsc.ar(blufreq*fmodfreq, 0, amod+(amodfreq2*blufreq*0.000007)))+(SinOsc.ar(blufreq*fmodfreq, 0, fmod))*EnvGen.kr(Env.asr(0.1, 0.8, 0.1), gate, doneAction: 2);
	gre = (LFTri.ar(grefreq*fmodfreq, 0, amod+(amodfreq2*grefreq*0.000007)))+(LFTri.ar(grefreq*fmodfreq, 0, fmod))*EnvGen.kr(Env.asr(0.1, 0.8, 0.1), gate, doneAction: 2);
	pred = Pan2.ar(red, sunpan);
	pyel = Pan2.ar(yel, sunpan);
	pblu = Pan2.ar(blu, sunpan);
	pgre = Pan2.ar(gre, sunpan);


	slevel = amp*Amplitude.kr(red);
	strig = SendTrig.kr(Impulse.kr(50), 1, slevel);
	slevel1 = amp*Amplitude.kr(yel);
	strig1 = SendTrig.kr(Impulse.kr(50), 2, slevel1);
	slevel2 = amp*Amplitude.kr(blu);
	strig2 = SendTrig.kr(Impulse.kr(50), 3, slevel2);
	slevel3 = amp*Amplitude.kr(gre);
	strig3 = SendTrig.kr(Impulse.kr(50), 4, slevel3);
	Out.ar([14,15], pred*amp*0.1);
	Out.ar([14,15], pyel*amp*0.1);
	Out.ar([14,15], pblu*amp*0.1);
	Out.ar([14,15], pgre*amp*0.1);
	Out.ar([2,3], pred*amp*0.1);
	Out.ar([2,3], pyel*amp*0.1);
	Out.ar([2,3], pblu*amp*0.1);
	Out.ar([2,3], pgre*amp*0.1);
}).add;

SynthDef(\black,{|amp=0.1, amp2=0.1, gate=1, bosc=0.2|
	var modulator, carrier, filt, noise, ring, pan, modulator2, carrier2, filt2, noise2, ring2, pan2, trig5, trig6, trig7, trig8, blevel1, blevel2;
	modulator = SinOsc.ar(bosc*0.1, 0.1, bosc/2.0+1.0);
	carrier = LFSaw.ar(modulator.abs);
	noise = PinkNoise.ar(carrier);
	filt = LPF.ar(noise, modulator.abs*300.0, 0.2);
	ring = filt+Mix(Ringz.ar(filt, [Line.kr(50, 2000, 120, 1, 0, 0), Line.kr(2000, 50, 120, 1, 0, 0), 920, 300, 456], 1, 0.1));
	pan = Pan2.ar(ring, modulator*0.2)*EnvGen.kr(Env.asr(0.5, 0.5, 2.0), gate, doneAction:2);
	blevel1 = Amplitude.kr(ring);
	trig5 = SendTrig.kr(Impulse.kr(50), 5, modulator);
	trig6 = SendTrig.kr(Impulse.kr(50), 6, pan);
	Out.ar([14,15],pan*amp*0.6);
	Out.ar([2,3], pan*amp*0.06);
	modulator2 = SinOsc.ar(bosc*0.1, 0.05, bosc/2.0+1.0);
	carrier2 = LFSaw.ar(modulator2.abs);
	noise2 = PinkNoise.ar(carrier2);
	filt2 = LPF.ar(noise2, modulator2.abs*300.0, 0.2);
	ring2 = filt2+Mix(Ringz.ar(filt2, [Line.kr(50, 2000, 120, 1, 0, 0), Line.kr(2000, 50, 120, 1, 0, 0), 950, 290, 459], 1, 0.1));
	pan2 = Pan2.ar(ring2, modulator2* -0.2)*EnvGen.kr(Env.asr(0.5, 0.5, 2.0), gate, doneAction:2);
	blevel2 = Amplitude.kr(ring2);
	trig5 = SendTrig.kr(Impulse.kr(50), 7, modulator2);
	trig6 = SendTrig.kr(Impulse.kr(50), 8, pan2);
	Out.ar([14,15],pan2*amp2*0.6);
	Out.ar([2,3],pan2*amp2*0.6);
}).add;

SynthDef(\verb,{|amp=0.5, gate=1|
	var vv, verblevel, verbtrig, verbosc;
	vv = Pan2.ar(Mix(FreeVerb.ar(In.ar([2,3]), 1.0, 0.9, 0.9)), 0)*EnvGen.kr(Env.asr(0.5, 0.5, 2.0), gate, doneAction:2);
	verbosc = SinOsc.ar(200)*EnvGen.kr(Env.asr(0.5, 0.5, 2.0), gate, doneAction:2);
	verblevel = Amplitude.kr(verbosc);
	verbtrig =  SendTrig.kr(Impulse.kr(50), 9, verblevel);
	Out.ar([14,15], vv);
}).add;

OSCdef(\tr,{ arg msg, time;
	[time, msg].postln;
	if (msg[2] == 0,{~whitOut.sendMsg("/whitamp", msg[3])});

	if (msg[2] == 1,{~sunOut.sendMsg("/sunredamp", msg[3])});
	if (msg[2] == 2,{~sunOut1.sendMsg("/sunyelamp", msg[3])});
	if (msg[2] == 3,{~sunOut2.sendMsg("/sunbluamp", msg[3])});
	if (msg[2] == 4,{~sunOut3.sendMsg("/sungreamp", msg[3])});

	if (msg[2] == 5,{~blackOut1.sendMsg("/blackpan1", msg[3])});
	if (msg[2] == 6,{~blackOut2.sendMsg("/blackamp1", msg[3])});
	if (msg[2] == 7,{~blackOut3.sendMsg("/blackpan2", msg[3])});
	if (msg[2] == 8,{~blackOut4.sendMsg("/blackamp2", msg[3])});

	if (msg[2] == 9,{~verbOut.sendMsg("/verb", msg[3])});
}, \tr, s.addr;
);


~synths = Array.fill(128,{nil});

~www = 1.0;
~freqw = 1.0;
~wchaos = 1.0;
~modw = 1.0;

~amodfreq = 1.0;
~amodfreq2 = 1.0;
~fmodfreq = 1.0;
~fmodamp = 1.0;
~redfreq = 100.0;
~yelfreq = 200.0;
~blufreq = 300.0;
~grefreq = 400.0;
~sunpan = 0.0;

~bosc = 1.0;

~whitOut2 = NetAddr("127.0.0.1", 48156);
~whitOut3 = NetAddr("127.0.0.1", 48158);
~whitOut4 = NetAddr("127.0.0.1", 48159);
~whitOut5 = NetAddr("127.0.0.1", 48160);

~sunOut4 = NetAddr("127.0.0.1", 48174);
~sunOut5 = NetAddr("127.0.0.1", 48175);
~sunOut6 = NetAddr("127.0.0.1", 48176);
~sunOut7 = NetAddr("127.0.0.1", 48177);
~sunOut8 = NetAddr("127.0.0.1", 48178);
~sunOut9 = NetAddr("127.0.0.1", 48179);
~sunOut10 = NetAddr("127.0.0.1", 48180);
~sunOut11 = NetAddr("127.0.0.1", 48181);
~sunOut12 = NetAddr("127.0.0.1", 48182);
~sunOut13 = NetAddr("127.0.0.1", 48183);

~blackOut5 = NetAddr("127.0.0.1", 48166);
~blackOut6 = NetAddr("127.0.0.1", 48167);


MIDIdef.noteOn(\testOn,{ arg vel,note;
	note.postln;
		if (note == 48, {~synths.put(48,Synth(\whit,[\amp,vel/127,\www,~www, \freqw, ~freqw, \wchaos,~wchaos, \modw,~modw]))});
	    if (note == 49, {~synths.put(49,Synth(\whit,[\amp,vel/127,\www,~www, \freqw, ~freqw, \wchaos,~wchaos, \modw,~modw]))});
	    if (note == 50, {~synths.put(50,Synth(\whit,[\amp,vel/127,\www,~www, \freqw, ~freqw, \wchaos,~wchaos, \modw,~modw]))});
	    if (note == 51, {~synths.put(51,Synth(\whit,[\amp,vel/127,\www,~www, \freqw, ~freqw, \wchaos,~wchaos, \modw,~modw]))});

	    if (note == 52, {~synths.put(52,Synth(\suns,[\amp,vel/127, \amodfreq,~amodfreq, \amodfreq2,~amodfreq2, \fmodfreq,~fmodfreq, \fmodamp,~fmodamp, \redfreq,~redfreq, \yelfreq,~yelfreq, \blufreq,~blufreq,\grefreq,~grefreq, \sunpan,~sunpan, ~sunOut5.sendMsg("/sunz", vel)]))});
	  	if (note == 53, {~synths.put(53,Synth(\suns,[\amp,vel/127, \amodfreq,~amodfreq, \amodfreq2,~amodfreq2, \fmodfreq,~fmodfreq, \fmodamp,~fmodamp, \redfreq,~redfreq, \yelfreq,~yelfreq, \blufreq,~blufreq,\grefreq,~grefreq, \sunpan,~sunpan, ~sunOut5.sendMsg("/sunz", vel)]))});
	    if (note == 54, {~synths.put(54,Synth(\suns,[\amp,vel/127, \amodfreq,~amodfreq, \amodfreq2,~amodfreq2, \fmodfreq,~fmodfreq, \fmodamp,~fmodamp, \redfreq,~redfreq, \yelfreq,~yelfreq, \blufreq,~blufreq,\grefreq,~grefreq, \sunpan,~sunpan, ~sunOut5.sendMsg("/sunz", vel)]))});
	  	if (note == 55, {~synths.put(55,Synth(\suns,[\amp,vel/127, \amodfreq,~amodfreq, \amodfreq2,~amodfreq2, \fmodfreq,~fmodfreq, \fmodamp,~fmodamp, \redfreq,~redfreq, \yelfreq,~yelfreq, \blufreq,~blufreq,\grefreq,~grefreq, \sunpan,~sunpan, ~sunOut5.sendMsg("/sunz", vel)]))});

	    if (note == 62, {~synths.put(62,Synth(\black,[\amp,vel/127, \amp2,vel/127, \bosc,~bosc]))});
	    if (note == 60, {~synths.put(60,Synth(\verb))});
},nil,0).fix(true);

MIDIdef.noteOff(\testOff,{ arg vel,note;
	if (~synths[note].notNil, { ~synths[note].release; ~synths.put(note,nil) });
},nil,0).fix(true);


MIDIdef.cc(\testCC,{ arg val, num, chan;  // this is the vector for controller events
	var synthsOn;
	num.postln;
	if (num == 0, { ~www=([0.1,20,\lin,0.01].asSpec.map(val/127));
		~synths[48].set(\www,~www);
		~synths[49].set(\www,~www);
		~synths[50].set(\www,~www);
		~synths[51].set(\www,~www);
		~whitOut2.sendMsg("/whitcc", val)});
	if (num == 16, { ~freqw=([0.1,40,\lin,0.1].asSpec.map(val/127));
		~synths[48].set(\freqw,~freqw);
		~synths[49].set(\freqw,~freqw);
		~synths[50].set(\freqw,~freqw);
		~synths[51].set(\freqw,~freqw);
		~whitOut3.sendMsg("/whitcc2", val)});
	if (num == 17, { ~wchaos=([1.0,2.0,\lin,0.01].asSpec.map(val/127));
		~synths[48].set(\wchaos,~wchaos);
		~synths[49].set(\wchaos,~wchaos);
		~synths[50].set(\wchaos,~wchaos);
		~synths[51].set(\wchaos,~wchaos);
		~whitOut4.sendMsg("/whitchaos", val)});
	if (num == 1, { ~modw=([1.0,20.0,\lin,0.01].asSpec.map(val/127));
		~synths[48].set(\modw,~modw);
		~synths[49].set(\modw,~modw);
		~synths[50].set(\modw,~modw);
		~synths[51].set(\modw,~modw);
		~whitOut5.sendMsg("/whitmod", val)});

	if (num == 6, { ~sunpan=([-1.0,1.0,\lin,0.01].asSpec.map(val/127));
		~synths[52].set(\sunpan,~sunpan);
		~synths[53].set(\sunpan,~sunpan);
		~synths[54].set(\sunpan,~sunpan);
		~synths[55].set(\sunpan,~sunpan);
	    ~sunOut4.sendMsg("/sunx", val)});

	if (num == 12, { ~sunpan=([-1.0,1.0,\lin,0.01].asSpec.map(val/127))});

	if (num == 2, { ~amodfreq=([0.01,100,\lin,0.01].asSpec.map(val/127));
		~synths[52].set(\amodfreq,~amodfreq);
		~synths[53].set(\amodfreq,~amodfreq);
		~synths[54].set(\amodfreq,~amodfreq);
		~synths[55].set(\amodfreq,~amodfreq);
		~sunOut6.sendMsg("/sunbfg", val)});

	if (num == 3, { ~fmodfreq=([0.1,3.0,\lin,0.01].asSpec.map(val/127));
		~synths[52].set(\fmodfreq,~fmodfreq);
		~synths[53].set(\fmodfreq,~fmodfreq);
		~synths[54].set(\fmodfreq,~fmodfreq);
		~synths[55].set(\fmodfreq,~fmodfreq);
	    ~sunOut7.sendMsg("/sundistance", val)});

	if (num == 4, { ~fmodamp=([1.0,2000.0,\lin,0.01].asSpec.map(val/127));
		~synths[52].set(\fmodamp,~fmodamp);
		~synths[53].set(\fmodamp,~fmodamp);
		~synths[54].set(\fmodamp,~fmodamp);
		~synths[55].set(\fmodamp,~fmodamp);
	    ~sunOut8.sendMsg("/sunsize", val)});

	if (num == 5, { ~amodfreq2=([0.01,100,\lin,0.01].asSpec.map(val/127));
		~synths[52].set(\amodfreq2,~amodfreq2);
		~synths[53].set(\amodfreq2,~amodfreq2);
		~synths[54].set(\amodfreq2,~amodfreq2);
		~synths[55].set(\amodfreq2,~amodfreq2);
	    ~sunOut9.sendMsg("/suny", val)});

	if (num == 18, { ~redfreq=([100.0,4000.0,\lin,0.1].asSpec.map(val/127));
		~synths[52].set(\redfreq,~redfreq);
		~synths[53].set(\redfreq,~redfreq);
		~synths[54].set(\redfreq,~redfreq);
		~synths[55].set(\redfreq,~redfreq);
		~sunOut10.sendMsg("/sunredcolor", val)});

	if (num == 19, { ~yelfreq=([100.0,4000.0,\lin,0.1].asSpec.map(val/127));
		~synths[52].set(\yelfreq,~yelfreq);
		~synths[53].set(\yelfreq,~yelfreq);
		~synths[54].set(\yelfreq,~yelfreq);
		~synths[55].set(\yelfreq,~yelfreq);
		~sunOut11.sendMsg("/sunyelcolor", val)});

	if (num == 20, { ~blufreq=([100.0,4000.0,\lin,0.1].asSpec.map(val/127));
		~synths[52].set(\blufreq,~blufreq);
		~synths[53].set(\blufreq,~blufreq);
		~synths[54].set(\blufreq,~blufreq);
		~synths[55].set(\blufreq,~blufreq);
	    ~sunOut12.sendMsg("/sunblucolor", val)});

	if (num == 21, { ~grefreq=([100.0,4000.0,\lin,0.1].asSpec.map(val/127));
		~synths[52].set(\grefreq,~grefreq);
		~synths[53].set(\grefreq,~grefreq);
		~synths[54].set(\grefreq,~grefreq);
		~synths[55].set(\grefreq,~grefreq);
	    ~sunOut13.sendMsg("/sungrecolor", val)});



	if (num == 23, { ~bosc=([0.1,20,\lin,0.1].asSpec.map(val/127));
		~synths[62].set(\bosc,~bosc)});


}).fix(true);
)


MIDIdef.freeAll;
