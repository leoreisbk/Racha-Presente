//
//  B2WCheckoutViewController.h
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 2/11/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#define USE_WK 1

@class B2WCheckoutViewController;
@class B2WProduct;

@protocol B2WCheckoutViewControllerDelegate <NSObject>
@optional
- (void)checkoutViewController:(B2WCheckoutViewController *)checkoutViewController didSelectProduct:(B2WProduct *)product error:(NSError *)error;
- (void)didPressBuyButtonWithLoggedUserURLString:(NSString *)urlString;
- (void)didPressOrdersButton;
- (void)didPressCloseButton;
@end

#if USE_WK
@interface B2WCheckoutViewController : UIViewController <WKNavigationDelegate, WKScriptMessageHandler>
#else
@interface B2WCheckoutViewController : UIViewController <UIWebViewDelegate>
#endif

#pragma mark - Public Properties

@property (nonatomic, weak) id <B2WCheckoutViewControllerDelegate> delegate;

#pragma mark - Public Interface

- (void)loadCheckoutURLWithCartID:(NSString *)cartID;
- (void)loadOneClickCheckoutWithCartProducts:(NSArray *)products;
- (void)loadURL:(NSURL *)URL;

@end
