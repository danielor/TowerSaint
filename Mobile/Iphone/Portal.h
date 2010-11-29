//
//  Portal.h
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/12/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//
#import "User.h"
#import "Model.h"

typedef enum {
	kParseUserPortal = 0,
	kParsePortal,
} parsePortalState;

// The indices of the lattice are ignored.
@interface Portal : NSObject<Model, GameImageProtocol> {
	// Variables for the portal object
	NSInteger hitPoints;				
	NSInteger level;
	CLLocationCoordinate2D startLocation;
	CLLocationCoordinate2D endLocation;
	User * user;
	
	// The state associated with the object
	NSInteger parseState;
	
	// The game image data
	UIImage * gameImage;
}

@property(nonatomic) NSInteger hitPoints;
@property(nonatomic) NSInteger level;
@property(nonatomic) CLLocationCoordinate2D startLocation;
@property(nonatomic) CLLocationCoordinate2D endLocation;
@property(nonatomic, retain) User * user;
@property(nonatomic) NSInteger parseState;
@property(nonatomic, retain) UIImage * gameImage;

// The interface to/from xml shold be consistent with the Google App Engine xml format.
-(void) parseXMLElement:(NSMutableString*)cE elementName:(NSString*)eN;
-(void) setState:(NSInteger)i;
-(NSInteger) getState;
-(NSString*) getCharacteristicXMLString;

// The game image protocol
-(NSString*) getImageString;
-(UIImage*) getGameImage;



@end
