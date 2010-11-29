//
//  MainViewController.h
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/12/10.
//  Copyright TowerSaint 2010. All rights reserved.
//

#import "FlipsideViewController.h"
#import "ModelConnectionAndParse.h"
#import "CoreLocationController.h"
#import "URLRequestManager.h"
#import "FBConnect.h"
#import "FBLoginDialog.h"
#import "Bounds.h"
#import "User.h"
#import "ImageId.h"

@protocol GImageProtocol<NSObject>
@required
-(ImageId*) getImageIdForModel:(id)cObj;
@end

typedef enum {
	initialState = 0,
	gameStart,
} gameStates;



@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, MKMapViewDelegate, MyCLControllerDelegate,GImageProtocol, ModelConnectionResultDelegate, FBSessionDelegate,FBRequestDelegate,FBDialogDelegate> {
	IBOutlet MKMapView * theMap;													/* The map */
	
	// The server connection
	ModelConnectionAndParse * connToServer;											/* The connection to the server */
	URLRequestManager * urlManager;													/* Factory class to create all of the requests */
	
	// The location control
	CoreLocationController * locationController;									/* Controls the updates to the location */
	CLLocationCoordinate2D currentLocation;											/* The current location of the controller */
													  
	// The facebook
	Facebook * _facebook;															/* The facebook object associated with this session */
	NSArray * facebookPermissions;													/* What we want the user to allow us to do? */

	// The game state
	NSInteger gameState;
	NSInteger facebookID;
	User * currentUser;																/* The current user of the game */
	NSMutableArray * listOfGameObjects;												/* The list of game objects */
	
	// The data
	NSMutableDictionary * gameImageData;													/* The array of gameImage data */
}

@property(nonatomic, retain) ModelConnectionAndParse * connToServer;
@property(nonatomic, retain) URLRequestManager * urlManager;
@property(nonatomic, retain) MKPlacemark * mPlacemark;
@property(nonatomic, retain) MKReverseGeocoder * geocoder;
@property(nonatomic) CLLocationCoordinate2D currentLocation;
@property(nonatomic, retain) CoreLocationController * locationController;
@property(nonatomic, retain) MKMapView * theMap;
@property(nonatomic, retain) NSMutableDictionary * gameImageData;
@property(nonatomic) NSInteger gameState;
@property(readonly) Facebook *facebook;
@property(nonatomic, retain) NSArray * facebookPermissions;
@property(nonatomic, retain) User * currentUser;
@property(nonatomic, retain) NSMutableArray * listOfGameObjects;

- (IBAction)showInfo:(id)sender;
-(BOOL) floatEquals:(float)f1 f2:(float)f2;

// The Game Image Protocol
-(ImageId*) getImageIdForModel:(id)cObj;


// Model connection result delegate
-(void) handleResultsFromServer:(NSArray*)a;

// Start the game
-(void) startGame;
-(void) getAllObjectInBounds:(Bounds*)b;

@end
