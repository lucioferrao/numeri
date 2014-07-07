//
//  CDot.h
//  Board
//
//  Created by Lucio Ferrao on 09/04/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enums.h"

@class CConnector;

@interface CDot : NSObject 
{
	
@public
	CConnector *Right;
	CConnector *Down;
	CConnector *Up;
	CConnector *Left;
	CDot *Parent;
	int X;
	int Y;
}


-(SimplifyResult) Replace:(ConnectorStatus)s1 s2:(ConnectorStatus)s2 changedConnectorList:(NSMutableArray *)changedConnectorList;
-(bool)showDotMarker;
-(bool)Valid;
-(SimplifyResult)Simplify:(NSMutableArray *)changedConnectorList;
-(int)Count:(ConnectorStatus)s;
-(int)dotImage;

-(bool)Corner;

-(CConnector *)getCommonConnector:(CDot*)dot;
-(CConnector *)GetConnectorTo:(CConnector*)c;

@end
