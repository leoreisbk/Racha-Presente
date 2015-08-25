//
//  B2WDebugSettingsTableViewController.m
//  B2WKit
//
//  Created by Eduardo Callado on 11/12/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WDebugSettingsTableViewController.h"

#import "B2WAPIAccount.h"
#import "B2WAPICustomer.h"
#import "B2WAPIOffers.h"
#import "B2WAPICatalog.h"

@implementation NSUserDefaults (containsObject)

+ (BOOL)containsKey:(NSString *)key {
	return [[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:key];
}

@end

@interface B2WDebugSettingsTableViewController ()

@property NSUserDefaults *userDefaults;

@property IBOutlet UISwitch *accountCustomerSwitch;
@property IBOutlet UISwitch *bannerSwitch;
@property IBOutlet UILabel *catalog;
@property IBOutlet UITextField *cart;
@property IBOutlet UITextField *opn;
@property IBOutlet UISwitch *allowInvalidCertificates;

@end

@implementation B2WDebugSettingsTableViewController

#pragma mark - Presentation

+ (void)presentInViewController:(UIViewController *)vC
{
	NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"B2WKit" ofType:@"bundle"];
	NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"B2WDebugSettings" bundle:bundle];
	B2WDebugSettingsTableViewController *debugSettings = [storyboard instantiateInitialViewController];
	[vC presentViewController:debugSettings animated:YES completion:nil];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.userDefaults = [NSUserDefaults standardUserDefaults];
	
	[self reloadView];
}

- (void)reloadView
{
	[self.accountCustomerSwitch setOn:[B2WAPIAccount isStaging]];
	
	[self.bannerSwitch setOn:[B2WAPIOffers isStaging]];
	
	switch ([B2WAPICatalog environment]) {
		case B2WAPICatalogEnvironmentDefault:
			self.catalog.text = @"Default";
			break;
		case B2WAPICatalogEnvironmentStaging:
			self.catalog.text = @"Staging";
			break;
		case B2WAPICatalogEnvironmentAWS:
			self.catalog.text = @"AWS";
			break;
		default:
			break;
	}
	
	if ([NSUserDefaults containsKey:checkoutURLKey]) {
		self.cart.text = [self.userDefaults valueForKey:checkoutURLKey];
	}
	else {
		self.cart.text = @"";
	}
	
	if ([NSUserDefaults containsKey:opnStringKey]) {
		self.opn.text = [self.userDefaults valueForKey:opnStringKey];
	}
	else {
		self.opn.text = @"";
	}
	
	if ([NSUserDefaults containsKey:invalidCertificatesKey])
		self.allowInvalidCertificates.on = [[self.userDefaults valueForKey:invalidCertificatesKey] boolValue];
	else
		self.allowInvalidCertificates.on = NO;
}

#pragma mark - General

+ (void)setupDebugSettings
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	[B2WAPIAccount setStaging:[[userDefaults valueForKey:accountStagingKey] boolValue]];
	[B2WAPICustomer setStaging:[[userDefaults valueForKey:customerStagingKey] boolValue]];
	[B2WAPIOffers setStaging:[[userDefaults valueForKey:offersStagingKey] boolValue]];
	
	if (! [NSUserDefaults containsKey:catalogEnvironmentKey])
	{
		[userDefaults setInteger:B2WAPICatalogEnvironmentAWS forKey:catalogEnvironmentKey];
		[userDefaults synchronize];
	}
	[B2WAPICatalog setEnvironment:[[userDefaults valueForKey:catalogEnvironmentKey] unsignedIntegerValue]];
	
	// Cart URL is read directly from NSUserDefaults
	
	[B2WAPIClient setOPNString:[userDefaults valueForKey:opnStringKey]];
	
	if (! [NSUserDefaults containsKey:invalidCertificatesKey])
	{
		[userDefaults setBool:NO forKey:invalidCertificatesKey];
		[userDefaults synchronize];
	}
	[[[B2WAPIClient sharedClient] securityPolicy] setAllowInvalidCertificates:[[userDefaults valueForKey:invalidCertificatesKey] boolValue]];
}

+ (void)_setupDebugSettingsForProduction
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	[B2WAPIAccount setStaging:NO];
	[B2WAPICustomer setStaging:NO];
	[B2WAPIOffers setStaging:NO];
	
	[B2WAPICatalog setEnvironment:B2WAPICatalogEnvironmentAWS];
	
	[userDefaults removeObjectForKey:checkoutURLKey];
	
	[[[B2WAPIClient sharedClient] securityPolicy] setAllowInvalidCertificates:NO];
}

#pragma mark - Switch

- (IBAction)accountCustomerSwitchAction:(UISwitch *)sender
{
	[B2WAPIAccount setStaging:sender.isOn];
	[B2WAPICustomer setStaging:sender.isOn];
	
	[self.userDefaults setBool:sender.isOn forKey:accountStagingKey];
	[self.userDefaults setBool:sender.isOn forKey:customerStagingKey];
	[self.userDefaults synchronize];
	
	[self reloadView];
}

- (IBAction)bannerSwitchAction:(UISwitch *)sender
{
	[B2WAPIOffers setStaging:sender.isOn];
	
	[self.userDefaults setBool:sender.isOn forKey:offersStagingKey];
	[self.userDefaults synchronize];
	
	[self reloadView];
}

- (IBAction)catalogAction
{
	B2WAPICatalogEnvironment environment = [B2WAPICatalog environment];
	environment++; if (environment == 3) environment = 0;
	
	[B2WAPICatalog setEnvironment:environment];
	
	[self.userDefaults setInteger:environment forKey:catalogEnvironmentKey];
	[self.userDefaults synchronize];
	
	[self reloadView];
}

- (void)cartAction
{
	if (self.cart.text.length > 0)
	{
		if ([self.cart.text containsString:@"http://"] || [self.cart.text containsString:@"https://"])
		{
			[self.userDefaults setValue:self.cart.text forKey:checkoutURLKey];
		}
		else
		{
			[self.userDefaults removeObjectForKey:checkoutURLKey];
		}
	}
	else
	{
		[self.userDefaults removeObjectForKey:checkoutURLKey];
	}
	
	[self.userDefaults synchronize];
}

- (void)opnAction
{
	if (self.opn.text.length > 0)
	{
		[self.userDefaults setValue:self.opn.text forKey:opnStringKey];
	}
	else
	{
		[self.userDefaults removeObjectForKey:opnStringKey];
	}
	
	[B2WAPIClient setOPNString:[self.userDefaults valueForKey:opnStringKey]];
	
	[self.userDefaults synchronize];
}

- (IBAction)allowInvalidCertificatesAction:(UISwitch *)sender
{
	[[[B2WAPIClient sharedClient] securityPolicy] setAllowInvalidCertificates:sender.isOn];
	
	[self.userDefaults setBool:sender.isOn forKey:invalidCertificatesKey];
	[self.userDefaults synchronize];
	
	[self reloadView];
}

#pragma mark - Dismiss

- (IBAction)dismiss
{
	[self cartAction];
	[self opnAction];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
