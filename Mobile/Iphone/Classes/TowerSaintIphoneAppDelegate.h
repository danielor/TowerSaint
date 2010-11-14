//
//  TowerSaintIphoneAppDelegate.h
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/12/10.
//  Copyright TowerSaint 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface TowerSaintIphoneAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MainViewController *mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;

@end

