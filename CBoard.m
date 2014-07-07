//
//  CBoard.m
//  Board
//
//  Created by Lucio Ferrao on 09/04/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CBoard.h"
#import "CDot.h"
#import "CConnector.h"
#import "CNumber.h"



@implementation CBoard

@synthesize solution;

-(int)IncreasedNumber:(int)posX posY:(int)posY {
	if (posX < 0 || posY < 0 || posX+1 >= MaxX || posY+1 >= MaxY) 
		return OutsideNumber->Number;
	return Number[posX][posY]->Number;
}


-(int)CountHidden {
	int count = 0;
	for( int x=0; x<MaxX-1; x++) {
		for( int y=0; y<MaxY-1; y++) {
			if( Number[x][y]->Hidden) count++;
		}
	}
	return count;
}


-(void)generatePuzzle:(int)count hard:(bool)hard {
	
	int aroundPos[9][2] = { { -1, -1 }, { 0, -1 }, { 1, -1 }, { 1, 0 }, { 1, 1 }, { 0, 1 }, { -1, 1 }, { -1, 0 }, { -1, -1 } };

	Number[random() % (MaxX - 1)][random() % (MaxY - 1)]->Number = 3;
	
	int tries = MaxX * MaxY * 20;
	
	while (count > 0 && tries-- > 0) {
		int posX = random() % (MaxX-1);
		int posY = random() % (MaxY-1);
		if (Number[posX][posY]->Number == 3) continue;
		if ( [self IncreasedNumber:(posX - 1) posY:posY] != 3 &&
			[self IncreasedNumber:(posX + 1) posY:posY] != 3 &&
			[self IncreasedNumber:posX posY:posY-1] != 3 &&
			[self IncreasedNumber:posX posY:posY+1] != 3) 
			continue; // Invalid numbers to grow. Must be adjacent to an existing one
		
		int prev= [self IncreasedNumber:posX+aroundPos[0][0] posY:posY+aroundPos[0][1]];
		int borderCount = 0;
		int fillCount = 0;
		bool valid = true;
		for (int i = 0; i < 9; i++) {
			if ([self IncreasedNumber:posX+aroundPos[i][0] posY:posY+aroundPos[i][1]] == 3) {
				fillCount++;
				if (fillCount > 4 || fillCount == 3 && random() % 2 == 0) {
					valid = false;
					break; // Avoid filling all the area
				}
			}
			
			if ([self IncreasedNumber:posX+aroundPos[i][0] posY:posY+aroundPos[i][1]] != prev) {
				borderCount++;
				if (borderCount > 2) {
					valid = false;
					break; // Bail-out. We touched another part. Avoid cycles.
				}
			}
			prev = [self IncreasedNumber:posX+aroundPos[i][0] posY:posY+aroundPos[i][1]];
		}
		
		if (valid) {
			Number[posX][posY]->Number = 3;
			count--;
			
		}
		
	}
	for (int x = 0; x < MaxX; x++) {
		for (int y = 0; y < MaxY; y++) {
			if ([self IncreasedNumber:x-1 posY:y] != [self IncreasedNumber:x posY:y]) {
				Dot[x][y]->Down->Status = StatusSet;
			} else {
				Dot[x][y]->Down->Status = StatusUnset;
			}
			if ([self IncreasedNumber:x posY:y-1] != [self IncreasedNumber:x posY:y]) {
				Dot[x][y]->Right->Status = StatusSet;
			} else {
				Dot[x][y]->Right->Status = StatusUnset;
			}
		}
	}
	for (int x = 0; x < MaxX - 1; x++) {
		for (int y = 0; y < MaxY - 1; y++) {
			Number[x][y]->Number = [Number[x][y] Count:StatusSet];
			Number[x][y]->Hidden = false;
		}
	}
	
	
	self.solution = [self toBinary];

	for( CConnector *c in ConnectorList) {
		c->Status = StatusUnknown;
	}
	
	[self Reduce:hard verticalSymmetry:false];
	int hidden1 = [self CountHidden];	
	NSData *board1 = [self toBinary];


	[self LoadBinary:solution clearUnknown:false];
	
	for( CConnector *c in ConnectorList) {
		c->Status = StatusUnknown;
	}
	
	[self Reduce:hard verticalSymmetry:true];
	int hidden2 = [self CountHidden];
	if( hidden2 < hidden1) {
		[self LoadBinary:board1 clearUnknown:false];
	}

}




-(NSData *) toBinary {
	
	NSMutableData *data = [[NSMutableData alloc] initWithLength: 2+(MaxX-1)*(MaxY-1)+2*MaxX*MaxY];
	
	int8_t *buffer = [data mutableBytes];
	int pos = 0;
	buffer[pos++] = (int8_t)MaxX;
	buffer[pos++] = (int8_t)MaxY;
	for (int x = 0; x < MaxX - 1; x++)
		for (int y = 0; y < MaxY - 1; y++) {
			if( !Number[x][y]->Hidden) {
				buffer[pos++] = (int8_t)Number[x][y]->Number;
			} else {
				buffer[pos++] = 4+(int8_t)Number[x][y]->Number;
			}
		}
	for (int x = 0; x < MaxX; x++)
		for (int y = 0; y < MaxY; y++)
			buffer[pos++] = (int8_t)Dot[x][y]->Right->Status;
	for (int x = 0; x < MaxX; x++)
		for (int y = 0; y < MaxY; y++)
			buffer[pos++] = (int8_t)Dot[x][y]->Down->Status;
	return [data autorelease];
}

+(NSData *)MergeBinaries:(NSData *)board1 board2:(NSData *)board2 {
	int pos = 0;
	
	int8_t *b1 = (int8_t *)[board1 bytes];
	int8_t *b2 = (int8_t *)[board2 bytes];
	
	int Mx = (int)b1[0];
	int My = (int)b1[1];
	int Length = 2 + (Mx - 1) * (My - 1) + 2*Mx * My;
	
	NSMutableData *result = [[NSMutableData alloc] initWithLength:Length];
	int8_t *b = [result mutableBytes];
    while (pos < Length) {
		if (b1[pos] != b2[pos]) {
			b[pos] = (int8_t)StatusUnknown;
		} else {
			b[pos] = b1[pos];
		}
		pos++;
	}
	return [result autorelease];
}

-(bool)Valid {
	for(int x=0; x<MaxX-1; x++) {
		for(int y=0; y<MaxY-1; y++) {
			if(![Number[x][y] Valid])
				return false;
		}
	}
	for(int x=0; x<MaxX; x++) {
		for(int y=0; y<MaxY; y++) {
			if(![Dot[x][y] Valid])
				return false;
		}
	}
	return true;
}


-(void)dealloc{

	for (int x=0; x<MaxX-1; x++) {		
		for( int y=0; y<MaxY-1; y++) {
			[Number[x][y] release];
		}
	}

	for (int x=0; x<MaxX; x++) {		
		for( int y=0; y<MaxY; y++) {
			[Dot[x][y] release];
		}
		free( Dot[x]);
		free( Number[x]);
	}	 
	free( Dot);
	free( Number);
	
	for( CConnector *c in AllConnectorList) {
		[c release];
	}
	[AllConnectorList release];
	[ConnectorList release];
	
	[OutsideNumber release];
		
	[super dealloc];
}
//
// Creates an empty board.
//
// X Number of horizontal dots
// Y Number of vertical dots
-(void) Setup:(int)X Y:(int)Y {
	
	self.solution = nil;
	
	MaxX = X;
	MaxY = Y;
	
	Dot = calloc(MaxX,sizeof(id));
	Number = calloc(MaxX,sizeof(id));
	for (int x=0; x<MaxX; x++) {
		Dot[x] = calloc(MaxY,sizeof(id));
		Number[x] = calloc(MaxY,sizeof(id));
	}
	
	ConnectorList = [[NSMutableArray alloc] init];
	AllConnectorList = [[NSMutableArray alloc] init];	
	
	OutsideNumber = [[CNumber alloc] init];
	
	// Setup dots and connectors for an empty grid.
	for( int x=0; x<MaxX; x++) {
		for( int y=0; y<MaxY; y++){
			Dot[x][y] = [[CDot alloc] init];
			Dot[x][y]->X = x;
			Dot[x][y]->Y = y;		
			if (x + 1 == MaxX) {
				Dot[x][y]->Right = [[CConnector alloc] init:StatusUnset];
				[AllConnectorList addObject:Dot[x][y]->Right];
			} else {
				Dot[x][y]->Right = [[CConnector alloc] init:StatusUnknown];
				[AllConnectorList addObject:Dot[x][y]->Right];
				[ConnectorList addObject:Dot[x][y]->Right];
			}
			if (y + 1 == MaxY) {
				Dot[x][y]->Down = [[CConnector alloc] init:StatusUnset];
				[AllConnectorList addObject:Dot[x][y]->Down];
			} else {
				Dot[x][y]->Down = [[CConnector alloc] init:StatusUnknown];
				[AllConnectorList addObject:Dot[x][y]->Down];
				[ConnectorList addObject:Dot[x][y]->Down];
			}
			if (x == 0) {
				Dot[x][y]->Left = [[CConnector alloc] init:StatusUnset];
				[AllConnectorList addObject:Dot[x][y]->Left];
			} else {
				Dot[x][y]->Left = Dot[x - 1][ y]->Right;
				Dot[x][y]->Left->Dot1 = Dot[x][ y];
				Dot[x][y]->Left->Dot2 = Dot[x - 1][ y];
			}
			if (y == 0) {
				Dot[x][y]->Up = [[CConnector alloc] init:StatusUnset];
				[AllConnectorList addObject:Dot[x][y]->Up];
			} else {
				Dot[x][y]->Up = Dot[x][y - 1]->Down;
				Dot[x][y]->Up->Dot1 = Dot[x][y];
				Dot[x][y]->Up->Dot2 = Dot[x][y-1];
			}
		}
	}
	for (int x = 0; x < MaxX-1; x++) {
		for (int y = 0; y < MaxY - 1; y++) {
			Number[x][y] = [[CNumber alloc] init:x y:y left:Dot[x][y]->Down right:Dot[x + 1][ y]->Down up:Dot[x][ y]->Right down:Dot[x][ y + 1]->Right];
		}
	}
	for (int x = 0; x < MaxX; x++) {
		for (int y = 0; y < MaxY - 1; y++) {
			if (x > 0) {
				Dot[x][y]->Down->Number1 = Number[x - 1][y];
			} else {
				Dot[x][y]->Down->Number1 = OutsideNumber;
			}
			if (x + 1 < MaxX) {
				Dot[x][y]->Down->Number2 = Number[x][ y];
			} else {
				Dot[x][y]->Down->Number2 = OutsideNumber;
			}
		}
	}
	for (int x = 0; x < MaxX-1; x++) {
		for (int y = 0; y < MaxY; y++) {
			if (y > 0) {
				Dot[x][ y]->Right->Number1 = Number[x][ y - 1];
			} else {
				Dot[x][y]->Right->Number1 = OutsideNumber;
			}
			if (y + 1 < MaxY) {
				Dot[x][y]->Right->Number2 = Number[x][y]; 
			} else {
				Dot[x][y]->Right->Number2 = OutsideNumber;
			}
		}
	}
}




-(NSString *) toString {
	NSArray *horiz = [NSArray arrayWithObjects:@" ",@"-",@"?",nil];
	NSArray *vert = [NSArray arrayWithObjects:@" ",@"|",@"?",nil];
	
	NSMutableString *sb = [[NSMutableString alloc] init];
	
	[sb appendString:@"\r\n"];
	
	for (int y = 0; y < MaxY-1; y++) {
		for (int x = 0; x < MaxX-1; x++) {
			[sb appendString:@"+"];
			[sb appendString:[horiz objectAtIndex: Dot[x][y]->Right->Status]];
		}
		[sb appendString: @"+\r\n"];
		for (int x = 0; x < MaxX-1; x++) {
			[sb appendString:[vert objectAtIndex:Dot[x][y]->Down->Status]]; 
			if(Number[x][y]->Hidden)
				[sb appendString:@" "];
			else
				[sb appendString: [NSString stringWithFormat:@"%d", Number[x][y]->Number]];
		}
		[sb appendString: [vert objectAtIndex:Dot[MaxX-1][y]->Down->Status]];
		[sb appendString:@"\r\n"];
	}
	for (int x = 0; x < MaxX-1; x++) {
		[sb appendString: @"+"];
		[sb appendString:[horiz objectAtIndex:Dot[x][MaxY-1]->Right->Status]];
	}
	[sb appendString:@"\r\n"];
	
	return [sb autorelease];
}

-(int) Count:(ConnectorStatus) stat {
	int countStat = 0;
	
	for (CConnector *c in ConnectorList) {
		if (c.Status == stat)
			countStat++;
	}
	return countStat;
}

-(bool)checkForCycle:(CConnector *)startConnector currConnector:(CConnector *)currConnector lastDot:(CDot *)lastDot cycleLength:(int *)cycleLength {
	// Get next dot.
	
	CDot *nextDot = (currConnector->Dot1 == lastDot) ? currConnector->Dot2 : currConnector->Dot1;
	
	// If the dot isn't valid or if there isn't a next connector then stop checking.
	
	if (![nextDot Valid]) return false;
	if ([nextDot Count:StatusSet] == 1) return false;
	
	// Get next connector.
	
	if ((nextDot->Up->Status == StatusSet) && (nextDot->Up != currConnector)) currConnector = nextDot->Up;
	else if ((nextDot->Left->Status == StatusSet) && (nextDot->Left != currConnector)) currConnector = nextDot->Left;
	else if ((nextDot->Right->Status == StatusSet) && (nextDot->Right != currConnector)) currConnector = nextDot->Right;
	else if ((nextDot->Down->Status == StatusSet) && (nextDot->Down != currConnector)) currConnector = nextDot->Down;
	(*cycleLength)++;
	
	// Check if we've come full circle.
	
	if (currConnector == startConnector) return (true);
	
	// Otherwise recurse.
	
	return [self checkForCycle:startConnector currConnector:currConnector lastDot:nextDot cycleLength:cycleLength];
}

-(CConnector *)GetAnySetConnnector {
	for (CConnector *connector in ConnectorList) {
		if (connector->Status == StatusSet) return connector;
	}
	return nil;
}

-(bool) IsSolved {
	// First check for a cycle.
	bool isSolved = false;
	int cycleLength = 0;
	
	CConnector *setConnector = [self GetAnySetConnnector];
	
	if( setConnector == nil) return false;
	
	bool cycleFound = [self checkForCycle:setConnector currConnector:setConnector lastDot:nil cycleLength:&cycleLength];
	
	if (cycleFound)	{
		// Now check to see if all connectors on the board were in the cycle.
		
		if (cycleLength == [self Count:StatusSet])	{
			// Check that all numbers have been fulfilled.
			// If so then the board has been solved.
			
			bool unfulfilledFound = false;
			for (int i = 0; i < MaxX - 1; i++) {
				for (int j = 0; j < MaxY - 1; j++) {
					if (![Number[i][j] Fulfilled]) {
						unfulfilledFound = true;
						break;
					}
				}				
				if (unfulfilledFound) break;
			}
			if (!unfulfilledFound) isSolved = true;
		}
	}
	return isSolved;
}

-(bool)ShowUnfulfilled{
		
	for (int x = 0; x < MaxX; x++) {
		for (int y = 0; y < MaxY; y++) {
			if ([Dot[x][y] showDotMarker]) {
				return false;
			}
		}
	}

	for (int x = 0; x < MaxX-1; x++) {
		for (int y = 0; y < MaxY-1; y++) {
			if (![Number[x][y] Valid]) {
				return false;
			}
		}
	}
	
	CConnector *setConnector = [self GetAnySetConnnector];
	
	if( setConnector == nil) {
		return false;
	}
	
	
	// First check for a cycle.
	
	int cycleLength = 0;
	bool cycleFound = [self checkForCycle:setConnector currConnector:setConnector lastDot:nil cycleLength:&cycleLength];

	return cycleFound;
}



ConnectorStatus charToConnectorStatus(char c) {
	if (c == ' ') return StatusUnset;
	if (c == '?') return StatusUnknown;
	return StatusSet;
}


-(CBoard *)initFromBinary:(NSData *)buffer {
	if( (self=[super init])) {
		int8_t *b = (int8_t *)[buffer bytes];
		[self Setup:b[0] Y:b[1]];
		[self LoadBinary:buffer clearUnknown:false];
	}
	return self;
}


-(CBoard *)init:(int)X Y:(int)Y textBoard:(NSString *)Board simplify:(bool)bSimplify {
	
	if( (self=[super init])) {
	
		[self Setup:X Y:Y];
		NSMutableArray *changedConnectorList = [[NSMutableArray alloc] init];
		NSMutableString *textBoard = [[NSMutableString alloc] initWithString:Board];

		[textBoard replaceOccurrencesOfString:@"\r" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [textBoard length])];
		[textBoard replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [textBoard length])];

		int pos=0;
	
		for (int y = 0; y < MaxY - 1; y++) {
			for (int x = 0; x < MaxX - 1; x++) {
				pos++;
			
				if (bSimplify)
					[Dot[x][y]->Right SetStatus:charToConnectorStatus([textBoard characterAtIndex:pos]) changedConnectorList:changedConnectorList];
				else 
					Dot[x][y]->Right->Status = charToConnectorStatus([textBoard characterAtIndex:pos]);
				pos++;
			
			}

			pos++;
		
			for (int x = 0; x < MaxX -1 ; x++) {
				if (bSimplify)
					[Dot[x][y]->Down SetStatus:charToConnectorStatus([textBoard characterAtIndex:pos]) changedConnectorList:changedConnectorList];
				else 
					Dot[x][y]->Down->Status = charToConnectorStatus([textBoard characterAtIndex:pos]);
				pos++;
			
				if ([textBoard characterAtIndex:pos] == ' ')
					Number[x][y]->Number = -1;
				else {
					Number[x][y]->Number = [textBoard characterAtIndex:pos] - '0';
				}
				pos++;
			}
			if(bSimplify)
				[Dot[MaxX-1][y]->Down SetStatus:charToConnectorStatus([textBoard characterAtIndex:pos]) changedConnectorList:changedConnectorList];
			else
				Dot[MaxX-1][y]->Down->Status = charToConnectorStatus([textBoard characterAtIndex:pos]);
			pos++;
		}
		for (int x = 0; x < MaxX - 1; x++) {
			pos++; // "+"
		
			if (bSimplify)
				[Dot[x][MaxY-1]->Right SetStatus:charToConnectorStatus([textBoard characterAtIndex:pos]) changedConnectorList:changedConnectorList];
			else 
				Dot[x][MaxY - 1]->Right->Status = charToConnectorStatus([textBoard characterAtIndex:pos]);
			pos++;
		}
	}
	return self;
	
}


-(bool)LoadBinary:(NSData *)data clearUnknown:(bool)clearUnknown changedConnectorList:(NSMutableArray*)changedConnectorList ignoreUnknown:(bool)ignoreUnknown {
	
	int8_t *buffer = (int8_t *)[data bytes];
	
	int pos = 2;
	bool changed = false;
	ConnectorStatus s;
	for (int x = 0; x < MaxX - 1; x++)
		for (int y = 0; y < MaxY - 1; y++) {
			int n = buffer[pos++];
			if( n>3) { 
				Number[x][y]->Hidden = true;
				Number[x][y]->Number = n - 4;
			} else {
				Number[x][y]->Hidden = false;
				Number[x][y]->Number = n;
			}
		}
	for (int x = 0; x < MaxX; x++)
		for (int y = 0; y < MaxY; y++) {
			s = (ConnectorStatus)buffer[pos++];
			if ( !ignoreUnknown ? Dot[x][y]->Right->Status != s : ( Dot[x][y]->Right->Status==StatusSet) != (s==StatusSet) ) {
				Dot[x][y]->Right->Status = s;
				[changedConnectorList addObject:Dot[x][y]->Right];
				changed = true;
			}
			if (clearUnknown && Dot[x][y]->Right->Status == StatusUnknown)
				Dot[x][y]->Right->Status = StatusUnset;
		}
	for (int x = 0; x < MaxX; x++)
		for (int y = 0; y < MaxY; y++) {
			s = (ConnectorStatus)buffer[pos++];
			if ( !ignoreUnknown ? Dot[x][y]->Down->Status != s : ( Dot[x][y]->Down->Status==StatusSet) != (s==StatusSet) ) {
				Dot[x][y]->Down->Status = s;
				[changedConnectorList addObject:Dot[x][y]->Down];
				changed = true;
			}
			if (clearUnknown && Dot[x][y]->Down->Status == StatusUnknown)
				Dot[x][y]->Down->Status = StatusUnset;
		}
	return changed;
}

-(bool) LoadBinary:(NSData *)buffer clearUnknown:(bool)clearUnknown {
	return [self LoadBinary:buffer clearUnknown:clearUnknown changedConnectorList:nil ignoreUnknown:false];
}

-(NSMutableArray *) HintList {

	
	
	NSData *buffer = [self toBinary];
	NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];

	if( [self IsSolved]) {
		
		for( CConnector *c in ConnectorList) {
			if( c->Status == StatusSet) {
				[list addObject:c];
			}
		}
		
		for( int i=0; i< [list count]-1; i++) {
			for( int j=i+1; j< [list count]; j++) {
				CConnector *ci = [list objectAtIndex:i];
				CConnector *cj = [list objectAtIndex:j];			
				if( [ci GetCommonDot:cj] != nil) {
					[list removeObject:cj];
					[list insertObject:cj atIndex:i+1];
					break;
				}
			}
		}
		
		NSMutableArray *finalList = [[[NSMutableArray alloc] init] autorelease];
		
		[finalList addObjectsFromArray:list];
		[finalList addObjectsFromArray:list];
		
		return finalList;
	}	
	
	if( self.solution == nil) {
		for( CConnector *c in ConnectorList) {
			c->Status = StatusUnknown;
		}
		SimplifyResult r = [self Simplify:5 singleStep:false isTop:true parentWhatifConnector:nil changedConnectorList:nil];

		if( r != ResultTerminal) {
			NSLog(@"Error");
		}
		self.solution = [self toBinary];		
	}
	
	
	[self LoadBinary:solution clearUnknown:false changedConnectorList:list ignoreUnknown:true];
	[self LoadBinary:buffer clearUnknown:false];
	
	for( int i=0; i< [list count]-1; i++) {
		for( int j=i+1; j< [list count]; j++) {
			CConnector *ci = [list objectAtIndex:i];
			CConnector *cj = [list objectAtIndex:j];			
			if( [ci GetCommonDot:cj] != nil) {
				[list removeObject:cj];
				[list insertObject:cj atIndex:i+1];
				break;
			}
		}
	}
	
	
	return list;
}

-(NSMutableArray *) NumberHintList {
	
	NSMutableArray *list = [[[NSMutableArray alloc] init] autorelease];
	
	if( [self IsSolved]) {
		return list;
	}	
	
	
	if( self.solution != nil) {
		CBoard *sol = [[[CBoard alloc] initFromBinary:solution] autorelease];
		for( int y=0; y<MaxY-1; y++) {
			bool isInside1 = false;
			bool isInside2 = false;
			for( int x=0; x<MaxX-1; x++) {
				if( Number[x][y]->Left->Status == StatusSet) {
					isInside1 = !isInside1;
				}
				if( sol->Number[x][y]->Left->Status == StatusSet) {
					isInside2 = !isInside2;
				}
				if( isInside1 != isInside2) {
					[list addObject:Number[x][y]];
				}
			}
		}
	}
	
	for( int i=0; i< [list count]-1; i++) {
		for( int j=i+1; j< [list count]; j++) {
			CNumber *ci = [list objectAtIndex:i];
			CNumber *cj = [list objectAtIndex:j];			
			if( (ci->X+1==cj->X && ci->Y==cj->Y) || (ci->X==cj->X && ci->Y+1==cj->Y) ) {
				[list removeObject:cj];
				[list insertObject:cj atIndex:i+1];
				break;
			}
		}
	}
	
	
	return list;
}

-(void)SetInsideNumbers {
}


-(SimplifyResult)Simplify:(int)guesses singleStep:(bool)singleStep isTop:(bool)isTop parentWhatifConnector:(CConnector*)parentWhatifConnector changedConnectorList:(NSMutableArray*)changedConnectorList {
	SimplifyResult r;
	
	r = [self Simplify: changedConnectorList];
	
	if (guesses <= 0 || r == ResultInvalid || r == ResultTerminal)
		return r;
	NSData *savedBoard = [self toBinary];
	bool changed = false;
	NSMutableArray *whatIfConnectorList = [[NSMutableArray alloc] init];
	for (CConnector* c in ConnectorList) {
		if (c->Status == StatusUnknown) {
            
			if ( isTop) {
				// first time test every unknown
				[whatIfConnectorList insertObject:c atIndex:random()%([whatIfConnectorList count]+1)];
			} else {
				// Second time. Only test connectors near to the ones in changedConnectorList
				for (CConnector* c2 in changedConnectorList) {
					if ([c IsNear:c2]) {
						[whatIfConnectorList insertObject:c atIndex:random()%([whatIfConnectorList count]+1)];
						break;
					}
				}
			}
		}
	}
	
	int terminalCount = 0;
	
	for (CConnector* c in whatIfConnectorList) {
		if (c->Status != StatusUnknown)
			continue;
		
		c->Status = StatusUnset;
		r = [self Simplify:guesses-1 singleStep:false isTop:false parentWhatifConnector:c changedConnectorList:nil];
		NSData *unsetResult = [self toBinary];
		if( r == ResultTerminal)
			if( ++terminalCount > 1) {
				[whatIfConnectorList release];
				return ResultTwoSolutions;
			}
		if (r == ResultTwoSolutions) {
			[whatIfConnectorList release];
			return r;
		}
		if (r == ResultInvalid) {
			[self LoadBinary:savedBoard clearUnknown:false];
			if ([c SetStatus:StatusSet changedConnectorList:changedConnectorList] == ResultInvalid) {
				[whatIfConnectorList release];	
				return ResultInvalid;
			}
			changed = true;
			break;
		}
		[self LoadBinary:savedBoard clearUnknown:false];
		
		c->Status = StatusSet;
		r = [self Simplify:guesses-1 singleStep:false isTop:false parentWhatifConnector:c changedConnectorList:nil];
		if (r == ResultTerminal)
			if (++terminalCount > 1) {
				[whatIfConnectorList release];				
				return ResultTwoSolutions;
			}
		if (r == ResultTwoSolutions) {
			[whatIfConnectorList release];				
			return r;
		}
		if (r == ResultInvalid) {
			[self LoadBinary:savedBoard clearUnknown:false];
			if ([c SetStatus:StatusUnset changedConnectorList:changedConnectorList] == ResultInvalid) {
				[whatIfConnectorList release];					
				return ResultInvalid;
			}
			changed = true;
			break;
		}
		NSData *setResult = [self toBinary];
		NSData *mergeResult = [CBoard MergeBinaries:unsetResult board2:setResult];
		[self LoadBinary:savedBoard clearUnknown:false];
		
		if ([self LoadBinary:mergeResult clearUnknown:false changedConnectorList:changedConnectorList ignoreUnknown:false]) {
			changed = true;
			break;
		}
	}
	

	[whatIfConnectorList release];
	
	if (changed) {
		if( singleStep) {
			return ResultChanged;
		} else {
			return [self Simplify:guesses singleStep:false isTop:isTop parentWhatifConnector:nil changedConnectorList:changedConnectorList];
		}
	} else {

		return ResultIncomplete;
	}
}



-(SimplifyResult) Simplify:(NSMutableArray *)changedConnectorList {
	
	OutsideNumber->Parent = nil;
	SimplifyResult status = ResultTerminal;
	for( int x=0; x<MaxX-1; x++) {
		for (int y = 0; y < MaxY - 1; y++) {
			Number[x][y]->Parent = nil;
			switch ([Number[x][y] Simplify:changedConnectorList]) {
				case ResultInvalid:
					return ResultInvalid;
				case ResultIncomplete:
					if (status == ResultTerminal)
						status = ResultIncomplete;
					break;
				case ResultChanged:
					status = ResultChanged;
					break;
				default:
					break;
			}
		}
	}
	
	for (int x = 0; x < MaxX; x++) {
		for (int y = 0; y < MaxY; y++) {
			Dot[x][y]->Parent = nil;
			switch ([Dot[x][y] Simplify:changedConnectorList]) {
				case ResultInvalid:
					return ResultInvalid;
				case ResultIncomplete:
					if (status == ResultTerminal)
						status = ResultIncomplete;
					break;
				case ResultChanged:
					status = ResultChanged;
					break;
				default:
					break;
			}
		}
	}
	
	int changeCount;
	do {
		changeCount = [changedConnectorList count];
		
		for (CConnector* c in ConnectorList) {
			if (![self MergeNumbers:c changedConnectorList:changedConnectorList ])
				return ResultInvalid;
		}
	} while (changeCount != [changedConnectorList count]);
	
	// Find closed loops
	int loopLength = 0;
	for (CConnector* c in ConnectorList) {
		if (c->Status == StatusSet) {
			loopLength++;
			if (![self MergeDots:c->Dot1 dot2:c->Dot2]) {
				// Found a loop. Validate final solution.
				if (status != ResultTerminal) {
					// Skip this test. 
					// There are no more unknown connectors then status = terminal
					//CBoard *newBoard = [[CBoard alloc] init];
					NSData * newBoardBuffer=[self toBinary];
					CBoard *newBoard = [[CBoard alloc] initFromBinary:newBoardBuffer];
					//[newBoard LoadBinary:newBoardBuffer clearUnknown:true];
					if (![newBoard Valid]) {
						[newBoard release];
						return ResultInvalid;
					}
					[newBoard release];
				}
				if( loopLength == [self Count:StatusSet])
					return ResultTerminal;
				else 
					return ResultInvalid;
			}
		}
	}
	
	return status;
	
}



-(void) Restart{
	for (CConnector* c in ConnectorList)
		c->Status = StatusUnknown;
}



-(void)Reduce:(bool)hard verticalSymmetry:(bool)verticalSymmetry {

	NSMutableArray * positionList = [[NSMutableArray alloc] init];
	
	for (int x = 0; x < MaxX/2; x++) {
		for (int y = 0; y < MaxY - 1; y++) {
			CNumber *num = Number[x][y];
			if( num->Number == 0 || Number[MaxX-2-num->X][verticalSymmetry ? num->Y : MaxY-2-num->Y]->Number == 0 || [positionList count]==0) {
				[positionList insertObject:num atIndex:0];
			} else {
				[positionList insertObject:num atIndex:1+random()%([positionList count])];
			}
		}
	}
	
	int depth = hard ? 7 : 4;
	
	NSData* savedBoard = [self toBinary];
	
	while ([positionList count] > 0) {
		CNumber *num=[positionList objectAtIndex:0];
		
		num->Hidden = true;
		Number[MaxX-2-num->X][verticalSymmetry ? num->Y : MaxY-2-num->Y]->Hidden = true;
		
		SimplifyResult r = [self Simplify:depth singleStep:false isTop:true parentWhatifConnector:nil changedConnectorList:nil];
		
		if( r == ResultTerminal) {
			[self LoadBinary:savedBoard clearUnknown:false];
			num->Hidden = true;
			Number[MaxX-2-num->X][verticalSymmetry ? num->Y : MaxY-2-num->Y]->Hidden = true;
			savedBoard = [self toBinary];
		}
		[positionList removeObjectAtIndex:0];
		[self LoadBinary:savedBoard clearUnknown:false];
	}
	
	[self LoadBinary:savedBoard clearUnknown:false];
	[positionList release];
}

-(bool) MergeDots:(CDot*)dot1 dot2:(CDot*)dot2 { 
	int dot1depth = 0;
	int dot2depth = 0;
	
	while( dot1->Parent != nil) {
		dot1depth++;
		dot1 = dot1->Parent;
	}
	while( dot2->Parent != nil) {
		dot2depth++;
		dot2 = dot2->Parent;
	}
	
	if( dot1 == dot2)
		return false;
	
	if( dot1depth < dot2depth)
		dot1->Parent = dot2;
	else
		dot2->Parent = dot1;
	
	return true;
}

-(bool)MergeNumbers:(CConnector*)c changedConnectorList:(NSMutableArray*)changedConnectorList {
	int parent1Depth = 0;
	int parent2Depth = 0;
	int parent1BorderCount = 0;
	int parent2BorderCount = 0;
	CNumber *parent1 = c->Number1;
	CNumber *parent2 = c->Number2;
	
	while (parent1->Parent != nil) {
		parent1Depth++;
		if (!parent1->ParentSameSide)
			parent1BorderCount++;
		parent1 = parent1->Parent;
	}
	while (parent2->Parent != nil) {
		parent2Depth++;
		if (!parent2->ParentSameSide)
			parent2BorderCount++;
		parent2 = parent2->Parent;
	}
	
	ConnectorStatus shouldBeStatus = ((parent1BorderCount + parent2BorderCount) % 2 == 0 ?
									  StatusUnset : StatusSet);
	
	if (parent1 == parent2) {
		// The two numbers are already on the same disjoint set. 
		if (c->Status == StatusUnknown) {
			return [c SetStatus:shouldBeStatus changedConnectorList:changedConnectorList] != ResultInvalid;
		} else {
			return shouldBeStatus == c->Status;
		}
	}
	
	if (c->Status == StatusUnknown) // Not previously connected & no information to connect them.
		return true; 
	
	if (parent1Depth < parent2Depth) {
		parent1->Parent = parent2;
		parent1->ParentSameSide = shouldBeStatus == c->Status;
	} else {
		parent2->Parent = parent1;
		parent2->ParentSameSide = shouldBeStatus == c->Status;
	}
	return true;
}

//public List<CConnector> manuallyCleared = new List<CConnector>();
-(void) MakeUnsetUnknown
{
	for (CConnector* c in ConnectorList)
	{
		if (c->Status == StatusUnset)
			//			if (!manuallyCleared.Contains(c))   //Don't change manually cleared connectors
			c->Status = StatusUnknown;
	}
}


-(void) AutoClear
{
	[self MakeUnsetUnknown];
	//Auto clear full numbers
	for (int x = 0; x < MaxX - 1; x++)
	{
		for (int y = 0; y < MaxY - 1; y++)
		{
			CNumber* num = Number[x][y];
			if (num != nil && num->Hidden == false)
			{
				int set = [num Count:StatusSet];
				int unknown = [num Count:StatusUnknown];
				if ((set == num->Number) && (unknown != 0))  //Already contains the correct number of connectors
				{
					if (num->Left->Status == StatusUnknown)
						num->Left->Status = StatusUnset;
					if (num->Right->Status == StatusUnknown)
						num->Right->Status = StatusUnset;
					if (num->Up->Status == StatusUnknown)
						num->Up->Status = StatusUnset;
					if (num->Down->Status == StatusUnknown)
						num->Down->Status = StatusUnset;
				}
			}
		}
	}
	//Auto clear ending lines (repeat until no ending lines)
	bool changed = false;
	do
	{
		changed = false;
		for (int x = 0; x < MaxX; x++)
		{
			for (int y = 0; y < MaxY; y++)
			{
				CDot* dot = Dot[x][y];
				int unset = [dot Count:StatusUnset];
				int set = [dot Count:StatusSet];
				int unknown = 4 - (unset + set); 
				if ((unset == 3 && unknown == 1)    //A line heading for the void
					| (set >= 2 && unknown > 0))    //A dot can only have two set connectors
				{
					changed = true;
					if (dot->Left->Status == StatusUnknown)
						dot->Left->Status = StatusUnset;
					if (dot->Right->Status == StatusUnknown)
						dot->Right->Status = StatusUnset;
					if (dot->Up->Status == StatusUnknown)
						dot->Up->Status = StatusUnset;
					if (dot->Down->Status == StatusUnknown)
						dot->Down->Status = StatusUnset;
				}
			}
		}
	} while (changed);
}

void advance(int x, int y, Direction dir, int *nextX, int *nextY) {
	*nextX = x;
	*nextY = y;
	switch (dir) {
		case DirectionRight:
			*nextX = x + 1;
			break;
		case DirectionLeft:
			*nextX = x - 1;
			break;
		case DirectionUp:
			*nextY = y - 1;
			break;
		case DirectionDown:
			*nextY = y + 1;
			break;
	}
}



@end