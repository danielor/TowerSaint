//
//  URLRequestManager.h
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/13/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "Bounds.h"

typedef enum {
	requestUserInfo = 0,
	reqeustObjectsInBounds,
} lastURLRequest;

// Class creates request managers that talk to the server in a particular way.
@interface URLRequestManager : NSObject {
	NSInteger lastRequest;
}

@property(nonatomic) NSInteger lastRequest;

// Url requests
-(id) init;
-(NSMutableURLRequest *) getAllObjectsInBounds:(Bounds*)b;
-(NSMutableURLRequest *) getUserInformation:(NSInteger)fbid;

@end
