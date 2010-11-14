//
//  Road.m
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/12/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "Road.h"


@implementation Road

@synthesize hitPoints, level, user, location;
@synthesize parseState;

-(id) init {
	self = [super init];
	if (self != nil) {
		self.parseState = kParseRoad;
		self.user = [[User alloc] init];
	}
	return self;
}

-(void) parseXMLElement:(NSMutableString*)currentElementValue elementName:(NSString*)elementName {
	if(parseState == kParseUser){
		[self.user parseXMLElement:currentElementValue elementName:elementName];
	}else {
		NSString * string = [NSString stringWithString:currentElementValue];
		NSString * trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		if([elementName isEqualToString:@"hitpoints"]){
			[self setHitPoints:[trimmedString intValue]];
		}
		if([elementName isEqualToString:@"level"]){
			[self setLevel:[trimmedString intValue]];
		}
		if([elementName isEqualToString:@"latitude"]){
			self.location.latitude = [trimmedString floatValue];
		}
		if([elementName isEqualToString:@"longitude"]){
			self.location.longitude = [trimmedString floatValue];
		}
	}
}

-(void) setState:(NSInteger)i {
	parseState = i;
}

@end
