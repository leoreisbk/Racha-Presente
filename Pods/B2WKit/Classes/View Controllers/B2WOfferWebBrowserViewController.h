//
//  B2WOfferWebBrowserViewController.h
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 11/11/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WWebViewController.h"

@class B2WOfferWebBrowserViewController;
@class B2WProduct;

@protocol B2WOfferWebBrowserViewControllerDelegate <NSObject>
@optional

- (void)offerWebBrowserViewController:(B2WOfferWebBrowserViewController *)offerWebBrowserViewController didSelectProductWithIdentifier:(NSString *)identifier;
- (void)offerWebBrowserViewController:(B2WOfferWebBrowserViewController *)offerWebBrowserViewController didSelectDepartmentWithIdentifier:(NSString *)identifier;
- (void)offerWebBrowserViewController:(B2WOfferWebBrowserViewController *)offerWebBrowserViewController didSelectSubdepartmentWithIdentifier:(NSString *)identifier;
- (void)offerWebBrowserViewController:(B2WOfferWebBrowserViewController *)offerWebBrowserViewController didSelectLineWithIdentifier:(NSString *)identifier;
- (void)offerWebBrowserViewController:(B2WOfferWebBrowserViewController *)offerWebBrowserViewController didSelectSublineWithIdentifier:(NSString *)identifier;
- (void)offerWebBrowserViewController:(B2WOfferWebBrowserViewController *)offerWebBrowserViewController didSelectHotsiteWithTags:(NSArray *)tags productIds:(NSArray *)productIds title:(NSString *)title;

@end

@interface B2WOfferWebBrowserViewController : B2WWebViewController <UIWebViewDelegate>

@property (nonatomic, weak) id <B2WOfferWebBrowserViewControllerDelegate> delegate;

+ (B2WOfferWebBrowserViewController *)webBrowserWithInitialURLString:(NSString *)URLString;
+ (B2WOfferWebBrowserViewController *)webBrowserWithInitialURL:(NSURL *)URL;

@end
