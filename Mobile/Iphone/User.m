//
//  User.m
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/12/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "User.h"


@implementation User

@synthesize FacebookID, Experience, Empire, isEmperor;
@synthesize completeManaProduction, completeStoneProduction;
@synthesize completeWoodProduction, gameImage, isActive;
@synthesize coordinate;

-(id) init {
	self = [super init];
	if (self != nil) {
		isActive = NO;
	}
	return self;
	
}

-(void) parseXMLElement:(NSMutableString*)currentElementValue elementName:(NSString*)elementName {
	NSString * string = [NSString stringWithString:currentElementValue];
	NSString * trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if([elementName isEqualToString:@"experience"]){
		[self setExperience:[trimmedString intValue]];
	}
	if([elementName isEqualToString:@"empire"]){
		[self setEmpire:trimmedString];
	}
	if([elementName isEqualToString:@"isemperor"]){
		[self setIsEmperor:[trimmedString boolValue]];
	}
	if([elementName isEqualToString:@"completemanaproduction"]){
		[self setCompleteManaProduction:[trimmedString intValue]];
	}
	if([elementName isEqualToString:@"completestoneproduction"]){
		[self setCompleteStoneProduction:[trimmedString intValue]];
	}
	if([elementName isEqualToString:@"completewoodproduction"]){
		[self setCompleteWoodProduction:[trimmedString intValue]];
	}
	if([elementName isEqualToString:@"facebookid"]){
		[self setFacebookID:[trimmedString intValue]];
	}
}

-(UIImage*) getGameImage{
	return gameImage;
}

-(NSString*) getImageString {
	return [[NSString alloc] initWithString:@"Crown.png"];
}



-(void) setState:(NSInteger)i{
	
}

- (void)setValueOfCoordinate:(CLLocationCoordinate2D)newCoordinate{
	self.coordinate = newCoordinate;
}

-(BOOL) getIsActive{
	return isActive;
}


-(void) release {
	[Empire release];
	[gameImage release];
}

-(NSInteger) getState{
	return 0;
}

-(NSString*) getCharacteristicXMLString{
	return [[NSString alloc] initWithString:@"User"];
}


@end
