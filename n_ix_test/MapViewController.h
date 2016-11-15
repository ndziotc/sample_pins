//
//  MapViewController.h
//  n_ix_test
//
//  Created by Natalia Dzioba on 11/10/16.
//  Copyright © 2016 Natalia Dzioba. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MapViewDelegate <NSObject>

-(void)saveUserPins;

@end

@interface MapViewController : UIViewController

@property (retain, nonatomic) NSMutableSet *pinSet;
@property (assign, nonatomic) id<MapViewDelegate> delegate;

@end
