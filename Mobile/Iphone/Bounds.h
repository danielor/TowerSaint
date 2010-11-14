//
//  Bounds.h
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/13/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Bounds : NSObject {
	CLLocationCoordinate2D southwestLocation;					/* The latlng coordinates */
	CLLocationCoordinate2D northeastLocation;
}

@property(nonatomic) CLLocationCoordinate2D southwestLocation;
@property(nonatomic) CLLocationCoordinate2D northeastLocation;

-(id) initBoundsFromSpan:(MKCoordinateRegion)s;
-(NSString*) toXML;

@end
