//
//  ModelConnectionAndParse.m
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/12/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "ModelConnectionAndParse.h"


@implementation ModelConnectionAndParse

@synthesize connection, dataFromConnection, parser, currentElementValue;
@synthesize resultDelegate, listOfData, currentModel;

-(id) init {
	self = [super init];
	if (self != nil) {
		dataFromConnection = [[NSMutableData alloc] init];
	}
	return self;
}

-(void) parseConnectionAndRespond:(NSURLRequest*)r response:(id<ModelConnectionResultDelegate>) rD{
	// Setup the connection/response
	self.resultDelegate = rD;
	connection = [[NSURLConnection alloc] initWithRequest:r delegate:self startImmediately:YES]; 
}

(void) parseServerData {
	// Parse the data if we have it.
	if([dataFromConnection length] != 0){
		// Release a previous instance of the parser
		if(parser){
			[parser release];
		}
		
		parser = [[NSXMLParser alloc] initWithData:dataFromConnection];
		[parser setDelegate:self];
		[parser setShouldResolveExternalEntities:YES];
		BOOL succcess = [parser parse];
		if(succcess){
			// Give the data to the main view to display.
			[self.resultDelegate handleResultsFromServer:listOfData];
		}
	}
}

// Parser elements
- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName attributes:(NSDictionary*) attributeDict{
	// Setup the list of data
	if([elementName isEqualToString:@"response"]){
		// Setup the list of data
		if(listOfData){
			[listOfData release];
		}
		
		listOfData = [[NSMutableArray alloc] init];
	}
	
}

- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string {
	if(!currentElementValue){
		currentElementValue = [[NSMutableString alloc] init];
	}
	[currentElementValue appendString:string];
}

- (void) parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName{
	if([elementName isEqualToString:@"Tower"]){
		currentModel = [[Tower alloc] init];
	}else if([elementName isEqualToString:@"Portal"]){
		currentModel = [[Portal alloc] init];
	}else if([elementName isEqualToString:@"Road"]){
		currentModel = [[Road alloc] init];
	}else if([elementName isEqualToString:@"User"]){
		[currentModel setState:0];
	}
}

- (void) parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName{
	if([elementName isEqualToString:@"Tower"] || [elementName isEqualToString:@"Portal"] || [elementName isEqualToString:@"Road"]){
		[listOfData addObject:self.currentModel];
		[self.currentModel release];
	}else if([elementName isEqualToString:@"User"]){
		[currentModel setState:1];
	}else{
		// Parse the element
		[currentModel parseXMLElement:currentElementValue elementName:elementName];
	}
}

// NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)t didReceiveResponse:(NSURLResponse *)response {
	[dataFromConnection setLength:0];	
}

- (void)connection:(NSURLConnection *)t didReceiveData:(NSData *)data{
	[dataFromConnection appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)t {
	[self parseServerData];
}

- (void)connection:(NSURLConnection *)t didFailWithError:(NSError *)error {
	[self parseServerData];
}

@end
