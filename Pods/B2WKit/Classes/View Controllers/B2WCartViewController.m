//
//  ACOMBasketViewController.m
//  Americanas
//
//  Created by Rodrigo Fontes on 12/2/13.
//  Copyright (c) 2013 Ideais. All rights reserved.
//

#import "B2WAPIClient.h"
#import "B2WAPICatalog.h"
#import "B2WAPIAccount.h"
#import "B2WAccountManager.h"
#import "B2WCartViewController.h"
#import "B2WBilletViewController.h"
#import "B2WSKUInformation.h"
#import "B2WCartURLProtocol.h"
#import "B2WAPICart.h"

#import "NSURL+B2WKit.h"
#import "UIViewController+B2WKit.h"

#import <IDMViewControllerStates/UIViewController+States.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "B2WDebugSettingsTableViewController.h"

@implementation NSString (Substring)

- (BOOL)containsSubstring:(NSString*)substring
{
    return ([self rangeOfString:substring].location != NSNotFound);
}

@end

@interface B2WCartViewController ()

@property (nonatomic, assign) BOOL isDebugActivated;

@end

static NSString *const B2WBasketBaseURLSubstring = @"/checkout/cart";
static NSString *const B2WBasketCheckoutURLSubstring = @"/checkout";
static NSString *const B2WBasketOneClickURLSubstring = @"/checkout/one_click";
static NSString *const B2WBasketBankSlipSubstring = @"/bankslipsec";
static NSString *const B2WBasketBankSlipSubstring2 = @"/bank-slip";
static NSString *const B2WBasketProductSubstring = @"/products";
static NSString *const B2WBasketCheckoutReceiptSubstring = @"/checkout/cc#/receipt";

@implementation B2WCartViewController

- (void)setSkus:(NSArray *)skus
{
    for (id obj in skus)
    {
        if (![obj isKindOfClass:[NSString class]])
        {
            [NSException raise:NSInternalInconsistencyException format:@"Incorrect object (%@) in SKU array. setSkus: expects strings", NSStringFromClass([obj class])];
            return;
        }
    }
    
    _skus = skus;
    
    if (skus != nil)
    {
        [self _loadInitialRequest];
    }
}

- (void)setSkusAndStoreIds:(NSArray *)skusAndStoreIds
{
    for (id obj in skusAndStoreIds)
    {
        if (![obj isKindOfClass:[NSString class]])
        {
            [NSException raise:NSInternalInconsistencyException format:@"Incorrect object (%@) in SKU array. setSkus: expects strings", NSStringFromClass([obj class])];
            return;
        }
    }
    
    _skusAndStoreIds = skusAndStoreIds;
    
    if (skusAndStoreIds != nil)
    {
        [self _loadInitialRequest];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[B2WAPIClient brandCode] isEqualToString:@"ACOM"])
    {
        self.navigationItem.title = @"Cesta de Compras";
    }
    else if ([[B2WAPIClient brandCode] isEqualToString:@"SUBA"])
    {
        self.navigationItem.title = @"Carrinho";
    }
    else if ([[B2WAPIClient brandCode] isEqualToString:@"SHOP"])
    {
        self.navigationItem.title = @"Carrinho";
    }
    
    [NSURLProtocol registerClass:[B2WCartURLProtocol class]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserSignedInNotification:) name:@"UserSignedIn" object:nil];
    
    [self.webView setScalesPageToFit:YES];
    
    self.didLoadInitialRequest =  NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!self.presentedViewController.isBeingDismissed)
    {
        if (!self.didLoadInitialRequest)
        {
            [self _loadInitialRequest];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self _adjustViewportDimensions];
}

#pragma mark - Custom

- (UIBarButtonItem *)reloadItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                         target:self.webView
                                                         action:@selector(reload)];
}

- (UIBarButtonItem *)backItem
{
    UIImage *backImage = [[UIImage imageNamed:@"B2WKit.bundle/b2w-icn-back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    return [[UIBarButtonItem alloc] initWithImage:backImage
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(backButtonPressed)];
}

- (void)backButtonPressed
{
    if ([self.lastRequestURLString isEqualToString:self.initialURLString] ||
        [self.lastRequestURLString containsSubstring:B2WBasketCheckoutReceiptSubstring])
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
    else
    {
        [self.webView goBack];
    }
}

- (NSString*)_baseURLString
{
    NSString *debugURLstring = [[NSUserDefaults standardUserDefaults] stringForKey:checkoutURLKey];
    if (debugURLstring)
    {
        self.isDebugActivated = YES;
        return debugURLstring;
    }
    else
    {
        self.isDebugActivated = NO;
    }
    
    return [NSString stringWithFormat:@"https://m.%@", [[[B2WAPIClient sharedClient] baseURL] domain]];
}

- (void)_loadInitialRequest
{
    self.initialURLString = [NSString stringWithFormat:@"%@%@?utm_source=app-ios&utm_medium=app&utm_campaign=app%@", [self _baseURLString], B2WBasketBaseURLSubstring, [self appVisitorID]];
    
    if ([B2WAPIClient OPNString])
    {
        self.initialURLString = [self.initialURLString stringByAppendingFormat:@"&opn=%@", [B2WAPIClient OPNString]];
    }
    
    NSMutableDictionary *parameters = nil;
    NSMutableURLRequest *request = nil;
    
    if (self.skusAndStoreIds)
    {
        parameters = self.skusAndStoreIds ? [NSMutableDictionary dictionaryWithDictionary:@{@"sku": self.skusAndStoreIds}] : nil;
        request = [[AFHTTPRequestSerializer serializer] requestWithMethod:self.skusAndStoreIds ? @"POST" : @"GET"
                                                                URLString:self.initialURLString
                                                               parameters:parameters
                                                                    error:nil];
    }
    else
    {
        parameters = self.skus ? [NSMutableDictionary dictionaryWithDictionary:@{@"sku": self.skus}] : nil;
        request = [[AFHTTPRequestSerializer serializer] requestWithMethod:self.skus ? @"POST" : @"GET"
                                                                URLString:self.initialURLString
                                                               parameters:parameters
                                                                    error:nil];
    }
    
    // metrics cookies
    NSString *domain = [[[B2WAPIClient sharedClient] baseURL] domain];
	domain = [NSString stringWithFormat:@".%@", domain];
	
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	
	NSMutableDictionary *cookieProperties_mobileapp = [NSMutableDictionary dictionary];
	[cookieProperties_mobileapp setObject:@"mobileapp" forKey:NSHTTPCookieName];
	[cookieProperties_mobileapp setObject:@"true" forKey:NSHTTPCookieValue];
	[cookieProperties_mobileapp setObject:domain forKey:NSHTTPCookieDomain];
	[cookieProperties_mobileapp setObject:domain forKey:NSHTTPCookieOriginURL];
	[cookieProperties_mobileapp setObject:@"/" forKey:NSHTTPCookiePath];
	[cookieProperties_mobileapp setObject:@"0" forKey:NSHTTPCookieVersion];
	
	// set expiration to one month from now or any NSDate of your choosing
	// this makes the cookie sessionless and it will persist across web sessions and app launches
	/// if you want the cookie to be destroyed when your app exits, don't set this
	[cookieProperties_mobileapp setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
	
	NSHTTPCookie *cookie_mobileapp = [NSHTTPCookie cookieWithProperties:cookieProperties_mobileapp];
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie_mobileapp];
	
	NSMutableDictionary *cookieProperties_appversion = [NSMutableDictionary dictionary];
	[cookieProperties_appversion setObject:@"appversion" forKey:NSHTTPCookieName];
	[cookieProperties_appversion setObject:version forKey:NSHTTPCookieValue];
	[cookieProperties_appversion setObject:domain forKey:NSHTTPCookieDomain];
	[cookieProperties_appversion setObject:domain forKey:NSHTTPCookieOriginURL];
	[cookieProperties_appversion setObject:@"/" forKey:NSHTTPCookiePath];
	[cookieProperties_appversion setObject:@"0" forKey:NSHTTPCookieVersion];
	
	// set expiration to one month from now or any NSDate of your choosing
	// this makes the cookie sessionless and it will persist across web sessions and app launches
	/// if you want the cookie to be destroyed when your app exits, don't set this
	[cookieProperties_mobileapp setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
	
	NSHTTPCookie *cookie_appversion = [NSHTTPCookie cookieWithProperties:cookieProperties_appversion];
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie_appversion];
	
    // load the request
    [self.loadingView show];
    self.initiallyLoadedRequest = request;
    [self.webView loadRequest:request];
}

- (NSString *)appVisitorID
{
    return @"";
}

- (void)didPressPrintBilletButtonWithURL:(NSURL*)url
{
    B2WBilletViewController *vc = [[B2WBilletViewController alloc] initWithURL:url];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showBasketResponseError:(NSError *)error
{
#ifdef kDefaultConnectionErrorTitle
    NSString *title = kDefaultConnectionErrorTitle;
#else
    NSString *title = @"Falha na Conexão";
#endif
    
#ifdef kDefaultConnectionErrorMessage
    NSString *message = kDefaultConnectionErrorMessage;
#else
    NSString *message = @"Não foi possível conectar ao servidor. Por favor, verifique sua conexão com a internet.";
#endif
    
    [self.contentUnavailableView showWithTitle:title message:message reloadButtonPressedBlock:^()
     {
         [self.contentUnavailableView dismiss];
         [self _loadInitialRequest];
     }];
}

- (void)_adjustViewportDimensions
{
    if (self.webView.frame.size.width < self.webView.window.frame.size.width)
    {
        // width=device-width results in a wrong viewport dimension for webpages displayed in a popover
        NSString *jsCmd = @"var viewport = document.querySelector('meta[name=viewport]');";
        jsCmd = [jsCmd stringByAppendingFormat:@"viewport.setAttribute('content', 'width=%lu, initial-scale=1.0, user-scalable=1');", (unsigned long)self.webView.frame.size.width];
        [self.webView stringByEvaluatingJavaScriptFromString:jsCmd];
    }
}

#pragma mark - UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"\n[*] B2WCartVC -> did start load: %@\n\n", webView.request.URL);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicator setColor:[self.navigationController.navigationBar tintColor]];
    [indicator startAnimating];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"\n[*] B2WCartVC -> did finish load: %@\n\n", webView.request.URL);
    
    // [!] This is brittle but should handle the case where an user changes the password on the website and is still signed in on the app
    // UPDATE: the server notices when a password has changed recently and the user is brought to the sign-in page with a "Usuário ou senha inválido" message.
    // TODO: We'll disable this because of a bug where the user is being logged out at random.
    /*
    if ([self isCheckoutURL:webView.request.URL]) {
        NSLog(@"[*] Finished loading checkout page");
        if ([[webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('pageNotFound').length > 0"] isEqualToString:@"true"]) {
            [webView stopLoading];
            [webView goBack];
            [B2WAPIAccount logout];
            [B2WAccountManager resetAccountSavedData];
            [UIAlertView showAlertViewWithTitle:@"Falha de autenticação" message:@"Este erro ocorre caso você tenha alterado sua senha recentemente, por favor tente novamente."];
        }
    }
    */
    
    [self _adjustViewportDimensions];
    
    if (!self.skipLoadingDismiss)
    {
        [self.loadingView dismiss];
    }
    self.navigationItem.rightBarButtonItem = [self reloadItem];
    
    if ([webView canGoBack] &&
        ![self.lastRequestURLString isEqualToString:self.initialURLString])
    {
        self.navigationItem.leftBarButtonItem = [self backItem];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    self.didLoadInitialRequest = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"\n[*] B2WCartVC -> did fail load with error: %@\n%@\n\n", webView.request.URL, error);
    
    [self.loadingView dismiss];

    DLog(@"Request Basket Error: %@", error);
    
    if (error.code != NSURLErrorCancelled)
    {
        [self showBasketResponseError:error];
    }
    self.navigationItem.rightBarButtonItem = [self reloadItem];
}

- (void)_didSelectProductIdentifier:(NSString*)identifier
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cartViewController:didSelectProduct:error:)])
    {
        [SVProgressHUD showWithStatus:@"Carregando..."];
        [B2WAPICatalog requestProductWithIdentifier:identifier block:^(B2WProduct *product, NSError *error) {
            [SVProgressHUD dismiss];
            if (error)
            {
                [self.delegate cartViewController:self didSelectProduct:nil error:error];
                return;
            }
            
            [self.delegate cartViewController:self didSelectProduct:product error:nil];
        }];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = request.URL.absoluteString;
    
    NSLog(@"[*] Loading URL: %@", urlString);
    
    NSString *urlCheckout = [NSString stringWithFormat:@"%@%@", [self _baseURLString], B2WBasketCheckoutURLSubstring];
    NSString *urlOneClick = [NSString stringWithFormat:@"%@%@", [self _baseURLString], B2WBasketOneClickURLSubstring];
    
    //
    // Ensure user has authenticated before clicking on 'Continuar'
    //
    if ([urlString isEqualToString:urlCheckout] || [urlString isEqualToString:urlOneClick]) {
        if ( ! [B2WAPIAccount isLoggedIn] ) {
            self.requestToBeLoadedAfterAuthentication = [request copy];
            [[B2WAccountManager sharedManager] presentLoginViewControllerWithUserSignedInHandler:^(){
                [self loadRequestAfterAuthentication];
            } failedHandler:nil canceledHandler:nil];
            return NO;
        }
    }
    
    //
    // Adds bank slip printing support
    //
    if ([urlString containsSubstring:B2WBasketBankSlipSubstring] ||
        [urlString containsSubstring:B2WBasketBankSlipSubstring2])
    {
        [self didPressPrintBilletButtonWithURL:request.URL];
        return NO;
    }
    //
    // Disable product page links
    //
    if ([urlString containsSubstring:B2WBasketProductSubstring])
    {
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(cartViewController:didSelectProduct:error:)])
        {
            NSString *productIdentifier;
            
            if (request.URL.pathComponents.count >= 3)
            {
                productIdentifier = request.URL.pathComponents[2];
            }
            
            if (productIdentifier.length == 0 || productIdentifier == nil)
            {
                return NO;
            }
            
            // Check if match is only numeric
            BOOL valid;
            NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:productIdentifier];
            valid = [alphaNums isSupersetOfSet:inStringSet];
            
            if (valid)
            {
                [self _didSelectProductIdentifier:productIdentifier];
            }
        }
        return NO;
    }
    self.lastRequestURLString = request.URL.absoluteString;
    
    return YES;
}

#pragma mark Notification handling

- (void)handleUserSignedInNotification:(NSNotification *)notification
{
    if ([B2WAPIAccount recentlyAlternatedAccounts])
	{
        if (self.initiallyLoadedRequest)
		{
			[self.webView loadRequest:self.initiallyLoadedRequest];
		}
    }
}

- (void)loadRequestAfterAuthentication
{
    if (self.requestToBeLoadedAfterAuthentication) {
        [self.webView loadRequest:self.requestToBeLoadedAfterAuthentication];
        self.requestToBeLoadedAfterAuthentication = nil;
    }
}

#pragma mark Helper methods

- (BOOL)isCheckoutURL:(NSURL *)URL
{
    BOOL isCorrectDomain = self.isDebugActivated ? YES : [[URL domain] isEqualToString:[NSString stringWithFormat:@"m.%@", [[[B2WAPIClient sharedClient] baseURL] domain]]];
    BOOL isCorrectPath = [[URL path] isEqualToString:B2WBasketCheckoutURLSubstring];
    
    return isCorrectDomain && isCorrectPath;
}

@end
