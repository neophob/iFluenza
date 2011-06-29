//
//  GameController.h
//  QuartzTest
//
//  Created by michael vogt on 13.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface GameController : NSObject {
	GameStatus		gameStatus;
	
	int				scoreTotal;
	int				scoreLevel;
	int				currentLevel;
	int				lvlNumberOfParticles;
	int				lvlNeededScore;
	float			lvlLifeTimeOfParticle;
	int				retries;
	bool			lvlRetry;
	
	bool			currentLevelX2;
	
	//0=NO, 1=RUNNING, 2=YES
	int				lvlShaked;
	int				loadCount;
	
	ccTime			timeLevel;
	ccTime			timeGame;
	
	TouchStatus     touchStatus;                                                                  
	CGPoint         touchPoint; 
}


@property (nonatomic,readwrite) GameStatus gameStatus;

@property (nonatomic,readwrite) int scoreTotal;
@property (nonatomic,readwrite) int scoreLevel;
@property (nonatomic,readwrite) int currentLevel;
@property (nonatomic,readwrite) int loadCount;
@property (nonatomic,readwrite) int lvlNumberOfParticles;
@property (nonatomic,readwrite) int lvlNeededScore;
@property (nonatomic,readwrite) float lvlLifeTimeOfParticle;
@property (nonatomic,readwrite) int retries;
@property (nonatomic,readwrite) bool lvlRetry;
@property (nonatomic,readwrite) int lvlShaked;

@property (nonatomic,readwrite) bool currentLevelX2;

@property (nonatomic,readwrite) TouchStatus touchStatus;                                                      
@property (nonatomic,readwrite) CGPoint touchPoint;

@property (nonatomic,readwrite) ccTime timeLevel;
@property (nonatomic,readwrite) ccTime timeGame;

-(float) getParticleTimeout;
-(int) getParticleHitrate: (int)lvlCount;
-(int) getParticleCount;
-(int) getRedOneCounter;

-(void) startLevel;
-(void) doNextLevel;

-(void) resetGame;

-(void) setTouchPoint: (CGPoint)touch touchType:(int)touchtype;

+(GameController *) get;
	
@end
