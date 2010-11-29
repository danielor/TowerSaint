//
//  ImageId.h
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/28/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//



/* Image Id is a small structure combining an image, and an identifier */
@interface ImageId : NSObject {
	UIImage * image;					/* The image for an icon */
	NSString * identifier;				/* The identifier */
}

@property(nonatomic, retain) UIImage * image;
@property(nonatomic, retain) NSString * identifier;

@end
