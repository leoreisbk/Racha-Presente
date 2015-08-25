//
//  B2WAccountTestTableViewController.m
//  B2WKit
//
//  Created by Caio Mello on 12/09/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WAccountTestTableViewController.h"
#import "B2WAccountManager.h"
#import "B2WSignUpCompletedViewController.h"

#import <UICKeyChainStore/UICKeyChainStore.h>

@interface B2WAccountTestTableViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *accountLabel;
@property (nonatomic, strong) IBOutlet UILabel *OneClickLabel;
@property (nonatomic, strong) IBOutlet UILabel *OneClickStatusLabel;

@end

@implementation B2WAccountTestTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.OneClickLabel.text = [B2WAccountManager sharedManager].oneClickBrandName;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleUserSignedInNotification:)
												 name:@"UserSignedIn" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleUserSignedOutNotification:)
												 name:@"UserSignedOut" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleUserInfonNotification:)
												 name:@"UserInfo" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if ([B2WAPIAccount isLoggedIn])
	{
		[self refreshInfos];
		[B2WAccountManager requestCustomerInformation];
	}
}

#pragma mark - General

- (void)refreshInfos
{
	if ([B2WAPIAccount isLoggedIn])
	{
		NSString *userEmail = [B2WAPIAccount username];
		[self.accountLabel setText:userEmail];
		
		if ([B2WAccountManager currentCustomer].oneClickEnabled)
		{
			[self.OneClickStatusLabel setText:@"Ativado"];
		}
		else
		{
			[self.OneClickStatusLabel setText:@"Desativado"];
		}
	}
	else
	{
		[self.accountLabel setText:[NSString stringWithFormat:@"Conectar na conta %@", [B2WAccountManager sharedManager].brandName]];
		
		if (self.tableView.numberOfSections == 2)
		{
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
		}
	}
}

- (void)userAccountStatusChanged
{
	if ([B2WAPIAccount isLoggedIn])
	{
		[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].textLabel setText:[B2WAPIAccount username]];
		
		[[self.tableView headerViewForSection:1].textLabel setText:@"MINHA CONTA"];
		
		//		[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1],
		//												 [NSIndexPath indexPathForRow:1 inSection:1],
		//												 [NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationLeft];
	}
	else
	{
		[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].textLabel setText:@"Fazer Login"];
		
		[[self.tableView headerViewForSection:1].textLabel setText:nil];
		
		//		[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1],
		//												 [NSIndexPath indexPathForRow:1 inSection:1],
		//												 [NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationRight];
	}
	
	// [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
	[self.tableView reloadData];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (![B2WAPIAccount isLoggedIn])
	{
		return 1;
	}
	
	return [super numberOfSectionsInTableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0)
	{
		if ([B2WAPIAccount isLoggedIn])
		{
			NSString *userEmail = [B2WAPIAccount username];
			NSString *appName = [B2WAccountManager sharedManager].brandName;

			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Conta %@", appName]
																message:userEmail
															   delegate:self
													  cancelButtonTitle:@"Cancelar"
													  otherButtonTitles:@"Desconectar", @"Editar Dados Pessoais", nil];
			[alertView show];
		}
		else
		{
			[[B2WAccountManager sharedManager] presentLoginViewController];
		}
	}
	else if ([B2WAPIAccount isLoggedIn])
	{
		switch (indexPath.row)
		{
			case 0: [self performSegueWithIdentifier:@"EditCustomerSegue" sender:nil]; break;
			case 1: [self performSegueWithIdentifier:@"AddressesSegue" sender:nil]; break;
            case 2: [self performSegueWithIdentifier:@"CreditCardsSegue" sender:nil]; break;
			case 3: [self performSegueWithIdentifier:@"OneClickSegue" sender:nil]; break;
			default: break;
		}
	}
}

#pragma mark - AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[B2WAPIAccount logout];
		
		[B2WAccountManager resetAccountSavedData];
		
		[self.accountLabel setText:[NSString stringWithFormat:@"Conectar na conta %@", [B2WAccountManager sharedManager].brandName]];
		
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	else if (buttonIndex == 2)
	{
		[self performSegueWithIdentifier:@"EditCustomerSegue" sender:nil];
	}
}

#pragma mark - Notifications

- (void)handleUserSignedInNotification:(NSNotification *)notification
{
	[self userAccountStatusChanged];
	[self refreshInfos];
}

- (void)handleUserSignedOutNotification:(NSNotification *)notification
{
	[self userAccountStatusChanged];
}

- (void)handleUserInfonNotification:(NSNotification *)notification
{
	[self userAccountStatusChanged];
	[self refreshInfos];
}

#pragma mark - Actions

- (IBAction)exitBarButtonAction:(UIBarButtonItem *)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
