//
//  Tower.h
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/12/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Model.h"

typedef enum {
	kParseUser = 0,
	kParseTower,
} parseTowerState;

@interface Tower : NSObject<Model> {
	// Stats about the tower.
	NSInteger Experience;
	NSInteger Speed;
	NSInteger Power;
	NSInteger Armor;
	NSInteger Range;
	float Accuracy;
	NSInteger HitPoints;
	BOOL isIsolated;
	BOOL isCapital;
	BOOL hasRuler;
	NSInteger Level;

	
	// Production/user data.
	User * user;
	NSInteger manaProduction;
	NSInteger stoneProduction;
	NSInteger woodProduction;
	CLLocationCoordinate2D  location;
	
	// Parsing information
	NSInteger parseState;
}

@property(nonatomic) NSInteger Experience;
@property(nonatomic) NSInteger Speed;
@property(nonatomic) NSInteger Power;
@property(nonatomic) NSInteger Armor;
@property(nonatomic) NSInteger Range;
@property(nonatomic) float Accuracy;
@property(nonatomic) NSInteger HitPoints;
@property(nonatomic) BOOL isIsolated;
@property(nonatomic) BOOL isCapital;
@property(nonatomic) BOOL hasRuler;
@property(nonatomic) NSInteger Level;
@property(nonatomic, retain) User * user;
@property(nonatomic) NSInteger manaProduction;
@property(nonatomic) NSInteger stonePrdouction;
@property(nonatomic) NSInteger woodProduction;
@property(nonatomic) CLLocationCoordinate2D location;
@property(nonatomic) NSInteger parseState;

// The interface to/from xml shold be consistent with the Google App Engine xml format.
-(void) parseXMLElement:(NSMutableString*)cE elementName:(NSString*)eN;
-(void) setState:(NSInteger)i;


@end
