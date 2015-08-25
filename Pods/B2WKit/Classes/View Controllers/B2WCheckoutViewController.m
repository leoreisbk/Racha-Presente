//
//  B2WCheckoutViewController.m
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 2/11/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WCheckoutViewController.h"

#import "B2WAccountManager.h"
#import "B2WAPIClient.h"
#import "B2WAPIAccount.h"
#import "B2WAPICart.h"
#import "B2WCartProduct.h"
#import "B2WCartURLProtocol.h"
#import "B2WNewCartURLProtocol.h"
#import "B2WBilletViewController.h"
#import "B2WKitUtils.h"
#import "NSURL+B2WKit.h"
#import "NSHTTPCookie+B2WKit.h"
#import "UIViewController+B2WKit.h"

#import <SVProgressHUD.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import <IDMViewControllerStates/UIViewController+States.h>

@interface B2WCheckoutViewController ()

#if USE_WK
@property (nonatomic, strong) WKWebView *webView;
#else
@property (nonatomic, strong) UIWebView *webView;
#endif
@property (nonatomic, strong) NSMutableDictionary *userScripts;
@property (nonatomic, strong) UIBarButtonItem *refreshButton, *activityIndicatorButton;
@property (nonatomic) BOOL didFinishPayment;
@property (nonatomic, strong) NSArray *cartProducts; // TODO: refact

@end

@implementation B2WCheckoutViewController

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
#if USE_WK
        self.webView = [WKWebView new];
#else
        self.webView = [UIWebView new];
#endif
        self.userScripts = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserSignedInNotification:) name:@"UserSignedIn" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserSignedOutNotification:) name:@"UserSignedOut" object:nil];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
#if USE_WK
        self.webView = [WKWebView new];
#else
        self.webView = [UIWebView new];
#endif
        self.userScripts = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserSignedInNotification:) name:@"UserSignedIn" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserSignedOutNotification:) name:@"UserSignedOut" object:nil];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // TODO: place this in the App Delegate
    [NSURLProtocol registerClass:[B2WCartURLProtocol class]];
    [NSURLProtocol registerClass:[B2WNewCartURLProtocol class]];
    
    // View
    [self.webView setFrame:self.view.bounds];
    [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
#if USE_WK
    [self.webView setNavigationDelegate:self];
#else
    self.webView.delegate = self;
#endif
    [self.webView setMultipleTouchEnabled:YES];
    [self.webView setAutoresizesSubviews:YES];
    [self.webView.scrollView setAlwaysBounceVertical:YES];
    [self.view addSubview:self.webView];
    
    // JavaScript communication
#if USE_WK
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"checkout"];
#endif
    
    // Adjust viewport for iPad (webview is displayed in a popover but website thinks it's a tablet sized window)
    if (kIsIpad) {
        self.userScripts[@"adjustViewport"] = [[WKUserScript alloc] initWithSource:@"var viewport = document.querySelector('meta[name=viewport]');viewport.setAttribute('content', 'width=320, initial-scale=1.0, user-scalable=1');" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        [self updateUserScripts];
    }
    
    // toolbar
    self.didFinishPayment = NO;
    [self setupToolbarItems];
    [self updateToolbarState];
}

#pragma mark - Toolbar

- (void)setupToolbarItems
{
    self.navigationItem.title = @"Pagamento";
	
    /*if ([[B2WAPIClient brandCode] isEqualToString:@"ACOM"]) { self.navigationItem.title = @"Cesta de Compras"; }
    else if ([[B2WAPIClient brandCode] isEqualToString:@"SUBA"]) { self.navigationItem.title = @"Carrinho"; }
    else if ([[B2WAPIClient brandCode] isEqualToString:@"SHOP"]) { self.navigationItem.title = @"Carrinho"; }*/
	
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    [activityIndicatorView startAnimating];
    self.activityIndicatorButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
}

- (void)updateToolbarState
{
    if (self.didFinishPayment)
	{
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed:)];
    }
	else
	{
        self.navigationItem.rightBarButtonItem = (self.webView.isLoading ? self.activityIndicatorButton : self.refreshButton);
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doneButtonPressed:)];
    }
}

#pragma mark - Public Interface

- (void)loadCheckoutURLWithCartID:(NSString *)cartID
{
    if (![B2WAPIAccount isLoggedIn]) { return; }
    
    self.didFinishPayment = NO;
    [self wipeWebView];
    
    [self.loadingView show];
    // make sure the token is fresh
    NSURLRequest *initialRequest = [self initialRequestWithCustomerID:[B2WAPIAccount userIdentifier]
                                                     customerAPIToken:[B2WAPIAccount token]
                                                               cartID:cartID];
    //[self downloadCustomJavaScriptThenLoadRequest:initialRequest];
    [self downloadCustomJavaScriptFromURL:[self customJavaScriptURLString] success:^{
        [self.webView loadRequest:initialRequest];
    } failure:^{
        [self.loadingView dismiss];
        [self showErrorViewWithReloadButtonPressedBlock:^{
            [self loadCheckoutURLWithCartID:cartID];
        }];
    }];
    
}

- (void)loadURL:(NSURL *)URL
{
    if (![B2WAPIAccount isLoggedIn]) { return; }
    
    self.didFinishPayment = NO;
    [self wipeWebView];
    
    [self.loadingView show];
	
    [B2WAccountManager refreshToken:^(id object, NSError *error) {
        if (error == nil) {
            [self downloadCustomJavaScriptFromURL:[self customJavaScriptURLString] success:^{
                NSURLRequest *request = [NSURLRequest requestWithURL:URL];
                [self.webView loadRequest:request];
            } failure:^{
                [self.loadingView dismiss];
                [self showErrorViewWithReloadButtonPressedBlock:^{
                    [self loadURL:URL];
                }];
            }];
        } else {
            [self.loadingView dismiss];
            [self showErrorViewWithReloadButtonPressedBlock:^{
                [self loadURL:URL];
            }];
        }
    }];
}

- (NSString *)customJavaScriptURLString
{
	NSString *URLString = @"";
	
	if ([[B2WKitUtils mainAppDisplayName] isEqualToString:@"Americanas"])
		URLString = @"http://iacom.s8.com.br/mktacom/mobile/assets/checkout-1.js";
	else if ([[B2WKitUtils mainAppDisplayName] isEqualToString:@"Submarino"]) {
		URLString = @"http://isuba.s8.com.br/mktsuba/mobile/assets/checkout-1.js";
	} else if ([[B2WKitUtils mainAppDisplayName] isEqualToString:@"Shoptime"]) {
		URLString = @"http://ishop.s8.com.br/mktshop/mobile/assets/checkout-1.js";
	}
	
	return URLString;
}

- (NSString *)oneClickURLString
{
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:@{
        @"customer_id": [B2WAPIAccount userIdentifier],
        @"customer_api_token": [B2WAPIAccount token],
        @"utm_source": @"app-ios",
        @"utm_medium": @"app",
        @"utm_campaign": @"app",
        @"header": @"false",
        @"footer": @"false",
        @"mobrandarg": [NSString stringWithFormat:@"%d", arc4random_uniform(10000)] // avoid weird WKWebView cache bugs
    }];
    
    if ([B2WAPIClient OPNString]) {
        query[@"opn"] = [B2WAPIClient OPNString];
    }
    
    if ([B2WAPIClient EPARString]) {
        query[@"epar"] = [B2WAPIClient EPARString];
    }
    
    if ([B2WAPIClient FRANQString]) {
        query[@"franq"] = [B2WAPIClient FRANQString];
    }
    
    if ([B2WAPIClient referrerURLString]) {
        query[@"referrer"] = [B2WAPIClient referrerURLString];
    }
    NSString *queryString = [self queryStringWithParameters:query];
    return [NSString stringWithFormat:@"https://carrinho.%@/checkout/cart/one-click-checkout/%@", [[[B2WAPIClient sharedClient] baseURL] domain], queryString];
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSString *action = message.body[@"action"];
    
    if ([action isEqualToString:@"stateChangeSuccess"]) {
        [self.loadingView dismiss];
        [self updateToolbarState];
    }
	else if ([action isEqualToString:@"stateChangeStart"]) {
    }
	else if ([action isEqualToString:@"stateChangeError"]) {
        id error = [message.body objectForKey:@"error"];
    }
	else if ([action isEqualToString:@"printBankSlip"] && message.body[@"URL"]) {
        NSURL *URL = [NSURL URLWithString:message.body[@"URL"]];
        [self printBankSlipWithURL:URL];
    }
	else if ([action isEqualToString:@"finish"]) {
        self.didFinishPayment = YES;
        [self updateToolbarState];
		
		[B2WCart setupNewCart];
    }
}

#pragma mark - WKNavigationDelegate

#if USE_WK

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    [self updateToolbarState];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self updateToolbarState];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.loadingView dismiss];
    [self updateToolbarState];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self.loadingView dismiss];
    [self updateToolbarState];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self.loadingView dismiss];
    [self updateToolbarState];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ([self isProductURL:navigationAction.request.URL]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(checkoutViewController:didSelectProduct:error:)]) {
            NSString *identifier = [self extractIdentifierFromProductURL:navigationAction.request.URL];
            
            if (identifier) {
                [SVProgressHUD showWithStatus:@"Carregando..."];
                [B2WAPICatalog requestProductWithIdentifier:identifier block:^(B2WProduct *product, NSError *error) {
                    [SVProgressHUD dismiss];
					
					/*if (error) {
						[self.delegate checkoutViewController:self didSelectProduct:nil error:error];
					 } else {
						[self.delegate checkoutViewController:self didSelectProduct:product error:nil];
					}*/
					
					if (error)
					{
						DLog(@"Request Product Error: %@", error);
						if (error.code != NSURLErrorCancelled)
						{
							// [IDMAlertViewManager showAlertWithTitle:kDefaultConnectionErrorTitle message:kDefaultConnectionErrorMessage priority:IDMAlertPriorityHigh];
							
							[UIAlertView showAlertViewWithTitle:kDefaultConnectionErrorTitle
														message:kDefaultConnectionErrorMessage];
						}
					}
					else
					{
						[[UIApplication sharedApplication].delegate performSelector:@selector(presentProductViewControllerFromCartWithProduct:) withObject:product];
					}
                }];
            }
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    } if ([self isExternalURL:navigationAction.request.URL] && navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
#else
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}
#endif

- (NSString *)extractIdentifierFromProductURL:(NSURL *)URL
{
    if (URL.pathComponents.count >= 3) {
        NSString *identifier = [URL.pathComponents objectAtIndex:2];
        
        if (identifier && identifier.length != 0) {
            NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:identifier];
            
            if ([alphaNums isSupersetOfSet:inStringSet]) {
                return identifier;
            }
        }
    }
    
    return nil;
}

- (BOOL)isProductURL:(NSURL *)URL
{
    return [URL.absoluteString containsString:@"product"] || [URL.absoluteString containsString:@"produto"];
}

- (BOOL)isExternalURL:(NSURL *)URL
{
    NSArray *components = [URL.host componentsSeparatedByString:@"."];
    return components.count > 1 && (![components[0] isEqualToString:@"sacola"]) && (![components[0] isEqualToString:@"carrinho"]);
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    [self updateToolbarState];
}

#pragma mark - UIBarButtonItem Target Action Methods

- (void)refreshButtonPressed:(id)sender
{
    [self.webView stopLoading];
    [self.webView reload];
}

- (void)doneButtonPressed:(id)sender
{
    [self.webView stopLoading];
    self.didFinishPayment = NO;
    [self dismissViewController];
    if (self.delegate && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.delegate didPressCloseButton];
    }
}

#pragma mark - Helper methods

- (NSURLRequest *)initialRequestWithCustomerID:(NSString *)customerID
							  customerAPIToken:(NSString *)customerAPIToken
										cartID:(NSString *)cartID
{
    NSString *baseURLString = [NSString stringWithFormat:@"https://sacola.%@", [[[B2WAPIClient sharedClient] baseURL] domain]];
	
	NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:@{
        @"customer_id": customerID,
        @"customer_api_token": customerAPIToken,
        @"cart_id": cartID,
        @"utm_source": @"app-ios",
        @"utm_medium": @"app",
        @"utm_campaign": @"app",
        @"header": @"false",
        @"footer": @"false",
        @"mobrandarg": [NSString stringWithFormat:@"%d", arc4random_uniform(10000)], // avoid weird WKWebView cache bugs
		@"appversion": version
    }];
	
    if ([B2WAPIClient OPNString]) {
        query[@"opn"] = [B2WAPIClient OPNString];
    }
    
    if ([B2WAPIClient EPARString]) {
        query[@"epar"] = [B2WAPIClient EPARString];
    }
    
    if ([B2WAPIClient FRANQString]) {
        query[@"franq"] = [B2WAPIClient FRANQString];
    }
    
    if ([B2WAPIClient referrerURLString]) {
        query[@"referrer"] = [B2WAPIClient referrerURLString];
    }
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@#/payment/", baseURLString, [self queryStringWithParameters:query]];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:URLString
                                                                                parameters:nil
                                                                                     error:nil];
    
	NSMutableDictionary *headers = [[NSMutableDictionary alloc] initWithDictionary:request.allHTTPHeaderFields];
	NSString *customerID_Cookie = [B2WKitUtils stringByAddingPercentEscapes:customerID];
	NSString *customerAPIToken_Cookie = [B2WKitUtils stringByAddingPercentEscapes:customerAPIToken];
	NSString *cartID_Cookie = [B2WKitUtils stringByAddingPercentEscapes:cartID];
	NSMutableArray *cookies = @[[NSHTTPCookie cookieWithName:@"customer.id" value:customerID_Cookie],
								[NSHTTPCookie cookieWithName:@"customer.api.token" value:customerAPIToken_Cookie],
								[NSHTTPCookie cookieWithName:@"cart.id" value:cartID_Cookie]];
	[headers addEntriesFromDictionary:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
	[request setAllHTTPHeaderFields:headers];
		
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    return request;
}

- (NSString *)queryStringWithParameters:(NSDictionary *)parameters
{
    NSMutableArray *pairs = [NSMutableArray array];
    
    for (NSString *name in parameters) {
        NSString *value = parameters[name];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", name, [B2WKitUtils stringByAddingPercentEscapes:value]]];
    }
    
    return [@"?" stringByAppendingString:[pairs componentsJoinedByString:@"&"]];
}

#pragma mark - JavaScript

- (void)downloadCustomJavaScriptFromURL:(NSString *)URLString success:(void (^)(void))success failure:(void (^)(void))failure
{
    if ([self.userScripts objectForKey:@"docStart"] == nil) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:URLString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSString *source = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSArray *sources = [source componentsSeparatedByString:@"/*SPLIT*FILE*HERE*/"];
            
            if (sources.count == 2) {
                NSString *docStartJS = sources[0];
                NSString *docEndJS = sources[1];
                
                [self setUserScriptWithSource:docStartJS injectionTime:WKUserScriptInjectionTimeAtDocumentStart forKey:@"docStart"];
                [self setUserScriptWithSource:docEndJS injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forKey:@"docEnd"];
            } else {
                [self setUserScriptWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forKey:@"docEnd"];
            }
            
            success();
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failure();
        }];
    } else {
        // cached script
        success();
    }
}

// You need to use set scripts on the self.userScripts dictionary and then call this instead of just adding user scripts
// because WebKit doesn't provide a way to update a user script once added
- (void)updateUserScripts
{
#if USE_WK
    // remove all scripts
    [self.webView.configuration.userContentController removeAllUserScripts];
    // re-add them
    NSEnumerator *enumerator = [self.userScripts objectEnumerator];
    WKUserScript *script;
    while ((script = (WKUserScript *) [enumerator nextObject])) {
        [self.webView.configuration.userContentController addUserScript:script];
    }
#endif
}

// A helper for the above method
- (void)setUserScriptWithSource:(NSString *)source injectionTime:(WKUserScriptInjectionTime)injectionTime forKey:(NSString *)key
{
    self.userScripts[key] = [[WKUserScript alloc] initWithSource:source injectionTime:injectionTime forMainFrameOnly:NO];
    [self updateUserScripts];
}

#pragma mark - Error

- (void)showErrorViewWithReloadButtonPressedBlock:(IDMReloadButtonPressedBlock)block
{
    [self.contentUnavailableView showWithTitle:kDefaultConnectionErrorTitle message:kDefaultConnectionErrorMessage reloadButtonPressedBlock:^{
        [self.contentUnavailableView dismiss];
        block();
    }];
}

#pragma mark - Bank slip

- (void)printBankSlipWithURL:(NSURL *)URL
{
    B2WBilletViewController *vc = [[B2WBilletViewController alloc] initWithURL:URL];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Notificatios

- (void)handleUserSignedInNotification:(NSNotification *)notification
{
    return;
}

- (void)handleUserSignedOutNotification:(NSNotification *)notification
{
#if USE_WK
    [self.webView evaluateJavaScript:@"__removeAuthCookies();" completionHandler:nil];
#endif
    [self dismissViewController];
}

- (void)dismissViewController
{
    if ([self isBeingPresentedModally])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        if (self.navigationController.viewControllers[0] != self)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)wipeWebView
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
}

/*
#pragma mark - iPad

- (void)adjustViewportDimensionsForTablet
{
    if(self.webView.frame.size.width < self.webView.window.frame.size.width)
    {
        // width=device-width results in a wrong viewport dimension for webpages displayed in a popover
        NSString *jsCmd = @"var viewport = document.querySelector('meta[name=viewport]');";
        jsCmd = [jsCmd stringByAppendingFormat:@"viewport.setAttribute('content', 'width=%lu, initial-scale=1.0, user-scalable=1');", (unsigned long)self.webView.frame.size.width];
        [self.webView evaluateJavaScript:jsCmd completionHandler:nil];
    }
}
*/

@end
