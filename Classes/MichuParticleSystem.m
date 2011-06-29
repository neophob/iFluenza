//
//  MichuParticleSystem.m
//  influenza2
//
//  Created by michael vogt on 23.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

// opengl
#import <OpenGLES/ES1/gl.h>

// cocos2d
#import "MichuParticleSystem.h"
//#import "TextureMgr.h"
#import "ccMacros.h"

// support
#import "OpenGL_Internal.h"
#import "CGPointExtension.h"

#import "Constants.h"
#import "GameController.h"

@implementation MichuParticleSystem

@synthesize partInfo, frame;
@synthesize cntShrink, cntBlownUp, cntDeleted;

-(id) initWithTotalParticles:(int) p {
	if( (self=[super initWithTotalParticles:p]) ) {
		//init my system
		int memSize = sizeof(MichuParticle) * p;
		partInfo = malloc( memSize );
		if( ! partInfo ) {
			CCLOG(@"Particle system: not enough memory");
			if( partInfo )
				free(partInfo);
			return nil;
		}
		bzero( partInfo, memSize );	
		CCLOG(@"particle init: alloc %i bytes (%i) particles", memSize, p);
		
		//alloc obj used for messages
		msg = [[ParticleMessage alloc] init];
		
	}
	return self;
}

-(void) dealloc {
	[msg release];
	free(partInfo);
	[super dealloc];
}

-(BOOL) addParticle {
	if( [self isFull] )
		return NO;
	
	MichuParticle *mp = &partInfo[particleCount++];
	[self initParticle:mp];
	return YES;
}

-(void) initParticle:(MichuParticle*) mp {
	mp->size = PARTICLE_INIT_SIZE + PARTICLE_INIT_SIZE_RANDOM*CCRANDOM_0_1();
	mp->blownUpSize = PARTICLE_BLOWNUP_SIZE;
	
	//movement
	mp->speed = 1.0f + ((arc4random()%7)*0.1f);
	mp->dir = 0;
	mp->headingDirection = degreesToRadian(arc4random()%360);
	
	mp->pulseRadius=0;
	mp->pulseSeed=arc4random()%360;
	
	mp->status=kNormal;
	mp->lifetime=[[GameController get] lvlLifeTimeOfParticle];
	
	//init the particle system HERE, we do NOT USE the parent!
	//center
	mp->pos.x=240;
	mp->pos.y=160;
	
	float startA = 30 + 160 * CCRANDOM_MINUS1_1();
	mp->angle = startA;
	mp->deltaAngle = startA;//(endA - startA) / particle->life;
	
	int i = particleCount-1;
	
	if (i < [[GameController get] getRedOneCounter]) {
		mp->specialFunction = kSpecialFunctionEvil;
	} else {
		mp->specialFunction = 1+arc4random()%10;
		//make sure there is at least a valid antibody to click on
		if (i<2) mp->specialFunction = kSpecialFunctionDoubleLifetime;		
	}
	
	//	mp->specialFunction = kSpecialFunctionEvil;
	if (mp->specialFunction==kSpecialFunctionDoubleRadius) {
		mp->blownUpSize*=1.5f;
	} else 
		if (mp->specialFunction==kSpecialFunctionHalfRadius) {
			mp->blownUpSize/=1.5;
		} else
			if (mp->specialFunction==kSpecialFunctionDoubleLifetime) {
				mp->lifetime*=1.5f;
			} else
				if (mp->specialFunction==kSpecialFunctionEvil) {
					//
				} else
					if (mp->specialFunction==kSpecialFunctionHalfLifetime) {
						mp->lifetime/=1.5f;
					} else {
						//no special function till now, get bonus
#ifdef DEV_MODE
						int tmp = arc4random()%7;
#endif
						
#ifndef DEV_MODE
						int tmp = arc4random()%32;
#endif
						if (tmp==2) {
							mp->specialFunction = kSpecialFunctionPowerupOneLife;
						} else
							if (tmp==4) {
								mp->specialFunction = kSpecialFunctionPowerupX2Bonus;
							} else 
								if (tmp==5) {
									mp->specialFunction = kSpecialFunctionPowerupLifeTimeKiller;
								} else {
									mp->specialFunction = 0;	
								}
					}
	
	mp->specialColor.r = 1; //226
	mp->specialColor.g = 1;
	mp->specialColor.b = 1; //122
	mp->specialColor.a = 0.75;
	
#define PARTICLEX (1.0f/4.0f)
#define PARTICLEY (1.0f/4.0f)
	//select texture
	if (mp->specialFunction==kSpecialFunctionEvil) {
		//there are 4 evil images
		int randomImg = random()%4;
		// bottom-left vertex:
		quads[i].bl.texCoords.u = PARTICLEX*(0+randomImg);
		quads[i].bl.texCoords.v = PARTICLEY*1;
		// bottom-right vertex:
		quads[i].br.texCoords.u = PARTICLEX*(1+randomImg);
		quads[i].br.texCoords.v = PARTICLEY*1;
		// top-left vertex:
		quads[i].tl.texCoords.u = PARTICLEX*(0+randomImg);
		quads[i].tl.texCoords.v = PARTICLEY*2;
		// top-right vertex:
		quads[i].tr.texCoords.u = PARTICLEX*(1+randomImg);
		quads[i].tr.texCoords.v = PARTICLEY*2;
	} else
		if (mp->specialFunction==kSpecialFunctionDoubleLifetime || mp->specialFunction==kSpecialFunctionHalfLifetime) {
			// bottom-left vertex:
			quads[i].bl.texCoords.u = PARTICLEX*0;
			quads[i].bl.texCoords.v = PARTICLEY*0;
			// bottom-right vertex:
			quads[i].br.texCoords.u = PARTICLEX*1;
			quads[i].br.texCoords.v = PARTICLEY*0;
			// top-left vertex:
			quads[i].tl.texCoords.u = PARTICLEX*0;
			quads[i].tl.texCoords.v = PARTICLEY*1;
			// top-right vertex:
			quads[i].tr.texCoords.u = PARTICLEX*1;
			quads[i].tr.texCoords.v = PARTICLEY*1;							
		} else
			if (mp->specialFunction==kSpecialFunctionDoubleRadius) {
				// bottom-left vertex:
				quads[i].bl.texCoords.u = PARTICLEX*1;
				quads[i].bl.texCoords.v = PARTICLEY*0;
				// bottom-right vertex:
				quads[i].br.texCoords.u = PARTICLEX*2;
				quads[i].br.texCoords.v = PARTICLEY*0;
				// top-left vertex:
				quads[i].tl.texCoords.u = PARTICLEX*1;
				quads[i].tl.texCoords.v = PARTICLEY*1;
				// top-right vertex:
				quads[i].tr.texCoords.u = PARTICLEX*2;
				quads[i].tr.texCoords.v = PARTICLEY*1;
			} else
				if (mp->specialFunction==kSpecialFunctionHalfRadius) {
					// bottom-left vertex:
					quads[i].bl.texCoords.u = PARTICLEX*1;
					quads[i].bl.texCoords.v = PARTICLEY*0;
					// bottom-right vertex:
					quads[i].br.texCoords.u = PARTICLEX*2;
					quads[i].br.texCoords.v = PARTICLEY*0;
					// top-left vertex:
					quads[i].tl.texCoords.u = PARTICLEX*1;
					quads[i].tl.texCoords.v = PARTICLEY*1;
					// top-right vertex:
					quads[i].tr.texCoords.u = PARTICLEX*2;
					quads[i].tr.texCoords.v = PARTICLEY*1;
				} else
					if (mp->specialFunction==kSpecialFunctionPowerupOneLife) {
						// bottom-left vertex:
						quads[i].bl.texCoords.u = PARTICLEX*0;
						quads[i].bl.texCoords.v = PARTICLEY*2;
						// bottom-right vertex:
						quads[i].br.texCoords.u = PARTICLEX*1;
						quads[i].br.texCoords.v = PARTICLEY*2;
						// top-left vertex:
						quads[i].tl.texCoords.u = PARTICLEX*0;
						quads[i].tl.texCoords.v = PARTICLEY*3;
						// top-right vertex:
						quads[i].tr.texCoords.u = PARTICLEX*1;
						quads[i].tr.texCoords.v = PARTICLEY*3;							
					} else
						if (mp->specialFunction==kSpecialFunctionPowerupX2Bonus) {
							// bottom-left vertex:
							quads[i].bl.texCoords.u = PARTICLEX*1;
							quads[i].bl.texCoords.v = PARTICLEY*2;
							// bottom-right vertex:
							quads[i].br.texCoords.u = PARTICLEX*2;
							quads[i].br.texCoords.v = PARTICLEY*2;
							// top-left vertex:
							quads[i].tl.texCoords.u = PARTICLEX*1;
							quads[i].tl.texCoords.v = PARTICLEY*3;
							// top-right vertex:
							quads[i].tr.texCoords.u = PARTICLEX*2;
							quads[i].tr.texCoords.v = PARTICLEY*3;					
						} else
							if (mp->specialFunction==kSpecialFunctionPowerupLifeTimeKiller) {
								// bottom-left vertex:
								quads[i].bl.texCoords.u = PARTICLEX*2;
								quads[i].bl.texCoords.v = PARTICLEY*2;
								// bottom-right vertex:
								quads[i].br.texCoords.u = PARTICLEX*3;
								quads[i].br.texCoords.v = PARTICLEY*2;
								// top-left vertex:
								quads[i].tl.texCoords.u = PARTICLEX*2;
								quads[i].tl.texCoords.v = PARTICLEY*3;
								// top-right vertex:
								quads[i].tr.texCoords.u = PARTICLEX*3;
								quads[i].tr.texCoords.v = PARTICLEY*3;					
							} else{
								// bottom-left vertex:
								quads[i].bl.texCoords.u = PARTICLEX*3;
								quads[i].bl.texCoords.v = PARTICLEY*0;
								// bottom-right vertex:
								quads[i].br.texCoords.u = PARTICLEX*4;
								quads[i].br.texCoords.v = PARTICLEY*0;
								// top-left vertex:
								quads[i].tl.texCoords.u = PARTICLEX*3;
								quads[i].tl.texCoords.v = PARTICLEY*1;
								// top-right vertex:
								quads[i].tr.texCoords.u = PARTICLEX*4;
								quads[i].tr.texCoords.v = PARTICLEY*1;					
							}
	
}

//setup texture for each particle
-(void) initTexCoords
{	
	//setup is done during particle init...
}	

// XXX
// XXX: All subclasses of ParticleSystem share this code
// XXX: so some parts of this coded should be moved to the base class
// XXX
// XXX: BUT the change shall NOT DROP a single FPS
// XXX:
-(void) step: (ccTime) dt
{
	frame ++;
	
	//add more particles if needed
	if( active && emissionRate ) {
		float rate = 1.0f / emissionRate;
		emitCounter += dt;
		while( particleCount < totalParticles && emitCounter > rate ) {
			[self addParticle];
			emitCounter -= rate;
		}
		
		elapsed += dt;
		if(duration != -1 && duration < elapsed)
			[self stopSystem];
	}
	
	//move the particles
	[self moveParticles:dt];
	
	//game loop
	GameStatus gameStatus = [[GameController get] gameStatus];
	if (gameStatus==kWaitOnInitialClick) {
		cntShrink=0; cntBlownUp=0; cntDeleted=0; cntRedOne=0;
		[self doWaitOnInitialClick];
		[[GameController get] setScoreLevel: cntRedOne];
	} else
		if (gameStatus==kGameIsRunning) {
			cntShrink=0; cntBlownUp=0; cntDeleted=0; cntRedOne=0;
			[self doGameIsRunning:dt];
			[[GameController get] setScoreLevel: cntRedOne];
		} else
			if (gameStatus==kFadeOutCurrentLevel) {
				cntShrink=0; cntBlownUp=0; cntDeleted=0; cntRedOne=0;
				[self doFadeOutLevel];
				[[GameController get] setScoreLevel: cntRedOne];
				
			} else
				if (gameStatus==kNextLevel) {
					[self doNextLevel];
				}
}

-(void) moveParticles: (ccTime) dt {
	MichuParticle *mp;
	ccColor4F selColor;
	float x,y;
	
	int shake = [[GameController get] lvlShaked]; 
	
	//do not use the actual delta time, this may
	//give ugly flicker if the game stucks/dt varies...
	dt=0.01f;
	
	int loop;
	int currentScore = [[GameController get] scoreLevel];                                                                                                                                     
	int neededScore = [[GameController get] lvlNeededScore];
	
	particleIdx = 0;
	while( particleIdx < particleCount )
	{
		mp = &partInfo[particleIdx];
		
		//UPDATE START
		//top left:     x=-240 y=160
		//bottom right: x=240  y=-160
		y = mp->pos.x;
		x = mp->pos.y;
		
		loop=1;
		//speedup after level done
		if (currentScore >= neededScore) {
			loop = 2;
		}
		
		while (loop > 0) {
			
			if (mp->dir == 0) {
				x += mp->speed * cos(mp->headingDirection);
				y += mp->speed * sin(mp->headingDirection);
			} else {
				float cx = x - mp->dir * mp->size * sin(mp->headingDirection);
				float cy = y + mp->dir * mp->size * cos(mp->headingDirection);
				mp->headingDirection += mp->dir * mp->speed/mp->size;
				x = cx + mp->dir * mp->size * sin(mp->headingDirection);
				y = cy - mp->dir * mp->size * cos(mp->headingDirection);
			}
			
			//this is needed, else the particles just turn arround!
			if ((random()%7)==0) {
				mp->dir = (random()%3)-1;
			}
			
#define HUD_SIZE 28	
			float cx = x - mp->size * sin(mp->headingDirection);
			float cy = y + mp->size * cos(mp->headingDirection);
			if (cx<mp->size+PARTICLE_BOARDER+HUD_SIZE || cx>XSIZE-mp->size-PARTICLE_BOARDER ||
				cy<mp->size+PARTICLE_BOARDER || cy>YSIZE-mp->size-PARTICLE_BOARDER) mp->dir = -1;
			
			cx = x + mp->size * sin(mp->headingDirection);
			cy = y - mp->size * cos(mp->headingDirection);
			if (cx<mp->size+PARTICLE_BOARDER+HUD_SIZE || cx>XSIZE-mp->size-PARTICLE_BOARDER ||
				cy<mp->size+PARTICLE_BOARDER || cy>YSIZE-mp->size-PARTICLE_BOARDER) mp->dir = 1;
			
			loop--;
		}
		
		if (shake==1) {
			x+=(random()%7)-3;
			y+=(random()%7)-3;
		}
		
		if (x<HUD_SIZE) x=HUD_SIZE;
		if (y<1) y=1;
		if (y>480) y=480;
		if (x>320) x=320;
		
		mp->pos.x = y;
		mp->pos.y = x;
		
		//UPDATE END
		
		int size=0;
		//p->size is used to store a temp size (pulse size)
		if (mp->status==kBlownup) {
			size = mp->size+mp->pulseRadius;
		} else {
			size = mp->size;
		}
		
		selColor = mp->specialColor;
		if (mp->inTouchRange != 0) {
			selColor.a = 1.0f;
			//size *= 2;
		}
		
		//set colors
		quads[particleIdx].bl.colors = selColor;
		quads[particleIdx].br.colors = selColor;
		quads[particleIdx].tl.colors = selColor;
		quads[particleIdx].tr.colors = selColor;
		
		float size_2 = size/2;
		
		mp->angle += (mp->deltaAngle * dt);
		if(mp->angle ) {
			float x1 = -size_2;
			float y1 = -size_2;
			
			float x2 = x1 + size;
			float y2 = y1 + size;
			float x = mp->pos.x;
			float y = mp->pos.y;
			
			float r = (float)-CC_DEGREES_TO_RADIANS(mp->angle);
			float cr = cosf(r);
			float sr = sinf(r);
			float ax = x1 * cr - y1 * sr + x;
			float ay = x1 * sr + y1 * cr + y;
			float bx = x2 * cr - y1 * sr + x;
			float by = x2 * sr + y1 * cr + y;
			float cx = x2 * cr - y2 * sr + x;
			float cy = x2 * sr + y2 * cr + y;
			float dx = x1 * cr - y2 * sr + x;
			float dy = x1 * sr + y2 * cr + y;
			
			quads[particleIdx].bl.vertices.x = ax;
			quads[particleIdx].bl.vertices.y = ay;
			
			// bottom-left vertex:
			quads[particleIdx].br.vertices.x = bx;
			quads[particleIdx].br.vertices.y = by;
			
			// top-right vertex:
			quads[particleIdx].tl.vertices.x = dx;
			quads[particleIdx].tl.vertices.y = dy;
			
			// top-right vertex:
			quads[particleIdx].tr.vertices.x = cx;
			quads[particleIdx].tr.vertices.y = cy;
		} else {
			// top-left vertex:
			quads[particleIdx].bl.vertices.x = mp->pos.x - size_2;
			quads[particleIdx].bl.vertices.y = mp->pos.y - size_2;
			
			// bottom-left vertex:
			quads[particleIdx].br.vertices.x = mp->pos.x + size_2;
			quads[particleIdx].br.vertices.y = mp->pos.y - size_2;
			
			// top-right vertex:
			quads[particleIdx].tl.vertices.x = mp->pos.x - size_2;
			quads[particleIdx].tl.vertices.y = mp->pos.y + size_2;
			
			// top-right vertex:
			quads[particleIdx].tr.vertices.x = mp->pos.x + size_2;
			quads[particleIdx].tr.vertices.y = mp->pos.y + size_2;				
		}
		
		particleIdx++;
	}	
	glBindBuffer(GL_ARRAY_BUFFER, quadsID);
//	glBufferData(GL_ARRAY_BUFFER, sizeof(quads[0])*particleCount, quads,GL_DYNAMIC_DRAW);	
	glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(quads[0])*particleCount, quads);
	glBindBuffer(GL_ARRAY_BUFFER, 0);	
}

//this should be a very fast sqrt implementation...
uint32 _sqrt4Cycle (uint32 n) {
    uint32 root = 0, try;
    iter1 (15);    iter1 (14);    iter1 (13);    iter1 (12);
    iter1 (11);    iter1 (10);    iter1 ( 9);    iter1 ( 8);
    iter1 ( 7);    iter1 ( 6);    iter1 ( 5);    iter1 ( 4);
    iter1 ( 3);    iter1 ( 2);    iter1 ( 1);    iter1 ( 0);
    return root >> 1;
}

- (void)blowUpParticle:(MichuParticle*)mp {
	mp->status=kBlownup;
	
	//increase game retries
	if (mp->specialFunction==kSpecialFunctionPowerupOneLife) {
		int r = [[GameController get] retries]+1;
		[[GameController get] setRetries:r];
	} else
		if (mp->specialFunction==kSpecialFunctionPowerupX2Bonus) {
			[[GameController get] setCurrentLevelX2:true];
			[[NSNotificationCenter defaultCenter] postNotificationName:MSG_POWERUP_X2 object:nil];
		} else 
			if (mp->specialFunction==kSpecialFunctionPowerupLifeTimeKiller) {
				int idx = 0;
				MichuParticle* tmp;
				while( idx < particleCount ) {
					tmp = &partInfo[idx];
					tmp->lifetime /=2;
					if (idx==1) CCLOG(@"lt: %f",tmp->lifetime);
					idx++;
				}		
			}
	
}

- (void) doWaitOnInitialClick {
	CGPoint p;
	int distance;
	
	TouchStatus     touchStatus = [[GameController get] touchStatus];                                                                  
	CGPoint         touchPoint = [[GameController get] touchPoint]; 
	bool			gameStarted = false;
	//enter loop only if we touched...
	if (touchStatus==kTouchMoved || touchStatus==kTouchClickEnded) {
		MichuParticle *mp;
		particleIdx = 0;
		
		int circleIsShown=0;
		
		while( particleIdx < particleCount ) {
			mp = &partInfo[particleIdx];
			
			//highlight possible selected items - we use double radius to simplify the navigation			
			[self updateParticle:mp time:0.0f];
			mp->inTouchRange = 0;
			
			if (!gameStarted) {
				
				//only blue antibodies can start the game!
				if (mp->specialFunction == 0 ||
					mp->specialFunction == kSpecialFunctionHalfRadius ||
					mp->specialFunction == kSpecialFunctionHalfLifetime ||
					mp->specialFunction == kSpecialFunctionDoubleLifetime ||					
					mp->specialFunction == kSpecialFunctionDoubleRadius) {
					
					p = ccpSub(mp->pos, touchPoint);
					distance = _sqrt4Cycle(p.x*p.x + p.y*p.y);
					if (distance < mp->size) {
						if (touchStatus==kTouchMoved) {
							mp->inTouchRange = 1;
							[msg updateWithParticle:mp];
							circleIsShown++;
							[[NSNotificationCenter defaultCenter] postNotificationName:MSG_PARTICLE_HIGHLIGHT object:msg];
							
							//CCLOG(@"still moving    particle %i",mp->specialFunction);	
						} else if (touchStatus==kTouchClickEnded) {
							//CCLOG(@"blow up!!!!!    particle %i",mp->specialFunction);	
							[self blowUpParticle:mp];
							mp->deltaAngle+=120 * CCRANDOM_MINUS1_1();
							[[GameController get] setGameStatus:kGameIsRunning];
							
							[[NSNotificationCenter defaultCenter] postNotificationName:MSG_PARTICLE_HIGHLIGHT_CLEAR object:nil];
							
							[msg updateWithParticle:mp];
							[[NSNotificationCenter defaultCenter] postNotificationName:MSG_PARTICLE_BLOWN_UP object:msg];
							[[NSNotificationCenter defaultCenter] postNotificationName:MSG_GAME_CHAIN_REACTION_STARTED object:nil];
							
							CCLOG(@"gamestatus: kGameIsRunning (selected %i)", particleIdx);
							gameStarted = true;							
						} 
						
					}
				}
				
			}
			
			particleIdx++;
		}
		
		if (circleIsShown==0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:MSG_PARTICLE_HIGHLIGHT_CLEAR object:nil];			
		}
		
		//clear touch status
		if (touchStatus==kTouchClickEnded) {
			[[GameController get] setTouchStatus:kTouchNone];
		}
	}
}

//check for blownup particles
- (void) doGameIsRunning:(ccTime)dt {
	MichuParticle *mp,*mp2;
	CGPoint p;
	particleIdx = 0;
	while( particleIdx < particleCount ) {
		mp = &partInfo[particleIdx];
		//todo move seperate
		[self updateParticle:mp time:dt];
		
		//make sure the red dot disapears...
		mp->inTouchRange = 0;
		
		int particleIdx2 = 0;
		while( particleIdx2 < particleCount ) {
			mp2 = &partInfo[particleIdx2];
			
			//check blownup
			if (mp2->status==kNormal && (mp->status==kBlownup || mp->status==kShrink) && particleIdx!=particleIdx2) {
				p = ccpSub(mp2->pos,mp->pos);
				
				int distance = _sqrt4Cycle(p.x*p.x + p.y*p.y);
				int size = (mp2->size+mp2->pulseRadius+mp->size+mp->pulseRadius)/2;
				if (distance < size) {
					[self blowUpParticle:mp2];
					mp2->deltaAngle+=120 * CCRANDOM_MINUS1_1();
					
					//check for evil paricle; if so, decrease lifetime
					if (mp->specialFunction==kSpecialFunctionEvil) {
						if (mp2->specialFunction != kSpecialFunctionEvil) {
							mp2->lifetime = 0;
						}
					}
					if (mp2->specialFunction==kSpecialFunctionEvil) {
						if (mp->specialFunction != kSpecialFunctionEvil) {
							mp->lifetime = 0;
						}
					}
					
					[msg updateWithParticle:mp2];
					[[NSNotificationCenter defaultCenter] postNotificationName:MSG_PARTICLE_BLOWN_UP object:msg];					
				}
			}
			particleIdx2++;
		}
		
		particleIdx++;
	}
	if (cntDeleted > 0 && cntBlownUp == 0 && cntShrink == 0) {
		[[GameController get] setGameStatus:kFadeOutCurrentLevel];
		CCLOG(@"gamestatus: kFadeOutCurrentLevel");
	}
}


//do fade out current level start
- (void) doFadeOutLevel {
	int cnt=0;
	
	MichuParticle *mp;
	particleIdx = 0;
	while( particleIdx < particleCount ) {
		mp = &partInfo[particleIdx];
		[self updateParticle:mp time:0.0f];
		
		if (mp->status==kNormal) {
			mp->status=kFadeAway;
		}
		if (mp->status==kFadeAway) {
			cnt++;
		}
		particleIdx++;
	}
	//CCLOG(@"there are %i particles left...",cnt);
	if (cnt==0) {
		[[GameController get] setGameStatus:kNextLevel];
	}
} 

//level done, send message
- (void) doNextLevel {
	[[GameController get] doNextLevel];
}

//update the particlestatus blownup->shrink->delete
- (void)updateParticle:(MichuParticle*)mp time:(ccTime)dt {
	if (mp->status==kBlownup) {
		//update game state
		cntBlownUp++;
		//update game points
		if (mp->specialFunction==kSpecialFunctionEvil) {
			cntRedOne++;
		}
		
		if (mp->size < mp->blownUpSize) {
			mp->size+=TOUCH_BLOWUP_AMOUNT;
		} else {
			mp->lifetime-=dt;
			int currentScore = [[GameController get] scoreLevel];                                                                                                                                     
			int neededScore = [[GameController get] lvlNeededScore];
			
			if (currentScore >= neededScore) {
				mp->lifetime-=dt;
			}
			
			if (mp->lifetime <= 0.0f) {
				mp->status=kShrink;
			}			
		}
		mp->pulseRadius=(int)(sin((mp->pulseSeed+(frame>>2))%360)*4);
	} else
		if (mp->status==kShrink) {
			cntShrink++;
			if (mp->specialFunction==kSpecialFunctionEvil) {
				cntRedOne++;
			}
			mp->size-=TOUCH_BLOWUP_AMOUNT*2;
			if (mp->size <= TOUCH_BLOWUP_AMOUNT) {
				mp->status=kDelete;
				mp->size=0;
				mp->pulseRadius=0;
				[msg updateWithParticle:mp];
				[[NSNotificationCenter defaultCenter] postNotificationName:MSG_PARTICLE_DELETED object:msg];					
			}
		} else
			if (mp->status==kFadeAway) {
				//no points for fadeaways...
				if (mp->size>0) {
					mp->size--;
				} else {
					mp->status=kFadeAwayDeleted;
				}
			} else
				if (mp->status==kDelete) {
					cntDeleted++;
					if (mp->specialFunction==kSpecialFunctionEvil) {
						cntRedOne++;
					}					
				}
}

@end
