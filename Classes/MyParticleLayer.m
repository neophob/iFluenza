//
//  MyParticleLayer.m
//  influenza2
//
//  Created by michael vogt on 23.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyParticleLayer.h"
#import "MichuParticleSystem.h"
#import "Constants.h"
#import "GameController.h"

enum {
	kTagLayerParticle = 6,
};

@implementation MyParticleLayer

@synthesize emitter;

-(id) init {
	CCLOG(@"MyParticleLayer: init...");
	if( (self=[super initWithColor:ccc4(0,0,0,0)] )) {		

		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(gameNextLevel:) 
													 name:MSG_GAME_NEXT_LEVEL
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(startShake:) 
													 name:MSG_SHAKE
												   object:nil];
		
		
		self.isRelativeAnchorPoint = YES;
		anchorPoint_ = ccp(0.0f, 0.0f);

	}
	return self;
}

//observer method, if new level starts
-(void) gameNextLevel:(NSNotification *)notification {
	CCLOG(@"MyParticleLayer:gameNextLevel");
	[self removeChildByTag:kTagLayerParticle cleanup:YES];
//	if ([[GameController get] currentLevel]==5) {
	
//	} else {
		[self addEmiter];
//	}
}

//observer method, if device shakes
-(void) startShake:(NSNotification *)notification {
	CCLOG(@"MyParticleLayer:startShake");
	[[GameController get] setLvlShaked:1]; 
	[self schedule:@selector(stopShake) interval:SHAKE_TIME_IN_S];		
}

-(void) stopShake {
	CCLOG(@"MyParticleLayer:stopShake");
	[self unschedule:@selector(stopShake)];
	[[GameController get] setLvlShaked:2]; 
}

-(void) addEmiter {
	int p = [[GameController get] lvlNumberOfParticles];
	self.emitter = [[MichuParticleSystem alloc] initWithTotalParticles:p];
	[self addChild: self.emitter z:1 tag:kTagLayerParticle];
	[emitter release];
	
	//image is only loaded once
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"texture5.pvr"];
	emitter.blendAdditive = NO;
	//TODO
	//emitter.emissionRate = 200;//DISPLAY_LEVEL_TIME_IN_S/p;
	emitter.emissionRate = p/1.4f;
	
	emitter.speed = 40;
	emitter.speedVar = 15;
	emitter.duration = -1;
	
	emitter.position = (CGPoint) {240,160
//		[[Director sharedDirector] winSize].width / 2,
//		[[Director sharedDirector] winSize].height /2
	};
	emitter.life = 1;
	emitter.lifeVar = 0;
	
	// gravity
	emitter.gravity = CGPointZero;
	emitter.centerOfGravity = ccp(480,320);
	//kPositionTypeGrouped or	kPositionTypeFree
	emitter.positionType = kPositionTypeFree;

	//init dummy values, these are unused because MichuParticleSystem is used.
	emitter.startSize = 1;
	emitter.startSizeVar = 0;
	emitter.endSize = kParticleStartSizeEqualToEndSize;
}

-(void) onEnter
{
	CCLOG(@"MyParticleLayer: on enter...");
	[super onEnter];
	[self addEmiter];
}

- (void) dealloc
{
	CCLOG(@"MyParticleLayer: dealloc");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[emitter release];
	[super dealloc];
}


-(NSString*) title
{
	return @"No title";
}

@end
