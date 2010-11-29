//
//  URLRequestManager.m
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/13/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "URLRequestManager.h"


@implementation URLRequestManager

static NSString * URL = @"http://localhost:8083";

@synthesize lastRequest;

-(id) init {
	self = [super init];
	if (self != nil) {
		lastRequest = -1;
	}
	return self;
}

-(NSMutableURLRequest *) getAllObjectsInBounds:(Bounds*)b {
	// The last request
	lastRequest = reqeustObjectsInBounds;
	
	// Create the post
	NSURL * serviceURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@/bounds/%@", URL, [b toXML]]];
	
	// Create the URL Request
	NSMutableURLRequest * serviceRequest = [NSMutableURLRequest requestWithURL:serviceURL];
	[serviceRequest setHTTPMethod:@"GET"];
	return serviceRequest;
}

-(NSMutableURLRequest *) getUserInformation:(NSInteger)fbid{
	// The last request
	lastRequest = requestUserInfo;
	
	NSURL *serviceURL = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@/user/%d", URL, fbid]];
	
	// Create the URL Request
	NSMutableURLRequest * serviceRequest = [NSMutableURLRequest requestWithURL:serviceURL];
	[serviceRequest setHTTPMethod:@"GET"];
	return serviceRequest;
}


@end
