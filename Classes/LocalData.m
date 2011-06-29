//
//  LocalData.m
//  iFluenza
//
//  Created by michael vogt on 13.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocalData.h"
#import "cocos2d.h"

#define START_COUNT_KEY @"startCount"
@implementation LocalData

//save each start of the application
+(int) updateStartCount {
	[self checkIfPlistFileExistInUserDirectory];
	checkIfPlistFileExistInUserDirectory;
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *finalPath = [path stringByAppendingPathComponent:@"data.plist"];
	NSMutableDictionary *plistData = [[NSMutableDictionary dictionaryWithContentsOfFile:finalPath] retain];

	int count = [[plistData objectForKey:START_COUNT_KEY] intValue];
	NSString *updatedValue = [NSString stringWithFormat:@"%i", count+1];
	
	[plistData setValue:updatedValue forKey:START_COUNT_KEY];
	[plistData writeToFile:finalPath atomically: YES];
	[plistData release];
	
	return count;
}




@end
