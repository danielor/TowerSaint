//
//  TowerSaintPhoneAppDelegate.h
//  TowerSaintPhone
//
//  Created by Daniel  Ortiz on 12/6/10.
//  Copyright TowerSaint 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TowerSaintPhoneViewController;

@interface TowerSaintPhoneAppDelegate : NSObject <UIApplicationDelegate> {

	// The windowing and the main view controller
	UIWindow *window;
    TowerSaintPhoneViewController *viewController;
}

// View controller
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TowerSaintPhoneViewController *viewController;




@end

