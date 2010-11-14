//
//  User.h
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/12/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// A User is an indivudal play from Facebook. 
// view
@interface User : NSObject {
	float FacebookID;
	NSInteger Experience;
	NSString * Empire;
	BOOL isEmperor;
	NSInteger completeManaProduction;
	NSInteger completeStoneProduction;
	NSInteger completeWoodProduction;
}

@property(nonatomic) float FacebookID;
@property(nonatomic) NSInteger Experience;
@property(nonatomic, retain) NSString * Empire;
@property(nonatomic) BOOL isEmperor;
@property(nonatomic) NSInteger completeManaProduction;
@property(nonatomic) NSInteger completeStoneProduction;
@property(nonatomic) NSInteger completeWoodProduction;

// The interface to/from xml shold be consistent with the Google App Engine xml format.
-(void) parseXMLElement:(NSMutableString*)cE elementName:(NSString*)eN;

@end
