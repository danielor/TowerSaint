//
//  ModelAnnotation.h
//  TowerSaintPhone
//
//  Created by Daniel  Ortiz on 12/15/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//


#import "Model.h"

@interface ModelAnnotation : NSObject<MKAnnotation> {
	// The model
	id model;
	
	// The coordinate
	CLLocationCoordinate2D coordinate;
}

@property(nonatomic, assign) id<GameImageProtocol, Model> model;
@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;

// add an init method so you can set the coordinate property on startup
- (id) initWithCoordinate:(CLLocationCoordinate2D)coord;


@end
