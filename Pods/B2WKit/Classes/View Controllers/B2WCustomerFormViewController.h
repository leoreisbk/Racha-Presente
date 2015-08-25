//
//  B2WCustomerFormViewController.h
//  B2WKit
//
//  Created by Eduardo Callado on 7/21/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "B2WKit.h"
#import "B2WFormTableViewController.h"
#import "B2WAccountManager.h"

@interface B2WCustomerFormViewController : B2WFormTableViewController

@property (nonatomic, weak) id<B2WAccountCreationDelegate> accountCreationDelegate;

@end
