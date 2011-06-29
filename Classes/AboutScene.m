//
//  AboutScene.m
//  iFluenza
//
//  Created by michael vogt on 14.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AboutScene.h"
#import "Constants.h"

#define kImageTag 1

int imageIdx;

static NSString *imageToDisplay[] = {
aboutImg,
//	helpscreen2,
//	helpscreen3,
nil
};

@implementation AboutScene

- (id) init {
    self = [super init];
    if (self != nil) {
		
		imageIdx = 0;
		[self displayImage];
    }
    return self;
}

- (void)displayImage {
	if (imageToDisplay[imageIdx] == nil) {
		CCLOG(@"goto main");
		[self removeChildByTag:kImageTag cleanup:YES];
		[[CCDirector sharedDirector] popScene];
	} else {
		if (imageIdx>0) {
			[self removeChildByTag:kImageTag cleanup:YES];
		}
		CCSprite *bg = [CCSprite spriteWithFile:imageToDisplay[imageIdx]];
		bg.position = ccp(240, 160);
		[self addChild:bg z:1 tag:kImageTag];
		imageIdx++;
	}
} 

- (void)onEnter
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}	

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	//we want the event
	return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	[self displayImage];
}

@end
