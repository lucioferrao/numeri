//
//  CNumber.m
//  Board
//
//  Created by Lucio Ferrao on 09/04/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CNumber.h"
#import "CDot.h"
#import "CConnector.h"



@implementation CNumber 

-(int) Count:(ConnectorStatus)s {
	if (Right == nil) return 0; // Special case for the "outside" number
	return (Right.Status == s ? 1 : 0) +
	(Left.Status == s ? 1 : 0) +
	(Up.Status == s ? 1 : 0) +
	(Down.Status == s ? 1 : 0);
}


// Creates the outside number (the only that doesn't have any connectors)
//public CNumber() {
//}

-(id)init:(int)x y:(int)y left:(CConnector *)left right:(CConnector *)right up:(CConnector *)up down:(CConnector *)down {
	if( (self=[super init])) {
		Right = right;
		Left = left;
		Up = up;
		Down = down;
		X = x;
		Y = y;
		Number = 0;
		Hidden = true;
	}
	return self;
}

-(id)init {
	if( (self=[super init])) {
		Number = 0;
		Hidden = true;
		X = -1;
		Y = -1;
		
	}
	return self;	
}

-(bool) StrictValid {
	return Number == [self Count:StatusSet];
}

-(bool) Valid {
	int c = [self Count:StatusSet];
	int u = [self Count:StatusUnknown];
	return (Hidden || (Number >= c && Number <= c + u));
}

-(bool) Fulfilled {
	return (Hidden || ([self Count:StatusSet] == Number));
}

-(bool)IsNear:(CNumber*)num {
	return abs(X-num->X)+abs(Y-num->Y)==1;
}


-(void)SwitchAll {
	[Up Switch];
	[Down Switch];
	[Left Switch];
	[Right Switch];
}

-(SimplifyResult) Simplify:(NSMutableArray *) changedConnectorList {
	int set = [self Count:StatusSet];
	int unknown = [self Count:StatusUnknown];
	if( !(set < 4 && (Hidden || (Number >= set && Number <= set + unknown))))
		return ResultInvalid;
	if( unknown == 0) 
		return ResultTerminal;
	if (Hidden) 
		return ResultIncomplete;
	if( Number == set)
		return [self Replace:StatusUnknown s2:StatusUnset changedConnectorList:changedConnectorList];	
	if (unknown == Number - set)
		return [self Replace:StatusUnknown s2:StatusSet changedConnectorList:changedConnectorList];
	return ResultIncomplete;
}

-(SimplifyResult) Replace:(ConnectorStatus) s1 s2:(ConnectorStatus)s2 changedConnectorList:(NSMutableArray *)changedConnectorList {
	if (Right.Status == s1) {
		if ([Right SetStatus:s2 changedConnectorList:changedConnectorList] == ResultInvalid)
			return ResultInvalid;
	}
	if (Left.Status == s1) {
		if ([Left SetStatus:s2 changedConnectorList:changedConnectorList] == ResultInvalid)
			return ResultInvalid;
	}
	if (Up.Status == s1) {
		if ([Up SetStatus:s2 changedConnectorList:changedConnectorList] == ResultInvalid)
			return ResultInvalid;
	}
	if (Down.Status == s1) {
		if ([Down SetStatus:s2 changedConnectorList:changedConnectorList] == ResultInvalid)
			return ResultInvalid;
	}
	return ResultChanged;
}

@end





