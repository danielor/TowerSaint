//
//  ModelAnnotation.m
//  TowerSaintPhone
//
//  Created by Daniel  Ortiz on 12/15/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "ModelAnnotation.h"


@implementation ModelAnnotation

@synthesize coordinate, model;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord
{
	self = [super init];
	if(self != nil){
		coordinate = coord;
	}
	return self;
}


@end
