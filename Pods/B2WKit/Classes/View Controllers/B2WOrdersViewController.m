//
//  B2WOrdersViewController.m
//  B2WKit
//
//  Created by Thiago Peres on 20/12/13.
//  Copyright (c) 2013 Ideais. All rights reserved.
//

#import "B2WOrdersViewController.h"
#import "NSURL+B2WKit.h"
#import "UIViewController+B2WKit.h"
#import "B2WAPIClient.h"
#import "B2WAPIAccount.h"
#import "B2WKitUtils.h"
#import "IDMAlertViewManager.h"

#import <IDMViewControllerStates/UIViewController+States.h>

@interface B2WOrdersViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURL *lastRequestURL;
@property (nonatomic) NSUInteger errorPageTrials;

@end

@implementation B2WOrdersViewController

static NSUInteger const MAX_ERROR_PAGE_TRIALS = 3;

/* Not needed anymore since cookie solution
NSString * _B2WOrdersBaseURLString()
{
    return [NSString stringWithFormat:@"https://carrinho.%@/CustomerWeb/pages/LoginMeusPedidosMobile", [[B2WAPIClient sharedClient] baseURL].domain];
}
*/

NSString * _B2WOrdersBaseURLString()
{
    return [NSString stringWithFormat:@"https://carrinho.%@/ControlPanelWeb/mobile/MobileLastOrders", [[B2WAPIClient sharedClient] baseURL].domain];
}

NSURL * _B2WOrdersBaseURL()
{
    return [NSURL URLWithString:_B2WOrdersBaseURLString()];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.errorPageTrials = 0;

	self.navigationItem.title = @"Meus Pedidos";
    [self.webView setScalesPageToFit:YES];
    
    [self.loadingView show];
    
    self.lastRequestURL = _B2WOrdersBaseURL();
    [self setAuthCookieThenLoadInitialRequest];
    
    if (self.isBeingPresentedModally)
    {
        self.navigationItem.leftBarButtonItem = [self closeBarButtonItem];
    }
    
    self.webView.scrollView.contentSize = CGSizeMake(320, 480);
}

- (void)setAuthCookieThenLoadInitialRequest
{
    NSString *eloId = [B2WAPIAccount userIdentifier]; //@"02-36472825-1";
    NSString *path = [NSString stringWithFormat:@"http://b2w-mobile-api.herokuapp.com/auth?string=%@", eloId];
    
    // Request the encrypted cookie and save it.
    // The cookie changes on a daily basis, so, for now, we'll request a new one everytime to make sure it's valid.
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Let's make sure the app won't blow up in case the server responds with something weird
        if (responseObject && responseObject[@"result"]) {
            NSString *hash = responseObject[@"result"];
            NSMutableDictionary *cookieProperties = [self cookiePropertiesWithHash:hash];
            NSLog(@"[*] Setting MyOrders cookie with hash: %@", hash);
            // Set expiration to one month from now or any NSDate of your choosing
            // this makes the cookie sessionless and it will persist across web sessions and app launches
            // if you want the cookie to be destroyed when your app exits, don't set this
            [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:(365*24*60*60)] forKey:NSHTTPCookieExpires];
            NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        } else {
            NSLog(@"[!] ERROR: cannot set MyOrders cookie, API response = %@", responseObject);
        }
        
        [self loadInitialRequest];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [IDMAlertViewManager showDefaultConnectionFailureAlert];
    }];
}

- (void)loadInitialRequest
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_B2WOrdersBaseURL()];
    [self.webView loadRequest:request];
}

- (NSMutableDictionary *)cookiePropertiesWithHash:(NSString *)hash
{
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *cookieName = @"21000Customer";
    NSString *cookieDomain = @".americanas.com.br";
    NSString *cookieOriginURL = @"carrinho.americanas.com.br";
    
    if ([[B2WKitUtils mainAppDisplayName] isEqualToString:@"Submarino"]) {
        cookieName = @"31000Customer";
        cookieDomain = @".submarino.com.br";
        cookieOriginURL = @"carrinho.submarino.com.br";
    } else if ([[B2WKitUtils mainAppDisplayName] isEqualToString:@"Shoptime"]) {
        cookieName = @"11000Customer";
        cookieDomain = @".shoptime.com.br";
        cookieOriginURL = @"carrinho.shoptime.com.br";
    }
    
    [cookieProperties setObject:cookieName forKey:NSHTTPCookieName];
    [cookieProperties setObject:hash forKey:NSHTTPCookieValue];
    [cookieProperties setObject:cookieDomain forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:cookieOriginURL forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    
    return cookieProperties;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"[*] start: %@", webView.request.URL);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicator setColor:[self.navigationController.navigationBar tintColor]];
    [indicator startAnimating];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicator];
}

- (UIBarButtonItem*)reloadBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                         target:self.webView
                                                         action:@selector(reload)];
}

- (UIBarButtonItem*)closeBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithTitle:@"Fechar"
                                            style:UIBarButtonItemStyleDone
                                           target:self
                                           action:@selector(_dismissViewController)];
}

- (UIBarButtonItem*)backBarButtonItem
{
    UIImage *backImage = [[UIImage imageNamed:@"B2WKit.bundle/b2w-icn-back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    return [[UIBarButtonItem alloc] initWithImage:backImage
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(backButtonPressed)];
}

- (void)_dismissViewController
{
    if ([self isBeingPresentedModally])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        if ([self.navigationController.viewControllers firstObject] != self)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)backButtonPressed
{
    if ([self isBaseURL:self.lastRequestURL] || (self.errorPageTrials >= MAX_ERROR_PAGE_TRIALS)) // errorPageTrials: as vezes carrega um frame estranho por último e vc fica preso na tela
    {
        [self _dismissViewController];
    }
    
    [self.webView goBack];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"[*] should: %@", webView.request.URL);
    
    if (self.errorPageTrials > MAX_ERROR_PAGE_TRIALS) {
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navigationItem.rightBarButtonItem = [self reloadBarButtonItem];
    self.lastRequestURL = webView.request.URL;
    
    NSLog(@"[*] finish: %@", webView.request.URL.path);
    //
    // Finds out if this is an error page
    //
    if ([self isErrorPage:webView]) {
        NSLog(@"[*] error, trial: %lu", (unsigned long)self.errorPageTrials);
        
        [webView stopLoading];
        
        if (self.errorPageTrials >= MAX_ERROR_PAGE_TRIALS) {
            NSLog(@"[*] alert");
            [self.loadingView dismiss];
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
            [self.contentUnavailableView showWithTitle:kDefaultConnectionErrorTitle message:kDefaultConnectionErrorMessage reloadButtonPressedBlock:^()
             {
                 [self.navigationItem.rightBarButtonItem setEnabled:YES];
                 [self.contentUnavailableView dismiss];
                 self.errorPageTrials = 0;
                 self.lastRequestURL = _B2WOrdersBaseURL();
                 [self.loadingView show];
                 [self loadInitialRequest];
             }];
        } else {
            NSLog(@"[*] reloading");
            self.errorPageTrials += 1;
            // Actually loads the request
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_B2WOrdersBaseURL()];
            [self.webView loadRequest:request];

        }
    } else {
        NSLog(@"[*] NO error page detected");
        [self.loadingView dismiss];
        
        if (self.errorPageTrials > 0) {
            self.errorPageTrials = 0;
        }
    }
    
    //
    // Fixes webview exhibition on form modals and popovers
    // width=device-width results in a wrong viewport dimension for webpages displayed in a popover
    //
    if (webView.frame.size.width < webView.window.frame.size.width)
    {
        NSString *jsCmd = @"var viewport = document.querySelector('meta[name=viewport]');";
        jsCmd = [jsCmd stringByAppendingFormat:@"viewport.setAttribute('content', 'width=%lu, initial-scale=1.0, user-scalable=1');", (unsigned long)webView.frame.size.width];
        
        [webView stringByEvaluatingJavaScriptFromString:jsCmd];
    }
    
    if ([webView canGoBack])
    {
        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    }
    else if (self.isBeingPresentedModally && [self isBaseURL:webView.request.URL]) // iPad
    {
        self.navigationItem.leftBarButtonItem = [self closeBarButtonItem];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"[*] failed: %@", webView.request.URL);
    
    if (error.code != NSURLErrorCancelled)
    {
        [self.loadingView dismiss];
        [self showOrdersResponseError:error];
        self.navigationItem.rightBarButtonItem = [self reloadBarButtonItem];
    }
}

- (void)showOrdersResponseError:(NSError*)error
{
#ifdef kDefaultConnectionErrorTitle
    NSString *title = kDefaultConnectionErrorTitle;
#else
    NSString *title = @"Falha na Conexão";
#endif
    
#ifdef kDefaultConnectionErrorMessage
    NSString *message = kDefaultConnectionErrorMessage;
#else
    NSString *message = kDefaultConnectionErrorMessage;
#endif
    
    [self.contentUnavailableView showWithTitle:title message:message reloadButtonPressedBlock:^()
     {
         [self.contentUnavailableView dismiss];
         [self.loadingView show];
         [self loadInitialRequest];
     }];
}

#pragma mark Helper methods

- (BOOL)isBaseURL:(NSURL *)URL
{
    NSURL *baseURL = _B2WOrdersBaseURL();
    NSString *baseDomain = [baseURL domain];
    NSArray *basePathComponents = [baseURL pathComponents];
    
    NSString *domain = [URL domain];
    NSArray *pathComponents = [URL pathComponents];
    
    // Sometimes weird parameters appear on the path, eg: https://carrinho.shoptime.com.br/ControlPanelWeb/mobile/MobileLastOrders/wicket:pageMapName/wicket-0/
    // and straightforward string comparison goes wrong.
    //
    // Path components array
    // 0: /
    // 1: ControlPanelWeb
    // 2: mobile
    // 3: MobileLastOrders
    if (([basePathComponents count] < 4) || ([pathComponents count] < 4)) { return NO; } // sanity check
    for (NSUInteger i = 0; i < 4; i++) {
        NSString *a = (NSString *)[basePathComponents objectAtIndex:i];
        NSString *b =(NSString *)[pathComponents objectAtIndex:i];
        if (a && b && ![a isEqualToString:b]) { return NO; }
    }
    
    return [baseDomain isEqualToString:domain];
}

- (BOOL)isErrorPage:(UIWebView *)webView
{
    
        return [[webView stringByEvaluatingJavaScriptFromString:@"$('#errorMessage').length"] isEqualToString:@"1"] ||
               [[webView stringByEvaluatingJavaScriptFromString:@"$('.not-found-info').length"] isEqualToString:@"1"];
}

@end
