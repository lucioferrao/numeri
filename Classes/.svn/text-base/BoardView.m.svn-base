

#import "BoardView.h"

#import "CBoard.h"
#import "CDot.h"
#import "CConnector.h"
#import "Enums.h"
#import "AppDelegate.h"


@implementation PathConnector
@end

@implementation BoardView

@synthesize board, connectorPath, numberMode, showHidden;





const int squaresize = 56;
const int dotsize = 5; 
const int linewidth = 3;

const int offsetX = 20;
const int offsetY = 60;


void DrawCorner( CGContextRef c, int x, int y) {
	CGContextBeginPath( c);
	CGContextMoveToPoint(c, x, 0);
	CGContextAddCurveToPoint( c, 0, 0, 0, 0, 0, y);
	CGContextAddLineToPoint(c, x, y);
	CGContextClosePath(c);
	CGContextDrawPath(c, kCGPathFillStroke);
}

void DrawCorner2( CGContextRef c, int x, int y) {
	CGContextBeginPath( c);
	CGContextMoveToPoint(c, x, 0);
	CGContextAddCurveToPoint( c, 0, 0, 0, 0, 0, y);
	CGContextAddLineToPoint(c, -x, y);
	CGContextAddLineToPoint(c, -x, -y);
	CGContextAddLineToPoint(c, x, -y);
	CGContextClosePath(c);
	CGContextDrawPath(c, kCGPathFillStroke);
}


void DrawRectangle( CGContextRef c, int x1, int x2, int y1, int y2) {
	CGContextMoveToPoint(c, x1, y1);
	CGContextAddLineToPoint(c, x1, y2);
	CGContextAddLineToPoint(c, x2, y2);
	CGContextAddLineToPoint(c, x2, y1);
	CGContextClosePath(c);
	CGContextDrawPath(c, kCGPathFillStroke);
}

-(void)createNumberImages {

//	int offsetX = (self.frame.size.width - rows * squaresize ) / 2;
//	int offsetY = (self.frame.size.height - columns * squaresize) / 2;
		
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	
	numberImage = calloc(10, sizeof(id));
	for( int i=0; i<10; i++) {
		CGContextRef c = CGBitmapContextCreate(	NULL, squaresize, squaresize, 
										   8, 0, colorSpace , kCGImageAlphaPremultipliedLast );
		CGContextSaveGState(c);
	
		CGAffineTransform textxform = CGAffineTransformMake( 1.0 , 0.0, 0.0, 1.0, 0, 0);
	
		CGContextSelectFont (c, "Helvetica", 0.6*squaresize, kCGEncodingMacRoman);
		CGContextSetCharacterSpacing (c, 10);
		CGContextSetTextDrawingMode (c, kCGTextFill);
	
		CGContextSetTextMatrix(c, textxform);
		CGContextTranslateCTM( c, squaresize*.35, squaresize*.3);
		float glowWidth = 5.0;
		float invalidColorValues[] = { 1, .2, .2, 1 };
		//float validColorValues[] = { .1, .1, .1, 1 };
		colorSpace = CGColorSpaceCreateDeviceRGB();
		CGColorRef invalidGlowColor = CGColorCreate( colorSpace, invalidColorValues );
		char *numbers[5] = { "0", "1", "2", "3", "?" };

	

		if( i < 5) {
			CGContextSetRGBFillColor (c, 1.0, 1.0, 1.0, 1); 
			CGContextSetShadowWithColor( c, CGSizeMake( 0, 0 ), glowWidth, 
										 nil );
		} else {
			CGContextSetRGBFillColor (c, 1.0, .6, .6, 1); 
			CGContextSetShadowWithColor( c, CGSizeMake( 0, 0 ), glowWidth, 
										invalidGlowColor );
		}
		
		char *text = numbers[ i % 5 ];
		CGContextShowTextAtPoint( c, 0, 0, text, 1);
		CGContextStrokePath(c);
		
		CGContextRestoreGState(c);
		CGImageRef image = CGBitmapContextCreateImage( c);
		CGContextRelease( c);
		
		UIImage *img = [[UIImage alloc] initWithCGImage:image];
		numberImage[i] = img;
	}
	
	
	
	numberLabel = calloc(board->MaxX,sizeof(id));

	numberImageView = calloc(board->MaxX, sizeof(id));
	
	for( int x=0; x< board->MaxX-1; x++) {
		numberLabel[x] = calloc( board->MaxY, sizeof(id));
		numberImageView[x] = calloc(board->MaxY, sizeof(id));
		for( int y=0; y<board->MaxY-1; y++) {			
			CGRect numberFrame = CGRectMake( x*squaresize + offsetX, y*squaresize + offsetY,  squaresize, squaresize);				
			UIImageView *iv = [[UIImageView alloc] initWithFrame:numberFrame];
			numberImageView[x][y] = iv;
			iv.image = nil;
			[self addSubview:iv];
			
		}
	}
	CGColorSpaceRelease( colorSpace );
}	
	
void CGSetConnectorColor( CGContextRef c, ConnectorStatus s) {
	if( s == StatusSet) 
		CGContextSetRGBStrokeColor(c, 1, 1, 1, 1.0);
	if( s == StatusUnset) 
		CGContextSetRGBStrokeColor(c, 0.2, 0.2, 0.2, 1);
	if( s == StatusUnknown) 
		CGContextSetRGBStrokeColor(c, 0.2, 0.2, 0.2, 1);
}


-(void) createBackgroundGrid {

	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef c = CGBitmapContextCreate(	NULL, squaresize * board->MaxX+1, squaresize * board->MaxY+1, 
											   8, 0, colorSpace , kCGImageAlphaPremultipliedLast );
	

	CGContextTranslateCTM(c, 1, 1);
	CGContextSetLineCap(c, kCGLineCapRound);
	CGContextSaveGState(c);
	CGSetConnectorColor(c, StatusUnset);
	CGContextSetLineWidth(c, 1);
	for( int x=0; x< board->MaxX; x++) {
		for( int y=0; y<board->MaxY; y++) {			
			if( x+1<board->MaxX) {
				CGContextMoveToPoint(c, x*squaresize+dotsize, y*squaresize);
				CGContextAddLineToPoint(c, (x+1)*squaresize-dotsize,  y*squaresize);
			}
			if( y+1<board->MaxY) {
				CGContextMoveToPoint(c,  x*squaresize,  y*squaresize+dotsize);
				CGContextAddLineToPoint(c,  x*squaresize,  (y+1)*squaresize-dotsize);
			}			
		}
	}
	CGContextStrokePath(c);
	CGContextRestoreGState(c);
	CGImageRef image = CGBitmapContextCreateImage( c);
	CGContextRelease( c);

	UIImage *img = [[UIImage alloc] initWithCGImage:image];
	UIImageView *imgview = [[UIImageView alloc] initWithImage:img];
	CGRect p;
	p.origin.x = offsetX-1;
	p.origin.y = offsetY-1-squaresize;
	p.size = img.size;
	imgview.frame = p;
	[self addSubview:imgview];
	CGColorSpaceRelease( colorSpace );
}	
	
-(void)createDotImages {
	
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

	dotImage = calloc(3*3*3*3, sizeof(id));
	
	for(int i=0; i<3*3*3*3; i++) {
		CGContextRef c = CGBitmapContextCreate(	NULL, squaresize, squaresize, 
													 8, 0, colorSpace , kCGImageAlphaPremultipliedLast );
		

		
		CGContextSaveGState(c);
		
		CGContextSetLineCap(c, kCGLineCapRound);
		CGContextTranslateCTM( c, squaresize / 2, squaresize / 2);
		int horizontal;
		int vertical;
		
		ConnectorStatus left = i % 3;
		ConnectorStatus down = (i/3) % 3;
		ConnectorStatus right = (i/3/3) % 3;
		ConnectorStatus up = (i/3/3/3) %3 ;

		
		/*
		CGContextSetLineWidth(c, 1);
		
		if( up == StatusUnknown) {
			CGSetConnectorColor( c, up);
			CGContextMoveToPoint(c, 0, 0.6*squaresize);
			CGContextAddLineToPoint(c, 0, dotsize);
			CGContextStrokePath(c);
		}
	
		if( down == StatusUnknown) {
			CGSetConnectorColor( c, down);
			CGContextMoveToPoint(c, 0, -0.6*squaresize);
			CGContextAddLineToPoint(c, 0, -dotsize);
			CGContextStrokePath(c);
		}
			
		if( left == StatusUnknown) {
			CGSetConnectorColor( c, left);
			CGContextMoveToPoint(c,  -0.6*squaresize, 0);
			CGContextAddLineToPoint(c,  -dotsize, 0);
			CGContextStrokePath(c);
		}
			
		if( right == StatusUnknown) {
			CGSetConnectorColor( c, right);
			CGContextMoveToPoint(c, 0.6*squaresize, 0);
			CGContextAddLineToPoint(c, dotsize, 0);
			CGContextStrokePath(c);
		}
		
		*/
		
		int countSet = (left==StatusSet ? 1 : 0) +(right==StatusSet ? 1 : 0) +(up==StatusSet ? 1 : 0) +(down==StatusSet ? 1 : 0); 
		
		CGSetConnectorColor( c, StatusSet);
		CGContextSetLineWidth(c, linewidth);



		
		if( countSet == 2 && !((left==StatusSet&&right==StatusSet)||(up==StatusSet&&down==StatusSet))) {
			horizontal = ( left == StatusSet) ? -1 : 1;
			vertical = ( down == StatusSet) ? -1 : 1; 
		
			CGContextBeginPath( c);
			CGContextSetRGBFillColor (c, 0, 0, 1, .3); 
			CGContextMoveToPoint(c, (0.6 *horizontal) *squaresize, 0);
			CGContextAddCurveToPoint( c, 0, 0, 0, 0, 0, (0.6 *vertical)*squaresize);
			CGContextDrawPath(c, kCGPathStroke);
		} else {
			if( countSet != 0 && countSet != 2) {
				CGContextSaveGState(c);
				float glowWidth = 4.0;
				float colorValues[] = { 1, .2, .2, 1 };
				CGColorRef glowColor = CGColorCreate( colorSpace, colorValues );
				CGContextSetShadowWithColor( c, CGSizeMake( 0, 0 ), glowWidth, glowColor );
				if( false) {
					CGRect rec;
					rec.origin.x = - dotsize;
					rec.origin.y = - dotsize;
					rec.size.width = dotsize*2;
					rec.size.height = dotsize*2;
					CGContextSetRGBFillColor (c, 1.0, .2, .2, 1); 
					CGContextFillEllipseInRect( c, rec);
				} else {
					
					float xsize = 1.5*dotsize;
					CGContextSetRGBStrokeColor (c, 1.0, 0.6, 0.6, 1); 
					CGContextMoveToPoint(c, xsize, xsize );
					CGContextAddLineToPoint(c, -xsize, -xsize  );
					CGContextMoveToPoint(c, xsize, -xsize );
					CGContextAddLineToPoint(c, -xsize, xsize  );
				}
				
				CGContextStrokePath(c);
				CGContextRestoreGState(c);				
			}
			
			if( up==StatusSet || down==StatusSet) {
				CGContextMoveToPoint(c, 0,  ( up==StatusSet ? 0.6*squaresize : 0) );
				CGContextAddLineToPoint(c, 0, - ( down==StatusSet? 0.6*squaresize : 0) );
			}
			if( left==StatusSet || right==StatusSet) {
				CGContextMoveToPoint(c, - ( left==StatusSet ? 0.6*squaresize : 0), 0 );
				CGContextAddLineToPoint(c, ( right==StatusSet? 0.6*squaresize : 0), 0 );
			}
			
			CGContextStrokePath(c);
		}
		
		

		
		CGContextStrokePath(c);

		
		CGContextRestoreGState(c);
		
		
		CGImageRef image = CGBitmapContextCreateImage( c);
		CGContextRelease( c);
		
		UIImage *img = [[UIImage alloc] initWithCGImage:image];
		dotImage[i] = img;

	}
	
	dotImageView = calloc( board->MaxX, sizeof(id));
	
	for( int x=0; x< board->MaxX; x++) {
		dotImageView[x] = calloc( board->MaxY, sizeof(id));
		for( int y=0; y<board->MaxY; y++) {	
			UIImage *img = dotImage[[board->Dot[x][y] dotImage]];
			UIImageView *imgview = [[UIImageView alloc] initWithImage:img];
			CGRect p;
			p.origin.x = (x-.5) * squaresize + offsetX;
			p.origin.y = (y-.5) * squaresize + offsetY;
			p.size.width = squaresize;
			p.size.height = squaresize;
			imgview.frame = p;
			[self addSubview:imgview];
			dotImageView[x][y] = imgview;
		}
	}
	CGColorSpaceRelease( colorSpace );
}

-(void)createDotImages2 {
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	dotImage2 = calloc(16, sizeof(id));
	
	for(int i=0; i<16; i++) {
		CGContextRef c = CGBitmapContextCreate(	NULL, squaresize, squaresize, 
											   8, 0, colorSpace , kCGImageAlphaPremultipliedLast );
		
		
		
		CGContextSaveGState(c);
		
		CGContextSetRGBStrokeColor(c, 1, 1, 1, 1);
		CGContextSetLineWidth(c, linewidth);
		CGContextSetLineCap(c, kCGLineCapRound);
		CGContextTranslateCTM( c, squaresize / 2, squaresize / 2);
		CGContextScaleCTM(c, squaresize*0.6, squaresize*0.6);
		CGContextBeginPath( c);
		CGContextSetRGBFillColor(c, 0, 0, 1, .3);
		
		switch( i ) {
			case 0:
				break;
			case 15:
				DrawRectangle( c, -1, 1, -1, 1);
				break;				
			case 1:
				DrawCorner( c, -1, -1);
				break;				
			case 2:
				DrawCorner( c, 1, -1);
				break;
			case 4:
				DrawCorner( c, 1, 1);
				break;
			case 8:
				DrawCorner( c, -1, 1);
				break;
			case 5:
				DrawCorner( c, -1, -1);
				DrawCorner( c, 1, 1);
				break;
			case 10:
				DrawCorner( c, 1, -1);
				DrawCorner( c, -1, 1);
				break;
			case 3:
				DrawRectangle( c, -1, 1, -1, 0);
				break;
			case 6:
				DrawRectangle( c, 0, 1, -1, 1);
				break;
			case 12:
				DrawRectangle( c, -1, 1, 0, 1);
				break;
			case 9:
				DrawRectangle( c, -1, 0, -1, 1);
				break;
			case 14:
				DrawCorner2( c, -1, -1);
				break;
			case 13:
				DrawCorner2( c, 1, -1);
				break;
			case 11:
				DrawCorner2( c, 1, 1);
				break;
			case 7:
				DrawCorner2( c, -1, 1);
				break;
		}
		
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		CGImageRef image = CGBitmapContextCreateImage( c);
		CGContextRelease( c);
		
		UIImage *img = [[UIImage alloc] initWithCGImage:image];
		dotImage2[i] = img;
		
	}
	
	
	CGColorSpaceRelease( colorSpace );
	
}



-(void)refreshView {
	
	bool showUnfulfilled = true;// [board ShowUnfulfilled];
	
	for( int x=0; x< board->MaxX; x++) {
		for( int y=0; y<board->MaxY; y++) {	
			dotImageView[x][y].image = dotImage[[board->Dot[x][y] dotImage]];
		}
	}
	for( int x=0; x< board->MaxX-1; x++) {
		for( int y=0; y<board->MaxY-1; y++) {
			[self redrawNumber:board->Number[x][y]];
		}
	}
	
}





-(void)createImages {
	
	if( board != nil) {
		[self createBackgroundGrid];
		[self createNumberImages];
		[self createDotImages];
		[self refreshView];

	}
}

-(void)ClearBoard {
	
	for( CConnector *c in board->ConnectorList) {
		if( numberMode) {
			c->Status = StatusUnset;
		} else {
			c->Status = StatusUnknown;
		}
	}
	
	if( !numberMode) {
		[board AutoClear];
	}
	[self refreshView];
}

- (void)stopAnimation
{
	[animationTimer invalidate];
	animationTimer = nil;
	[animationConnectors release];
	animationConnectors = nil;
	
	[app boardChanged];

	[app animationStopped];
}


- (void)animate {
	
	if( animationStep >= [animationConnectors count]) {
		[self stopAnimation];
	} else {
		
		if( numberMode) {
			CNumber *n = [animationConnectors objectAtIndex:animationStep];
			[n SwitchAll];	
		} else {
				
			CConnector *c = [animationConnectors objectAtIndex:animationStep];
			c->Status = (c->Status == StatusSet ? StatusUnknown : StatusSet);
			[board AutoClear];
		}
		[self refreshView];
		animationStep++;
	}
	
}




- (void)startAnimation
{
	animationInterval = 1.0/25;
	[self stopAnimation];
	
	if( numberMode) {
		animationConnectors = [board NumberHintList];
	} else {
		animationConnectors = [board HintList];
	}
	[animationConnectors retain];
	animationStep = 0;
	app->showCongrats = false;

	[app animationStarted];
	
	animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(animate) userInfo:nil repeats:YES];
}


-(void)showSolution {
	[self startAnimation];
}


-(void) showHint {

	
	if( board->solution != nil) {
		NSMutableArray *newNumbers = [[[NSMutableArray alloc] init] autorelease];
		NSMutableArray *newInvalidNumbers = [[[NSMutableArray alloc] init] autorelease];
		CBoard *solution = [[[CBoard alloc] initFromBinary:board->solution] autorelease];
		for( int x=0; x<board->MaxX-1; x++) {
			for( int y=0; y<board->MaxY-1; y++) {
				if( board->Number[x][y]->Number == -1) {
					board->Number[x][y]->Number = solution->Number[x][y]->Number;
					if( ![board->Number[x][y] StrictValid]) {
						[newInvalidNumbers addObject:board->Number[x][y]];
					}
					[newNumbers addObject:board->Number[x][y]];					
					board->Number[x][y]->Number = -1;
				}
			}			
		}
		
		if( [newInvalidNumbers count] > 0) {
			CNumber *num = [newInvalidNumbers objectAtIndex:random()%[newInvalidNumbers count]];
			num->Number = solution->Number[num->X][num->Y]->Number;
			[self redrawNumber:num];
		} else {
			if( [newNumbers count] > 0) {
				CNumber *num = [newNumbers objectAtIndex:random()%[newNumbers count]];
				num->Number = solution->Number[num->X][num->Y]->Number;
				[self redrawNumber:num];
			}
		}
	}
}




-(void)drawPuzzle {
	
	/*
	
	// Preserve the current drawing state
	CGContextSaveGState(context);
	
	CGContextTranslateCTM( context, offsetX, offsetY);
	
	CGContextClearRect(context, view.bounds);

	
	CGContextSetLineCap(context, kCGLineCapRound);

	// Draw background grid
	
	
	CGContextSaveGState(context);
	
	CGContextSetRGBStrokeColor(context, 0.2, 0.2, 0.2, 1.0);
	CGContextSetLineWidth(context, 1);
	for( int x=0; x< board->MaxX; x++) {
		for( int y=0; y<board->MaxY; y++) {			
			if( x+1<board->MaxX) {
				CGContextMoveToPoint(context, x*squaresize+dotsize, y*squaresize);
				CGContextAddLineToPoint(context, (x+1)*squaresize-dotsize,  y*squaresize);
			}
			if( y+1<board->MaxY) {
				CGContextMoveToPoint(context,  x*squaresize,  y*squaresize+dotsize);
				CGContextAddLineToPoint(context,  x*squaresize,  (y+1)*squaresize-dotsize);
			}			
		}
	}
	CGContextStrokePath(context);
	
	CGContextRestoreGState(context);
	
	
	// Draw invalid dots
	
	CGContextSaveGState(context);
	float glowWidth = 4.0;
	float colorValues[] = { 1, .2, .2, 1 };
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef glowColor = CGColorCreate( colorSpace, colorValues );
	CGContextSetShadowWithColor( context, CGSizeMake( 0, 0 ), glowWidth, glowColor );
	
	
	bool invalidDots = false;
	
	for( int x=0; x< board->MaxX; x++) {
		for( int y=0; y<board->MaxY; y++) {	
			
			
			if( [board->Dot[x][y] showDotMarker]) {
				invalidDots = true;
				CGRect rec;
				rec.origin.x = x*squaresize - dotsize;
				rec.origin.y =  y*squaresize - dotsize;
				rec.size.width = dotsize*2;
				rec.size.height = dotsize*2;
				CGContextSetRGBFillColor (context, 1.0, .2, .2, 1); 
				CGContextFillEllipseInRect( context, rec);
			}
		}
	}
	CGContextRestoreGState(context);
	
	
	
	// Draw connectors
	
	CGContextSaveGState(context);

	CGContextSetRGBStrokeColor(context, 1, 1, 0.5 + 0.5*cos(2*0.31415926535897932*animationFrames), 1.0);
	CGContextSetLineWidth(context, linewidth);
	bool connectorsFound = false;

	for( int x=0; x< board->MaxX; x++) {
		for( int y=0; y<board->MaxY; y++) {	
			if( [board->Dot[x][y] Corner]) {
				int vertical=1;
				if( board->Dot[x][y]->Up->Status == StatusSet) {
					vertical = -1;
				}
				int horizontal = 1;
				if( board->Dot[x][y]->Left->Status == StatusSet) {
					horizontal = -1;
				}
				connectorsFound = true;
				CGContextMoveToPoint(context, 
									  (x + 0.6 *horizontal) *squaresize, 
									  y*squaresize);
				CGContextAddCurveToPoint( context,
										  (x + 0 *horizontal) *squaresize, 
										  y*squaresize,
										  x*squaresize, 
										  (y + 0 *vertical)*squaresize,
										  x*squaresize, 
										  (y + 0.6 *vertical)*squaresize);
			} else {
				if( board->Dot[x][y]->Up->Status == StatusSet || board->Dot[x][y]->Down->Status == StatusSet ) {
					CGContextMoveToPoint(context, x*squaresize, y*squaresize - (board->Dot[x][y]->Up->Status == StatusSet ? 0.6*squaresize : 0));
					CGContextAddLineToPoint(context, x*squaresize,  y*squaresize +  (board->Dot[x][y]->Down->Status == StatusSet ? 0.6*squaresize : 0) );
					connectorsFound = true;
				}
				if( board->Dot[x][y]->Left->Status == StatusSet || board->Dot[x][y]->Right->Status == StatusSet ) {
					CGContextMoveToPoint(context,  x*squaresize- (board->Dot[x][y]->Left->Status == StatusSet ? 0.6*squaresize : 0), y*squaresize );
					CGContextAddLineToPoint(context, x*squaresize+ (board->Dot[x][y]->Right->Status == StatusSet ? 0.6*squaresize : 0),  y*squaresize  );
					connectorsFound = true;
				}
			}
		}
	}
	CGContextStrokePath(context);
	CGContextRestoreGState(context);
	

	
	char *numbers[4] = { "0", "1", "2", "3" };
	
	NSLog( [board toString]);
	
	
	
	//CGAffineTransform textxform = CGAffineTransformRotate( CGAffineTransformMake(
	//													1.0,  0.0,
	//													0.0, -1.0,
	//													0, 0), animationFrames / 20.0 * 3.14159);
	
	
	// Draw numbers
	if( !connectorsFound) invalidDots = true;
	CGAffineTransform textxform = CGAffineTransformMake( 1.0 , 0.0, 0.0, -1.0, 0, 0);

	CGContextSelectFont (context, "Helvetica", 0.6*squaresize, kCGEncodingMacRoman);
	CGContextSetCharacterSpacing (context, 10);
	CGContextSetTextDrawingMode (context, kCGTextFill);
	
	CGContextSetTextMatrix(context, textxform);
	CGContextTranslateCTM( context, squaresize*.35, squaresize*.7);
	glowWidth = 5.0;
	float invalidColorValues[] = { 1, .2, .2, 1 };
	//float validColorValues[] = { .1, .1, .1, 1 };
	colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef invalidGlowColor = CGColorCreate( colorSpace, invalidColorValues );
	//CGColorRef validGlowColor = CGColorCreate( colorSpace, validColorValues );

	bool invalidNumbers = false;
	for( int x=0; x< board->MaxX; x++) {
		for( int y=0; y<board->MaxY; y++) {			
			if( board->Number[x][y]->Number != -1) {
				//CGContextSaveGState(context);


				bool valid = invalidDots ? [board->Number[x][y] Valid] : [board->Number[x][y] StrictValid];
				if( valid) {
					CGContextSetRGBFillColor (context, 1.0, 1.0, 1.0, 1); 
				} else {
					CGContextSetRGBFillColor (context, 1.0, .6, .6, 1); 
					invalidNumbers = true;
				}
				
				
				CGContextSetShadowWithColor( context, CGSizeMake( 0, 0 ), glowWidth, 
											valid ? nil : invalidGlowColor );
				
				char *text = numbers[board->Number[x][y]->Number];
			    CGContextShowTextAtPoint( context, x*squaresize,  
										 y*squaresize , text, 1);
				CGContextStrokePath(context);
				//CGContextRestoreGState(context);
			}
		}
	}

	// Preserve the current drawing state
	CGContextRestoreGState(context);


	if( !invalidDots && !invalidNumbers && animationTimer == nil) {
		[self startAnimation];
	}
	 
	 */
}





- (CConnector *)getConnectorAtLocation:(CGPoint)location margin:(float)margin {
	int x;
	int y;

	location.x -= offsetX;
	location.y -= offsetY;
	location.x /= squaresize;
	location.y /= squaresize;
	
	float dx=fabs(location.x-round(location.x));
	float dy=fabs(location.y-round(location.y));
	
	if( dx < margin && dy< margin) 
		return nil;
	if( fabs( dx-dy) < margin) 
		return nil;
	
	if( dx < dy) {
		// vertical
		x = round(location.x);
		y = trunc(location.y);
		if( x>=0 && y>=0 && x<board->MaxX && y<board->MaxY-1) {
			return board->Dot[x][y]->Down;
		}
	} else {
		// horizontal
		x = trunc(location.x);
		y = round(location.y);
		if( x>=0 && y>=0 && x<board->MaxX-1 && y<board->MaxY) {
			return board->Dot[x][y]->Right;
		}
	}
	return nil;
}

- (CNumber *)getNumberAtLocation:(CGPoint)location margin:(float)margin{
	int x;
	int y;
	
	location.x -= offsetX;
	location.y -= offsetY;
	location.x /= squaresize;
	location.y /= squaresize;
	location.x -= 0.5;
	location.y -= 0.5;

	float dx=fabs(location.x-round(location.x));
	float dy=fabs(location.y-round(location.y));
	
	if( dx < margin && dy< margin) {
		x = round(location.x);
		y = round(location.y);
		if( x>=0 && y>=0 && x<board->MaxX-1 && y<board->MaxY-1) {
			return board->Number[x][y];
		}
	}
	return nil;
}


- (CDot *)getDotAtLocation:(CGPoint)location margin:(float)margin {
	int x;
	int y;
	
	location.x -= offsetX;
	location.y -= offsetY;
	location.x /= squaresize;
	location.y /= squaresize;
	
	float dx=fabs(location.x-round(location.x));
	float dy=fabs(location.y-round(location.y));
	
	if( dx < margin && dy< margin) {
		// vertical
		x = round(location.x);
		y = round(location.y);
		if( x>=0 && y>=0 && x<board->MaxX && y<board->MaxY) {
			return board->Dot[x][y];
		}
		return nil;
	}
	
	return nil;
}


- (void)redrawDot:(CDot *)dot {
	dotImageView[dot->X][dot->Y].image = dotImage[[dot dotImage]];	
}

- (void)redrawNumber:(CNumber *)num {
	if( num->Hidden == false || showHidden) {
		//if( num->Hidden) {
		//	numberImageView[num->X][num->Y].image = numberImage[ [num StrictValid] ? 4 : 9];
		//} else {
		numberImageView[num->X][num->Y].image = numberImage[ [num StrictValid] ? num->Number : num->Number+5];
		//}
	} else {
		if( num->X != -1) {
			numberImageView[num->X][num->Y].image = nil;
		}
	}
}

- (void)redrawNumberAndConnectors:(CNumber *)num {

	[self redrawNumber:num];
	if( (num->X+2) < board->MaxX) [self redrawNumber:board->Number[num->X+1][num->Y]];
	if( (num->Y+2) < board->MaxY) [self redrawNumber:board->Number[num->X][num->Y+1]];
	if( num->X > 0) [self redrawNumber:board->Number[num->X-1][num->Y]];
	if( num->Y > 0) [self redrawNumber:board->Number[num->X][num->Y-1]];
	
	[self redrawDot:num->Up->Dot1];
	[self redrawDot:num->Up->Dot2];
	[self redrawDot:num->Down->Dot1];
	[self redrawDot:num->Down->Dot2];
}

- (void)redrawConnector:(CConnector *)con {
	[self redrawDot:con->Dot1];
	[self redrawDot:con->Dot2];
	[self redrawNumber:con->Number1];
	[self redrawNumber:con->Number2];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

	lastDot = nil;
	beforeLastDot = nil;
	ignoreTouches = false;
	self.connectorPath = [[[NSMutableArray alloc] init] autorelease];
	
	if( numberMode) {
		CNumber *num = [self getNumberAtLocation:[[touches anyObject] locationInView:self] margin:0.95];
		lastNum = num;
		if( num != nil) {
			[app playSound];
			[num SwitchAll];
			[self redrawNumberAndConnectors:num];
		}
		return;
	}
	
	CConnector *con = [self getConnectorAtLocation:[[touches anyObject] locationInView:self] margin:0.1];
	
	if( con == nil) {
		CDot *dot = [self getDotAtLocation:[[touches anyObject] locationInView:self] margin:0.25];
		if( dot != nil) {
			if( dot->X > 0 && [board->Dot[dot->X-1][dot->Y] Count:StatusSet] == 1) {
				con = dot->Left;
			} else if( dot->X+1 < board->MaxX && [board->Dot[dot->X+1][dot->Y] Count:StatusSet] == 1) {
				con = dot->Right;
			} else if( dot->Y > 0 && [board->Dot[dot->X][dot->Y-1] Count:StatusSet] == 1) {
				con = dot->Up;
			} else if( dot->Y+1 < board->MaxY && [board->Dot[dot->X][dot->Y+1] Count:StatusSet] == 1) {
				con = dot->Down;
			} else if( dot->X > 0 && dot->Y > 0 && [board->Dot[dot->X-1][dot->Y-1] Count:StatusSet] == 1) {
				if( board->Dot[dot->X-1][dot->Y-1]->Down->Status == StatusSet) {
					board->Dot[dot->X-1][dot->Y-1]->Down->Status = StatusUnknown;
					[self redrawConnector:board->Dot[dot->X-1][dot->Y-1]->Down];
					con = dot->Left;
				} else if( board->Dot[dot->X-1][dot->Y-1]->Right->Status == StatusSet) {
					board->Dot[dot->X-1][dot->Y-1]->Right->Status = StatusUnknown;
					[self redrawConnector:board->Dot[dot->X-1][dot->Y-1]->Right];
					con = dot->Up;
				}
			} else if( dot->X+1 < board->MaxX && dot->Y+1 < board->MaxY && [board->Dot[dot->X+1][dot->Y+1] Count:StatusSet] == 1) {
				if( board->Dot[dot->X+1][dot->Y+1]->Up->Status == StatusSet) {
					board->Dot[dot->X+1][dot->Y+1]->Up->Status = StatusUnknown;
					[self redrawConnector:board->Dot[dot->X+1][dot->Y+1]->Up];
					con = dot->Right;
				} else if( board->Dot[dot->X+1][dot->Y+1]->Left->Status == StatusSet) {
					board->Dot[dot->X+1][dot->Y+1]->Left->Status = StatusUnknown;
					[self redrawConnector:board->Dot[dot->X+1][dot->Y+1]->Left];
					con = dot->Down;
				}
			} else if( dot->X > 0 && dot->Y+1 < board->MaxY && [board->Dot[dot->X-1][dot->Y+1] Count:StatusSet] == 1) {
				if( board->Dot[dot->X-1][dot->Y+1]->Up->Status == StatusSet) {
					board->Dot[dot->X-1][dot->Y+1]->Up->Status = StatusUnknown;
					[self redrawConnector:board->Dot[dot->X-1][dot->Y+1]->Up];
					con = dot->Left;
				} else if( board->Dot[dot->X-1][dot->Y+1]->Right->Status == StatusSet) {
					board->Dot[dot->X-1][dot->Y+1]->Right->Status = StatusUnknown;
					[self redrawConnector:board->Dot[dot->X-1][dot->Y+1]->Right];
					con = dot->Down;
				}
			} else if( dot->X+1 < board->MaxX && dot->Y > 0 && [board->Dot[dot->X+1][dot->Y-1] Count:StatusSet] == 1) {
				if( board->Dot[dot->X+1][dot->Y-1]->Down->Status == StatusSet) {
					board->Dot[dot->X+1][dot->Y-1]->Down->Status = StatusUnknown;
					[self redrawConnector:board->Dot[dot->X+1][dot->Y-1]->Down];
					con = dot->Right;
				} else if( board->Dot[dot->X+1][dot->Y-1]->Left->Status == StatusSet) {
					board->Dot[dot->X+1][dot->Y-1]->Left->Status = StatusUnknown;
					[self redrawConnector:board->Dot[dot->X+1][dot->Y-1]->Left];
					con = dot->Up;
				}
			}
		}	
	}
	if( con != nil) {
		
		PathConnector *pc = [[PathConnector alloc] init];
		pc->Connector = con;
		pc->PreviousStatus = con->Status;

		[connectorPath addObject:pc];

		[app playSound];

		
		con->Status = (con->Status == StatusSet) ? StatusUnknown : StatusSet;
		//[self redrawConnector:con];
		[board AutoClear];
		[self refreshView];

	}

}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

	if( numberMode) {
		CNumber *num = [self getNumberAtLocation:[[touches anyObject] locationInView:self] margin:0.95];
		if( num != nil && num != lastNum) {
			lastNum = num;
			[app playSound];
			[num SwitchAll];
			[self redrawNumberAndConnectors:num];
		}
		return;
	}
	
	
	if( ignoreTouches) return;
	
	CConnector *con = [self getConnectorAtLocation:[[touches anyObject] locationInView:self] margin:0.1];
	if( con != nil) {
		
		if( [connectorPath count] == 0) {
			PathConnector *pc = [[PathConnector alloc] init];
			pc->Connector = con;
			pc->PreviousStatus = con->Status;
			con->Status =  (con->Status == StatusSet) ? StatusUnknown : StatusSet;
			[connectorPath addObject:pc];
			//[self redrawConnector:con];
			[board AutoClear];
			[app playSound];
			[self refreshView];

			return;				
		}
			
		PathConnector *last = [connectorPath lastObject];
		if( last->Connector == con) return;
			
		PathConnector *first = [connectorPath objectAtIndex:0];
		if( [connectorPath count] > 1) {
			PathConnector *beforeLast = [connectorPath objectAtIndex:[connectorPath count]-2];

			if( beforeLast->Connector == con) {
				last->Connector->Status = last->PreviousStatus;
				[self redrawConnector:last->Connector];
				[connectorPath removeLastObject];	
				[board AutoClear];
				[app playSound];
				[self refreshView];

				return;
			}
			if( [beforeLast->Connector GetCommonDot:con] != nil && [beforeLast->Connector GetCommonDot:con] == [last->Connector GetCommonDot:con]) {
				last->Connector->Status = last->PreviousStatus;
				[self redrawConnector:last->Connector];
				last->Connector = con;
				last->PreviousStatus = con->Status;
				last->Connector->Status = first->Connector->Status;
				[self redrawConnector:last->Connector];
				[board AutoClear];
				[app playSound];
				[self refreshView];

				return;
			}
			
			if( [last->Connector GetCommonNumber:con] != nil) {
				CDot *d = [beforeLast->Connector GetCommonDot:last->Connector];
				CConnector *c2 = [d GetConnectorTo:con];
				if( c2 == beforeLast->Connector) {
					last->Connector->Status = last->PreviousStatus;
					[self redrawConnector:last->Connector];
					[connectorPath removeObject:last];

					beforeLast->Connector->Status = beforeLast->PreviousStatus;
					[self redrawConnector:beforeLast->Connector];
					[connectorPath removeObject:beforeLast];
				} else {
				
					last->Connector->Status = last->PreviousStatus;
					[self redrawConnector:last->Connector];
					last->Connector = c2;
					last->PreviousStatus = c2->Status;
					last->Connector->Status = first->Connector->Status;
					[self redrawConnector:last->Connector];
				}

				PathConnector *pc = [[PathConnector alloc] init];
				pc->Connector = con;
				pc->PreviousStatus = con->Status;
				con->Status =  first->Connector->Status;
				[connectorPath addObject:pc];
				[self redrawConnector:con];
				[board AutoClear];
				[app playSound];
				[self refreshView];

				return;
			}
			
			
			
		}
		if( [last->Connector GetCommonDot:con] != nil) {
			PathConnector *pc = [[PathConnector alloc] init];
			pc->Connector = con;
			pc->PreviousStatus = con->Status;
			con->Status = first->Connector->Status;
			[connectorPath addObject:pc];
			[self redrawConnector:con];
			[board AutoClear];
			[app playSound];
			[self refreshView];

			return;
		}
		
		ignoreTouches = true;
	}
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

	self.connectorPath = nil;
	
	[app boardChanged];
	
	if( ![board IsSolved] ) return; 
	
	[app boardSolved];
}



@end