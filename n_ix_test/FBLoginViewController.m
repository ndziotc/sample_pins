//
//  FBLoginViewController.m
//  n_ix_test
//
//  Created by Natalia Dzioba on 11/11/16.
//  Copyright © 2016 Natalia Dzioba. All rights reserved.
//

#import "FBLoginViewController.h"

@implementation FBLoginViewController


- (id)initWithAppId:(NSString *)apiKey
requestedPermissions:(NSString *)requestedPermissions
           delegate:(id<FBLoginDelegate>)delegate {
    if ((self = [super initWithNibName:@"FBLoginViewController"
                                bundle:[NSBundle mainBundle]])) {
        self.apiKey = apiKey;
        self.requestedPermissions = requestedPermissions;
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc {
    self.webView = nil;
    self.apiKey = nil;
    self.requestedPermissions = nil;
    [super dealloc];
}

- (void)login {
    
    [_webView loadRequest:
     [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    
    NSString *redirectUrlString =
    @"http://www.facebook.com/connect/login_success.html";
    NSString *authFormatString =
    @"https://graph.facebook.com/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@&type=user_agent&display=touch";
    
    NSString *urlString = [NSString stringWithFormat:authFormatString,
                           _apiKey, redirectUrlString, _requestedPermissions];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

-(void)logout {
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie* cookie in
         [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [cookies deleteCookie:cookie];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *urlString = request.URL.absoluteString;
    
    [self checkForAccessToken:urlString];
    [self checkLoginRequired:urlString];
    
    return TRUE;
}

-(void)checkForAccessToken:(NSString *)urlString {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"access_token=(.*)&"
                                  options:0 error:&error];
    if (regex != nil) {
        NSTextCheckingResult *firstMatch =
        [regex firstMatchInString:urlString
                          options:0 range:NSMakeRange(0, [urlString length])];
        if (firstMatch) {
            NSRange accessTokenRange = [firstMatch rangeAtIndex:1];
            NSString *accessToken = [urlString substringWithRange:accessTokenRange];
            accessToken = [accessToken
                           stringByRemovingPercentEncoding];
            if(self.presentingViewController)
                [self dismissViewControllerAnimated:YES completion:nil];
            
            [_delegate accessTokenFound:accessToken];
        }
    }
}

-(void)checkLoginRequired:(NSString *)urlString {
    if ([urlString rangeOfString:@"login.php"].location != NSNotFound) {
        [_delegate displayRequired];
    }
}

- (IBAction)closeTapped:(id)sender {
    [_delegate closeTapped];
}

@end
