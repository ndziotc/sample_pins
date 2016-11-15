//
//  FBLoginViewController.h
//  n_ix_test
//
//  Created by Natalia Dzioba on 11/11/16.
//  Copyright © 2016 Natalia Dzioba. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <UIKit/UIKit.h>

@protocol FBLoginDelegate
- (void)accessTokenFound:(NSString *)accessToken;
- (void)displayRequired;
- (void)closeTapped;
@end

@interface FBLoginViewController : UIViewController <UIWebViewDelegate> {
    UIWebView *_webView;
    NSString *_apiKey;
    NSString *_requestedPermissions;
    id <FBLoginDelegate> _delegate;
}

@property (retain) IBOutlet UIWebView *webView;
@property (copy) NSString *apiKey;
@property (copy) NSString *requestedPermissions;
@property (assign) id <FBLoginDelegate> delegate;

- (id)initWithAppId:(NSString *)apiKey
requestedPermissions:(NSString *)requestedPermissions
           delegate:(id<FBLoginDelegate>)delegate;
- (IBAction)closeTapped:(id)sender;
- (void)login;
- (void)logout;

-(void)checkForAccessToken:(NSString *)urlString;
-(void)checkLoginRequired:(NSString *)urlString;

@end
