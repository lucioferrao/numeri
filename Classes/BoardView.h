
#import <UIKit/UIKit.h>
#import "CBoard.h"


extern int squaresize;
extern int dotsize; 
extern int linewidth;

extern int offsetX;
extern int offsetY;


@interface PathConnector : NSObject
{
	@public
	CConnector *Connector;
	ConnectorStatus PreviousStatus;
}

@end

@class AppDelegate;

@interface BoardView : UIView
{
	
@public
	
	CBoard *board;

	AppDelegate *app;
	CConnector *lastConnector;
	CDot *beforeLastDot;
	CDot *lastDot;

	bool ignoreTouches;
	bool numberMode;
	
	UIImage **numberImage;
	UILabel ***numberLabel;
	UIImage **dotImage;
	UIImage **dotImage2;
	UIImageView ***dotImageView;
	UIImageView ***numberImageView;

	
	NSMutableArray *connectorPath;
	CNumber *lastNum;
	
	NSMutableArray *animationConnectors;
	int animationStep;
	
	NSTimer *animationTimer;
	NSTimeInterval animationInterval;
	bool showHidden;
}


@property (nonatomic, retain) CBoard *board;
@property (nonatomic, retain) NSMutableArray *connectorPath;
@property (nonatomic) bool numberMode;
@property (nonatomic) bool showHidden;


- (void)redrawConnector:(CConnector *)con;
- (void)redrawNumber:(CNumber *)num;
- (void)redrawDot:(CDot *)dot;
-(void)ClearBoard;
-(void)showHint;
-(void)refreshView;
-(void)showSolution;
-(void)createImages;
-(void)startAnimation;

@end