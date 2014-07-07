//
//  CConnector.m
//  Board
//
//  Created by Lucio Ferrao on 09/04/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CConnector.h"

@implementation CConnector 

-(id)init:(ConnectorStatus)s {
	if( (self=[super init])) {
		Status = s;
	}
	return self;
}

-(ConnectorStatus)Status { return Status; }

-(bool) Valid {
	return (Dot1 == nil || Dot1.Valid) && (Dot2 == nil || Dot2.Valid) &&
	(Number1 == nil || Number1.Valid) && (Number2 == nil || Number2.Valid);
}

-(CDot *)GetCommonDot:(CConnector *)c {
	if( Dot1 == c->Dot1) return Dot1;
	if( Dot1 == c->Dot2) return Dot1;
	if( Dot2 == c->Dot1) return Dot2;
	if( Dot2 == c->Dot2) return Dot2;
	return nil;
}

-(CNumber *)GetCommonNumber:(CConnector *)c {
	if( Number1->X != -1 && Number1->Y != -1) {
		if( Number1 == c->Number1 || Number1 == c->Number2) return Number1;
	}
	if( Number2->X != -1 && Number2->Y != -1) {
		if( Number2 == c->Number1 || Number2 == c->Number2) return Number2;
	}
	return nil;
}

-(void) Switch {
	Status = Status == StatusSet ? StatusUnset : StatusSet;
}

-(bool) IsNear:(CConnector *)c {
	return
	Number1 == c->Number2 ||
	Number2 == c->Number1 ||
	Number1 == c->Number1 ||
	Number2 == c->Number2 ||
	Dot1 == c->Dot2 ||
	Dot2 == c->Dot1 ||
	Dot1 == c->Dot1 ||
	Dot2 == c->Dot2;
}

-(SimplifyResult)SetStatus:(ConnectorStatus)s changedConnectorList:(NSMutableArray *)changedConnectorList {
	[changedConnectorList addObject: self];
	Status = s;
	if (Dot1 != nil)
		if ([Dot1 Simplify: changedConnectorList] == ResultInvalid)
			return ResultInvalid;
	if (Dot2 != nil)
		if ([Dot2 Simplify: changedConnectorList] == ResultInvalid)
			return ResultInvalid;
	if (Number1 != nil)
		if ([Number1 Simplify: changedConnectorList] == ResultInvalid)
			return ResultInvalid;
	if (Number2 != nil)
		if ([Number2 Simplify: changedConnectorList] == ResultInvalid)
			return ResultInvalid;
	return ResultChanged;
}

@end

