
#import "BonusLevelBigOne.h"
#import "GameController.h"

enum {
	kTagSprite = 1,
};

@implementation BonusLevelBigOne


- (id) init {
	CCLOG(@"BonusLevelBigOne init");
	if( (self=[super initWithColor:ccc4(0,0,0,0)] )) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(gameNextLevel:) 
													 name:MSG_GAME_NEXT_LEVEL
												   object:nil];
		self.isAccelerometerEnabled=NO;
    }
    return self;
}		

/*
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	CocosNode *sprite = [self getChildByTag:kTagSprite];
	
	// Convert the coordinates to 'landscape' coords
	// since they are always in 'portrait' coordinates
	CGPoint converted = ccp( (float)-acceleration.y, (float)acceleration.x);	
	
	// update the rotation based on the z-rotation
	// the sprite will always be 'standing up'
	sprite.rotation = (float) CC_RADIANS_TO_DEGREES( atan2f( converted.x, converted.y) + M_PI );
	
	// update the scale based on the length of the acceleration
	// the higher the acceleration, the higher the scale factor
	sprite.scale = 0.5f + sqrtf( (converted.x * converted.x) + (converted.y * converted.y) );
}
*/

//observer method, if new level starts
-(void) gameNextLevel:(NSNotification *)notification {
	CCLOG(@"BonusLevelBigOne:gameNextLevel");
	if ([[GameController get] currentLevel]==5) {
		//self.isAccelerometerEnabled=YES;
		
		imgBigOne = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage: @"bigOne.png"]];
		
		//id action = [RepeatForever actionWithAction:[Animate actionWithAnimation: animation]];
		CGSize s = [[CCDirector sharedDirector] winSize];
		[imgBigOne setPosition: ccp(s.width/2, s.height/2)];
		[imgBigOne setOpacity:255];
		
		[self addChild:imgBigOne z:1 tag:kTagSprite];
		
		//add scheduler function
	} else {
		self.isAccelerometerEnabled=NO;
		[self removeChildByTag:kTagSprite cleanup:YES];
	}
}


- (void) dealloc
{
	CCLOG(@"BonusLevelBigOne: dealloc");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


@end
