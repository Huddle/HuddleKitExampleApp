//
//  SignInViewController.m
//  HuddleKitExampleApp
//
//  Copyright (c) 2013 Huddle. All rights reserved.
//

#import "SignInViewController.h"

#import "HDKLoginHTTPClient.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (IBAction)signIn:(id)sender {
    NSURL *url = [NSURL URLWithString:[[HDKLoginHTTPClient sharedClient] loginPageUrl]];
    [[UIApplication sharedApplication] openURL:url];
}

@end
