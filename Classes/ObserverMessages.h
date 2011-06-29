//
//  ObserverMessages.h
//  influenza2
//
//  Created by michael vogt on 05.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"

@interface ParticleMessage : NSObject {
	ParticleStatus	status;
	CGPoint			pos;
	int				specialFunction;
	int				blownUpSize;
}
- (void) updateWithParticle:(MichuParticle*)particle;

@property (nonatomic,readwrite) CGPoint pos;
@property (nonatomic,readwrite) ParticleStatus status;
@property (nonatomic,readwrite) int specialFunction;
@property (nonatomic,readwrite) int blownUpSize;
@end

////

@interface TriggerMessage : NSObject {
}

@end

////

@interface AwardUnlockMsg : NSObject {
	int				awardId;
}
- (id) initWithId:(int)award_Id;

@property (nonatomic,readwrite) int awardId;

@end
