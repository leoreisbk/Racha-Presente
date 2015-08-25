//
//  B2WDebugSettingsTableViewController.h
//  B2WKit
//
//  Created by Eduardo Callado on 11/12/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const accountStagingKey = @"B2WAPIAccount_staging";
static NSString *const customerStagingKey = @"B2WAPICustomer_staging";
static NSString *const offersStagingKey = @"B2WAPIOffers_staging";
static NSString *const catalogEnvironmentKey = @"B2WAPICatalog_environment";

static NSString *const checkoutURLKey = @"B2WCheckoutDebugURL";
static NSString *const opnStringKey = @"OPNString";
static NSString *const invalidCertificatesKey = @"allowInvalidCertificates";

@interface B2WDebugSettingsTableViewController : UITableViewController

+ (void)presentInViewController:(UIViewController *)vC;

+ (void)setupDebugSettings;

@end
