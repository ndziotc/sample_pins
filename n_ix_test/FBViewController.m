//
//  FBViewController.m
//  n_ix_test
//
//  Created by Natalia Dzioba on 11/11/16.
//  Copyright © 2016 Natalia Dzioba. All rights reserved.
//

#import "FBViewController.h"

@implementation FBViewController

#pragma mark Main

- (void)dealloc {
    self.loginStatusLabel = nil;
    self.loginButton = nil;
    self.loginDialog = nil;
    self.loginDialogView = nil;
    self.fbUserName = nil;
    [super dealloc];
}

- (void)refresh {
    if (_loginState == LoginStateStartup || _loginState == LoginStateLoggedOut) {
        _loginStatusLabel.text = @"Not connected to Facebook";
        [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
        _loginButton.hidden = NO;
    } else if (_loginState == LoginStateLoggingIn) {
        _loginStatusLabel.text = @"Connecting to Facebook...";
        _loginButton.hidden = YES;
    } else if (_loginState == LoginStateLoggedIn) {
        _loginStatusLabel.text = @"Connected to Facebook";
        [_loginButton setTitle:@"Logout" forState:UIControlStateNormal];
        _loginButton.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self tryToLogin];
    [self refresh];
}

- (void)tryToLogin
{
    NSString *appId = @"1868659243369419";
    NSString *permissions = @"public_profile";
    
    if (_loginDialog == nil) {
        self.loginDialog = [[[FBLoginViewController alloc] initWithAppId:appId requestedPermissions:permissions delegate:self] autorelease];
        self.loginDialogView = _loginDialog.view;
    }
    
    if (_loginState == LoginStateStartup || _loginState == LoginStateLoggedOut) {
        _loginState = LoginStateLoggingIn;
        [_loginDialog login];
    } else if (_loginState == LoginStateLoggedIn) {
        _loginState = LoginStateLoggedOut;
        [_loginDialog logout];
    }
    
    [self refresh];
}

#pragma mark Login Button

- (IBAction)loginButtonTapped:(id)sender {
    
    [self tryToLogin];
    [self refresh];
    
}

#pragma mark FBFunLoginDialogDelegate

- (void)accessTokenFound:(NSString *)apiKey {
    NSLog(@"Access token found: %@", apiKey);
    _loginState = LoginStateLoggedIn;
    [self getFacebookProfile:apiKey];
}

- (void)getFacebookProfile:(NSString *)tocken {
    NSString *urlString = [NSString
                           stringWithFormat:@"https://graph.facebook.com/me?access_token=%@",
                           [tocken stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    // 2
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";

    NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
        NSDictionary *json = nil;
        
        if(!error)
            json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if(json)
                _fbUserName = [[json valueForKey:@"name"] retain];
        [self didGetProfileResponse];
                                        }];
    [uploadTask resume];
    [request release];
}

- (void)didGetProfileResponse
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self refresh];
}

- (void)displayRequired {
    [self presentViewController:_loginDialog animated:YES completion:nil];
}

- (void)closeTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
    _loginState = LoginStateLoggedOut;
    [_loginDialog logout];
    [self refresh];
}

- (BOOL)isSuccessfullyLogedIn
{
    if(_loginState != LoginStateLoggedIn)
        [self tryToLogin];
    return (_loginState == LoginStateLoggedIn);
}

@end
