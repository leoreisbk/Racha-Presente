//
//  B2WNotificationSettingsViewController.m
//  B2WKit
//
//  Created by Flávio Caetano on 4/11/14.
//  Copyright (c) 2014 Ideais. All rights reserved.
//

#define kHEADER_VIEW_HEIGHT 66.f
#define kCELL_IDENTIFIER    @"cell"

#import "B2WNotificationSettingsViewController.h"

// Cells
#import "B2WNotificationSettingsTableViewCell.h"

// Networking
#import "B2WAPIPush.h"
#import "B2WAPIAccount.h"

// Controllers
#import <IDMAlertViewManager.h>
#import "B2WKitUtils.h"

@interface B2WNotificationSettingsViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSString *userEmail;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;

@end

@implementation B2WNotificationSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		self.headerViewTopConstraint.constant = 44;
	}

    UINib *nib = [UINib nibWithNibName:@"B2WNotificationSettingsTableViewCell" bundle:[NSBundle B2WKitBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:kCELL_IDENTIFIER];
    
    self.title = @"Notificações";
	
	self.extendedLayoutIncludesOpaqueBars = YES;
	
    self.helpTextLabel.text = [self.helpTextLabel.text stringByAppendingString:[NSString stringWithFormat:@" %@.", [B2WKitUtils mainAppDisplayName]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

#pragma mark - UI Actions

- (IBAction)didChangeSwitch:(UISwitch *)sender
{
    if ([[AFNetworkReachabilityManager sharedManager] isReachable]) {
        switch (sender.tag) {
            case 0:
                [self _didChangePushNotificationSwitch:sender];
                
                break;
            case 1:
                [self _didChangePriceNotificationSwitch:sender];
                
                break;
            case 2:
                [self _didChangeStockNotificationSwitch:sender];
                
                break;
            default:
                break;
        }
    } else {
        [sender setOn:![sender isOn] animated:NO];
        [IDMAlertViewManager showDefaultConnectionFailureAlert];
    }
}

#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    __block B2WNotificationSettingsTableViewCell *cell = (B2WNotificationSettingsTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (buttonIndex == 0)
    {
        [self _disablePushSettingsWithCell:cell];
        
        return;
    }
    
    if ([B2WAPIAccount isLoggedIn])
    {
        [self _enablePushSettings];
    }
    else
    {
        NSString *username = [[alertView textFieldAtIndex:0] text];
        NSString *password = [[alertView textFieldAtIndex:1] text];

        self.userEmail     = username;
        
        cell.loading = YES;
        [B2WAPIAccount _loginWithUsername:username password:password block:^(id object, NSError *error) {
            cell.loading = NO;
            
            if (error == nil)
            {
                if (object != nil)
                {
                    [self _enablePushSettings];
                }
            }
            else if ((error.domain != NSURLErrorDomain) ||
                     (error.code != NSURLErrorCancelled))
            {
                DLog(@"%@", error);
                
                if (error.domain == B2WAPIErrorDomain && error.code == B2WAPIBadCredentialsError)
                {
                    [IDMAlertViewManager showAlertWithTitle:kDefaultBadLoginTitle message:kDefaultBadLoginMessage priority:IDMAlertPriorityHigh];
                }
                else
                {
                    [IDMAlertViewManager showDefaultConnectionFailureAlert];
                }
                
                [self _disablePushSettingsWithCell:cell];
                cell.switchView.on = NO;
            }
        }];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; // set number of sections to 3 to enable wishlist settings, or 1 to hide
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    B2WNotificationSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCELL_IDENTIFIER];
    
    switch (indexPath.section) {
        case 0:
            cell.titleLabel.text = @"Status do Pedido";
            cell.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kUSER_DEFAULTS_PUSH_NOTIFICATION_SETTINGS];
            
            [cell.switchView addTarget:self action:@selector(didChangeSwitch:) forControlEvents:UIControlEventValueChanged];
            
            if (cell.switchView.isOn)
            {
                [self _updateUserEmailLabel:NO];
            }
            
            break;
        case 1:
            cell.titleLabel.text = @"Redução de Preço";
            cell.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kUSER_DEFAULTS_PRICE_NOTIFICATION_SETTINGS];
            
            [cell.switchView addTarget:self action:@selector(didChangeSwitch:) forControlEvents:UIControlEventValueChanged];
            
            break;
        case 2:
            cell.titleLabel.text = @"Estoque";
            cell.switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:kUSER_DEFAULTS_STOCK_NOTIFICATION_SETTINGS];
            
            [cell.switchView addTarget:self action:@selector(didChangeSwitch:) forControlEvents:UIControlEventValueChanged];
            
            break;
    }
    
    cell.switchView.tag = indexPath.section;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Notificações";
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Receba notificações push sobre o status do seu pedido.";
            
        case 1:
            return @"Receba notificações sobre reduções no preço dos seus produtos favoritados";
            
        case 2:
            return @"Receba notificações sempre que um produto favoritado estiver disponível.";
            
        default:
            return nil;
    }
}

#pragma mark - Private Methods

- (void)_didChangeStockNotificationSwitch:(UISwitch *)switchView
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:switchView.isOn forKey:kUSER_DEFAULTS_STOCK_NOTIFICATION_SETTINGS];
    [userDefaults synchronize];
}

- (void)_didChangePriceNotificationSwitch:(UISwitch *)switchView
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:switchView.isOn forKey:kUSER_DEFAULTS_PRICE_NOTIFICATION_SETTINGS];
    [userDefaults synchronize];
}

- (void)_didChangePushNotificationSwitch:(UISwitch *)switchView
{
    if (switchView.isOn)
    {
        [self _enablePushSettings];
    }
    else
    {
        __block B2WNotificationSettingsTableViewCell *cell = (B2WNotificationSettingsTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.loading = YES;
        [B2WAPIPush updateSettingsWithTrackingEnabled:NO
                                     marketingEnabled:NO
                                                block:^(id object, NSError *error) {
                                                    cell.loading = NO;
                                                    
                                                    if (error != nil && (error.domain != NSURLErrorDomain || error.code != NSURLErrorCancelled))
                                                    {
                                                        DLog(@"%@", error);
                                                    }
                                                    else
                                                    {
                                                        DLog(@"Did disabled tracking opt-ins");
                                                    }
                                                }];
        
        [self _disablePushSettingsWithCell:cell];
    }
}

- (void)_disablePushSettingsWithCell:(B2WNotificationSettingsTableViewCell *)cell
{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    //[B2WAPIAccount logout];
    [B2WAPIPush setDeviceToken:nil];
	
    cell.switchView.on = NO;
    
    self.headerViewHeightConstraint.constant = kHEADER_VIEW_HEIGHT;
    [UIView animateWithDuration:.28 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setBool:cell.switchView.isOn forKey:kUSER_DEFAULTS_PUSH_NOTIFICATION_SETTINGS];
    [standardDefaults synchronize];
}

- (void)_enablePushSettings
{
    [self _updateUserEmailLabel:YES];
    
    if ([B2WKitUtils isRegisteredForAPNS])
    {
        [B2WAPIPush updateSettingsWithTrackingEnabled:YES marketingEnabled:NO block:^(id object, NSError *error) {
            if (error)
            {
                DLog(@"%@", error);
                
                // Updating the saved value for push settings.
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:NO forKey:kUSER_DEFAULTS_PUSH_NOTIFICATION_SETTINGS];
                [userDefaults synchronize];
                return;
            }
            
            DLog(@"%@ %@", object, error);
        }];
    }
    else
    {
        [B2WKitUtils registerForAPNS];
    }
    
    B2WNotificationSettingsTableViewCell *cell = (B2WNotificationSettingsTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setBool:cell.switchView.isOn forKey:kUSER_DEFAULTS_PUSH_NOTIFICATION_SETTINGS];
    [standardDefaults synchronize];
}

- (void)_updateUserEmailLabel:(BOOL)animated
{
    self.headerViewHeightConstraint.constant = 0;
    [UIView animateWithDuration:.28*animated animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
