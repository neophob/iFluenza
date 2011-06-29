#include "ccTypes.h"

// ####################### GAME DEFINITION
#define RADIUS 50
#define DISPLAY_LEVEL_TIME_IN_S 4

//#define DEV_MODE 1

#define AGON_LEADERBOARD_ID 0
#define AGON_LEADERBOARD_LATEST_SCORE 1
#define AGON_LEADERBOARD_FAILED_SCORE 2

#define GAME_DONE_BONUS_POINTS 200
#define GAME_10er_BONUS_POINTS 60

#ifdef DEV_MODE
#define	AGON_SERVER AgonDeveloperServers
#endif
#ifndef DEV_MODE
#define	AGON_SERVER AgonProductionServers
#endif

#define PARTICLE_INIT_SIZE 22.0f
#define PARTICLE_INIT_SIZE_RANDOM 10.0f
#define INIT_PARTICLE_NEEDED_SCORE 2
#define PARTICLE_BLOWNUP_SIZE 50
#define PARTICLE_BOARDER 20

#define TOUCH_BLOWUP_AMOUNT 1
#define INIT_PARTICLE_BLOWNUP_TIME_IN_S 5.0f
#define INIT_PARTICLE_COUNT 10

//explosion layer
#define PARTICLE_PER_EXPLOSION 72
#define PARTICLE_PER_DELETE 8
#define PARTICLE_EXPLOSION_POOL PARTICLE_PER_EXPLOSION*12

#define GAME_BITMAP_FONT @"fps_images4.png"
#define GAME_BITMAP_FONT_X 16
#define GAME_BITMAP_FONT_Y 19

#define SHAKE_TIME_IN_S 1.2f

#define WARNING_NO_AGON_USER @"No user profile selected! Without selected profile, there is no Award or Highscore support.\nHint: You may also create an offline-only user"
#define HINT_DISPLAY_HELP @"Please view the help screen to maximise your fun! Do not forget to shake your device!"

//#define particleImg @"particleA.png"
#define fireImg @"bubble.pvr"
#define menuBackgroundImg @"Menu.png"

#define agonAwardImg @"sprite-award.png"
#define helpscreen1 @"screen-help1.png"
#define helpscreen2 @"screen-help2.png"
#define helpscreen3 @"screen-help3.png"
#define helpscreen4 @"screen-help4.png"
#define aboutImg @"screen-about.png"

#define menuFontSize 50
#define menuFontName @"Georgia"

#define zOrderHud 10

#define PLAY_SCENE_LEVEL_DONE red:220 green:220 blue:230
#define PLAY_SCENE_LEVEL_START red:180 green:200 blue:200

#define MAX_LEVEL 25

#define CONFIGUREDFPS 50.0f
#define DISPLAY_DELAY 1.1f

//todo: get dynamic size                                                                                            
#define XSIZE 320                                                                                                   
#define YSIZE 480     

#define MSG_PARTICLE_HIGHLIGHT @"particleHighlight"
#define MSG_PARTICLE_HIGHLIGHT_CLEAR @"particleHighlightClear"
#define MSG_PARTICLE_BLOWN_UP @"particleBlownup"
#define MSG_PARTICLE_DELETED @"particleDeleted"
#define MSG_SHAKE @"shake"

#define MSG_GAME_OVER @"gameOver"
#define MSG_GAME_FINISHED @"gameWon"
#define MSG_GAME_LEVEL_DONE @"gameLevelDone"
#define MSG_GAME_LEVEL_RETRY @"gameLevelRetry"
#define MSG_GAME_NEXT_LEVEL @"gameNextLevel"
#define MSG_GAME_CHAIN_REACTION_STARTED @"gameChainReactionStarted"
#define MSG_AWARD_UNLOCKED @"awardUnlocked"

#define MSG_POWERUP_X2 @"powerupx2"

typedef enum {
	kNormal,
	kBlownup,
	kShrink,
	kFadeAway,
	kDelete,
	kFadeAwayDeleted
} ParticleStatus;

typedef enum {
	kDisplayLevel,
	kWaitOnInitialClick,
	kGameIsRunning,
	kFadeOutCurrentLevel,
	kNextLevel,
	kFinished,
	kGameOver,
	kWaitForNextLevel,
	kDummy
} GameStatus;

typedef enum {
	kTouchNone,
	kTouchMoved,
	kTouchClickEnded
} TouchStatus;

//status for sound engine
#define SND_ID_LEVEL 0
#define SND_ID_BLUB 1
#define SND_ID_BLUB_BIG 2
#define SND_ID_CLICK 3
#define SND_ID_LEVEL_NAME @"sndLevelA.caf"
#define SND_ID_BLUB_NAME @"sndBlubA.caf"
#define SND_ID_BLUB_BIG_NAME @"sndBlubBigA.caf"
#define SND_ID_CLICK_NAME @"clickA.caf"

#define MUSIC_GAME @"gnx-virus.mp3"
//Channel group ids, the channel groups define how voices
//will be shared.  If you wish you can simply have a single
//channel group and all sounds will share all the voices
#define CGROUP_LEVEL_SND 0
#define CGROUP_FX 1
//#define CGROUP_NON_INTERRUPTIBLE 4

#define CGROUP_TOTAL 2

typedef enum {
	kAppStateAudioManagerInitialising,	//Audio manager is being initialised
	kAppStateSoundBuffersLoading,		//Sound buffers are loading
	kAppStateReady						//Everything is loaded
} sndAppState;
//sound end

#define kSpecialFunctionDoubleRadius 3
#define kSpecialFunctionHalfRadius 5
#define kSpecialFunctionHalfLifetime 6
#define kSpecialFunctionDoubleLifetime 7
#define kSpecialFunctionEvil 9

#define kSpecialFunctionPowerupOneLife 11
#define kSpecialFunctionPowerupX2Bonus 12
#define kSpecialFunctionPowerupLifeTimeKiller 13

typedef struct _michuParticle
{
	CGPoint			pos;
	int				size;
	int				blownUpSize;
	int				pulseRadius;
	int				pulseSeed;
	
	int				specialFunction;
		
	float			headingDirection;
	float			speed;
	int				dir;
	
	float			angle;
	float			deltaAngle;
	
	unsigned char   inTouchRange;
	
	ccColor4F		specialColor;
	ParticleStatus	status;
	//lifetime in seconds
	float				lifetime;
} MichuParticle;

#define degreesToRadian(x) (M_PI * (x) / 180.0) 

//used for the very fast sqrt function (http://www.finesse.demon.co.uk/steven/sqrt.html)
typedef unsigned uint32;
#define iter1(N) \
try = root + (1 << (N)); \
if (n >= try << (N))   \
{   n -= try << (N);   \
root |= 2 << (N); \
}

