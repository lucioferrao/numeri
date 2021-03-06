
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

NSString *kNumberModeKey = @"NumberMode";	// preference key to obtain our restore the board

#define kAccelerometerFrequency			10 //Hz
#define kFilteringFactor				0.1
#define kMinEraseInterval				0.5
#define kEraseAccelerationThreshold		2.0


@implementation AppDelegate

@synthesize window, boardView, congratulationsButton, prevImage, conImage, squareImage, prevBoard, prevBoardSol, toggleSwitch, pleaseWaitView, next, prev, nextBoard, generationThread, about, aboutCloseButton, aboutView, aboutContentView;

const int columns = 4;
const int rows = 4;

NSString *kSavedBoardKey = @"SavedBoard";	// preference key to obtain our restore the board
NSString *kSavedSolutionBoardKey = @"SavedSolutionBoard";	// preference key to obtain our restore the board
NSString *kSavedCounterOk = @"CounterOk";


// Called when the accelerometer detects motion; plays the erase sound and redraws the view if the motion is over a threshold.
- (void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	UIAccelerationValue				length,
	x,
	y,
	z;
	
	//Use a basic high-pass filter to remove the influence of the gravity
	myAccelerometer[0] = acceleration.x * kFilteringFactor + myAccelerometer[0] * (1.0 - kFilteringFactor);
	myAccelerometer[1] = acceleration.y * kFilteringFactor + myAccelerometer[1] * (1.0 - kFilteringFactor);
	myAccelerometer[2] = acceleration.z * kFilteringFactor + myAccelerometer[2] * (1.0 - kFilteringFactor);
	// Compute values for the three axes of the acceleromater
	x = acceleration.x - myAccelerometer[0];
	y = acceleration.y - myAccelerometer[0];
	z = acceleration.z - myAccelerometer[0];
	
	//Compute the intensity of the current acceleration 
	length = sqrt(x * x + y * y + z * z);
	
	// If above a given threshold, play the erase sounds and erase the drawing view
	if((length >= kEraseAccelerationThreshold) && (CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval)) {
	//	[erasingSound play];
	//	[boardView ClearBoard];
	//	lastTime = CFAbsoluteTimeGetCurrent();
	}
	
	
	length = sqrt( acceleration.x*acceleration.x + acceleration.y*acceleration.y + acceleration.z*acceleration.z);
	
	if( !facingDown && length > .8 && length < 1.4 && acceleration.z > .8) {
		facingDown = true;
		boardView.showHidden = true;
		[boardView refreshView];
		//[boardView showHint];
		[erasingSound play];
	}
	if( facingDown && length > .8 && length < 1.4 && acceleration.z < .7 ) {
		facingDown = false;
		boardView.showHidden = false;
		[boardView refreshView];
		[erasingSound play];
	}
}


-(void)animationStarted {
	disableInput = true;
}

-(void)animationStopped {
	disableInput = false;
}

-(void) generateNextPuzzle:(id)info {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[NSThread setThreadPriority:0.1];
	
	CBoard *b = [[CBoard alloc] init];
	[b Setup:columns+1 Y:rows+1];
	
	[b generatePuzzle:columns*rows*(0.5+0.02*(random()%10)) hard:boardView->numberMode];
	
	self.nextBoard = [b autorelease];
	if( [pleaseWaitView isAnimating]) {
		[self newPuzzle];
		[window setNeedsDisplay];
	}
	[pleaseWaitView stopAnimating];
	next.hidden = false;
	[pool release];
}


-(void) startBackgroundPuzzleGeneration {
	NSThread *t = [[NSThread alloc] initWithTarget:self selector:@selector(generateNextPuzzle:) object:nil];
	[t start];
	self.generationThread = [t autorelease];
}

-(UIImage *) createFace:(bool)evil {
	
	const int squaresize = 46; 

	
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef c = CGBitmapContextCreate(	NULL,squaresize, squaresize, 
										   8, 0, colorSpace , kCGImageAlphaPremultipliedLast );
	
	CGContextTranslateCTM(c, 23, 23);
	CGContextSetLineCap(c, kCGLineCapButt);
	CGContextSaveGState(c);
	CGContextSetLineWidth(c, 2);

	CGContextSetRGBStrokeColor (c, 1, 1, 1, 1); 
	

	if( evil) {
		float glowWidth = 5.0;
		float invalidColorValues[] = { 1, .2, .2, 1 };
		CGColorRef invalidGlowColor = CGColorCreate( colorSpace, invalidColorValues );
		CGContextSetRGBStrokeColor (c, 1.0, .6, .6, 1); 
		CGContextSetShadowWithColor( c, CGSizeMake( 0, 0 ), glowWidth, invalidGlowColor );
	}
		
	CGContextAddEllipseInRect ( c, CGRectMake(-10,-10,20,20));
	CGContextStrokePath(c);
	
	
	float pi = 3.14159;

	if( evil) {
		CGContextAddArc(c, 0, 0, 5, 9*pi/8, 15*pi/8, 0);
		CGContextStrokePath(c);
		
		CGContextAddArc(c, -3, 3, 1, 6*pi/8, 15*pi/8, 0);
		CGContextStrokePath(c);
	
		CGContextAddArc(c, 3, 3, 1, 9*pi/8, 2*pi/8,  0);
		CGContextStrokePath(c);
	} else {
		CGContextAddArc(c, 0, 0, 5, 10*pi/8, 14*pi/8, 0);
		CGContextStrokePath(c);

		CGContextAddEllipseInRect ( c, CGRectMake(-4,2,1,1));
		CGContextAddEllipseInRect ( c, CGRectMake( 3,2,1,1));
		CGContextStrokePath(c);
	}
	
	CGContextRestoreGState(c);
	CGImageRef image = CGBitmapContextCreateImage( c);
	CGContextRelease( c);

	CGColorSpaceRelease( colorSpace );
	
	UIImage *img = [[[UIImage alloc] initWithCGImage:image] autorelease];
	
	CGImageRelease(image);

	return img;
	//UIImageView *imgview = [[UIImageView alloc] initWithImage:img];
	//imgview.frame = CGRectMake(22 + squaresize,480 - squaresize - 10,squaresize,squaresize);
	//[window addSubview:imgview];
}	

-(UIImage *) createButtonImage:(bool)forward glow:(bool)glow {
	
	const int squaresize = 46; 
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef c = CGBitmapContextCreate(	NULL,squaresize, squaresize, 
										   8, 0, colorSpace , kCGImageAlphaPremultipliedLast );
	
	CGContextTranslateCTM(c, 23, 23);
	if( !forward) {
		CGContextScaleCTM(c, -1, 1);
	}
	CGContextSaveGState(c);
	CGContextSetLineWidth(c, 1.5);

	CGContextSetRGBStrokeColor (c, 1, 1, 1, 1); 
	
	if( glow) {
		float glowWidth = 5.0;
		float invalidColorValues[] = { 1, .2, .2, 1 };
		CGColorRef invalidGlowColor = CGColorCreate( colorSpace, invalidColorValues );
		CGContextSetRGBStrokeColor (c, 1.0, .6, .6, 1); 
		CGContextSetShadowWithColor( c, CGSizeMake( 0, 0 ), glowWidth, invalidGlowColor );
	}
	
	if( false) {
		CGContextAddEllipseInRect ( c, CGRectMake(-10,-10,20,20));
		CGContextStrokePath(c);

		CGContextMoveToPoint(c, -4, 0);
		CGContextAddLineToPoint( c, -4, 4);
		CGContextAddLineToPoint(c, 1, 0);
		CGContextAddLineToPoint( c, -4, -4);
		CGContextAddLineToPoint( c, -4, 0);
		CGContextStrokePath(c);

		CGContextSetLineWidth(c, 2);
		CGContextMoveToPoint(c, 4, 5);
		CGContextAddLineToPoint( c, 4, -5);
		CGContextStrokePath(c);
	} else {

		CGContextSetLineJoin(c, kCGLineJoinRound);
		CGContextSetLineCap(c, kCGLineCapRound);
		CGContextSetLineWidth(c, 3);
		CGContextMoveToPoint(c, -8, 8);
		//CGContextAddLineToPoint( c, -8, 8);
		CGContextAddLineToPoint(c, 2, 0);
		CGContextAddLineToPoint( c, -8, -8);
		//CGContextAddLineToPoint( c, -8, 0);
		CGContextStrokePath(c);
		
	}
	
	CGContextRestoreGState(c);
	CGImageRef image = CGBitmapContextCreateImage( c);
	CGContextRelease( c);
	
	CGColorSpaceRelease( colorSpace );
	
	UIImage *img = [[[UIImage alloc] initWithCGImage:image] autorelease];
	
	CGImageRelease(image);
	
	return img;
}	


- (void)dealloc
{
	[boardView release];
    [window release];    
	[next release];
	[prev release];
	[toggleSwitch release];
	[transitionView release];
    [super dealloc];
}

-(void)setPrevImage {
	if( prevImage == nil) {
		self.prevImage = [self createButtonImage:false glow:false];
		self.squareImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"square" ofType:@"png"]];
		self.conImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connector" ofType:@"png"]];
	}
	
	
	if( !switchMode) {
		[prev setImage:prevImage forState:0];
	} else {
		if( boardView->numberMode) {
			[prev setImage:squareImage forState:0];
		} else {
			[prev setImage:conImage forState:0];
		}
	}
}




- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	const int squaresize = 46; 
	const int offsetX = 22;

	[application setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:true];
	[application setStatusBarHidden:false animated:true];

	NSBundle *mainBundle = [NSBundle mainBundle];

	srandomdev();
	
	disableInput = false;

	transitionView = [[TransitionView alloc] initWithFrame:window.frame];
	[window addSubview:transitionView];
	[transitionView setDelegate:self];
	
	counterOk = [[NSUserDefaults standardUserDefaults] integerForKey:kSavedCounterOk];
	/*
	self.counter = [[[UILabel alloc] initWithFrame:CGRectMake(200,0,100,18)] autorelease];
	counter.numberOfLines = 1;
	counter.font = [UIFont boldSystemFontOfSize:14];
	counter.textAlignment = UITextAlignmentCenter;
	counter.textColor = [UIColor whiteColor];
	counter.backgroundColor = [UIColor blackColor];
	[window addSubview:counter];
	[self UpdateCounter];
	*/
	
	self.aboutView = [[[UIView alloc] initWithFrame:CGRectMake(0,20,320,460)] autorelease];
	[aboutView setBackgroundColor:[UIColor blackColor]];
	
	self.aboutContentView = [[[UIWebView alloc] initWithFrame:CGRectMake(0,0,320,420)] autorelease];
	[aboutContentView setBackgroundColor:[UIColor blackColor]];
	[aboutContentView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"numeri" ofType:@"htm"]]]];
	
	[aboutView addSubview:aboutContentView];
	
	self.aboutCloseButton = [[[UIButton buttonWithType:0] initWithFrame:CGRectMake(100,425,120,30)] autorelease];
	[aboutCloseButton setTitle:NSLocalizedString( @"Play", @"Button to close about window") forState:0];
	[aboutCloseButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	aboutCloseButton.showsTouchWhenHighlighted = true;
	[aboutView addSubview:aboutCloseButton];
	

	
	
	
	// add the navigation controller's view to the window
	self.boardView = [[[BoardView alloc] initWithFrame:window.frame] autorelease];  
	boardView->app = self;
	
	
	NSData *savedBoard = [[[NSUserDefaults standardUserDefaults] objectForKey:kSavedBoardKey] autorelease];
	
	if( savedBoard != nil) {
		[transitionView addSubview:boardView];
	} else {
		[transitionView addSubview:aboutView];
	}

	boardView.numberMode = true;	
	if( savedBoard != nil) {
		//boardView.numberMode = [[NSUserDefaults standardUserDefaults] boolForKey:kNumberModeKey];
		boardView.board = [[CBoard alloc] initFromBinary:savedBoard];
		boardView.board->solution = [[[NSUserDefaults standardUserDefaults] objectForKey:kSavedSolutionBoardKey] autorelease];
	} else {
		boardView.board = [[CBoard alloc] init];
		[boardView.board Setup:columns+1 Y:rows+1];		
		//[boardView.board generatePuzzle:columns*rows*0.5 hard:false];
		firstTime = true;
	}
	
	if( !boardView.numberMode) {
		[boardView.board AutoClear];
	}
	
	if( [boardView.board IsSolved]) {
		showCongrats = false;
	} else {
		showCongrats = true;
	}

	[boardView createImages];




	if( false) {
		self.toggleSwitch = [[[UIButton buttonWithType:0] initWithFrame:CGRectMake(offsetX, 430, squaresize, squaresize)] autorelease];
		boardView.numberMode = [[NSUserDefaults standardUserDefaults] boolForKey:kNumberModeKey];
		toggleSwitch.showsTouchWhenHighlighted = true;
		[toggleSwitch setImage:[self createFace:boardView.numberMode] forState:0];	
		[toggleSwitch addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventTouchUpInside];
		[boardView addSubview:toggleSwitch];
	}
	
	
	
	self.about = [[[UIButton buttonWithType:0] initWithFrame:CGRectMake(120,431,80,40)] autorelease];
	about.showsTouchWhenHighlighted = true;
	[about setImage:[UIImage imageWithContentsOfFile:[mainBundle pathForResource:@"Numeri" ofType:@"png"]] forState:0];
	[about addTarget:self action:@selector(AboutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[boardView addSubview:about];

	self.congratulationsButton = [[[UIButton buttonWithType:0] initWithFrame:CGRectMake(110,433,120,40)] autorelease];
	congratulationsButton.showsTouchWhenHighlighted = true;
	//[congratulationsButton setImage:[UIImage imageWithContentsOfFile:[mainBundle pathForResource:@"congrats" ofType:@"png"]] forState:0];
	//[congratulationsButton setTitle:NSLocalizedString( @"Congratulations", @"Congratulations Message") forState:0];
	congratulationsButton.hidden = true;
	[congratulationsButton setFont:[UIFont systemFontOfSize:26]];
	[congratulationsButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[boardView addSubview:congratulationsButton];
		
	
	self.prev = [[[UIButton buttonWithType:0] initWithFrame:CGRectMake(offsetX,430,squaresize,squaresize)] autorelease];
	prev.showsTouchWhenHighlighted = true;
	[prev setImage:[self createButtonImage:false glow:false] forState:0];
	//[self setPrevImage];
	switchMode = false;
	[prev addTarget:self action:@selector(prevButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[boardView addSubview:prev];	


	
	self.next = [[[UIButton buttonWithType:0] initWithFrame:CGRectMake(squaresize*5+offsetX,430,squaresize,squaresize)] autorelease];
	next.showsTouchWhenHighlighted = true;
	[next setImage:[self createButtonImage:true glow:false] forState:0];
	[next addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[boardView addSubview:next];
	
	self.pleaseWaitView = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(squaresize*5.5+offsetX-10, 430+squaresize/2-10, 20, 20)] autorelease];
	[boardView addSubview:pleaseWaitView];
	
	[window makeKeyAndVisible];
	
	//Load the sounds
	
	erasingSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Erase" ofType:@"caf"]];
	//selectSound =  [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Select" ofType:@"caf"]];
	congratsSound =  [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"success" ofType:@"caf"]];
	
	
	//Configure and enable the accelerometer
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	[self startBackgroundPuzzleGeneration];
}




- (IBAction)switchAction {
	bool newState = !boardView.numberMode;
	boardView.numberMode = newState;
	[[NSUserDefaults standardUserDefaults] setBool:newState forKey:kNumberModeKey];
	[toggleSwitch setImage:[self createFace:boardView.numberMode] forState:0];
	//[next setImage:[self createSkipForward:boardView.numberMode] forState:0];

	//[toggleSwitch setTitle:(boardView.numberMode ? @" [] " : @" -- ") forState:UIControlStateNormal];
	[boardView ClearBoard];
	[erasingSound play];
	//[transitionView replaceSubview:boardView withSubview:boardView transition:kCATransitionPush direction:kCATransitionFromRight duration:0.75];


	//boardView.hidden = !boardView.hidden;
	//boardView.frame = CGRectMake(0,200, window.frame.size.width, window.frame.size.height);
}

-(void)boardChanged {
	[[NSUserDefaults standardUserDefaults] setObject:[boardView.board toBinary] forKey:kSavedBoardKey];	
}

-(void) newPuzzle {
	
	[next setImage:[self createButtonImage:true glow:false] forState:0];

	if( self.nextBoard == nil) {
		[pleaseWaitView startAnimating];
		next.hidden = true;
		return;
	}
	[erasingSound play];
	
	congratulationsButton.hidden = true;
	about.hidden = false;
	
	showCongrats = true;
	
	boardView.board = self.nextBoard;
	self.nextBoard = nil;
	boardView.showHidden = false;

	[self startBackgroundPuzzleGeneration];
		
	[boardView ClearBoard];

	[self boardChanged];
	[[NSUserDefaults standardUserDefaults] setObject:boardView.board->solution forKey:kSavedSolutionBoardKey];		

}


-(void)prevButtonPressed {
	
	if( disableInput) return;
	
	if( prevBoard != nil) {
		[boardView->board LoadBinary:prevBoard clearUnknown:false];
		self.prevBoard = nil;
		[boardView refreshView];
		[erasingSound play];
		return;
	}

	[boardView ClearBoard];
	[erasingSound play];	

	return;
	
	
	if( switchMode) {
		bool newState = !boardView.numberMode;
		boardView.numberMode = newState;
		
		[self setPrevImage];
		[[NSUserDefaults standardUserDefaults] setBool:newState forKey:kNumberModeKey];
	} else {
		[boardView ClearBoard];
		[erasingSound play];	
		switchMode = true;
		[self setPrevImage];
	}		
}

-(void)nextButtonPressed {
	
	if( disableInput) return;
	
	if( [boardView.board IsSolved] || boardView.board->solution == nil) {
		self.prevBoard = nil;		
		[self newPuzzle];

	} else {
		[prev setImage:[self createButtonImage:false glow:false] forState:0];
		if( !switchMode) {
			self.prevBoard = [boardView->board toBinary];
		}
		[boardView showSolution];
	}
	switchMode = false;
	[self setPrevImage];
}


-(void)AboutButtonPressed {
	
	
	/*
	[CATransaction begin];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	//[UIView setAnimationRepeatCount:2];
	//[UIView setAnimationRepeatAutoreverses:true];
	[UIView setAnimationDelegate:about];
	//[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
	[CATransaction begin];
	CGAffineTransform transform;
	transform = CGAffineTransformMakeScale(1.2, 1.2);
	about.transform = transform;
	[CATransaction commit];
	[CATransaction begin];
	transform = CGAffineTransformMakeScale(1, 1);
	about.transform = transform;
	[CATransaction commit];
	[CATransaction commit];
	[UIView commitAnimations];
	return;
	*/
	
	if( disableInput) return;
	
	[transitionView replaceSubview:boardView withSubview:aboutView transition:kCATransitionPush direction:kCATransitionFromTop duration:0.75];
}

-(void)closeButtonPressed {
	[transitionView replaceSubview:aboutView withSubview:boardView transition:kCATransitionPush direction:kCATransitionFromBottom duration:0.75];
	[aboutContentView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"numeri" ofType:@"htm"]]]];
	if( firstTime) {
		firstTime = false;
		[self nextButtonPressed];
	}
}
-(void)playSound {
	if( switchMode) {
		[prev setImage:[self createButtonImage:false glow:false] forState:0];
		switchMode = false;
	}
	//[selectSound play];
}

-(void)boardSolved {
	
	
	if( !showCongrats) return;
	
	showCongrats = false;
	
	counterOk++;
	[[NSUserDefaults standardUserDefaults] setInteger:counterOk forKey:kSavedCounterOk];
	
	about.hidden = true;
	
	[congratulationsButton setTitle:[NSString stringWithFormat:@"%i \u2713", counterOk] forState:0];

	congratulationsButton.hidden = false;

	
	
	//[next setImage:[self createFace:false] forState:0];
	[congratsSound play];

	
	
	//[boardView startAnimation];
	
	
	//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"You completed the puzzle" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	//[alert show];
	//[alert release];
	
}

@end

