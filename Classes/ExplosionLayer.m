#import "ExplosionLayer.h"
#import "Constants.h"
#import "ObserverMessages.h"

@implementation ExplosionLayer

@synthesize emitter;
@synthesize colMagenta, colCyan, colBlack;

-(id) init {
	CCLOG(@"ExplosionLayer: init...");
	if( (self=[super initWithColor:ccc4(0,0,0,0)] )) {
		//set up listener (observer pattern)
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(particleBlownup:) 
													 name:MSG_PARTICLE_BLOWN_UP 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(particleDelete:) 
													 name:MSG_PARTICLE_DELETED 
												   object:nil];
		self.isRelativeAnchorPoint = YES;
		anchorPoint_ = ccp(0.0f, 0.0f);

#define alpha 0.6f		
		ccColor4F tmp1 = {0.886f, 0.0f, 0.478f, alpha};
		colMagenta = tmp1;
		ccColor4F tmp2 = {0.0f, 0.8f, 0.851f, alpha};
		colCyan = tmp2;
		ccColor4F tmp3 = {0.0f, 0.0f, 0.0f, alpha};
		colBlack = tmp3;
	}
	return self;
}

-(void) particleBlownup:(NSNotification *)notification {
	ParticleMessage *msg = [notification object];

	if (msg.specialFunction == kSpecialFunctionEvil) {
		emitter.startColor = colMagenta;
	} else
		if (msg.specialFunction == kSpecialFunctionPowerupOneLife || msg.specialFunction == kSpecialFunctionPowerupX2Bonus
			|| msg.specialFunction == kSpecialFunctionPowerupLifeTimeKiller) {
			emitter.startColor = colBlack;
		} else {
			emitter.startColor = colCyan;
		}
	
	//emitter position = particle blowup position
	emitter.centerOfGravity = msg.pos;

	for (int i=0; i<PARTICLE_PER_EXPLOSION; i++) {
		[emitter addParticle];
	}
}

-(void) particleDelete:(NSNotification *)notification {
	ParticleMessage *msg = [notification object];
	
	if (msg.specialFunction == kSpecialFunctionEvil) {
		emitter.startColor = colMagenta;
	} else
		if (msg.specialFunction == kSpecialFunctionPowerupOneLife || msg.specialFunction == kSpecialFunctionPowerupX2Bonus) {
			emitter.startColor = colBlack;
		} else {
			emitter.startColor = colCyan;
		}
	
	//emitter position = particle blowup position
	emitter.centerOfGravity = msg.pos;
	int cnt=PARTICLE_PER_DELETE;
	if (msg.blownUpSize < PARTICLE_BLOWNUP_SIZE) {
		cnt/=2;
	}
	for (int i=0; i<cnt; i++) {
		[emitter addParticle];
	}	
}

-(void) onEnter
{
	CCLOG(@"ExplosionLayer: on enter...");
	[super onEnter];
	
	self.emitter = [[CCPointParticleSystem alloc] initWithTotalParticles:PARTICLE_EXPLOSION_POOL];
	[self addChild: emitter z:1];
	[emitter release];
	
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: fireImg];
	emitter.positionType = kPositionTypeFree;
	emitter.blendAdditive = NO;
	//particle will be added manually (if a particle blows up)
	emitter.emissionRate = 0;
	
	ccColor4F startColorVar = {0.0f, 0.0f, 0.0f, 0.2f};
	emitter.startColorVar = startColorVar;
	ccColor4F endColor = {1.0f, 1.0f, 1.0f, 0.0f};
	emitter.endColor = endColor;
	ccColor4F endColorVar = {0.0f, 0.0f, 0.0f, 0.0f};	
	emitter.endColorVar = endColorVar;
	
	emitter.startSize = 12.0f;
	emitter.startSizeVar = 8.0f;
	emitter.endSize = 10.f;//kParticleStartSizeEqualToEndSize;
	emitter.endSizeVar = 6.0f;
	
	emitter.life = 2;
	emitter.lifeVar = 1;
	//-1 would be repeat forever
	emitter.duration = 1;
	
	emitter.angle = 10;
	emitter.angleVar = 350;
	emitter.radialAccel = -120;
	emitter.radialAccelVar = 60;
	emitter.tangentialAccel = 90;
	emitter.tangentialAccelVar = 30;
	
	emitter.speed = 60;
	emitter.speedVar = 30;
	
	emitter.position = ccp(240, 160);
	emitter.posVar = CGPointZero;
}

- (void) dealloc
{
	CCLOG(@"ExplosionLayer: dealloc");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[emitter release];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	[super dealloc];
}

@end
