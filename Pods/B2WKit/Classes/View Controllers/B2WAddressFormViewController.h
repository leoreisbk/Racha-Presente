//
//  B2WAddressFormViewController.h
//  B2WKit
//
//  Created by Eduardo Callado on 7/21/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "B2WKit.h"
#import "B2WAccountManager.h"
#import "B2WFormTableViewController.h"

@class B2WAddressFormViewController;

@protocol AddressFormViewControllerDelegate <NSObject>

- (void)addressFormViewController:(B2WAddressFormViewController *)controller didCreateAddress:(B2WAddress *)address;
- (void)addressFormViewController:(B2WAddressFormViewController *)controller didEditAddress:(B2WAddress *)address;

@end

@interface B2WAddressFormViewController : B2WFormTableViewController <UIAlertViewDelegate>

@property (nonatomic, assign) BOOL isCreatingNewAddress;
@property (nonatomic, weak) id<B2WAccountCreationDelegate> accountCreationDelegate;
@property (nonatomic, weak) id<AddressFormViewControllerDelegate> delegate;

@end
