//
//  B2WWebBrowserViewController.m
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 2/5/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//
#import "B2WWebBrowserViewController.h"

static void *B2WContext = &B2WContext;

@interface B2WWebBrowserViewController ()

@property (nonatomic, assign) BOOL previousNavigationControllerToolbarHidden, previousNavigationControllerNavigationBarHidden;
@property (nonatomic, strong) UIBarButtonItem *backButton, *forwardButton, *refreshButton, *stopButton, *fixedSeparator, *flexibleSeparator, *activityIndicatorButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation B2WWebBrowserViewController

#pragma mark - Static Initializers

+ (B2WWebBrowserViewController *)webBrowser {
    B2WWebBrowserViewController *webBrowserViewController = [B2WWebBrowserViewController webBrowserWithConfiguration:nil];
    return webBrowserViewController;
}

+ (B2WWebBrowserViewController *)webBrowserWithConfiguration:(WKWebViewConfiguration *)configuration {
    B2WWebBrowserViewController *webBrowserViewController = [[B2WWebBrowserViewController alloc] initWithConfiguration:configuration];
    return webBrowserViewController;
}

+ (UINavigationController *)navigationControllerWithWebBrowser {
    B2WWebBrowserViewController *webBrowserViewController = [[B2WWebBrowserViewController alloc] initWithConfiguration:nil];
    return [B2WWebBrowserViewController navigationControllerWithBrowser:webBrowserViewController];
}

+ (UINavigationController *)navigationControllerWithWebBrowserWithConfiguration:(WKWebViewConfiguration *)configuration {
    B2WWebBrowserViewController *webBrowserViewController = [[B2WWebBrowserViewController alloc] initWithConfiguration:configuration];
    return [B2WWebBrowserViewController navigationControllerWithBrowser:webBrowserViewController];
}

+ (UINavigationController *)navigationControllerWithBrowser:(B2WWebBrowserViewController *)webBrowser {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:webBrowser action:@selector(doneButtonPressed:)];
    [webBrowser.navigationItem setRightBarButtonItem:doneButton];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webBrowser];
    return navigationController;
}

#pragma mark - Initializers

- (id)init {
    return [self initWithConfiguration:nil];
}

- (id)initWithConfiguration:(WKWebViewConfiguration *)configuration {
    self = [super init];
    if (self) {
        
        if (configuration) {
            self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        }
        else {
            self.wkWebView = [[WKWebView alloc] init];
        }
        
        self.showsURLInNavigationBar = NO;
        self.showsPageTitleInNavigationBar = YES;
        
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.previousNavigationControllerToolbarHidden = self.navigationController.toolbarHidden;
    self.previousNavigationControllerNavigationBarHidden = self.navigationController.navigationBarHidden;
    
    [self.wkWebView setFrame:self.view.bounds];
    [self.wkWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.wkWebView setNavigationDelegate:self];
    [self.wkWebView setMultipleTouchEnabled:YES];
    [self.wkWebView setAutoresizesSubviews:YES];
    [self.wkWebView.scrollView setAlwaysBounceVertical:YES];
    [self.view addSubview:self.wkWebView];
    
    [self.wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:B2WContext];
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
    [self.progressView setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height-self.progressView.frame.size.height, self.view.frame.size.width, self.progressView.frame.size.height)];
    [self.progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self.navigationController.navigationBar addSubview:self.progressView];
    
    [self updateToolbarState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:self.previousNavigationControllerNavigationBarHidden animated:animated];
    
    [self.navigationController setToolbarHidden:self.previousNavigationControllerToolbarHidden animated:animated];
    
    [self.progressView removeFromSuperview];
}

#pragma mark - Public Interface

- (void)loadURL:(NSURL *)URL {
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)loadURLString:(NSString *)URLString {
    NSURL *URL = [NSURL URLWithString:URLString];
    [self loadURL:URL];
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    [self.progressView setTintColor:tintColor];
    [self.navigationController.navigationBar setTintColor:tintColor];
    [self.navigationController.toolbar setTintColor:tintColor];
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    _barTintColor = barTintColor;
    [self.navigationController.navigationBar setBarTintColor:barTintColor];
    [self.navigationController.toolbar setBarTintColor:barTintColor];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if (webView == self.wkWebView) {
        [self updateToolbarState];
        if ([self.delegate respondsToSelector:@selector(webBrowser:didStartLoadingURL:)]) {
            [self.delegate webBrowser:self didStartLoadingURL:self.wkWebView.URL];
        }
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (webView == self.wkWebView) {
        [self updateToolbarState];
        if ([self.delegate respondsToSelector:@selector(webBrowser:didFinishLoadingURL:)]) {
            [self.delegate webBrowser:self didFinishLoadingURL:self.wkWebView.URL];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if (webView == self.wkWebView) {
        [self updateToolbarState];
        if ([self.delegate respondsToSelector:@selector(webBrowser:didFailToLoadURL:error:)]) {
            [self.delegate webBrowser:self didFailToLoadURL:self.wkWebView.URL error:error];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    if (webView == self.wkWebView) {
        [self updateToolbarState];
        if ([self.delegate respondsToSelector:@selector(webBrowser:didFailToLoadURL:error:)]) {
            [self.delegate webBrowser:self didFailToLoadURL:self.wkWebView.URL error:error];
        }
    }
}

#pragma mark - Toolbar State

- (void)updateToolbarState {
    
    BOOL canGoBack = self.wkWebView.canGoBack;
    BOOL canGoForward = self.wkWebView.canGoForward;
    
    [self.backButton setEnabled:canGoBack];
    [self.forwardButton setEnabled:canGoForward];
    
    if (!self.backButton) {
        [self setupToolbarItems];
    }
    
    NSArray *barButtonItems;
    if (self.wkWebView.loading) {
        [self.activityIndicatorView startAnimating];
        barButtonItems = @[self.backButton, self.fixedSeparator, self.forwardButton, self.fixedSeparator, self.activityIndicatorButton, self.flexibleSeparator, self.stopButton];
        
        if (self.showsURLInNavigationBar) {
            NSString *URLString;
            URLString = [self.wkWebView.URL absoluteString];
            
            URLString = [URLString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            URLString = [URLString stringByReplacingOccurrencesOfString:@"https://" withString:@""];
            URLString = [URLString substringToIndex:[URLString length]-1];
            self.navigationItem.title = URLString;
        }
    }
    else {
        [self.activityIndicatorView stopAnimating];
        barButtonItems = @[self.backButton, self.fixedSeparator, self.forwardButton, self.fixedSeparator, self.activityIndicatorButton, self.flexibleSeparator, self.refreshButton];
        
        if (self.showsPageTitleInNavigationBar) {
            self.navigationItem.title = self.wkWebView.title;
        }
    }
    
    [self setToolbarItems:barButtonItems animated:YES];
}

- (void)setupToolbarItems {
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    self.stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonPressed:)];
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[self backButtonImage] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[self forwardButtonImage] style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonPressed:)];
    self.fixedSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.fixedSeparator.width = 50.0f;
    self.flexibleSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];
}

#pragma mark - Done Button Action

- (void)doneButtonPressed:(id)sender {
    [self dismissAnimated:YES];
}

#pragma mark - UIBarButtonItem Target Action Methods

- (void)backButtonPressed:(id)sender {
    [self.wkWebView goBack];
    [self updateToolbarState];
}

- (void)forwardButtonPressed:(id)sender {
    [self.wkWebView goForward];
    [self updateToolbarState];
}

- (void)refreshButtonPressed:(id)sender {
    [self.wkWebView stopLoading];
    [self.wkWebView reload];
}

- (void)stopButtonPressed:(id)sender {
    [self.wkWebView stopLoading];
}

#pragma mark - Estimated Progress KVO (WKWebView)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.wkWebView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:animated];
        
        // Once complete, fade out UIProgressView
        if (self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Dismiss

- (void)dismissAnimated:(BOOL)animated {
    [self.navigationController dismissViewControllerAnimated:animated completion:nil];
}

#pragma mark - Interface Orientation

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark - Dealloc

- (void)dealloc {
    [self.wkWebView setNavigationDelegate:nil];
    [self.wkWebView setUIDelegate:nil];
    if ([self isViewLoaded]) {
        [self.wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
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

@end

@implementation UINavigationController(B2WWebBrowser)

- (B2WWebBrowserViewController *)rootWebBrowser {
    UIViewController *rootViewController = [self.viewControllers objectAtIndex:0];
    return (B2WWebBrowserViewController *)rootViewController;
}

@end
