
#import "PlayScene.h"
#import "cocos2d.h"
#import "MainMenuScene.h"

#import "MyParticleLayer.h"
#import "GameTouchLayer.h"
#import "ExplosionLayer.h"
#import "AgonAwardLayer.h"
//#import "BonusLevelBigOne.h"

#import "Constants.h"
#import "ccMacros.h"

#import "ObserverMessages.h"

#import "AgonStuff.h"

#define kTagParticleLayer 10
#define kTagExplosionLayer 11
#define kTagAgonLayer 12
#define kTagBigOneLayer 13
#define kTagBackgroundImage 15
#define kTagTouchLayer 20

#define kTagHudMenu 30

#define kTagAlertBoxMainMenu 100
#define kTagAlertBoxGameOver 101
#define kTagAlertBoxGameFinished 102
#define kTagAlertHighscore 103

#define backgroundImages 3
static NSString *backgroundImage[] = {
	@"bg-1.png",
	@"bg-2.png",
	@"bg-3.png",
	nil
};

enum {
	kTagLabelAtlas = 1,
	kTagLabelLevel = 2,
	kTagLabelRetries = 3,
	kTagLabelScore = 4,
	kTagLabelPoints = 5,
	kTagLayerParticle = 6,
	kTagLabelBonus = 7,
	kTagSpriteManager = 8,
};


@implementation PlayScene

- (id) init {
    self = [super init];
    if (self != nil) {
		CCLOG(@"PlayScene init");
		
		//add spite manager
		//AtlasSpriteManager *mgr = [AtlasSpriteManager spriteManagerWithFile:@"gameResources.png" capacity:10];
		CCSpriteSheet *mgr = [CCSpriteSheet spriteSheetWithFile:@"gameResources.png" capacity:10];
		[self addChild:mgr z:10 tag:kTagSpriteManager];
		
		//add background image
		int idx = random()%backgroundImages;                                                                                                   
		bg = [CCSprite spriteWithFile:backgroundImage[idx]];                                                                                     
		bg.anchorPoint = CGPointZero;                                                                                                          
		[self addChild:bg z:-10 tag:kTagBackgroundImage];                                                                                      
		
		//add hud image
//		CCSprite *sprite = [CCSprite spriteWithRect:CGRectMake(1,372,480,33) spriteManager: mgr];
		CCSprite *sprite = [CCSprite spriteWithSpriteSheet:mgr rect:CGRectMake(1,372,480,33) ];
		sprite.anchorPoint = CGPointZero;
		[sprite setPosition: ccp(0, 0)];
		[mgr addChild:sprite z:0];
		
		levelImgGood = [CCSprite spriteWithSpriteSheet:mgr rect:CGRectMake(1,170,349,176) ];
//		levelImgGood = [CCSprite spriteWithRect:CGRectMake(1,170,349,176) spriteManager: mgr];
		[levelImgGood setPosition: ccp((YSIZE)/2, (XSIZE)/2)];
		[levelImgGood setOpacity:0];
		[mgr addChild:levelImgGood z:249];

		levelImgBad = [CCSprite spriteWithSpriteSheet:mgr rect:CGRectMake(43,0,333,169) ];
//		levelImgBad = [CCSprite spriteWithRect:CGRectMake(43,0,333,169) spriteManager: mgr];
		[levelImgBad setPosition: ccp((YSIZE)/2, (XSIZE)/2)];
		[levelImgBad setOpacity:0];
		[mgr addChild:levelImgBad z:249];

		gameLevelDone = [CCSprite spriteWithSpriteSheet:mgr rect:CGRectMake(351,170,115,103)];
//		gameLevelDone = [CCSprite spriteWithRect:CGRectMake(351,170,115,103) spriteManager: mgr];
		gameLevelDone.anchorPoint = CGPointZero;
		[gameLevelDone setPosition: ccp(240-64, 160-64+16)];
		[gameLevelDone setOpacity:0];
		[mgr addChild:gameLevelDone z:100];

		//bonus display
		bonusX2 = [CCSprite spriteWithSpriteSheet:mgr rect:CGRectMake(1,1,41,18)];
//		bonusX2 = [AtlasSprite spriteWithRect:CGRectMake(1,1,41,18) spriteManager: mgr];
		bonusX2.anchorPoint = CGPointZero;
		[bonusX2 setPosition: ccp(4, 34)];
		[bonusX2 setOpacity:0];
		[mgr addChild:bonusX2 z:100];		
		
		//circle.png
		highlightParticle = [CCSprite spriteWithSpriteSheet:mgr rect:CGRectMake(377,1,96,94)];
		highlightParticle.anchorPoint = CGPointZero;
		[highlightParticle setOpacity:0];
		[mgr addChild:highlightParticle z:100];		
		
		
		hint = [CCSprite spriteWithSpriteSheet:mgr rect:CGRectMake(1,407,256,31)];
		hint.anchorPoint = CGPointZero;
		[hint setPosition: ccp(224-4, 34+2)];
		[hint setOpacity:0];
		[mgr addChild:hint z:0];

		progressBar = [CCSprite spriteWithSpriteSheet:mgr rect:CGRectMake(0,480,512,29)];
		progressBar.anchorPoint = CGPointZero;
		[progressBar setPosition: ccp(0,00)];
		[progressBar setOpacity:64];
		[progressBar setScaleX:0.0f];
		[mgr addChild:progressBar z:20];
		
		hintStarted = [CCSprite spriteWithSpriteSheet:mgr rect:CGRectMake(2,348,218,10)];
		hintStarted.anchorPoint = CGPointZero;
		[hintStarted setPosition: ccp(262-4, 34+2)];
		[hintStarted setOpacity:0];
		[mgr addChild:hintStarted z:0];
		
		//hud elements
		CCLabelAtlas *labelLevel = [CCLabelAtlas labelAtlasWithString:@"" charMapFile:GAME_BITMAP_FONT itemWidth:GAME_BITMAP_FONT_X itemHeight:GAME_BITMAP_FONT_Y startCharMap:'.' ];
		[self addChild:labelLevel z:10 tag:kTagLabelLevel];
		labelLevel.position = ccp(45,5);
		
		CCLabelAtlas *labelRetries = [CCLabelAtlas labelAtlasWithString:@"" charMapFile:GAME_BITMAP_FONT itemWidth:GAME_BITMAP_FONT_X itemHeight:GAME_BITMAP_FONT_Y startCharMap:'.' ];
		[self addChild:labelRetries z:10 tag:kTagLabelRetries];
		labelRetries.position = ccp(445,5);
		
		CCLabelAtlas *labelScore = [CCLabelAtlas labelAtlasWithString:@"" charMapFile:GAME_BITMAP_FONT itemWidth:GAME_BITMAP_FONT_X itemHeight:GAME_BITMAP_FONT_Y startCharMap:'.' ];
		[self addChild:labelScore z:10 tag:kTagLabelScore];
		labelScore.position = ccp(297,5);
		
		CCLabelAtlas *labelPoints = [CCLabelAtlas labelAtlasWithString:@"" charMapFile:GAME_BITMAP_FONT itemWidth:GAME_BITMAP_FONT_X itemHeight:GAME_BITMAP_FONT_Y startCharMap:'.' ];
		[self addChild:labelPoints z:10 tag:kTagLabelPoints];
		labelPoints.position = ccp(150,5);
		
		//add touch layer
		[self addChild:[GameTouchLayer node] z:0 tag:kTagTouchLayer];
		
		//add layer which displays the blownup fx
		[self addChild:[ExplosionLayer node] z:20 tag:kTagExplosionLayer];

		//add layer which displays the blownup fx
		//[self addChild:[BonusLevelBigOne node] z:220 tag:kTagBigOneLayer];

		//add award layer if a agon profile is selected
		isAgonEnabled = [AgonStuff doesUserProfileExists];
		if (isAgonEnabled) { 
			[self addChild:[AgonAwardLayer node] z:50 tag:kTagAgonLayer];			
		}

		//display the current level delayed
		[self schedule:@selector(initialDisplayCurrentLevel:) interval:DISPLAY_DELAY];
		[self schedule:@selector(checkLevelDone) interval:0.3f];
		
		//update the hud 5 times/second
		neededPoints = [[GameController get] lvlNeededScore];
		[self schedule:@selector(step:) interval:0.2f];		
		
		[self addMenu:NO];

		gameIsPaused=NO;
		levelDone = NO;
		updateBg = NO;

		//set up listener (observer pattern)
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(gameOver:) 
													 name:MSG_GAME_OVER 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(gameFinished:) 
													 name:MSG_GAME_FINISHED
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(gameNextLevel:) 
													 name:MSG_GAME_NEXT_LEVEL
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(gameLevelDone:) 
													 name:MSG_GAME_LEVEL_DONE
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(gameLevelRetry:) 
													 name:MSG_GAME_LEVEL_RETRY
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(stopBlink) 
													 name:MSG_PARTICLE_BLOWN_UP
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(drawBonusX2:) 
													 name:MSG_POWERUP_X2
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(drawParticleHighlight:) 
													 name:MSG_PARTICLE_HIGHLIGHT
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(drawParticleHighlightClear:) 
													 name:MSG_PARTICLE_HIGHLIGHT_CLEAR
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(chainReactionStarted:) 
													 name:MSG_GAME_CHAIN_REACTION_STARTED
												   object:nil];
		
		[[SoundController get] playGameMusic];
		
		[self updateHud];
		
		[[GameController get] resetGame];
		frame=0;
    }
    return self;
}

-(void) stopBlink {
	CCLOG(@"stop blink");
	[hint setOpacity:0];
}

-(void) stopBlinkChainReaction {
	CCLOG(@"stop blink");
	[hintStarted setOpacity:0];
}


-(void) drawBonusX2:(NSNotification *)notification {
	CCLOG(@"______MyParticleLayer:drawBonusX2");
	[bonusX2 setOpacity:255];
}


-(void) drawParticleHighlight:(NSNotification *)notification {
	ParticleMessage *msg = [notification object];
	[highlightParticle setPosition: ccp(msg.pos.x-48, msg.pos.y-47)];
	[highlightParticle setOpacity:200];
}

-(void) drawParticleHighlightClear:(NSNotification *)notification {
	//CCLOG(@"clear CIRCLE");
	[highlightParticle setOpacity:0];
}


-(void) updateHud {                                                                                                                                    
	//update hud - this is only needed once per level                                                                                              
	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:kTagLabelLevel];                                                                         
	NSString *str = [NSString stringWithFormat:@"%i", [[GameController get] currentLevel]];                                                        
	[atlas setString:str];                                                                                                                         
	
	atlas = (CCLabelAtlas*) [self getChildByTag:kTagLabelScore];                                                                                     
	str = [NSString stringWithFormat:@"%i", [[GameController get] scoreTotal]];                                                                    
	[atlas setString:str];                                                                                                                         
}           


#ifdef DEV_MODE
- (void)cheat:(id)sender {
	[[GameController get] setScoreLevel:50];
	[[GameController get] doNextLevel];
}
#endif

- (void)addMenu:(BOOL) isPaused {
	//register "pause menu" and "goto mainmenu" items
	CGSize s = [[CCDirector sharedDirector] winSize];

	CCMenuItem *menuItem1;
	CCMenuItem *menuItem2 = [CCMenuItemImage itemFromNormalImage:@"home.png" selectedImage:@"home.png" target:self selector:@selector(gotoMain:)];
	
	if (!isPaused) {
		menuItem1 = [CCMenuItemImage itemFromNormalImage:@"icopause.png" selectedImage:@"icopause.png" target:self selector:@selector(doPause:)];
	} else {
		menuItem1 = [CCMenuItemImage itemFromNormalImage:@"icoplay.png" selectedImage:@"icoplay.png" target:self selector:@selector(doPause:)];
	}
	
#ifdef DEV_MODE
	MenuItem *menuItem3 = [MenuItemImage itemFromNormalImage:@"home.png" selectedImage:@"home.png" target:self selector:@selector(cheat:)];
	menuItem3.position = ccp( s.width/2,s.height-32);		
	Menu *menu = [Menu menuWithItems:menuItem1, menuItem2, menuItem3, nil];
#endif
	
#ifndef DEV_MODE
	CCMenu *menu = [CCMenu menuWithItems:menuItem1, menuItem2, nil];
#endif
	
	menu.position = CGPointZero;
	menuItem1.position = ccp( 32, s.height-32);
	menuItem2.position = ccp( s.width-32,s.height-32);		
	[self addChild:menu z:zOrderHud tag:kTagHudMenu];		
}

//user clicks on goto main screen 
- (void)gotoMain:(id)sender {
    CCLOG(@"goto main");
	if (gameIsPaused)
		return;
	
	//pause if we display a alert view
	[[CCDirector sharedDirector] pause];	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Quit Game" 
                                                    message:@"Are you sure you want to quit the current game?"
                                                   delegate:self
                                          cancelButtonTitle:@"Yes" 
                                          otherButtonTitles:@"No way!",nil];
	[alert setTag:kTagAlertBoxMainMenu];
    [alert show]; 
    [alert release]; 
}

//used to parse touches from the UIAlertView (message box)
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag==kTagAlertBoxMainMenu) {
		[[CCDirector sharedDirector] resume];
		if (buttonIndex==0) {
			//go home...
			[self exitScene];
		} else {
			[[SoundController get] playFx:SND_ID_CLICK];
		}
	} else
		if (alertView.tag==kTagAlertBoxGameOver) {
			//if game over
			if (buttonIndex==1) {
				[[SoundController get] playFx:SND_ID_CLICK];
				[[GameController get] resetGame];
				[[GameController get] startLevel];
			} else {
				//go back to main menu
				[self exitScene];
			}
		} else
			if (alertView.tag==kTagAlertBoxGameFinished) {
				//if game over
				if (buttonIndex==1) {
					[[SoundController get] playFx:SND_ID_CLICK];
					[[GameController get] resetGame];
					[[GameController get] startLevel];
				} else {
					//show highscore
					[[SoundController get] playFx:SND_ID_CLICK];
					[self schedule:@selector(showAgonDelayed) interval:0.5f];
				}		
			} else
				if (alertView.tag==kTagAlertHighscore) {
					//if game over
					if (buttonIndex==0) {
						[[SoundController get] playFx:SND_ID_CLICK];
						[[GameController get] resetGame];
						[[GameController get] startLevel];
					} else {
						//go back to main menu
						[self exitScene];
					}		
				}
}

//called after highscore view
- (void) agonDidHide {
	[[CCDirector sharedDirector] resume];

	CCLOG(@"agonDidHide");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: 
															@"What's next?" 
                                                    message:@"Restart game or go to main menu?"
                                                   delegate:self
                                          cancelButtonTitle:@"Restart" 
                                          otherButtonTitles:@"Menu",nil];
	[alert setTag:kTagAlertHighscore];
    [alert show]; 
    [alert release]; 	
}

//user clicks on pause 
- (void)doPause:(id)sender {
    CCLOG(@"do pause");
	if (gameIsPaused) {
		[[CCDirector sharedDirector] resume];
		[[SoundController get] resumeGameMusic];
		[self removeChildByTag:kTagHudMenu cleanup:YES];
		[self addMenu:NO];
		gameIsPaused=NO;
#ifdef DEV_MODE		
		AwardUnlockMsg* msg = [[AwardUnlockMsg alloc] initWithId:0];
		[[NSNotificationCenter defaultCenter] postNotificationName:MSG_AWARD_UNLOCKED object:msg];
		[msg release];
#endif
		//clear touch 
		[[GameController get] setTouchStatus:kTouchNone];
	} else {
		[self removeChildByTag:kTagHudMenu cleanup:NO];
		[self addMenu:YES];
		[[SoundController get] pauseGameMusic];
		[[CCDirector sharedDirector] pause];

		gameIsPaused=YES;
	}
}

//observer method, if game is over
-(void) gameOver:(NSNotification *)notification {
	CCLOG(@"PlayScene, gameOver");
	[AgonStuff submitScore];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Game Over..." 
                                                    message:@"Do you want to restart the game or back to the main menu?"
                                                   delegate:self
                                          cancelButtonTitle:@"Menu" 
                                          otherButtonTitles:@"Restart",@"Highscore",nil]; 
    [alert show]; 
	[alert setTag:kTagAlertBoxGameOver];
    [alert release]; 	
}

//observer method, if game is finished
-(void) gameFinished:(NSNotification *)notification {
	[AgonStuff submitScore];
	[AgonStuff gameFinished];
	
	//TODO: add sexy particle system
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"You did it!" 
                                                    message:@"Do you want to restart the game or display the highscrore?"
                                                   delegate:self
                                          cancelButtonTitle:@"Highscore" 
                                          otherButtonTitles:@"Restart",nil]; 
    [alert show]; 
	[alert setTag:kTagAlertBoxGameFinished];
    [alert release]; 	
}

//level done, check for awards
-(void) gameLevelDone:(NSNotification *)notification {
	CCLOG(@"PlayScene:gameLevelDone():check awards");
	[AgonStuff checkForAwards];
	[self schedule:@selector(nextLevel:) interval:DISPLAY_DELAY];
}

//level goal failed, retry
-(void) gameLevelRetry:(NSNotification *)notification {
	CCLOG(@"PlayScene:gameLevelRetry():retry level");
	[self schedule:@selector(nextLevel:) interval:DISPLAY_DELAY];
}


-(void) chainReactionStarted:(NSNotification *)notification {
	CCLOG(@"PlayScene:chainReactionStarted()");
	[bonusX2 setOpacity:0];	
	[hintStarted runAction:[CCSequence actions:						 
							[CCFadeIn  actionWithDuration:0.0f],
							[CCBlink actionWithDuration:12.0f blinks:24],
							[CCCallFunc actionWithTarget:self selector:@selector(stopBlinkChainReaction)],
							nil
							]];	
}


-(void) nextLevel:(ccTime)dt {
	[self unschedule:@selector(nextLevel:)];
	CCLOG(@"PlayScene:nextLevel():start next level delayed");
	[[GameController get] startLevel];	
}

//check each second if level is done; if so display an animation
-(void) checkLevelDone {
	int currentScore = [[GameController get] scoreLevel];                                                                                                                                     
	int neededScore = [[GameController get] lvlNeededScore];
	float f=(float)currentScore/neededScore;
	if (f>1.0) f=1.0f;
//	CCLOG(@"process: %f",f);
	[progressBar setScaleX:f];
	
	if (!levelDone && currentScore >= neededScore) {
		[gameLevelDone setPosition:ccp(240-64+16, 320)];
		id move = [CCMoveBy actionWithDuration:1.5f position:ccp(0, -200)];
		id move2 = [CCMoveBy actionWithDuration:1.5f position:ccp(0, -300)];
		
		id fadeIn = [CCSequence actions:
					 [CCFadeIn  actionWithDuration:0.75f],
					 [CCDelayTime actionWithDuration:1.5f],
					 [CCFadeOut actionWithDuration:0.75f],
					 nil];
		id fadeOut = [CCSequence actions:
					  [CCEaseElasticInOut actionWithAction:[[move copy] autorelease] period:0.45f],
					  [CCEaseElasticInOut actionWithAction:[[move2 copy] autorelease] period:0.45f],
					  nil];
		
		[gameLevelDone runAction:[CCSequence actions:
						  [CCSpawn actions:
						   fadeIn,
						   fadeOut,
						   nil],
						  nil]];
				
		levelDone = YES;                                                                                                                                                                  
	}                   
}

//removes the current level tag and starts the game
- (void)startLevel {
	CCLOG(@"PlayScene:startLevel");
	[[GameController get] setGameStatus:kWaitOnInitialClick];
	//clear touch 
	[[GameController get] setTouchStatus:kTouchNone];
}


//observer method, if new level starts
-(void) gameNextLevel:(NSNotification *)notification {
	CCLOG(@"PlayScene:gameNextLevel");
	
	neededPoints = [[GameController get] lvlNeededScore];

	bool retryLevel = [[GameController get] lvlRetry];
	if (retryLevel) {
		CCLOG(@"__RETRY LEVEL");
		[levelImgBad runAction:[CCSequence actions:						 
						 [CCFadeIn actionWithDuration:0.25f],	 
						 [CCDelayTime actionWithDuration:DISPLAY_DELAY],
						 [CCFadeOut  actionWithDuration:0.25f],
						 [CCCallFunc actionWithTarget:self selector:@selector(startLevel)],
						 nil
						 ]];		
	} else {
		[levelImgGood runAction:[CCSequence actions:						 
								[CCFadeIn actionWithDuration:0.25f],	 
								[CCDelayTime actionWithDuration:DISPLAY_DELAY],
								[CCFadeOut  actionWithDuration:0.25f],
								[CCCallFunc actionWithTarget:self selector:@selector(startLevel)],
								nil
								]];
		
	}
	
	levelDone=NO;
	[gameLevelDone setOpacity:0];
	[bonusX2 setOpacity:0];	
	[hintStarted setOpacity:0];

	if ([[GameController get] currentLevel]<5) {
		[hint runAction:[CCSequence actions:	
						 [CCDelayTime actionWithDuration:1.1f],
						 [CCFadeIn  actionWithDuration:0.0f],
						 [CCBlink actionWithDuration:12.0f blinks:24],
						 [CCCallFunc actionWithTarget:self selector:@selector(stopBlink)],
						 nil
						 ]];		
	}	
	
	
	//do not update the bg image the first time
	if (updateBg) {
		[self removeChild:bg cleanup:YES];                                                                                                             
        int idx = random()%backgroundImages;                                                                                                           
        bg = [CCSprite spriteWithFile:backgroundImage[idx]];                                                                                             
        bg.anchorPoint = CGPointZero;                                                                                                                  
		[self addChild:bg z:-10 tag:kTagBackgroundImage];        
	}
	updateBg = YES;
	
	//update hud - this is only needed once per level
	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:kTagLabelLevel];
	NSString *str = [NSString stringWithFormat:@"%i", [[GameController get] currentLevel]];
	[atlas setString:str];
	
	atlas = (CCLabelAtlas*) [self getChildByTag:kTagLabelScore];
	str = [NSString stringWithFormat:@"%i", [[GameController get] scoreTotal]];
	[atlas setString:str];	
}

-(void) step:(ccTime) dt
{
	//update hud 
	//display particle count
	CCLabelAtlas *atlas;
	NSString *str;
	
	atlas = (CCLabelAtlas*) [self getChildByTag:kTagLabelPoints];
	str = [NSString stringWithFormat:@"%i/%i", [[GameController get] scoreLevel], neededPoints];
	[atlas setString:str];
	
	atlas = (CCLabelAtlas*) [self getChildByTag:kTagLabelRetries];
	str = [NSString stringWithFormat:@"%i", [[GameController get] retries]];
	[atlas setString:str];
}


//used to delay the start of the first level
-(void) initialDisplayCurrentLevel:(ccTime)dt {
	[self unschedule:@selector(initialDisplayCurrentLevel:)];
	CCLOG(@"add initial particle");
	[[GameController get] startLevel];
	[self addChild:[MyParticleLayer node] z:0 tag:kTagParticleLayer];
}

//this method is used to display agon. showing agon directly in a UIAlertView is a bad idea!
- (void)showAgonDelayed {
	CCLOG(@"showAgonDelayed!" );
	[self unschedule:@selector(showAgonDelayed)];
	//make sure the director is NOT paused
	//[[Director sharedDirector] resume];	
	AgonShowLeaderboard(/*self, @selector(agonDidHide), */AGON_LEADERBOARD_ID, YES);
}

//this call is executed before we leave this scene - need to unschedule the
//scheduled times manually or the dealloc function will NOT be called
-(void) exitScene {
	CCLOG(@"PlayScene exit scene");
	[[SoundController get] stopGameMusic];
	[[CCDirector sharedDirector] resume];
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[[SoundController get] playFx:SND_ID_CLICK];
	[[CCDirector sharedDirector] replaceScene:[CCSlideInRTransition transitionWithDuration:1.0 scene:[MainMenuScene node]]];
}

- (void)dealloc {
	CCLOG(@"PlayScene: dealloc");
/*	[self removeChildByTag:kTagExplosionLayer cleanup:YES];	
	[self removeChildByTag:kTagParticleLayer cleanup:YES];	
	[self removeChildByTag:kTagTouchLayer cleanup:YES];	
	[self removeChildByTag:kTagBigOneLayer cleanup:YES];
	[self removeChild:hint cleanup:YES];
	[self removeChild:hintStarted cleanup:YES];
	[self removeChild:levelImgGood cleanup:YES];
	[self removeChild:levelImgBad cleanup:YES];
	[self removeChild:gameLevelDone cleanup:YES];
	[self removeChild:bonusX2 cleanup:YES];
	[self removeChild:highlightParticle cleanup:YES];
	[self removeChild:progressBar cleanup:YES];
	if (isAgonEnabled) {
		[self removeChildByTag:kTagAgonLayer cleanup:YES];		
	}*/
	
	[self removeAllChildrenWithCleanup:YES];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];	
	
	[super dealloc];
}


@end
