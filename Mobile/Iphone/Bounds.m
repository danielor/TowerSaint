//
//  Bounds.m
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/13/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "Bounds.h"


@implementation Bounds

@synthesize southwestLocation,northeastLocation;

-(id) initBoundsFromSpan:(MKCoordinateRegion)s {
	self = [super init];
	if(self != nil){
		// Extract information from the span
		southwestLocation.longitude = s.center.longitude - s.span.longitudeDelta;
		southwestLocation.latitude = s.center.latitude - s.span.latitudeDelta;
		northeastLocation.longitude = s.center.longitude - s.span.longitudeDelta;
		northeastLocation.latitude = s.center.latitude - s.span.latitudeDelta;
	}
	return self;
}

-(NSString*) toXML {
	NSString * xml = [[NSString alloc] initWithFormat:@"<bounds><southwestlocation><latitude>%f</latitude><longitude>%f</longitude></southwestlocation>" \
					  @"<northeastlocation><latitude>%f</latitude><longitude>%f</longitude></northeastlocation></bounds>", southwestLocation.latitude,
					  southwestLocation.longitude, northeastLocation.latitude, northeastLocation.longitude];
	return xml;
}



@end
