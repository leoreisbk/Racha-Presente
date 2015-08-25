//
//  B2WWebBrowserViewController.h
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 2/5/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class B2WWebBrowserViewController;

/*
 
 UINavigationController+B2WWebBrowserWrapper category enables access to casted B2WWebBroswerViewController when set as rootViewController of UINavigationController
 
 */
@interface UINavigationController(B2WWebBrowser)

// Returns rootViewController casted as B2WWebBrowserViewController
- (B2WWebBrowserViewController *)rootWebBrowser;

@end



@protocol B2WWebBrowserDelegate <NSObject>
@optional
- (void)webBrowser:(B2WWebBrowserViewController *)webBrowser didStartLoadingURL:(NSURL *)URL;
- (void)webBrowser:(B2WWebBrowserViewController *)webBrowser didFinishLoadingURL:(NSURL *)URL;
- (void)webBrowser:(B2WWebBrowserViewController *)webBrowser didFailToLoadURL:(NSURL *)URL error:(NSError *)error;
@end


/*
 
 B2WWebBrowserViewController is designed to be used inside of a UINavigationController.
 For convenience, two sets of static initializers are available.
 
 */
@interface B2WWebBrowserViewController : UIViewController <WKNavigationDelegate>

#pragma mark - Public Properties

@property (nonatomic, weak) id <B2WWebBrowserDelegate> delegate;

// The main and only UIProgressView
@property (nonatomic, strong) UIProgressView *progressView;

// The web views
// Depending on the version of iOS, one of these will be set
@property (nonatomic, strong) WKWebView *wkWebView;

- (id)initWithConfiguration:(WKWebViewConfiguration *)configuration NS_AVAILABLE_IOS(8_0);

#pragma mark - Static Initializers

/*
 Initialize a basic B2WWebBrowserViewController instance for push onto navigation stack
 
 Ideal for use with UINavigationController pushViewController:animated: or initWithRootViewController:
 
 Optionally specify B2WWebBrowser options or WKWebConfiguration
 */

+ (B2WWebBrowserViewController *)webBrowser;
+ (B2WWebBrowserViewController *)webBrowserWithConfiguration:(WKWebViewConfiguration *)configuration NS_AVAILABLE_IOS(8_0);

/*
 Initialize a UINavigationController with a B2WWebBrowserViewController for modal presentation.
 
 Ideal for use with presentViewController:animated:
 
 Optionally specify B2WWebBrowser options or WKWebConfiguration
 */

+ (UINavigationController *)navigationControllerWithWebBrowser;
+ (UINavigationController *)navigationControllerWithWebBrowserWithConfiguration:(WKWebViewConfiguration *)configuration NS_AVAILABLE_IOS(8_0);



@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, assign) BOOL showsURLInNavigationBar;
@property (nonatomic, assign) BOOL showsPageTitleInNavigationBar;

#pragma mark - Public Interface

// Load a NSURL to webView
// Can be called any time after initialization
- (void)loadURL:(NSURL *)URL;

// Loads a URL as NSString to webView
// Can be called any time after initialization
- (void)loadURLString:(NSString *)URLString;

@end
