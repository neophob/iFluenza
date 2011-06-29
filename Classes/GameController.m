#import "GameController.h"
#import "Constants.h"
#import "ccMacros.h"
#import "cocos2d.h"

//used for timing
#import "QuartzCore/QuartzCore.h"

#define PARTICLE_CNT_START 8.0f
#define PARTICLE_CNT_END 25.0f

/* 
           8          3 rote, 5 andere
 */
#define POINT_PERCENT_START (100/PARTICLE_CNT_START)
#define POINT_PERCENT_END 75

#define LIFETIME_S_START 5.5f
#define LIFETIME_S_END 3.5f

#define RED_COUNT_AMMOUNT_START 2.0f
#define RED_COUNT_AMMOUNT_END 1.0f

@implementation GameController

@synthesize gameStatus;
@synthesize touchPoint,touchStatus, loadCount;
@synthesize scoreTotal, scoreLevel,lvlShaked;
@synthesize lvlNumberOfParticles, lvlNeededScore, lvlLifeTimeOfParticle;
@synthesize currentLevel, retries, currentLevelX2;
@synthesize timeLevel, timeGame, lvlRetry;

- (id) init {
	if( (self=[super init] )) {
		[self resetGame];
	}
	return self;
}

//calculate the red counters
-(int) getRedOneCounter {
	float f = RED_COUNT_AMMOUNT_START-((RED_COUNT_AMMOUNT_START-RED_COUNT_AMMOUNT_END)/MAX_LEVEL)*currentLevel;
	return (int)(0.5f+f*[self getParticleHitrate:[self getParticleCount]]);
}

//calculate particles lifetime for current level
-(float) getParticleTimeout {
	float f=currentLevel * ((LIFETIME_S_START-LIFETIME_S_END)/MAX_LEVEL);
	return LIFETIME_S_START-f;
}

//calculate particles hitrate for current level
-(int) getParticleHitrate: (int)lvlCount{
	float f = ((POINT_PERCENT_END-POINT_PERCENT_START)/MAX_LEVEL)*currentLevel;
	f+=POINT_PERCENT_START;
	f/=100;
	int r=(int)(f*(float)lvlCount);
	if (r<1) {
		r=1;
	}
	return r;
}

//calculate particles for current level
-(int) getParticleCount {
	float f=currentLevel * ((PARTICLE_CNT_END-PARTICLE_CNT_START)/MAX_LEVEL);
	return PARTICLE_CNT_START+f;
}

//reset game
-(void) resetGame {
#ifdef DEV_MODE
	for (int i=1; i<MAX_LEVEL+1; i++) {
		currentLevel = i;
		int cnt=[self getParticleCount];
		int hitrate=[self getParticleHitrate:cnt];
		float timeout=[self getParticleTimeout];
		int reds=[self getRedOneCounter];
		CCLOG(@"lvl:%i\tcnt:%i\thitrate:%i\ttimeout:%f\tredone:%i",i,cnt,hitrate,timeout,reds);
	}
#endif
	currentLevel = 1;

	//init level
	lvlNumberOfParticles = [self getParticleCount];
	lvlNeededScore = [self getParticleHitrate:lvlNumberOfParticles];
	//lvlNeededScore = [self getRedOneCounter];
	//time in seconds
	lvlLifeTimeOfParticle = [self getParticleTimeout];//lvlLifeTime[currentLevel-1];
	
	scoreTotal = 0;
	scoreLevel = 0;
	retries = 3;	
	lvlShaked = 0;

	timeLevel = 0;
	timeGame = 0;
	
	lvlRetry=NO;
	currentLevelX2 = NO;
}


//starts next level, inform view
-(void) startLevel {
	CCLOG(@"GameController:startLevel()");
	scoreLevel = 0;
	timeLevel = CACurrentMediaTime();
	gameStatus = kDisplayLevel;
	currentLevelX2 = false;

	//start next level delayed
	[[NSNotificationCenter defaultCenter] postNotificationName:MSG_GAME_NEXT_LEVEL object:nil];
}


-(void) setTouchPoint: (CGPoint)touch touchType:(int)touchtype {
	touchPoint = touch;
	touchStatus = touchtype;
}

- (void)dealloc {
    [super dealloc];
}

//level is done, check for next level/end of game/game over
- (void) doNextLevel {
	float usedTime = CACurrentMediaTime()-timeLevel;
	CCLOG(@"GameController:doNextLevel():level time: %f (%f/%f)", usedTime, timeLevel, CACurrentMediaTime());
	timeGame+=usedTime;
	lvlRetry=NO;
	lvlShaked=0;
	if (scoreLevel >= lvlNeededScore) {
		if (currentLevelX2) {
			scoreTotal+=scoreLevel*2;
		} else {
			scoreTotal+=scoreLevel;
		}
		
		if (currentLevel == 10 || currentLevel == 20) {
			scoreTotal+=GAME_10er_BONUS_POINTS;
		}
		
		//goal reached
		if (currentLevel >= MAX_LEVEL) {
			gameStatus = kFinished;
			//add game bonus
			scoreTotal += GAME_DONE_BONUS_POINTS;
			CCLOG(@"game finshed!");
			[[NSNotificationCenter defaultCenter] postNotificationName:MSG_GAME_FINISHED object:nil];
		} else {
			self.currentLevel++;
			lvlNumberOfParticles = [self getParticleCount];
			lvlNeededScore = [self getParticleHitrate:lvlNumberOfParticles];
			//lvlNeededScore = [self getRedOneCounter];
			lvlLifeTimeOfParticle = [self getParticleTimeout];
			//mark game status, waiting
			gameStatus = kWaitForNextLevel;
			CCLOG(@"GameController:doNextLevel():next level %i",currentLevel);
			//notify game that the level is done - used to check agon awards
			[[NSNotificationCenter defaultCenter] postNotificationName:MSG_GAME_LEVEL_DONE object:nil];
		}
	}
	else {
		//level failed
		if (retries > 1) {
			retries--;
			CCLOG(@"failed, retries: %i",retries);
			lvlRetry=true;
			//mark game status, waiting
			gameStatus = kWaitForNextLevel;
			[[NSNotificationCenter defaultCenter] postNotificationName:MSG_GAME_LEVEL_RETRY object:nil];
		} else {
			CCLOG(@"game over");
			retries = 0;
			scoreLevel = 0;
			gameStatus = kGameOver;
			[[NSNotificationCenter defaultCenter] postNotificationName:MSG_GAME_OVER object:nil];

		}
	}
}




//////

//singleton
+(GameController *) get {
    static GameController *instance;
	@synchronized(self) {
		if(!instance) {
			instance = [[GameController alloc] init];
		}
	}
	return instance;
}

@end


