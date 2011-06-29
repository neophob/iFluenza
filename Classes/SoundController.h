//
//  SoundController.h
//  influenza2
//
//  Created by michael vogt on 03.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CocosDenshion.h"
#import "CDAudioManager.h"
#import "Constants.h"

@interface SoundController : NSObject {
	UIWindow		*window;
	CDAudioManager	*am;
	CDSoundEngine	*soundEngine;
//	sndAppState		_appState;	
}

-(void) setUpAudioManager;
-(void) loadSoundBuffers:(NSObject*) data;
-(void) playFx:(int) snd;

-(void) playGameMusic;
-(void) stopGameMusic;
-(void) pauseGameMusic;
-(void) resumeGameMusic;

-(void) playMenuMusic;
-(void) stopMenuMusic;

-(void) particleBlownup:(NSNotification *)notification;

+(SoundController *) get;

@end


