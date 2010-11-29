//
//  Portal.m
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/12/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "Portal.h"


@implementation Portal

@synthesize hitPoints, level, startLocation;
@synthesize endLocation, user, parseState;
@synthesize gameImage;

-(id) init {
	self = [super init];
	if (self != nil) {
		self.user = [[User alloc] init];
		self.parseState = kParsePortal;
	}
	return self;
}

// The interface to/from xml shold be consistent with the Google App Engine xml format.
-(void) parseXMLElement:(NSMutableString*)currentElementValue elementName:(NSString*)elementName {
	if(parseState == kParseUserPortal){
		[self.user parseXMLElement:currentElementValue elementName:elementName];
	}else{
		NSString * string = [NSString stringWithString:currentElementValue];
		NSString * trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		if([currentElementValue isEqualToString:@"hitpoints"]){
			[self setHitPoints:[trimmedString intValue]];
		}
		if([currentElementValue isEqualToString:@"level"]){
			[self setLevel:[trimmedString intValue]];
		}
		if([currentElementValue isEqualToString:@"startlatitude"]){
			startLocation.latitude = [trimmedString floatValue];
		}
		if([currentElementValue isEqualToString:@"startlongitude"]){
			startLocation.longitude = [trimmedString floatValue];
		}
		if([currentElementValue isEqualToString:@"endlatitude"]){
			endLocation.latitude = [trimmedString floatValue];
		}
		if([currentElementValue isEqualToString:@"endlongitude"]){
			endLocation.longitude = [trimmedString floatValue];
		}
	}
}

-(void) setState:(NSInteger)i {
	parseState = i;
}

-(UIImage*) getGameImage {
	return gameImage;
}

-(NSString*) getImageString {
	return [[NSString alloc] initWithString:@"Portal.png"];
}


-(NSInteger) getState {
	return parseState;	
}

-(void) release {
	[gameImage release];
}

-(NSString*) getCharacteristicXMLString{
	return [[NSString alloc] initWithString:@"Portal"];
}

@end
