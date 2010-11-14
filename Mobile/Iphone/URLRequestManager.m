//
//  URLRequestManager.m
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/13/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "URLRequestManager.h"


@implementation URLRequestManager

-(NSURLRequest *) getAllObjectsInBounds:(Bounds*)b {
	// Create the post
	NSURL * serviceURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@/bounds/%@", URL, [b toXML]]];
	
	// Create the URL Request
	NSMutableURLRequest * serviceRequest = [NSMutableURLRequest requestWithURL:serviceURL];
	[serviceRequest setHTTPMethod:@"GET"];
	return serviceRequest;
}


@end
