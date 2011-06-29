#import "cocos2d.h"

@interface MyParticleLayer : CCColorLayer {
	CCParticleSystem	*emitter;
}

-(void) addEmiter;

@property (nonatomic,readwrite,retain) CCParticleSystem *emitter;

@end
