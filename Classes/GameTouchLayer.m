#import "GameTouchLayer.h"
#import "GameController.h"

@implementation GameTouchLayer

-(id) init
{
	if( (self=[super init] )) {
		// isTouchEnabled is property of Layer (the super class).
		// When it is YES, then the accelerometer will be enabled
		self.isAccelerometerEnabled = YES;
		self.isTouchEnabled = YES;
	}
	return self;
}

-(void) registerWithTouchDispatcher{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
}


//-(void) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
- (void)ccTouchBegan:(UITouch *)touches withEvent:(UIEvent *)event {	
	CGPoint touchPoint = [touches locationInView:[touches view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];

	[[GameController get] setTouchPoint:touchPoint touchType:kTouchClickEnded];
//	[[GameController get] setTouchStatus:kTouchNone];
}

//-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
- (void)ccTouchEnded:(UITouch *)touches withEvent:(UIEvent *)event {		
	CGPoint touchPoint = [touches locationInView:[touches view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
	[[GameController get] setTouchPoint:touchPoint touchType:kTouchClickEnded];
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
	[[GameController get] setTouchStatus:kTouchNone];
	
	//clear the circle
	[[NSNotificationCenter defaultCenter] postNotificationName:MSG_PARTICLE_HIGHLIGHT_CLEAR object:nil];
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
	[[GameController get] setTouchPoint:touchPoint touchType:kTouchMoved];
}


#define kAccelerationThreshold          2.0
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	// Convert the coordinates to 'landscape' coords
	// since they are always in 'portrait' coordinates
	//CGPoint converted = ccp( (float)-acceleration.y, (float)acceleration.x);     
	
	if ([[GameController get] lvlShaked]==0 && [[GameController get] gameStatus]==kGameIsRunning) {
		if (fabsf(acceleration.x) > kAccelerationThreshold || fabsf(acceleration.y) > kAccelerationThreshold
			|| fabsf(acceleration.z) > kAccelerationThreshold) {
			[[NSNotificationCenter defaultCenter] postNotificationName:MSG_SHAKE object:nil];
			CCLOG(@"Shake!!!");                    
		}      
	}
}
@end
