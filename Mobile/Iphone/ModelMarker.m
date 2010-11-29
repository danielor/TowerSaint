//
//  ModelMarker.m
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/28/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "ModelMarker.h"


@implementation ModelMarker

@synthesize modelObject;

-(id) initWithModel:(id<MKAnnotation, Model>)model{
	self = [super init];
	if (self != nil) {
		modelObject = model;
	}
	return self;
}

@end
