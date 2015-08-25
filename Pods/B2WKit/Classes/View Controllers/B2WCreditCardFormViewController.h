//
//  B2WCreditCardFormViewController.h
//  B2WKit
//
//  Created by Eduardo Callado on 7/21/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "B2WKit.h"
#import "B2WFormTableViewController.h"

@class B2WCreditCardFormViewController;

@protocol B2WCreditCardFormViewControllerDelegate <NSObject>

@optional
- (void)oneClickActivationCompleted:(B2WCreditCardFormViewController *)creditCardViewController;
- (void)showCheckoutViewControllerSelected:(B2WCreditCardFormViewController *)creditCardViewController;
- (void)creditCardFormViewController:(B2WCreditCardFormViewController *)controller didCreateCreditCard:(B2WCreditCard *)creditCard;

@end

@interface B2WCreditCardFormViewController : B2WFormTableViewController

@property (nonatomic, assign) BOOL isOneClickActivation;
@property (nonatomic, assign) BOOL showingOtherPaymentOptions;
@property (nonatomic, weak) id<B2WCreditCardFormViewControllerDelegate> creditCardFormViewControllerDelegate;

@end
