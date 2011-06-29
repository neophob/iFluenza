//
//  AgonStuff.h
//  influenza2.2
//
//  Created by michael vogt on 05.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

#import "AGON.h"

@interface AgonStuff : NSObject {

}

+(void) initAgon;
+(void) checkForAwards;
+(void) gameFinished;
+(BOOL) doesUserProfileExists;
+(BOOL) submitScore;
//+(void) submitFailedScore;

@end
