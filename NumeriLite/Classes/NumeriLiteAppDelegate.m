//
//  NumeriLiteAppDelegate.m
//  NumeriLite
//
//  Created by Lucio Ferrao on 09/07/13.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "NumeriLiteAppDelegate.h"

@implementation NumeriLiteAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
