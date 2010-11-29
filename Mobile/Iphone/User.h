//
//  User.h
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/12/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "Model.h"

// A User is an indivudal play from Facebook. 
// view
@interface User : NSObject<GameImageProtocol, Model, MKAnnotation> {
	NSInteger FacebookID;
	NSInteger Experience;
	NSString * Empire;
	BOOL isEmperor;
	NSInteger completeManaProduction;
	NSInteger completeStoneProduction;
	NSInteger completeWoodProduction;
	
	// The game data associated with 
	UIImage * gameImage;
	BOOL isActive;
	
	// Annotation interface
	CLLocationCoordinate2D coordinate;
}

@property(nonatomic) NSInteger FacebookID;
@property(nonatomic) NSInteger Experience;
@property(nonatomic, retain) NSString * Empire;
@property(nonatomic) BOOL isEmperor;
@property(nonatomic) NSInteger completeManaProduction;
@property(nonatomic) NSInteger completeStoneProduction;
@property(nonatomic) NSInteger completeWoodProduction;
@property(nonatomic, retain) UIImage * gameImage;
@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic) BOOL isActive;


// Constructor sets the game state of the object
-(id) init;

// The interface to/from xml shold be consistent with the Google App Engine xml format.
-(void) parseXMLElement:(NSMutableString*)cE elementName:(NSString*)eN;
-(void) setState:(NSInteger)i;
-(NSInteger) getState;
-(void) release;
-(NSString*) getCharacteristicXMLString;

// Is the object active on the map?
-(BOOL) getIsActive;

// Annotation interface
- (void)setValueOfCoordinate:(CLLocationCoordinate2D)newCoordinate;
// GameImage Protocol
-(NSString*) getImageString;
-(UIImage*) getGameImage;

@end
