//
//  ViewController.m
//  n_ix_test
//
//  Created by Natalia Dzioba on 11/10/16.
//  Copyright © 2016 Natalia Dzioba. All rights reserved.
//

#import "ViewController.h"
#import "MapViewController.h"
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "FBViewController.h"
#import "User+CoreDataProperties.h"
#import "Pin+CoreDataProperties.h"

@interface ViewController ()<MapViewDelegate>
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIView *containerView;
@property   (nonatomic, retain) FBViewController *fbLogin;

@property   (nonatomic, retain)  MapViewController *map;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _fbLogin = [FBViewController new];
    _map = [MapViewController new];
    _map.delegate = self;
    
}

- (NSPersistentContainer *)persistentContainer{
    
    NSPersistentContainer *container = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(persistentContainer)]) {
        container = [delegate persistentContainer];
    }
    return container;
}

- (void)saveUserToCoreDataIfNeeded{
    
    NSPersistentContainer *container = [self persistentContainer];
    
    [container performBackgroundTask:^(NSManagedObjectContext *context){
        
        NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:nil];
        User *currentUser = nil;
        for (User *user in fetchedObjects)
            if([user.name isEqualToString: self.fbLogin.fbUserName])
            {
                NSSet *set = [user hasArray];
                [self setForUserFound:set];
                currentUser = user;
                break;
            }
        if(!currentUser)
        {
            NSManagedObject *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
            [newUser setValue:self.fbLogin.fbUserName forKey:@"name"];
            
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
    }];
}

- (void)setForUserFound:(NSSet *)set
{
    self.map.pinSet = [[set mutableCopy] autorelease];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    if([self.fbLogin isSuccessfullyLogedIn])
    {
        self.titleLabel.text = [NSString stringWithFormat:@"%@'s Map", self.fbLogin.fbUserName];
        
        [self saveUserToCoreDataIfNeeded];
        [self.containerView addSubview:self.map.view];
    }
    else
    {
        [self presentViewController:self.fbLogin animated:YES completion:nil];
    }
}

- (void)saveUserPins{
    NSPersistentContainer *container = [self persistentContainer];
    
    [container performBackgroundTask:^(NSManagedObjectContext *context){
        
        NSMutableSet *pinSet = [NSMutableSet new];
        
        for(MKPointAnnotation *userPin in self.map.pinSet)
        {
            Pin *newPin = [NSEntityDescription insertNewObjectForEntityForName:@"Pin" inManagedObjectContext:context];
            newPin.longitude = userPin.coordinate.longitude;
            newPin.latitude = userPin.coordinate.latitude;
            [pinSet addObject:newPin];
        }
        
        NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:nil];
        for (User *user in fetchedObjects)
            if([user.name isEqualToString: self.fbLogin.fbUserName])
            {
                NSSet *prevSet = [user hasArray];
                [user removeHasArray:prevSet];
                [user addHasArray:pinSet];
                break;
            }
        [pinSet release];
        
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
    }];
}

- (IBAction)logoutUser:(id)sender {
    
    [self saveUserPins];
    [self.map.view removeFromSuperview];
    [self presentViewController:self.fbLogin animated:YES completion:nil];
    [self.fbLogin loginButtonTapped:nil];
}

- (void)dealloc {
    [_containerView release];
    [_titleLabel release];
    [_fbLogin release];
    [_map release];
    [super dealloc];
}
@end
