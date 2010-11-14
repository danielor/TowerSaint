//
//  Portal.h
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/12/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "User.h"
#import "Model.h"

typedef enum {
	kParseUser = 0,
	kParsePortal,
} parsePortalState;

// The indices of the lattice are ignored.
@interface Portal : NSObject<Model> {
	// Variables for the portal object
	NSInteger hitPoints;				
	NSInteger level;
	CLLocationCoordinate2D startLocation;
	CLLocationCoordinate2D endLocation;
	User * user;
	
	// The state associated with the object
	NSInteger parseState;
}

@property(nonatomic) NSInteger hitPoints;
@property(nonatomic) NSInteger level;
@property(nonatomic) CLLocationCoordinate2D startLocation;
@property(nonatomic) CLLocationCoordinate2D endLocation;
@property(nonatomic, retain) User * user;
@property(nonatomic) NSInteger parseState;

// The interface to/from xml shold be consistent with the Google App Engine xml format.
-(void) parseXMLElement:(NSMutableString*)cE elementName:(NSString*)eN;
-(void) setState:(NSInteger)i;

@end
