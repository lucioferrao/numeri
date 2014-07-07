

#import <UIKit/UIKit.h>
#import "BoardView.h"
#import "SoundEffect.h"
#import "TransitionView.h"


@interface AppDelegate : NSObject <UIApplicationDelegate> {
	
@public
	
	UIWindow *window;
	BoardView *boardView;
	CBoard *nextBoard;
	NSData *prevBoard;
	NSData *prevBoardSol;
	UIButton *next;
	UIButton *prev;
	UIButton *about;
	UIButton *upgrade;
	bool showCongrats;
	UIButton *toggleSwitch;
	IBOutlet TransitionView *transitionView;
	int counterOk;
	
	bool switchMode;
	
	UIView *aboutView;
	UIWebView *aboutContentView;
	UIButton *aboutCloseButton;
	UIButton *congratulationsButton;
	
	UIActivityIndicatorView *pleaseWaitView;
	
	NSThread *generationThread;
	
	UIAccelerationValue	myAccelerometer[3];
	SoundEffect			*erasingSound;
	//SoundEffect			*selectSound;
	SoundEffect			*congratsSound;
	bool firstTime;
	bool disableInput;
	
	CFTimeInterval		lastTime;
	bool facingDown;
	
	UIImage *prevImage;
	UIImage *conImage;
	UIImage *squareImage;
	NSURL *iTunesURL;
}


@property (nonatomic, retain) UIImage *prevImage;
@property (nonatomic, retain) UIImage *conImage;
@property (nonatomic, retain) UIImage *squareImage;
@property (nonatomic, retain) CBoard *nextBoard;
@property (nonatomic, retain) NSThread *generationThread;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) BoardView *boardView;
@property (nonatomic, retain) UIButton *toggleSwitch;
@property (nonatomic, retain) UIButton *next;
@property (nonatomic, retain) UIButton *prev;
@property (nonatomic, retain) UIButton *about;
@property (nonatomic, retain) UIView *aboutView;
@property (nonatomic, retain) UIWebView *aboutContentView;
@property (nonatomic, retain) UIButton *aboutCloseButton;
@property (nonatomic, retain) UIActivityIndicatorView *pleaseWaitView;
@property (nonatomic, retain) NSData *prevBoard;
@property (nonatomic, retain) NSData *prevBoardSol;
@property (nonatomic, retain) UIButton *congratulationsButton;
@property (nonatomic, retain) UIButton *upgrade;
@property (nonatomic, retain) NSURL *iTunesURL;



-(void)boardChanged;
-(void)boardSolved;
-(void)playSound;
-(void)animationStarted;
-(void)animationStopped;

@end
