//
//  Tower.m
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/12/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "Tower.h"


@implementation Tower

@synthesize Experience, Speed, Power, Armor, Range, Accuracy;
@synthesize HitPoints, isIsolated, isCapital, hasRuler, Level;
@synthesize user, manaProduction, stoneProduction, woodProduction;
@synthesize location;

-(id) init {
	self = [super init];
	if (self != nil) {
		self.user = [[User alloc] init];
		self.parseState = kParseTower;
	}
	return self;
}

-(void) parseXMLElement:(NSMutableString*)currentElementValue elementName:(NSString*)elementName {
	if(parseState == kParseUser){
		[user parseXMLElement:currentElementValue elementName:elementName];
	}else{
		NSString * string = [NSString stringWithString:currentElementValue];
		NSString * trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		// Set all of the tower stats
		if([elementName isEqualToString:@"experience"]){
			[self setExperience:[trimmedString intValue]];
		}
		if([elementName isEqualToString:@"speed"]){
			[self setSpeed:[trimmedString intValue]];
		}
		if([elementName isEqualToString:@"power"]){
			[self setPower:[trimmedString intValue]];
		}
		if([elementName isEqualToString:@"armor"]){
			[self setArmor:[trimmedString intValue]];
		}
		if([elementName isEqualToString:@"range"]){
			[self setRange:[trimmedString intValue]];
		}
		if([elementName isEqualToString:@"accuracy"]){
			[self setAccuracy:[trimmedString floatValue]];
		}
		if([elementName isEqualToString:@"hitpoints"]){
			[self setHitPoints:[trimmedString intValue]];
		}
		if([elementName isEqualToString:@"isisolated"]) {
			[self setIsIsolated:[trimmedString boolValue]];
		}
		if([elementName isEqualToString:@"iscapital"]){
			[self setIsCapital:[trimmedString boolValue]];
		}
		if([elementName isEqualToString:@"hasruler"]){
			[self setHasRuler:[trimmedString boolValue]];
		}	
		if([elementName isEqualToString:@"level"]){
			[self setLevel:[trimmedString floatValue]];
		}
		if([elementName isEqualToString:@"manaproduction"]){
			[self setManaProduction:[trimmedString intValue]];
		}
		if([elementName isEqualToString:@"stoneproduction"]){
			[self setStonePrdouction:[trimmedString intValue]];
		}
		if([elementName isEqualToString:@"woodproduction"]){
			[self setWoodProduction:[trimmedString intValue]];
		}
		if([elementName isEqualToString:@"latitude"]){
			location.latitude = [trimmedString floatValue];
		}
		if([elementName isEqualToString:@"longitude"]){
			location.longitude = [trimmedString floatValue];
		}
	}
}

-(void) setState:(NSInteger)i {
	parseState = i;
}

@end
