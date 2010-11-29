//
//  Road.h
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/12/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "User.h"
#import "Model.h"

typedef enum {
	kParseUserRoad = 0,
	kParseRoad,
} parseRoadState;

@interface Road : NSObject<Model, GameImageProtocol> {
	// Data associated with the object
	NSInteger hitPoints;
	NSInteger level;
	User * user;
	CLLocationCoordinate2D location;
	
	// State variables
	NSInteger parseState;
	
	// Game Image data
	UIImage * gameImage;
}

@property(nonatomic) NSInteger hitPoints;
@property(nonatomic) NSInteger level;
@property(nonatomic, retain) User * user;
@property(nonatomic) CLLocationCoordinate2D location;
@property(nonatomic) NSInteger parseState;
@property(nonatomic, retain) UIImage * gameImage;

// The interface to/from xml shold be consistent with the Google App Engine xml format.
-(void) parseXMLElement:(NSMutableString*)cE elementName:(NSString*)eN;
-(void) setState:(NSInteger)i;
-(NSInteger) getState;
-(void) release;
-(NSString*) getCharacteristicXMLString;

// Game image protocol
-(UIImage*) getGameImage;
-(NSString*) getImageString;


@end
