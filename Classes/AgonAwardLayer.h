#import "cocos2d.h"

@interface AgonAwardLayer : CCColorLayer {

}

-(void) awardUnlocked:(NSNotification *)notification;
-(void) displayAward;
-(void) finish;
@end
