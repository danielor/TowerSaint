//
//  Model.h
//  TowerSaintIphone
//
//  Created by Daniel  Ortiz on 11/13/10.
//  Copyright 2010 TowerSaint. All rights reserved.
//



@protocol Model
@required
-(void) parseXMLElement:(NSMutableString*)cE elementName:(NSString*)eN;
-(void) setState:(NSInteger)i;
-(void) release;
-(NSString*) getCharacteristicXMLString;
-(NSInteger) getState;
@end

@protocol GameImageProtocol
@required
-(UIImage*) getGameImage;
-(NSString*) getImageString;
@end

