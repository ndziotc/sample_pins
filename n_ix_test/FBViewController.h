//
//  FBViewController.h
//  n_ix_test
//
//  Created by Natalia Dzioba on 11/11/16.
//  Copyright © 2016 Natalia Dzioba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBLoginViewController.h"

typedef enum {
    LoginStateStartup,
    LoginStateLoggingIn,
    LoginStateLoggedIn,
    LoginStateLoggedOut
} LoginState;

@interface FBViewController : UIViewController <FBLoginDelegate> {
    UILabel *_loginStatusLabel;
    UIButton *_loginButton;
    LoginState _loginState;
    FBLoginViewController *_loginDialog;
    UIView *_loginDialogView;
}

@property (retain) IBOutlet UILabel *loginStatusLabel;
@property (retain) IBOutlet UIButton *loginButton;
@property (retain) FBLoginViewController *loginDialog;
@property (retain) IBOutlet UIView *loginDialogView;
@property (retain) NSString *fbUserName;

- (IBAction)loginButtonTapped:(id)sender;

- (BOOL)isSuccessfullyLogedIn;

@end
