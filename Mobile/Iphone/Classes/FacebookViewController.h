//
//  FacebookViewController.h
//  TowerSaintPhone
//
//  Created by Daniel  Ortiz on 12/6/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TowerSaintPhoneViewController.h"
#import "FBConnect.h"

@interface FacebookViewController : UIViewController<FBSessionDelegate,FBRequestDelegate,FBDialogDelegate> {
	Facebook * _facebook;															/* The facebook object associated with this session */
	NSArray * facebookPermissions;													/* What we want the user to allow us to do? */
	
	// The viewController
	id viewController;
}

@property(readonly) Facebook * facebook;
@property(nonatomic, retain) NSArray * facebookPermissions;
@property(nonatomic, assign) id<MyViewControllerDelegate> viewController;


@end
