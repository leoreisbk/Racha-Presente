//
//  ACOMBasketViewController.h
//  Americanas
//
//  Created by Rodrigo Fontes on 12/2/13.
//  Copyright (c) 2013 Ideais. All rights reserved.
//

#import <UIKit/UIKit.h>

@class B2WCartViewController;
@class B2WProduct;

@protocol B2WCartViewControllerDelegate <NSObject>
@optional

- (void)cartViewController:(B2WCartViewController*)cartVC didSelectProduct:(B2WProduct*)product error:(NSError*)error;

@end

@interface B2WCartViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, readwrite) BOOL skipLoadingDismiss;
@property (nonatomic, readwrite) BOOL didLoadInitialRequest;

/**
 An array containing SKU identifier strings.
 */
@property (nonatomic, strong) NSArray *skus;

/**
 An array containing SKU identifier and storeId strings.
 */
@property (nonatomic, strong) NSArray *skusAndStoreIds;

@property (nonatomic, strong) NSString *initialURLString;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, weak) id <B2WCartViewControllerDelegate> delegate;

@property (nonatomic, strong) NSURLRequest *initiallyLoadedRequest; // we'll save the first request and use it in case a user switches accounts

@property (nonatomic, strong) NSURLRequest *requestToBeLoadedAfterAuthentication;

@property (nonatomic, strong) NSString *lastRequestURLString;

- (void)loadRequestAfterAuthentication;
- (void)didPressPrintBilletButtonWithURL:(NSURL*)url;
- (void)_didSelectProductIdentifier:(NSString*)identifier;
- (NSString *)appVisitorID;

@end