//
//  URLRequestManager.h
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/13/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Bounds.h"

static NSString * URL = @"http://localhost:8083";

// Class creates request managers that talk to the server in a particular way.
@interface URLRequestManager : NSObject {
	
}

-(NSURLRequest *) getAllObjectsInBounds:(Bounds*)b;

@end
