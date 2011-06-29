#import "CCQuadParticleSystem.h"
#import "Constants.h"
#import "ObserverMessages.h"

/** PointParticleSystem is a subclass of ParticleSystem
 Attributes of a Particle System:
 * All the attributes of Particle System
 
 Features:
 * consumes small memory: uses 1 vertex (x,y) per particle, no need to assign tex coordinates
 * size can't be bigger than 64
 * the system can't be scaled since the particles are rendered using GL_POINT_SPRITE
 */

@interface MichuParticleSystem : CCQuadParticleSystem
{
		MichuParticle	*partInfo;
		int				cntBlownUp;
		int				cntDeleted;
		int				cntShrink;
	
		//count the actual points
		int				cntRedOne;
	
		int				frame;
	
		//object used to send as a message
		ParticleMessage *msg;
}

@property (nonatomic,readonly)  MichuParticle	*partInfo;
@property (nonatomic,readwrite) int cntShrink;
@property (nonatomic,readwrite) int cntBlownUp;
@property (nonatomic,readwrite) int cntDeleted;
@property (nonatomic,readwrite) int frame;

//! Add a particle to the emitter
-(BOOL) addParticle;
//! Initializes a particle
-(void) initParticle:(MichuParticle*)mp;
//! Initializes a system with a fixed number of particles
-(id) initWithTotalParticles:(int) p;

-(void) moveParticles: (ccTime) dt;

- (void)doWaitOnInitialClick;
- (void)updateParticle:(MichuParticle*)mp time:(ccTime)dt;
- (void)blowUpParticle:(MichuParticle*)mp;
- (void)doFadeOutLevel;
- (void)doNextLevel;
- (void)doGameIsRunning:(ccTime)dt;

@end

