
#import "ObserverMessages.h"
#import "cocos2d.h"

@implementation ParticleMessage 
@synthesize pos, specialFunction, status, blownUpSize;

- (id) init {
	if( (self=[super init] )) {
		status = 0;
		pos = ccp(0,0);
		specialFunction = 0;
	}
	return self;
}

- (void) updateWithParticle:(MichuParticle*)particle {
	status = particle->status;
	pos = particle->pos;
	specialFunction = particle->specialFunction;
	blownUpSize = particle->blownUpSize;
}
@end


@implementation TriggerMessage 
- (id) init {
	if( (self=[super init] )) {
		//blubbr
	}
	return self;
}

@end


@implementation AwardUnlockMsg 
@synthesize awardId;

- (id) initWithId:(int)award_Id {
	if( (self=[super init] )) {
		[self setAwardId:award_Id];
	}
	return self;
}


@end
