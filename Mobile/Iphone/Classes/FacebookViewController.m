//
//  FacebookViewController.m
//  TowerSaintPhone
//
//  Created by Daniel  Ortiz on 12/6/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import "FacebookViewController.h"


@implementation FacebookViewController


@synthesize facebook = _facebook, facebookPermissions, viewController;
static NSString* kAppId = @"142447749129831";


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		
		// What we want the user to allow us to do?
		facebookPermissions =  [[NSArray arrayWithObjects:@"read_stream", @"offline_access",nil] retain];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Allocate the facebook object
	_facebook = [[Facebook alloc] initWithAppId:kAppId];

	[_facebook authorize:facebookPermissions delegate:self];
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
		
		// Save the facebook id
		[self.viewController setFacebookID:[idResult intValue]];
		[self.viewController toggleView:self];
	}
}

/**
 * Called when an error prevents the Facebook API request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	
}

/************************ FACEBOOK *************************/



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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	
	// Remove the facebook objects
	[_facebook release];
	[facebookPermissions release];
}


@end
