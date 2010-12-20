//
//  TowerSaintPhoneViewController.h
//  TowerSaintPhone
//
//  Created by Daniel  Ortiz on 12/6/10.
//  Copyright TowerSaint 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreUser.h"


// The Protocol controls how the application views interact with each other
@protocol MyViewControllerDelegate<NSObject>
@required
-(void) toggleView:(id)sender;									/* Change the current view */
-(void) setFacebookID:(NSInteger)v;								/* Set the facebook id for the view */
-(CoreUser *) getUser;												/* Get the user for the game */
-(BOOL) isUserLoggedIn;
@end

@class FacebookViewController;
@class MainViewController;


@interface TowerSaintPhoneViewController : UIViewController<MyViewControllerDelegate> {
	FacebookViewController	* facebookViewController;							/* Logs the user into facebook */
	MainViewController * mainViewController;									/* The main view controller - runs the game */
	
	// The facebook id
	CoreUser * currentUser;
	
	// Check if the user is logged in
	BOOL isLoggedIn;
	
	// The data model
	NSManagedObjectModel * schema;												/* The database schema */
	NSManagedObjectContext * databaseConnection;								/* The connection to the core database */
	NSPersistentStoreCoordinator * schemaController;							/* Controller for database queries */

}

// The view controllers for logging in and playing the game
@property(nonatomic, retain) FacebookViewController * facebookViewController;
@property(nonatomic, retain) MainViewController * mainViewController;
@property(nonatomic, retain) CoreUser * currentUser;
@property(nonatomic) BOOL isLoggedIn;

// Data model
@property(nonatomic, retain, readonly) NSManagedObjectModel * schema;
@property(nonatomic, retain, readonly) NSManagedObjectContext * databaseConnection;
@property(nonatomic, retain, readonly) NSPersistentStoreCoordinator * schemaController;

// My view controller delegate
-(void)  toggleView:(id)sender;
-(void) setFacebookID:(NSInteger)v;								
-(CoreUser *) getUser;	
-(BOOL) isUserLoggedIn;


// Get the application document directory
- (NSString *)applicationDocumentsDirectory;
- (void)handleOpenURL:(NSURL *)url; 


@end

