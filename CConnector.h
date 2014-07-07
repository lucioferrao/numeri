//
//  CConnector.h
//  Board
//
//  Created by Lucio Ferrao on 09/04/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDot.h"
#import "CNumber.h"
#import "Enums.h"



@interface CConnector : NSObject 
{
@public
	CDot *Dot1;
	CDot *Dot2;
	CNumber *Number1;
	CNumber *Number2;
	ConnectorStatus Status;
}

@property(readonly) ConnectorStatus Status;

-(id)init:(ConnectorStatus)s;
-(bool)Valid;
-(bool)IsNear:(CConnector *)c;
-(CDot *)GetCommonDot:(CConnector *)c;
-(CNumber *)GetCommonNumber:(CConnector*)c;
-(SimplifyResult)SetStatus:(ConnectorStatus)s changedConnectorList:(NSMutableArray *)changedConnectorList;
-(void) Switch;

@end

