//
//  CNumber.h
//  Board
//
//  Created by Lucio Ferrao on 09/04/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSArray.h>
#import "Enums.h"

@class CConnector;
@class CDot;


@interface CNumber : NSObject {
@public
	int Number; // 0, 1, 2, 3
	bool Hidden;
	int X;
	int Y;
	
	CConnector *Right;
	CConnector *Down;
	CConnector *Up;
	CConnector *Left;     	
	// Used in the Disjoint Set Forest for the topology checks
	CNumber *Parent;
	
	// true when this number and the parent number are on the same side of the border
	bool ParentSameSide; 
	
}


-(bool)StrictValid;
-(bool)Valid;
-(SimplifyResult)Simplify:(NSMutableArray *)changedConnectorList;
-(SimplifyResult) Replace:(ConnectorStatus)s1 s2:(ConnectorStatus)s2 changedConnectorList:(NSMutableArray *)changedConnectorList;
-(id)init:(int)x y:(int)y left:(CConnector *)left right:(CConnector *)right up:(CConnector *)up down:(CConnector *)down;
-(id)init;
-(bool)Fulfilled;
-(int) Count:(ConnectorStatus)s;
-(void)SwitchAll;
-(bool)IsNear:(CNumber*)num;
@end
