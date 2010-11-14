//
//  MainViewController.h
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/12/10.
//  Copyright TowerSaint 2010. All rights reserved.
//

#import "FlipsideViewController.h"
#import "ModelConnectionAndParse.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {
	ModelConnectionAndParse * connToServer;											/* The connection to the server */
}

@property(nonatomic, retain) ModelConnectionAndParse * connToServer;

- (IBAction)showInfo:(id)sender;

@end
