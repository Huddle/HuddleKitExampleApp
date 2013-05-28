//
//  ViewController.m
//  HuddleKitExampleApp
//
//  Copyright (c) 2013 Huddle. All rights reserved.
//


#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [[HDKHTTPClient sharedClient] getPath:@"/entry" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.displayNameLabel.text = [responseObject valueForKeyPath:@"profile.personal.displayName"];

        NSString *avatarUrl = @"https://my.huddle.net/images/logos/avatar.jpg";
        for (NSDictionary *link in responseObject[@"links"]) {
            if ([link[@"rel"] isEqualToString:@"avatar"]) {
                avatarUrl = link[@"href"];
            }
        }

        [self.avatarImageView setImageWithURL:[NSURL URLWithString:avatarUrl]];

        [SVProgressHUD dismiss];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error calling /entry", nil)
                                    message:[error localizedDescription]
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];

        [SVProgressHUD dismiss];
    }];
}

- (IBAction)signOut:(id)sender
{
    [[HDKSession sharedSession] signOut];
    [[UIApplication sharedApplication].delegate performSelector:@selector(presentSignIn)];
}

@end
