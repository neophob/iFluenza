
#import "MainMenuScene.h"
#import "cocos2d.h"

#import "PlayScene.h"
#import "AboutScene.h"
#import "HelpScene.h"

#import "Constants.h"
#import "ccMacros.h"
#import "SoundController.h"

#import "AGON.h"
#import "AgonStuff.h"

#define zOrderMenu 11
#define zOrderBackground -10
#define zOrderParticle 10

#define kTagAlertBoxHint 100

@implementation MainMenuScene

@synthesize emitter;

- (id) init
{
	CCLOG(@"init");
    self = [super init];
    if (self != nil) {
		CCMenuItem *menuItem1 = [CCMenuItemImage itemFromNormalImage:@"play.png" selectedImage:@"play-on.png" target:self selector:@selector(onPlay:)];
		CCMenuItem *menuItem2 = [CCMenuItemImage itemFromNormalImage:@"help.png" selectedImage:@"help-on.png" target:self selector:@selector(onHelp:)];
		CCMenuItem *menuItem3 = [CCMenuItemImage itemFromNormalImage:@"highscore.png" selectedImage:@"highscore-on.png" target:self selector:@selector(onHighscore:)];
		CCMenuItem *menuItem4 = [CCMenuItemImage itemFromNormalImage:@"about.png" selectedImage:@"about-on.png" target:self selector:@selector(onAbout:)];

		CCMenu *menu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, menuItem4, nil];
		//+ (id) menuWithItems: (MenuItem*) item, ... NS_REQUIRES_NIL_TERMINATION;

		CGSize s = [[CCDirector sharedDirector] winSize];
		menu.position = CGPointZero;
#define STARTY 50
#define MENU_Y_STEP 48
#define STARTX 130
		menuItem4.position = ccp( s.width-STARTX, STARTY +3*MENU_Y_STEP);		
		menuItem1.position = ccp( s.width-STARTX, STARTY +2*MENU_Y_STEP);
		menuItem2.position = ccp( s.width-STARTX, STARTY +MENU_Y_STEP);
		menuItem3.position = ccp( s.width-STARTX, STARTY);
		
		//menu should be infront
		[self addChild:menu z:zOrderMenu];	
		
//		[[SoundController get] playMenuMusic];
		
		CCSprite *sprite = [CCSprite spriteWithFile:menuBackgroundImg];
		sprite.anchorPoint = CGPointZero;
		[self addChild:sprite z:zOrderBackground];		
		
		self.emitter = [[CCPointParticleSystem alloc] initWithTotalParticles:1000];
		[self addChild: emitter z:zOrderParticle];
		[emitter release];
				
		// duration
		emitter.duration = -1;
		
		// gravity
		emitter.gravity = ccp(0,0);
		
		// angle
		emitter.angle = 0;
		emitter.angleVar = 360;
		
		// radial
		emitter.radialAccel = 45;
		emitter.radialAccelVar = 10;
		
		// tagential
		emitter.tangentialAccel = -90;
		emitter.tangentialAccelVar = 0;
		
		// speed of particles
		emitter.speed = 50;
		emitter.speedVar = 10;
		
		// emitter position
		emitter.position = ccp( s.width/2, s.height/2);
		emitter.posVar = CGPointZero;
		
		// life of particles
		emitter.life = 2.5f;
		emitter.lifeVar = 0.4f;
		
		// emits per frame
		emitter.emissionRate = emitter.totalParticles/emitter.life;
#define col 0.01f
		// color of particles
		ccColor4F startColor = {col, col, col, col};
		emitter.startColor = startColor;
		ccColor4F startColorVar = {0.0f, 0.0f, 0.0f, 0.01f};
		emitter.startColorVar = startColorVar;
		ccColor4F endColor = {col, col, col, col};
		emitter.endColor = endColor;
		ccColor4F endColorVar = {0.0f, 0.0f, 0.0f, 0.01f};	
		emitter.endColorVar = endColorVar;
		
		// size, in pixels
		emitter.startSize = 8.0f;
		emitter.startSizeVar = 4.0f;
		emitter.endSize = 32.0f;
		emitter.endSizeVar = 8.0f;
		
		// additive
		emitter.blendAdditive = NO;
		
		emitter.position = ccp(220, 130);
		emitter.posVar = ccp(20, 20);
		
		//check if the user has to view the help
		int cnt=[[GameController get] loadCount];
		CCLOG(@"started %i times...",cnt);
		if (cnt<3) {
			CCLOG(@"display help!");
			doDisplayHelp = YES;
			//[self schedule:@selector(onHelp:) interval:0.3f];
		}
		
	}
	return self;
}	

- (void)onAbout:(id)sender {
	[[SoundController get] playFx:SND_ID_CLICK];
	
	CCLOG(@"MainMenuScene on about");
	[emitter stopSystem];
	[[CCDirector sharedDirector] pushScene:[CCSlideInTTransition transitionWithDuration:1.0 scene:[AboutScene node]]];
	
}

//used to parse touches from the UIAlertView (message box)
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag==kTagAlertBoxHint) {
		CCLOG(@"do play");
		[[CCDirector sharedDirector] replaceScene:[CCSlideInLTransition transitionWithDuration:1.0 scene:[PlayScene node]]];
	}
}


//nice transitions: FlipYTransition, FlipAngularTransition
- (void)onPlay:(id)sender
{
    CCLOG(@"MainMenuScene on play");
	[[SoundController get] playFx:SND_ID_CLICK];
	emitter.endSize = 0.0f;
	emitter.endSizeVar = .0f;
	[emitter resetSystem];
	if (doDisplayHelp) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: 
							  @"Hint" 
														message:HINT_DISPLAY_HELP
													   delegate:self
											  cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil]; 	
		[alert setTag:kTagAlertBoxHint];
		[alert show]; 
		[alert release]; 
	} else {
		CCLOG(@"do play");
		[[CCDirector sharedDirector] replaceScene:[CCSlideInLTransition transitionWithDuration:1.0 scene:[PlayScene node]]];
	}
}

- (void)onHelp:(id)sender
{
    CCLOG(@"MainMenuScene on help");
	[[SoundController get] playFx:SND_ID_CLICK];
	[emitter stopSystem];
	doDisplayHelp = NO;
	[[CCDirector sharedDirector] pushScene:[CCSlideInRTransition transitionWithDuration:1.0 scene:[HelpScene node]]];
}

- (void)onHighscore:(id)sender
{
    CCLOG(@"MainMenuScene on highscore");
	[[SoundController get] playFx:SND_ID_CLICK];
	//stop emiter while highscore is displayed
	[emitter stopSystem];
	// Show the leaderboard corresponding to the current difficulty.
	AgonShowLeaderboard(AGON_LEADERBOARD_ID, YES);
	//AgonShowLeaderboard(self, @selector(agonDidHide), AGON_LEADERBOARD_ID, YES);
}

// The AGON view has been hidden
- (void)agonDidHide {
	CCLOG(@"agon did hide");
	if (![AgonStuff doesUserProfileExists]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: 
							  @"Warning" 
											  message:WARNING_NO_AGON_USER
											 delegate:nil
									cancelButtonTitle:@"Ok" 
									otherButtonTitles:nil]; 	
		[alert show]; 
		[alert release]; 
		
	}
	[emitter resetSystem];

}

+ (void)goToMainMenu {
	CCLOG(@"goto main menu");
	[[SoundController get] playFx:SND_ID_CLICK];
	[[CCDirector sharedDirector] replaceScene:[CCSlideInRTransition transitionWithDuration:1.0 scene:[MainMenuScene node]]];
}


-(void) onEnter {
	[super onEnter];
	[emitter resetSystem];
	CCLOG(@"MainMenuScene on enter");
	if (![AgonStuff doesUserProfileExists]) {
		CCLOG(@"MainMenuScene on enter: user profile does NOT exist, display picker");
		AgonShowProfilePicker(self, @selector(agonDidHide), NO);
	} else {
		CCLOG(@"MainMenuScene on enter: user profile does exists");
	}	
}

-(void) exitScene {
	CCLOG(@"MainMenuScene exit scene");
	[super onExit];
}

- (void) dealloc {
	CCLOG(@"MainMenuScene dealloc");
	[emitter release];
	[super dealloc];
}


@end

