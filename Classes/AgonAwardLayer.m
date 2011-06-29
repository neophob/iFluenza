
#import "AgonAwardLayer.h"
#import "ObserverMessages.h"
#import "Constants.h"

enum {
	kTagAwardImage = 1,
};

@implementation AgonAwardLayer

-(id) init {
	CCLOG(@"AgonAwardLayer: init...");
	if( (self=[super initWithColor:ccc4(0,0,0,0)] )) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(awardUnlocked:) 
													 name:MSG_AWARD_UNLOCKED
												   object:nil];
	}
	return self;
}


-(void) awardUnlocked:(NSNotification *)notification {
	//AwardUnlockMsg *msg = [notification object];
	//CCLOG(@"awardUnlocked: %i", [msg awardId]);
	//display the current level delayed
	[self schedule:@selector(displayAward) interval:DISPLAY_DELAY*4];
}


-(void) displayAward {
	[self unschedule:@selector(displayAward)];
	CCLOG(@"display AWARD");
	
	//Sprite *child = [Sprite spriteWithFile:agonAwardImg];
	CCSprite *child = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage: agonAwardImg]];
	[child setPosition:ccp((YSIZE)/2, (XSIZE)/2)];
	[child setOpacity:0];
	[child.texture setAntiAliasTexParameters];

	[self addChild:child z:1 tag:kTagAwardImage];
	
#define duration 1.6f
	id fade = [CCSequence actions:
			   [CCFadeIn  actionWithDuration:0.7f],
			   [CCDelayTime actionWithDuration:0.2f],
			   [CCFadeOut actionWithDuration:0.7f],			   
				 nil];
	id scale = [CCSequence actions:
				 [CCScaleTo actionWithDuration:duration/4 scale:0.4f],
				 [CCScaleTo actionWithDuration:duration/4 scale:1.0f],
				 [CCScaleTo actionWithDuration:duration/2 scale:4.0f],
				 nil];

	[child runAction:[CCSequence actions:
					  [CCSpawn actions:
						fade,
					    scale,
					    [CCRotateBy actionWithDuration:duration angle:40],
						nil],
					  [CCCallFunc actionWithTarget:self selector:@selector(finish)],
					  nil]];
}

-(void) finish {
	CCLOG(@"REMOOOOVE");
	[self removeChildByTag:kTagAwardImage cleanup:NO];
}

- (void) dealloc {
	CCLOG(@"AgonAwardLayer: dealloc");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
