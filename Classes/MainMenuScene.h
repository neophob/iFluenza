#import "cocos2d.h"

@interface MainMenuScene : CCScene {
	CCParticleSystem	*emitter;
	BOOL			doDisplayHelp;
}
@property (readwrite,retain) CCParticleSystem *emitter;

- (void)onAbout:(id)sender;
- (void)onPlay:(id)sender;
- (void)onHelp:(id)sender;
- (void)onHighscore:(id)sender;
+ (void)goToMainMenu;

@end
