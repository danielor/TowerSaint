//
//  Constants.h
//  TowerSaintPhone
//
//  Created by Daniel  Ortiz on 12/19/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//

// Game constants.
@interface Constants : NSObject {
	
	// Constants associated with the indexing of the data
	float latOffset;
	float lonOffset;
}

@property(nonatomic, readonly) float latOffset;
@property(nonatomic, readonly) float lonOffset;

@end
