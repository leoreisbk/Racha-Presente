//
//  B2WWebViewController.m
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 11/18/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WWebViewController.h"

@interface B2WWebViewController () <UIPopoverControllerDelegate>

@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) UIBarButtonItem *stopLoadingButton;
@property (strong, nonatomic) UIBarButtonItem *reloadButton;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIBarButtonItem *forwardButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (assign, nonatomic) BOOL webViewIsLoading;
@property (assign, nonatomic) BOOL toolbarPreviouslyHidden;

@end

@implementation B2WWebViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _showsNavigationToolbar = YES;
}

- (void)load
{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:4.0];
    [self.webView loadRequest:request];
    
    if (self.navigationController.toolbarHidden) {
        self.toolbarPreviouslyHidden = YES;
        if (self.showsNavigationToolbar) {
            [self.navigationController setToolbarHidden:NO animated:YES];
        }
    }
}

- (void)clear
{
    [self.webView loadHTMLString:@"" baseURL:nil];
    self.title = @"";
}

#pragma mark - View controller lifecycle

- (void)loadView
{
    self.webView = [[UIWebView alloc] init];
    self.webView.scalesPageToFit = YES;
    self.view = self.webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupToolBarItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.webView.delegate = self;
    if (self.URL) {
        [self load];
    }
    [self updateToolbarState];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
    self.webView.delegate = nil;
    
    if (self.toolbarPreviouslyHidden && self.showsNavigationToolbar) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

#pragma mark - Helpers

- (UIImage *)backButtonImage
{
    static UIImage *image;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        CGSize size = CGSizeMake(12.0, 21.0);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 1.5;
        path.lineCapStyle = kCGLineCapButt;
        path.lineJoinStyle = kCGLineJoinMiter;
        [path moveToPoint:CGPointMake(11.0, 1.0)];
        [path addLineToPoint:CGPointMake(1.0, 11.0)];
        [path addLineToPoint:CGPointMake(11.0, 20.0)];
        [path stroke];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

- (UIImage *)forwardButtonImage
{
    static UIImage *image;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        UIImage *backButtonImage = [self backButtonImage];
        
        CGSize size = backButtonImage.size;
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat x_mid = size.width / 2.0;
        CGFloat y_mid = size.height / 2.0;
        
        CGContextTranslateCTM(context, x_mid, y_mid);
        CGContextRotateCTM(context, M_PI);
        
        [backButtonImage drawAtPoint:CGPointMake(-x_mid, -y_mid)];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

- (void)setupToolBarItems
{
    self.stopLoadingButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                           target:self
                                                                           action:@selector(stopButtonPressed:)];
    
    self.reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                      target:self
                                                                      action:@selector(refreshButtonPressed:)];
    
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[self backButtonImage]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(backButtonPressed:)];
    
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[self forwardButtonImage]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(forwardButtonPressed:)];
    
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidesWhenStopped = YES;
    
    UIBarButtonItem *activityIndicatorButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil];
    
    UIBarButtonItem *space_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                            target:nil
                                                                            action:nil];
    space_.width = 60.0f;
    
    self.toolbarItems = @[self.stopLoadingButton, space, self.backButton, space_, self.forwardButton, space, activityIndicatorButton];
}

- (void)updateToolbarState
{
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
    
    NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
    if (self.webViewIsLoading) {
        [self.activityIndicatorView startAnimating];
        toolbarItems[0] = self.stopLoadingButton;
    } else {
        [self.activityIndicatorView stopAnimating];
        toolbarItems[0] = self.reloadButton;
        
        self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    
    self.toolbarItems = [toolbarItems copy];
}

#pragma mark - UIBarButtonItem Target Action Methods

- (void)backButtonPressed:(id)sender {
    
    [self.webView goBack];
    [self updateToolbarState];
}

- (void)forwardButtonPressed:(id)sender {
    [self.webView goForward];
    [self updateToolbarState];
}

- (void)refreshButtonPressed:(id)sender {
    [self.webView stopLoading];
    [self.webView reload];
    [self updateToolbarState];
}

- (void)stopButtonPressed:(id)sender {
    [self.webView stopLoading];
    [self updateToolbarState];
}


#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    NSString *nav = @"other";
//    if (navigationType == UIWebViewNavigationTypeLinkClicked) { nav = @"link"; }
//    else if (navigationType == UIWebViewNavigationTypeFormSubmitted) { nav = @"form submit"; }
//    else if (navigationType == UIWebViewNavigationTypeFormResubmitted) { nav = @"form re-submit"; }
//    else if (navigationType == UIWebViewNavigationTypeBackForward) { nav = @"back/forward"; }
//    else if (navigationType == UIWebViewNavigationTypeReload) { nav = @"reload"; }
//    
//    NSLog(@"[*] Should (nav: %@):\n\t%@", nav, request.URL);
    
    self.webViewIsLoading = YES;
    [self updateToolbarState];
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //NSLog(@"[*] Start:\n\t%@", webView.request.URL);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //NSLog(@"[*] Finish:\n\t%@", webView.request.URL);
    
    self.webViewIsLoading = NO;
    [self updateToolbarState];
    
    self.URL = self.webView.request.URL;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //NSLog(@"[*] Fail:\n\t%@\n\t- error: %@", webView.request.URL, error.description);
    
    self.webViewIsLoading = NO;
    [self updateToolbarState];
}

@end
