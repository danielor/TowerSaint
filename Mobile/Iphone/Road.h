//
//  Road.h
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
	kParseRoad,
} parseRoadState;

@interface Road : NSObject<Model> {
	// Data associated with the object
	NSInteger hitPoints;
	NSInteger level;
	User * user;
	CLLocationCoordinate2D location;
	
	// State variables
	NSInteger parseState;

}

@property(nonatomic) NSInteger hitPoints;
@property(nonatomic) NSInteger level;
@property(nonatomic, retain) User * user;
@property(nonatomic, retain) CLLocationCoordinate2D location;
@property(nonatomic) NSInteger parseState;

// The interface to/from xml shold be consistent with the Google App Engine xml format.
-(void) parseXMLElement:(NSMutableString*)cE elementName:(NSString*)eN;
-(void) setState:(NSInteger)i;


@end
