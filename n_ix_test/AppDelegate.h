//
//  AppDelegate.h
//  n_ix_test
//
//  Created by Natalia Dzioba on 11/10/16.
//  Copyright © 2016 Natalia Dzioba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

