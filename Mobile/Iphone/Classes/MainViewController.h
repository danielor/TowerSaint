//
//  MainViewController.h
//  TowerSaintPhone
//
//  Created by Daniel  Ortiz on 12/7/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TowerSaintPhoneViewController.h"
#import "ModelConnectionAndParse.h"
#import "CoreLocationController.h"
#import "URLRequestManager.h"
#import "Bounds.h"
#import "User.h"
#import "ImageId.h"
#import "ModelAnnotation.h"
#import "Constants.h"

@protocol GImageProtocol<NSObject>
@required
-(ImageId*) getImageIdForModel:(id)cObj;
@end

typedef enum {
	initialState = 0,
	gameStart,
} gameStates;


@interface MainViewController : UIViewController<MKMapViewDelegate, MyCLControllerDelegate,GImageProtocol, ModelConnectionResultDelegate> {
	IBOutlet MKMapView * theMap;
	
	// The server connection
	ModelConnectionAndParse * connToServer;											/* The connection to the server */
	URLRequestManager * urlManager;													/* Factory class to create all of the requests */
	
	// The location control
	CoreLocationController * locationController;									/* Controls the updates to the location */
	CLLocationCoordinate2D currentLocation;											/* The current location of the controller */
	
	// The game state
	NSInteger gameState;
	User * currentUser;																/* The current user of the game */
	NSMutableArray * listOfGameObjects;												/* The list of game objects */
	BOOL isUpdatingLocation;														/* True if core location is updating positions */
	Constants * gameConstants;														/* Constants associated with the game */
	
	// The data
	NSMutableDictionary * gameImageData;											/* The array of gameImage data */
	
	
	// The view controller
	id viewController;
}


@property(nonatomic, retain) MKMapView * theMap;
@property(nonatomic, assign) id<MyViewControllerDelegate> viewController;
@property(nonatomic, retain) ModelConnectionAndParse * connToServer;
@property(nonatomic, retain) URLRequestManager * urlManager;
@property(nonatomic, retain) MKPlacemark * mPlacemark;
@property(nonatomic, retain) MKReverseGeocoder * geocoder;
@property(nonatomic) CLLocationCoordinate2D currentLocation;
@property(nonatomic, retain) CoreLocationController * locationController;
@property(nonatomic, retain) NSMutableDictionary * gameImageData;
@property(nonatomic) NSInteger gameState;
@property(nonatomic) BOOL isUpdatingLocation;
@property(nonatomic, retain) User * currentUser;
@property(nonatomic, retain) NSMutableArray * listOfGameObjects;
@property(nonatomic, retain) Constants * gameConstants;

-(BOOL) floatEquals:(float)f1 f2:(float)f2;

// The Game Image Protocol
-(ImageId*) getImageIdForModel:(id)cObj;

// Model connection result delegate
-(void) handleResultsFromServer:(NSArray*)a;

// Start the game
-(void) startGame;
-(void) getAllObjectInBounds:(Bounds*)b;

@end
