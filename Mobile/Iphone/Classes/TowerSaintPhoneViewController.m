//
//  TowerSaintPhoneViewController.m
//  TowerSaintPhone
//
//  Created by Daniel  Ortiz on 12/6/10.
//  Copyright TowerSaint 2010. All rights reserved.
//

#import "TowerSaintPhoneViewController.h"
#import "FacebookViewController.h"
#import "MainViewController.h"


@implementation TowerSaintPhoneViewController

@synthesize facebookViewController, mainViewController;
@synthesize schema, databaseConnection, schemaController;
@synthesize currentUser, isLoggedIn;



// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
       
    }
    return self;
}


-(void) loadFacebookViewController {
	FacebookViewController * viewController = [[FacebookViewController alloc] initWithNibName:@"FacebookViewController" bundle:nil];
	self.facebookViewController = viewController;
	self.facebookViewController.viewController = self;
	[viewController release];
}

-(void) loadMainViewController {
	MainViewController * viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
	self.mainViewController = viewController;
	self.mainViewController.viewController = self;
	[viewController release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	

	
	// Fetch the user object
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext * context = [self databaseConnection];
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"CoreUser" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	NSError * error;
	NSArray * userList = [context executeFetchRequest:fetchRequest error:&error];
	
	// Set the current user with the context

	
	// Load the view controllers
	[self loadFacebookViewController];
	[self loadMainViewController];
	
	// Depending on the initialization
	if([userList count] == 0){
		isLoggedIn = NO;
		[self.view addSubview:facebookViewController.view];
	}else {
		isLoggedIn = YES;
		
		// Get the current user from the data store and load the game!!!!
		currentUser = (CoreUser*)[userList objectAtIndex:0];
		[self.view addSubview:mainViewController.view];
	}
}

/*
Returns the managed object context for the application.
*/
-(NSManagedObjectContext*) databaseConnection {
	if(databaseConnection != nil){
		return databaseConnection;
	}
	
	NSPersistentStoreCoordinator * coordinator = [self schemaController];
	if (coordinator != nil) {
		databaseConnection = [[NSManagedObjectContext alloc] init];
		[databaseConnection setPersistentStoreCoordinator:coordinator];
	}
	
	return databaseConnection;
}


/*

File: CoreDataBooksAppDelegate.m

Abstract: Application delegate to set up the Core Data stack and configure the first view and navigation controllers.

Version: 1.1



Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple

Inc. ("Apple") in consideration of your agreement to the following

terms, and your use, installation, modification or redistribution of

this Apple software constitutes acceptance of these terms.  If you do

not agree with these terms, please do not use, install, modify or

redistribute this Apple software.



In consideration of your agreement to abide by the following terms, and

subject to these terms, Apple grants you a personal, non-exclusive

license, under Apple's copyrights in this original Apple software (the

"Apple Software"), to use, reproduce, modify and redistribute the Apple

Software, with or without modifications, in source and/or binary forms;

provided that if you redistribute the Apple Software in its entirety and

without modifications, you must retain this notice and the following

text and disclaimers in all such redistributions of the Apple Software.

Neither the name, trademarks, service marks or logos of Apple Inc. may

be used to endorse or promote products derived from the Apple Software

without specific prior written permission from Apple.  Except as

expressly stated in this notice, no other rights or licenses, express or

implied, are granted by Apple herein, including but not limited to any

patent rights that may be infringed by your derivative works or by other

works in which the Apple Software may be incorporated.



The Apple Software is provided by Apple on an "AS IS" basis.  APPLE

MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION

THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS

FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND

OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.



IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL

OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF

SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS

INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,

MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED

AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),

STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE

POSSIBILITY OF SUCH DAMAGE.



Copyright (C) 2010 Apple Inc. All Rights Reserved.



*/
- (NSPersistentStoreCoordinator *)schemaController {
	
	if (schemaController != nil) {
		return schemaController;
	}
	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"TowerSaint.sqlite"];
	
	/*
	 Set up the store.
	 For the sake of illustration, provide a pre-populated default store.
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"TowerSaint" ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];    
	schemaController = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self schema]];
	
	NSError *error;
	if (![schemaController addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}    
	
	return schemaController;
	
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */

- (NSManagedObjectModel *)schema {
    if (schema != nil) {
        return schema;
    }
	
    schema = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return schema;
}

/**
 
 Returns the path to the application's documents directory.
 
 */

- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
	
}

// Flip between the view
-(void) toggleView:(id)sender{
	// Animation for flipping views
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:((mainViewController == sender) ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];
	
	if(facebookViewController == sender){
		// Change does not depend on the state of the view controller
		[mainViewController viewWillAppear:YES];
		[facebookViewController viewWillDisappear:YES];
		[facebookViewController.view removeFromSuperview];
		[self.view addSubview:mainViewController.view];
		[facebookViewController viewDidDisappear:YES];
		[mainViewController viewDidAppear:YES];
	}
	
	[UIView commitAnimations];

}

-(void) setFacebookID:(NSInteger)v {

	// Setup the core user
	NSManagedObjectContext * context = [self databaseConnection];
	CoreUser * u = [NSEntityDescription insertNewObjectForEntityForName:@"CoreUser" inManagedObjectContext:context];
	u.facebookID = [[NSNumber alloc] initWithInt:v];
	
	// Change the state
	isLoggedIn = YES;
	
	// Save the user
	NSError * error;
	if (![context save:&error]) {
		NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
	}
	
}
-(CoreUser*) getUser{
	return currentUser;
}


-(BOOL) isUserLoggedIn {
	return isLoggedIn;
}


- (void) handleOpenURL:(NSURL *)url {
	BOOL value = [[facebookViewController facebook] handleOpenURL:url];
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/





/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[currentUser release];
    [super dealloc];
}

@end
