//
//  MapViewController.m
//  n_ix_test
//
//  Created by Natalia Dzioba on 11/10/16.
//  Copyright © 2016 Natalia Dzioba. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Pin+CoreDataProperties.h"

@interface MapViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>
@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) CLLocationManager *locationManager;
@end

@implementation MapViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.mapView.delegate =  self;
    self.mapView.showsUserLocation = YES;
    
    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    if([CLLocationManager locationServicesEnabled])
    {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if(self.pinSet)
    {
        for(MKPointAnnotation *pin in self.pinSet)
        {
            [self.mapView addAnnotation:pin];
        }
    }
}

- (void)setPinSet:(NSMutableSet *)pinSet{
    
    if(!_pinSet)
        _pinSet = [NSMutableSet new];
    
    for(Pin *pin in pinSet)
        [self createPinFromLocation:CLLocationCoordinate2DMake(pin.latitude, pin.longitude)];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    [self.mapView setCenterCoordinate:newLocation.coordinate animated:YES];
    [self.locationManager stopUpdatingLocation];
}

- (IBAction)addNewPin:(id)sender{

    [self createPinFromLocation:self.mapView.userLocation.location.coordinate];
    [self.delegate saveUserPins];
}

- (void)createPinFromLocation:(CLLocationCoordinate2D )coordinate{
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coordinate];
    annotation.title = @"deletePin";
    
    [_pinSet addObject:annotation];
    [self.mapView addAnnotation:annotation];
    
    [annotation release];
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation{
    
    if([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        MKPinAnnotationView *pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ident"] autorelease];
        pinView.draggable = YES;
        pinView.selected = YES;
        pinView.canShowCallout = YES;
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    [self.pinSet removeObject:view.annotation];
    [view removeFromSuperview];
    [self.delegate saveUserPins];
}


-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    
    MKAnnotationView *av = [mapView viewForAnnotation:mapView.userLocation];
    av.enabled = NO; 
}


- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState{
    
    if (newState == MKAnnotationViewDragStateStarting)
    {
        [mapView deselectAnnotation:annotationView.annotation animated:NO];
    }
    if (newState == MKAnnotationViewDragStateEnding)
    {
        annotationView.dragState = MKAnnotationViewDragStateNone;
        [self.delegate saveUserPins];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.delegate saveUserPins];
}

- (void)dealloc {
    [_mapView release];
    [_locationManager release];
    [_pinSet release];
    [super dealloc];
}
@end
