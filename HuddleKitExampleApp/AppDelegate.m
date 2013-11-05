//
//  AppDelegate.m
//  HuddleKitExampleApp
//
//  Copyright (c) 2013 Huddle. All rights reserved.
//

#import "AppDelegate.h"

#import "AFNetworkActivityIndicatorManager.h"
#import "HDKLoginHTTPClient.h"
#import "SignInViewController.h"
#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@interface AppDelegate ()

@property (nonatomic, strong) UIViewController *mainViewController;
@property (nonatomic, strong) SignInViewController *signInViewController;

@end

@implementation AppDelegate

#pragma mark - Properties

- (UIViewController *)mainViewController {
    if (!_mainViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        _mainViewController = [storyboard instantiateInitialViewController];
    }

    return _mainViewController;
}

- (SignInViewController *)signInViewController {
    if (!_signInViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        _signInViewController = [storyboard instantiateViewControllerWithIdentifier:@"SignInViewController"];
    }

    return _signInViewController;
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    #warning You need to set your API client Id and redirect URL
    #warning Have you set a custom URL scheme for this app?
    [HuddleKit setClientId:@"YOUR_API_CLIENT_ID"];
    [HuddleKit setRedirectUrl:@"YOUR_API_REDIRECT_URL"]; // this needs to match the custom URL scheme for this app
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    if ([[HDKSession sharedSession] isAuthenticated]) {
        self.window.rootViewController = self.mainViewController;
    } else {
        self.window.rootViewController = self.signInViewController;
    }

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSURL *redirectURL = [NSURL URLWithString:[HDKLoginHTTPClient redirectUrl]];
    if ([[url host] isEqualToString:[redirectURL host]]) {
        NSString *code = [url.query componentsSeparatedByString:@"="][1];
        [SVProgressHUD showWithStatus:@"Signing in…" maskType:SVProgressHUDMaskTypeGradient];
        [[HDKLoginHTTPClient sharedClient] signInWithAuthorizationCode:code success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *accessToken = responseObject[@"access_token"];
            [[HDKHTTPClient sharedClient] setAuthorizationHeaderWithToken:accessToken];
            [SVProgressHUD dismiss];
            [self signInSuccess];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD dismiss];
            [self signInFailure:error];
        }];
    }
}

#pragma mark - Private methods

- (void)signInFailure:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign In Error", nil)
                                                        message:NSLocalizedString(@"Sorry, there was a problem signing in. Please try again.", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)signInSuccess {
    [self dismissSignIn];
}

- (void)presentSignIn {
    if (!_signInViewController) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        transition.type = kCATransitionFade;

        if (_mainViewController) {
            [self.mainViewController.view removeFromSuperview];
            self.mainViewController = nil;
        }

        self.window.rootViewController = self.signInViewController;
        [self.window.layer addAnimation:transition forKey:nil];
    }
}

- (void)dismissSignIn {
    if (_signInViewController) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        transition.type = kCATransitionFade;

        [self.signInViewController.view removeFromSuperview];
        self.signInViewController = nil;
        self.window.rootViewController = self.mainViewController;

        [self.window.layer addAnimation:transition forKey:nil];
    }
}

@end
