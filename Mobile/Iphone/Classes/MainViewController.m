//
//  MainViewController.m
//  TowerSaintPhone
//
//  Created by Daniel  Ortiz on 12/7/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "MainViewController.h"


@implementation MainViewController

@synthesize viewController, theMap, gameConstants;
@synthesize connToServer, mPlacemark, geocoder, currentLocation,locationController;
@synthesize gameImageData, gameState, urlManager, currentUser;
@synthesize listOfGameObjects, isUpdatingLocation;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Setup the data
		//GameImages.plist
		NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"GameImages" ofType:@"plist"];
		gameImageData = [[NSMutableDictionary alloc] initWithDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:plistPath]];
		
		// The game state
		gameState = initialState;
		isUpdatingLocation = NO;
		gameConstants = [[Constants alloc] init];
		
		// The Current User
		currentUser = [[User alloc] init];
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	BOOL isLoggedIn = [self.viewController isUserLoggedIn];
	if(isLoggedIn){
		[self startGame];
	}
}

- (void)viewWillAppear:(BOOL)will{
	// Call the super function
	[super viewWillAppear:will];
	
	// Setup the location controller
	BOOL isLoggedIn = [self.viewController isUserLoggedIn];
	if(isLoggedIn){
		[self startGame];
	}
}


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
		//theMap.showsUserLocation = TRUE;
		theMap.mapType = MKMapTypeStandard;
		
		// Change th updating state
		isUpdatingLocation = YES;
		
		// Get all of the game objects within the bounds
		Bounds * b = [[Bounds alloc] initBoundsFromSpan:region];
		[self getAllObjectInBounds:b];
		
		// Set the region of the map view
		[theMap setRegion:region animated:TRUE];
		
		// Update the location of the view.
		if([currentUser getIsActive]){
			ModelAnnotation * ma = [[ModelAnnotation alloc] initWithCoordinate:currentLocation];
			ma.model = currentUser;
			[theMap addAnnotation:ma];

		}
	}
}

-(void) getAllObjectInBounds:(Bounds*)b{
	NSMutableURLRequest * request = [urlManager getAllObjectsInBounds:b constants:gameConstants];
	[connToServer parseConnectionAndRespond:request response:self];
	[b release];
}



-(void) startGame {
	// Setup the connection objects
	connToServer = [[ModelConnectionAndParse alloc] init];
	urlManager = [[URLRequestManager alloc] init];
	
	
	// Get the data from the server on the user
	CoreUser * cu = [self.viewController getUser];
	NSInteger facebookID = [cu.facebookID intValue];
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
-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:
(id <MKAnnotation>)annotation {
	if (annotation == theMap.userLocation){ 
		return nil;
	}
	
	// Get the identifier
	ModelAnnotation * ma = (ModelAnnotation*)annotation;
	id<Model ,GameImageProtocol> model = ma.model;
	NSString * mImage = [model getImageString];
	MKAnnotationView * cached = [theMap dequeueReusableAnnotationViewWithIdentifier:mImage];
	
	// Release the identifier
	
	// If we have already created this view return it. If not, then create a new one.
	if(cached != nil){
		return cached;
	}else{
		MKAnnotationView * newAnnotation = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:mImage] autorelease];
		newAnnotation.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:mImage ofType:nil]];
		newAnnotation.annotation = annotation;
		
		// Release and return the view
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

		
			// Draw the model associated with the user of the game
			if(isUpdatingLocation){
				ModelAnnotation * ma = [[ModelAnnotation alloc] initWithCoordinate:currentLocation];
				ma.model = currentUser;
				[theMap addAnnotation:ma];
			}
			// Keep the user as a singleton
			//[u release];
			
			// Save the annotaton
			//[theMap addAnnotation:currentUser];
		}else{
			id<MapObject,Model, GameImageProtocol> ann = (id<MapObject, Model, GameImageProtocol>)currentObject;
		
			
			NSArray * n = [ann getObjectLocaions];
			for(id currentObject in n){
				// Get the position(latlng) of the object and draw it on the map
				CLLocation * cl = (CLLocation*) currentObject;
				CLLocationCoordinate2D pos = [cl coordinate];
				
				
				// Get the model annotation. Add the annotation
				ModelAnnotation * ma = [[ModelAnnotation alloc] initWithCoordinate:pos];
				ma.model = ann;
				[theMap addAnnotation:ma];
				
				[cl release];
			}
			[n release];
		}
	}
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


- (void)dealloc {
	[gameConstants release];
	[connToServer release];
	[urlManager release];
    [super dealloc];
}



@end
