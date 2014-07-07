//
//  CBoard.h
//  Board
//
//  Created by Lucio Ferrao on 09/04/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSArray.h>
#import "CNumber.h"
#import "CDot.h"





@interface CBoard : NSObject
{
@public
	int MaxX;
	int MaxY;
	CNumber *OutsideNumber;
	CDot*** Dot;
	CNumber*** Number;
	NSMutableArray *ConnectorList;
	NSMutableArray *AllConnectorList;
	NSData *solution;
}

@property (nonatomic, retain) NSData *solution;

-(void) Setup:(int)X Y:(int)Y ;
-(NSString *)toString;
-(NSData *) toBinary;
-(bool) LoadBinary:(NSData *)buffer clearUnknown:(bool)clearUnknown;
-(CBoard *)initFromBinary:(NSData *)buffer;
-(bool)Valid;
-(CBoard *)init:(int)X Y:(int)Y textBoard:(NSString *)Board simplify:(bool)bSimplify;
-(bool) MergeDots:(CDot*)dot1 dot2:(CDot*)dot2;
-(bool)MergeNumbers:(CConnector*)c changedConnectorList:(NSMutableArray*)changedConnectorList;
-(SimplifyResult) Simplify:(NSMutableArray *)changedConnectorList;
-(void)generatePuzzle:(int)count hard:(bool)hard;
-(void)Reduce:(bool)hard;
-(void)dealloc;
-(bool) IsSolved ;
-(bool) ShowUnfulfilled;
-(NSMutableArray *)HintList;
-(NSMutableArray *)NumberHintList;
-(void)AutoClear;
-(SimplifyResult)Simplify:(int)guesses singleStep:(bool)singleStep isTop:(bool)isTop parentWhatifConnector:(CConnector*)parentWhatifConnector changedConnectorList:(NSMutableArray*)changedConnectorList;
@end

