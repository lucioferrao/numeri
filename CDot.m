//
//  CDot.m
//  Board
//
//  Created by Lucio Ferrao on 09/04/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CDot.h"
#import "CNumber.h"
#import "CConnector.h"




@implementation CDot 

-(int)Count:(ConnectorStatus)s {
	return (Right->Status == s ? 1 : 0) + 
	(Left->Status == s ? 1 : 0) +
	(Up->Status == s ? 1 : 0) + 
	(Down->Status == s ? 1 : 0);
}

-(CConnector *) getConnector:(Direction) dir {
	switch (dir) {
		case DirectionRight:
			return Right;
		case DirectionLeft:
			return Left;
		case DirectionUp:
			return Up;
		default:
			return Down;
	}
}

-(bool)Valid {
	int set = [self Count:StatusSet];
	return set < 3 && !(set == 1 && [self Count:StatusUnknown] == 0);
}

-(bool)showDotMarker {
	int set = [self Count:StatusSet];
	return !(set==0 || set==2);
}


-(int)dotImage {
	return ((Up.Status*3 + Right.Status)*3 + Down.Status)*3 + Left.Status;
}

-(bool)Corner {
	int set = [self Count:StatusSet];
	if( set != 2 ||
	   (Up.Status == StatusSet && Down.Status == StatusSet) || 
	   (Left.Status == StatusSet && Right.Status == StatusSet))
		return false;
	return true;
}

-(SimplifyResult) Replace:(ConnectorStatus)s1 s2:(ConnectorStatus)s2 changedConnectorList:(NSMutableArray *)changedConnectorList {
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
	return ResultIncomplete;
}

-(SimplifyResult) Simplify:(NSMutableArray *) changedConnectorList {
	int set = [self Count:StatusSet];
	int unknown = [self Count:StatusUnknown];
	if (set > 2 || (set == 1 && unknown == 0))
		return ResultInvalid;
	if (unknown == 0) 
		return ResultTerminal;
	if (set == 2)
		return [self Replace:StatusUnknown s2:StatusUnset changedConnectorList:changedConnectorList];
	if (unknown == 1) {
		if (set == 1)
			return [self Replace:StatusUnknown s2:StatusSet changedConnectorList:changedConnectorList];
		else
			return [self Replace:StatusUnknown s2: StatusUnset changedConnectorList:changedConnectorList];
	}
	return ResultIncomplete;
}

-(CConnector *)GetConnectorTo:(CConnector *)c {
	CConnector *r;
	r = [self getCommonConnector:c->Dot1];
	if( r == nil) {
		r = [self getCommonConnector:c->Dot2];
	}
	return r;
}


-(CConnector *)getCommonConnector:(CDot*)dot {
	if( Up == dot->Down) return Up;
	if( Down == dot->Up) return Down;
	if( Left == dot->Right) return Left;
	if( Right == dot->Left) return Right;
	return nil;
}

@end



