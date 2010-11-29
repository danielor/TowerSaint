//
//  ModelMarker.h
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/28/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Model.h"
/* 
 The object implements the interface between the model data(Tower, User, Portal Road),
 and the map. It holds state information associated with the drawing of these 
 objects
 */
@interface ModelMarker : MKAnnotationView {
	id<MKAnnotation, Model> modelObject;			/* The User, Portal, Tower, Road */
}

-(id) initWithModel:(id<MKAnnotation, Model>)model;

@property(nonatomic, assign) id<MKAnnotation, Model> modelObject;

@end
