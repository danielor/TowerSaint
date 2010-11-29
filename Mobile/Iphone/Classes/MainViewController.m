//
//  MainViewController.m
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/12/10.
//  Copyright TowerSaint 2010. All rights reserved.
//

#import "MainViewController.h"


@implementation MainViewController

@synthesize facebook = _facebook;
@synthesize connToServer, mPlacemark, geocoder, currentLocation,locationController, theMap;
@synthesize gameImageData, gameState, facebookPermissions, urlManager, currentUser;
@synthesize listOfGameObjects;

static NSString* kAppId = @"142447749129831";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
		// What we want the user to allow us to do?
		facebookPermissions =  [[NSArray arrayWithObjects:@"read_stream", @"offline_access",nil] retain];
		
	
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];

	// Allocate the facebook object
	_facebook = [[Facebook alloc] init];
	
	// Setup the data
	//GameImages.plist
	NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"GameImages" ofType:@"plist"];
	gameImageData = [[NSMutableDictionary alloc] initWithDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:plistPath]];

	
	// The game state
	gameState = initialState;
	currentUser = [[User alloc] init];
}

- (void)viewWillAppear:(BOOL)will{
	// Call the super function
	[super viewWillAppear:will];
	
	// Setup the location controller
	if(gameState == initialState){
		[_facebook authorize:kAppId permissions:facebookPermissions delegate:self];
	}
	
	
}

/************************ FACEBOOK *************************/
/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
	 [_facebook requestWithGraphPath:@"me" andDelegate:self]; 
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {

}

/**
* Called when the Facebook API request has returned a response. This callback
* gives you access to the raw response. It's called before
* (void)request:(FBRequest *)request didLoad:(id)result,
* which is passed the parsed response object.
*/
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {

}

/**
* Called when a request returns and its response has been parsed into an object.
* The resulting object may be a dictionary, an array, a string, or a number, depending
* on the format of the API response.
* If you need access to the raw response, use
* (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response.
*/
- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	if([result isKindOfClass:[NSDictionary class]]){
		NSDictionary * d  = (NSDictionary*) result;
		NSString * idResult =(NSString*)[d objectForKey:@"id"];
		facebookID = [idResult intValue];
		[self startGame];
	}
}

/**
* Called when an error prevents the Facebook API request from completing successfully.
*/
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {

}

/************************ FACEBOOK *************************/


// The location controller
- (void)locationError:(NSError *)error {
	
}

-(BOOL) floatEquals:(float)f1 f2:(float)f2{
	float v = fabs(f1 - f2);
	return v < 1e-3;
}

- (void)locationUpdate:(CLLocation *)newLocation oldLocation:(CLLocation*)OldLocation {
	
	
	// Get the coordinate and format the string
	CLLocationCoordinate2D newLoc = [newLocation coordinate];
	if(![self floatEquals:currentLocation.latitude f2:newLoc.latitude]|| ![self floatEquals:currentLocation.longitude f2:newLoc.longitude]){
		currentLocation = newLoc;

		// Find location of the value on the map
		MKCoordinateRegion region;
		region.center = currentLocation;
		
		// Set the zoom level and span level
		MKCoordinateSpan span;
		span.latitudeDelta = .02;
		span.longitudeDelta = .02;
		region.span = span;
		
		// Set up the MapView
		theMap.showsUserLocation = TRUE;
		theMap.mapType = MKMapTypeStandard;
		
		
		// Get all of the game objects within the bounds
		Bounds * b = [[Bounds alloc] initBoundsFromSpan:region];
		[self getAllObjectInBounds:b];
		
		// Set the region of the map view
		[theMap setRegion:region animated:TRUE];
		
		// Update the location of the view.
		if([currentUser getIsActive]){
			//[currentUser setValueOfCoordinate:currentLocation];
			MKAnnotationView * mkView = [theMap viewForAnnotation:currentUser];
			mkView.center = theMap.center;
		}
	}
}

-(void) getAllObjectInBounds:(Bounds*)b{
	NSMutableURLRequest * request = [urlManager getAllObjectsInBounds:b];
	[connToServer parseConnectionAndRespond:request response:self];
	[b release];
}
	


-(void) startGame {
	// Setup the connection objects
	connToServer = [[ModelConnectionAndParse alloc] init];
	urlManager = [[URLRequestManager alloc] init];
	
	
	// Get the data from the server on the user
	NSMutableURLRequest * request = [urlManager getUserInformation:facebookID];
	[connToServer parseConnectionAndRespond:request response:self];
	
	// Set the delegate of the map view
	theMap.delegate = self;
	
	// Turn on the location controller
	// Setup the location controller
	locationController = [[CoreLocationController alloc] init];
	locationController.delegate = self;
	[locationController.locationManager startUpdatingLocation];
	
}


// Draw the appropriate icon depending on the user object
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
	// Get the identifier
	id<MKAnnotation,GameImageProtocol> model = (id<MKAnnotation, GameImageProtocol>)annotation;
	NSString * mImage = [model getImageString];
	MKAnnotationView * cached = [theMap dequeueReusableAnnotationViewWithIdentifier:mImage];
	
	// Release the identifier
	[mImage release];
	
	// If we have already created this view return it. If not, then create a new one.
	if(cached != nil){
		return cached;
	}else{
		ImageId * iid = [self getImageIdForModel:annotation];
		
		// Create the MKAnnotatiionView from the ImageId
		MKAnnotationView * newAnnotation = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:mImage];
		[newAnnotation setImage:iid.image];
	
		// Release and return the view
		//[iid release];
		return newAnnotation;
	}
}

-(ImageId*) getImageIdForModel:(id)cObj{
	id<GameImageProtocol> model = (id<GameImageProtocol>)cObj;
	
	// Get the string associated with the model
	NSString * mImage = [model getImageString];
	
	// Create the ImageId
	ImageId * iid = [[ImageId alloc] init];
	
	for(id currentDict in gameImageData){
		NSDictionary * dataItem = (NSDictionary*)[gameImageData objectForKey:currentDict];
		NSString * imageNamed = [dataItem objectForKey:@"Icon"];
		if([mImage isEqualToString:imageNamed]){
			[iid setImage:[UIImage imageNamed:imageNamed]];
			[iid setIdentifier:mImage];
		}
	}
	[mImage release];
	return iid;
}

-(void) handleResultsFromServer:(NSArray*)a{
	for(id currentObject in a){
		if([currentObject isKindOfClass:[User class]]){
			User * u = (User*)currentObject;
			[currentUser setIsActive:YES];
			[currentUser setFacebookID:u.FacebookID];
			[currentUser setExperience:u.Experience];
			[currentUser setEmpire:u.Empire];
			[currentUser setIsEmperor:u.isEmperor];
			[currentUser setCompleteManaProduction:u.completeManaProduction];
			[currentUser setCompleteStoneProduction:u.completeStoneProduction];
			[currentUser setCompleteWoodProduction:u.completeWoodProduction];
			
			// Keep the user as a singleton
			//[u release];
			
			// Save the annotaton
			[theMap addAnnotation:currentUser];
		}else{
			id<MKAnnotation> ann = (id<MKAnnotation>)currentObject;
			[theMap addAnnotation:ann];
		}
	}
}


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)showInfo:(id)sender {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
	[_facebook release];
	[facebookPermissions release];
	[connToServer release];
	[urlManager release];
    [super dealloc];
}


@end
