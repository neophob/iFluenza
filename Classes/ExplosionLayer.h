#import "cocos2d.h"

@interface ExplosionLayer : CCColorLayer {
	CCParticleSystem	*emitter;
	ccColor4F colCyan;
	ccColor4F colMagenta;
	ccColor4F colBlack;
}

-(void) particleBlownup:(NSNotification *)notification;
-(void) particleDelete:(NSNotification *)notification;
@property (nonatomic,readwrite,retain) CCParticleSystem *emitter;
@property (nonatomic,readwrite) ccColor4F colCyan;
@property (nonatomic,readwrite) ccColor4F colMagenta;
@property (nonatomic,readwrite) ccColor4F colBlack;

@end
