//
//  ImageId.m
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/28/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "ImageId.h"


@implementation ImageId

@synthesize image, identifier;

-(void) dealloc{
	[image release];
	[identifier release];
	[super dealloc];
}

@end
