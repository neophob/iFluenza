#import "cocos2d.h"
#import "GameController.h"
#import "SoundController.h"

@interface PlayScene : CCScene {
	int frame;
	int	neededPoints;
	BOOL gameIsPaused;
	BOOL isAgonEnabled;
	BOOL levelDone;
	BOOL updateBg;
	CCSprite *bg;
	CCSprite *gameLevelDone;
	CCSprite *hint;
	CCSprite *hintStarted;
	CCSprite	*bonusX2;
	
	CCSprite *levelImgGood;
	CCSprite *levelImgBad;
	
	CCSprite *highlightParticle;
	
	CCSprite *progressBar;
}

-(void) addMenu:(BOOL) isPaused;
-(void) gameOver:(NSNotification *)notification;
-(void) gameFinished:(NSNotification *)notification;
-(void) gameNextLevel:(NSNotification *)notification;
-(void) gameLevelDone:(NSNotification *)notification;
-(void) gameLevelRetry:(NSNotification *)notification;
-(void) nextLevel:(ccTime)dt;
-(void) exitScene;
-(void) updateHud;
@end
