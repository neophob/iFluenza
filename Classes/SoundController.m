//
//  SoundController.m
//  influenza2
//
//  Created by michael vogt on 03.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SoundController.h"
#import "Constants.h"
#import "ccMacros.h"
#import "ObserverMessages.h"

@implementation SoundController

- (id) init {
	CCLOG(@"Denshion: init");
	//setup soundengine
	[self setUpAudioManager];
	
	am = nil;
	soundEngine = nil;
	
	if ([CDAudioManager sharedManagerState] != kAMStateInitialised) {
		//The audio manager is not initialised yet so kick off the sound loading as an NSOperation that will wait for the audio manager
		NSInvocationOperation* bufferLoadOp = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadSoundBuffers:) object:nil] autorelease];
		NSOperationQueue *opQ = [[[NSOperationQueue alloc] init] autorelease]; 
		[opQ addOperation:bufferLoadOp];
//		[self loadSoundBuffers:nil];
//		_appState = kAppStateAudioManagerInitialising;
	} else {
		[self loadSoundBuffers:nil];
//		_appState = kAppStateSoundBuffersLoading;
	}	
	
	//set master volume
	[[[CDAudioManager sharedManager] soundEngine] setMasterGain:1.0f];
	
	//register observer, we play the sound if we receieve a message...
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(particleBlownup:) 
												 name:MSG_PARTICLE_BLOWN_UP
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(gameNextLevel:) 
												 name:MSG_GAME_NEXT_LEVEL
											   object:nil];
	
	//[[CDAudioManager sharedManager] setBackgroundMusicCompletionListener:self selector:@selector(backgroundMusicFinished)];
	return self;
}

//play the "i just got touched" sound
-(void) particleBlownup:(NSNotification *)notification {
	ParticleMessage *msg = [notification object];
	
	if (msg.specialFunction == 0) {
		[self playFx:SND_ID_BLUB];
	} else {
		[self playFx:SND_ID_BLUB_BIG];
	}	
}

//play the sound level for a new level
-(void) gameNextLevel:(NSNotification *)notification {
	[self playFx:SND_ID_LEVEL];
}

-(void) loadSoundBuffers:(NSObject*) data {
	CCLOG(@"Denshion: loadSoundBuffers");
	//Wait for the audio manager if it is not initialised yet
	while ([CDAudioManager sharedManagerState] != kAMStateInitialised) {
		[NSThread sleepForTimeInterval:0.1];
	}	

	//Load the buffers with audio data. There is no correspondence between voices/channels and
	//buffers.  For example you can play the same sound in multiple channel groups with different
	//pitch, pan and gain settings.
	//Buffers can be loaded with different sounds simply by calling loadBuffer again, however,
	//any sources attached to the buffer will be stopped if they are currently playing
	//Use: afconvert -f caff -d ima4 yourfile.wav to create an ima4 compressed version of a wave file
	CDSoundEngine *sse = [CDAudioManager sharedManager].soundEngine;
	
	//Load sound buffers asynchrounously
/*	NSMutableArray *loadRequests = [[[NSMutableArray alloc] init] autorelease];
	[loadRequests addObject:[[[CDBufferLoadRequest alloc] init:SND_ID_CLICK filePath:SND_ID_CLICK_NAME] autorelease]];
	[loadRequests addObject:[[[CDBufferLoadRequest alloc] init:SND_ID_LEVEL filePath:SND_ID_LEVEL_NAME] autorelease]];
	[loadRequests addObject:[[[CDBufferLoadRequest alloc] init:SND_ID_BLUB filePath:SND_ID_BLUB_NAME] autorelease]];
	[loadRequests addObject:[[[CDBufferLoadRequest alloc] init:SND_ID_BLUB_BIG filePath:SND_ID_BLUB_BIG_NAME] autorelease]];
	[sse loadBuffersAsynchronously:loadRequests];
	_appState = kAppStateSoundBuffersLoading;
	*/
	[sse loadBuffer:SND_ID_CLICK filePath:SND_ID_CLICK_NAME];
	[sse loadBuffer:SND_ID_LEVEL filePath:SND_ID_LEVEL_NAME];
	[sse loadBuffer:SND_ID_BLUB filePath:SND_ID_BLUB_NAME];	
	[sse loadBuffer:SND_ID_BLUB_BIG filePath:SND_ID_BLUB_BIG_NAME];
	
//	_appState = kAppStateReady;	
	CCLOG(@"Denshion: init done!");	

	//Sound engine is now set up. You can check the functioning property to see if everything worked.
	//In addition the loadBuffer method returns a boolean indicating whether it worked.
	//If your buffers loaded and the functioning = TRUE then you are set to play sounds.	
}

-(void) setUpAudioManager {
	//Channel groups define how voices are shared, the maximum number of voices is defined by 
	//CD_MAX_SOURCES in the CocosDenshion.h file
	//When a request is made to play a sound within a channel group the next available voice
	//is used.  If no voices are free then the least recently used voice is stopped and reused.
	int channelGroupCount = CGROUP_TOTAL;
	int channelGroups[CGROUP_TOTAL];
	channelGroups[CGROUP_LEVEL_SND] = 1;//This means only 1 loop will play at a time
	channelGroups[CGROUP_FX] = 4;
	//	channelGroups[CGROUP_NON_INTERRUPTIBLE] = 2;//2 voices that can't be interrupted
	
	//Initialise audio manager asynchronously as it can take a few seconds
	[CDAudioManager initAsynchronously:kAMM_FxPlusMusicIfNoOtherAudio channelGroupDefinitions:channelGroups channelGroupTotal:channelGroupCount];
//	[CDAudioManager initAsynchronously:kAudioManagerFxPlusMusicIfNoOtherAudio channelGroupDefinitions:channelGroups channelGroupTotal:channelGroupCount];
	//[CDAudioManager initAsynchronously:kAudioManagerFxPlusMusic channelGroupDefinitions:channelGroups channelGroupTotal:channelGroupCount];
}

/*
-(void) checkIfSoundIsLoaded {
	if (_appState == kAppStateSoundBuffersLoading) {
		//Check if sound buffers have completed loading, asynchLoadProgress represents fraction of completion and 1.0 is complete.
		if ([CDAudioManager sharedManager].soundEngine.asynchLoadProgress >= 1.0f) {
			//Sounds have finished loading
			_appState = kAppStateReady;
			//			[[CDAudioManager sharedManager] setBackgroundMusicCompletionListener:self selector:@selector(backgroundMusicFinished)]; 
			//			[[CDAudioManager sharedManager].soundEngine setChannelGroupNonInterruptible:CGROUP_NON_INTERRUPTIBLE isNonInterruptible:TRUE];
			[[CDAudioManager sharedManager] setResignBehavior:kAMRBStopPlay autoHandle:TRUE];
			CCLOG(@"Denshion: sound buffers are ready...");
		} else {
			CCLOG(@"Denshion: sound buffers loading %0.2f",[CDAudioManager sharedManager].soundEngine.asynchLoadProgress);
		}
	}
}
*/
//plays an sound fx, max 4 fx simult.
-(void) playFx:(int) snd {
	/*
	if (_appState != kAppStateReady) {
		[self checkIfSoundIsLoaded];
	}	[soundEngine setMasterGain:1];
	*/
//	if (_appState == kAppStateReady) {
		am = [CDAudioManager sharedManager];

		soundEngine = am.soundEngine;
		//CCLOG(@"play it loud!");
		[soundEngine playSound:snd channelGroupId:CGROUP_FX pitch:1.0f pan:1.0f gain:1.0f loop:NO];
//	}
}

- (void)playGameMusic {
	[[CDAudioManager sharedManager] playBackgroundMusic:MUSIC_GAME loop:YES];
	[CDAudioManager sharedManager].backgroundMusic.numberOfLoops = 9999;
}

- (void)stopGameMusic {
	[[CDAudioManager sharedManager] stopBackgroundMusic];
}

- (void) pauseGameMusic {
	[[CDAudioManager sharedManager] pauseBackgroundMusic];
}

- (void) resumeGameMusic {
	[[CDAudioManager sharedManager] resumeBackgroundMusic];
}

////

- (void)playMenuMusic {
	[[CDAudioManager sharedManager] playBackgroundMusic:@"gnx-virus.mp3" loop:YES];
	[CDAudioManager sharedManager].backgroundMusic.numberOfLoops = 9999;
}

- (void)stopMenuMusic {
	[[CDAudioManager sharedManager] stopBackgroundMusic];
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[am release];
	[super dealloc];
}

//////

//singleton
+(SoundController *) get {
    static SoundController *instance;
	@synchronized(self) {
		if(!instance) {
			instance = [[SoundController alloc] init];
		}
	}
	return instance;
}

@end
