//
//  B2WLoginMenuTableViewController.m
//  B2WKit
//
//  Created by Caio Mello on 08/08/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WLoginMenuTableViewController.h"

#import "B2WAccountManager.h"

#import "B2WLoginViewController.h"

@interface B2WLoginMenuTableViewController () <LoginViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *createAccountLabel;

@end

@implementation B2WLoginMenuTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignedInNotificationAction:) name:@"UserSignedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignInFailedNotificationAction:) name:@"UserSignInFailed" object:nil];
	
	[self.tableView setContentInset:UIEdgeInsetsMake(50, 0, 0, 0)];
	
	[self.createAccountLabel setTextColor:[B2WAccountManager sharedManager].appPrimaryColor];
	
	NSString *mainAppName = [B2WKitUtils mainAppDisplayName];
	NSString *createAccountLabelPrefix = [mainAppName isEqualToString:@"Americanas"] ? @"Criar Conta na" : @"Criar Conta no";
	[self.createAccountLabel setText:[NSString stringWithFormat:@"%@ %@", createAccountLabelPrefix, [B2WAccountManager sharedManager].brandName]];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackScreenView"
														object:self
													  userInfo:@{@"screenName" : @"Login"}];
}

#pragma mark - TableView

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *headerView = [UIView new];
	[headerView setBackgroundColor:[UIColor clearColor]];
	return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1)
	{
		if (self.userSignInCanceledHandler) {
			self.userSignInCanceledHandler();
		}
		
		[[B2WAccountManager sharedManager] setIsCreatingNewAccount:YES];
		[[B2WAccountManager sharedManager] presentSignUpForm];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	cell.backgroundColor = [UIColor clearColor];
}

#pragma mark - LoginController

- (void)loginViewControllerDidCancel:(B2WLoginViewController *)controller
{
    [self.formSheetController dismissAnimated:YES completionHandler:^(UIViewController *vc) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserSignInCanceled" object:nil];
    }];
    
    if (self.userSignInCanceledHandler) {
        self.userSignInCanceledHandler();
    }
}

#pragma mark - Actions

- (void)userSignedInNotificationAction:(NSNotification *)notification{
	[[B2WAccountManager sharedManager] setIsCreatingNewAccount:NO];
	
    [self.formSheetController dismissAnimated:YES completionHandler:nil];
    
    if (self.userSignedInHandler) {
        self.userSignedInHandler();
    }
}

- (void)userSignInFailedNotificationAction:(NSNotification *)notification{
    if (self.userSignInFailedHandler) {
        self.userSignInFailedHandler();
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"LoginSegue"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
		B2WLoginViewController *destination = (B2WLoginViewController *)navigationController.topViewController;
		[destination setDelegate:self];
	}
}

@end
