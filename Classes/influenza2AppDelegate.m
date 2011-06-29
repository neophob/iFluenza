//
//  influenza2AppDelegate.m
//  influenza2
//
//  Created by michael vogt on 19.08.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "influenza2AppDelegate.h"
#import "cocos2d.h"
#import "MainMenuScene.h"
#import "Constants.h"
#import "SoundController.h"
#import "AgonStuff.h"
#import "GameController.h"

@implementation influenza2AppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{		
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:NO];
	
	// must be called before any othe call to the director
	// WARNING: FastDirector doesn't interact well with UIKit controls
	//[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[CCDirector sharedDirector] setAnimationInterval:1.0/CONFIGUREDFPS];
#ifdef DEV_MODE
	[[CCDirector sharedDirector] setDisplayFPS:YES];
#endif
#ifndef DEV_MODE
	[[CCDirector sharedDirector] setDisplayFPS:NO];
#endif
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	//// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];

	[[CCDirector sharedDirector] setPixelFormat:kRGBA8];
	//	[[Director sharedDirector] setDepthBufferFormat:kDepthBuffer16];
	
	//load sound first (async) - needs quite a lot of time...
//	[[SoundController get] playFx:SND_ID_BLUB_BIG];

	// create an openGL view inside a window
	[[CCDirector sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];		

	// prevent flicker
	CCSprite *sprite = [[CCSprite spriteWithFile:@"Default.png"] retain];
	sprite.anchorPoint = CGPointZero;
	[sprite draw];	
	[[[CCDirector sharedDirector] openGLView] swapBuffers];
	[sprite release];
	
	[AgonStuff initAgon];
	
	//load saved user settings
	NSDictionary *appDefaults = [NSDictionary
								  dictionaryWithObjects:[NSArray arrayWithObjects:
														[NSNumber numberWithInt:0],
														//[NSNumber numberWithInt:1],
														nil]
								 forKeys:[NSArray arrayWithObjects:
										  @"LoadedTimes", // how many times we loaded this app
										  //@"Level",		  // starts at level 1
										  nil]];
	
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	int loadCount=[[NSUserDefaults standardUserDefaults] integerForKey:@"LoadedTimes"];
	[[GameController get] setLoadCount:loadCount];
	
	CCLOG(@"load count: %i", loadCount);

	CCLOG(@"goto mainmenu");
	[[CCDirector sharedDirector] runWithScene: [MainMenuScene node]];

}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Free AGON resources.
//	AgonDestroy();

	int loadCount = 1+[[GameController get] loadCount];
	[[NSUserDefaults standardUserDefaults] setObject:
		[NSNumber numberWithInt:loadCount] forKey:@"LoadedTimes"];
	//[[NSUserDefaults standardUserDefaults] setObject:
	//	[NSNumber numberWithInt:gLevel] forKey:@"Level"];
	[[CCDirector sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];

	[window release];
	[super dealloc];
}

@end
