//
//  ModelConnectionAndParse.h
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/12/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "Tower.h"
#import "Road.h"
#import "Portal.h"
#import "User.h"
#import "Model.h"

// The model connection result deleage is a protocol which grabs information
// from the
@protocol ModelConnectionResultDelegate
@required
-(void) handleResultsFromServer:(NSArray*)a;		/* A list of objects from the server */
@end

typedef enum {
	parseTower = 0,
	parseRoad,
	parsePortal,
} modelParse;

typedef enum {
	activeConnection =0,
	doneConnection,
} connState;

@interface ModelConnectionAndParse : NSObject<NSXMLParserDelegate > {
	// The object necessary to make the model connection function properly
	NSURLConnection * connection;					/* The url connection to the server */
	NSMutableData * dataFromConnection;				/* Th unparsed data from the connection */
	NSXMLParser * parser;							/* Parser used to parse server data */
	NSMutableString * currentElementValue;			/* The current value of the xml data */
	NSMutableArray	* listOfData;					/* The list of objects from the server */
	
	// A queue of connections
	NSMutableArray * queueOfConnections;			/* The queue of the connections */

	// The current objects
	id<Model> currentModel;
	
	// The interface for sending results to objects that need them. 
	id resultDelegate;								/* An instance of the modelconnectionresult delegate. Gets the result of the connection */
}

// The properties
@property(nonatomic, retain) NSURLConnection * connection;
@property(nonatomic, retain) NSMutableData * dataFromConnection;
@property(nonatomic, retain) NSXMLParser * parser;
@property(nonatomic, retain) NSMutableString * currentElementValue;
@property(nonatomic, assign) id<ModelConnectionResultDelegate> resultDelegate;
@property(nonatomic, retain) id<Model> currentModel;
@property(nonatomic, retain) NSMutableArray * listOfData;
@property(nonatomic, retain) NSMutableArray * queueOfConnections;

// Initialize with request
-(id) init;
-(void) parseConnectionAndRespond:(NSURLRequest*)r response:(id<ModelConnectionResultDelegate>) responseDelegate;
-(void) parseServerData;															/* Parses the data coming from the server */


@end
