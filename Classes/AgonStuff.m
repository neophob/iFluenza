//
//  AgonStuff.m
//  influenza2.2
//
//  Created by michael vogt on 05.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "AgonStuff.h"
#import "GameController.h"
#import "ObserverMessages.h"
#import <UIKit/UIColor.h>

typedef enum {                                                                                                                                     
	AWARD_JUST_PLAY = 0,                                                                                                       
	AWARD_REACH_LVL_5 = 1,
	AWARD_COUNT_TO_THREE = 3,
	AWARD_REACH_LVL_10 = 4,
	AWARD_REACH_LVL_15 = 5,
	AWARD_REACH_LVL_20 = 6,
	AWARD_FINISH_GAME = 7,
	AWARD_MISTERY = 8,
} AgonAwardId; 


@implementation AgonStuff

+(void) initAgon {
	//agon START	
	// Enable logging from inside of AGON.
	// NOTICE: Logging must be disabled in your distribution build.
#ifdef DEV_MODE
	AgonShowLogs(YES);
#endif
#ifndef DEV_MODE
	AgonShowLogs(NO);
#endif
	
	NSString* gameSecret = @"599785D34168CC35CC9E3BCA67C29B6FBDC14534"; // App secret that matches the DevDB environment.
	
	// Initialize AGON with application secret key. All other 
	// information is stored inside the AgonPackage.bundle.
	if(!AgonCreate(gameSecret, AGON_SERVER)) {
		NSLog(@"WARNING: Failed to initialize AGON - check log output from AGON in the console to see what the problem is.");
	}
	
	// Enable retain count asserts inside libagon. You should not enable this
	// if your game uses a custom event loop (e.g. using the new event loop
	// structure in current Unity beta release). This only has any effect in
	// debug builds, since asserts are not enabled in release builds.
	AgonEnableRetainCountAsserts(NO);
	
	//submit supported orientations
	UIInterfaceOrientation orientations[1];
	orientations[0] = UIDeviceOrientationLandscapeLeft;
	AgonSetSupportedInterfaceOrientations(orientations,1);

	UIColor *colStart = [UIColor colorWithRed:0.886f green:0.0f blue:0.478f alpha:0.9f];
	UIColor *colEnd = [UIColor colorWithRed:0.066f green:0.654f blue:0.769f alpha:0.9f];
	
	int i=arc4random()%8;
	if (i>4) {
		AgonSetStartBackgroundTint(colStart);	
		AgonSetEndBackgroundTint(colEnd);
	} else {
		AgonSetStartBackgroundTint(colEnd);	
		AgonSetEndBackgroundTint(colStart);
	}
	
	//agon END		
}


+(BOOL) doesUserProfileExists {
	NSString *user = AgonGetActiveProfileUserName();
	if (user == nil) {
		return NO;
	}
	return YES;
}

+(void) unlockAward:(int) id {
	if (!AgonIsAwardWithIdUnlocked(id)) {
		AgonUnlockAwardWithId(id);
		AwardUnlockMsg* msg = [[AwardUnlockMsg alloc] initWithId:id];
		[[NSNotificationCenter defaultCenter] postNotificationName:MSG_AWARD_UNLOCKED object:msg];
		[msg release];
	}	
}

+(void) checkForAwards{
	int lvl = [[GameController get] currentLevel]-1;
	int pnt = [[GameController get] scoreTotal];
	
	switch (lvl) {
		case 1:
			[self unlockAward:AWARD_JUST_PLAY];
			break;
		case 5-1:
			[self unlockAward:AWARD_REACH_LVL_5];
			break;
		case 10-1:
			[self unlockAward:AWARD_REACH_LVL_10];
			break;
		case 15-1:
			[self unlockAward:AWARD_REACH_LVL_15];
			break;
		case 20-1:
			[self unlockAward:AWARD_REACH_LVL_20];
			break;
		default:
			break;
	}

	if (pnt==123) {
		[self unlockAward:AWARD_COUNT_TO_THREE];
	} else
		if (pnt==111) {
			[self unlockAward:AWARD_MISTERY];
		}
	CCLOG(@"current level %i, points %i",lvl,pnt);
}

+(void) gameFinished {
	[self unlockAward:AWARD_FINISH_GAME];
}

/*+(void) submitFailedScore {
	int _theScore = [[GameController get] scoreTotal];
	NSString* s = [NSString stringWithFormat:@"%d", _theScore];

	AgonSubmitScore(_theScore, s, AGON_LEADERBOARD_FAILED_SCORE);
}*/

//returns true if a new highscore
+(BOOL) submitScore {
	int _theScore = [[GameController get] scoreTotal];
	NSString* s = [NSString stringWithFormat:@"%d", _theScore];
	NSString* bestScore_ = AgonGetActiveProfileBestDisplayScore(AGON_LEADERBOARD_ID);
	int bestScore = [bestScore_ intValue];
	CCLOG(@"best score: %i, current score: %@", bestScore, s);
	
	if (_theScore>0) {
		//is this call ok or only if current score > best score?
		// Submit to AGON's local storage which synchronizes with the
		// AGON backend when going online (when a blade is shown).
		AgonSubmitScore(_theScore, s, AGON_LEADERBOARD_ID);
		
		// Always submit to the latest scores leaderboard as well. The
		// latest score leaderboard is always updated regardless of the
		// score being the user's best.
		AgonSubmitScore(_theScore, s, AGON_LEADERBOARD_LATEST_SCORE);	
	}
	
	if (_theScore > bestScore) {		
		return YES;
	}
	
	return NO;
}


@end
