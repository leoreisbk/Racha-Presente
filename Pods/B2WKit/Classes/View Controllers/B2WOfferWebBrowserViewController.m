//
//  B2WOfferWebBrowserViewController.m
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 11/11/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WOfferWebBrowserViewController.h"
#import "B2WAPICatalog.h"
#import "UIViewController+B2WKit.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <IDMAlertViewManager.h>
#import <AFNetworking.h>
#import "B2WKitUtils.h"
#import "NSDictionary+B2WKit.h"

@implementation NSURL (B2WHelpers)

- (NSString *)pathComponentAtIndex:(NSUInteger)index
{
    NSArray *components = [self pathComponents];
    if (components.count > index) {
        return [components objectAtIndex:index];
    } else return @"";
}

- (BOOL)isB2WProductURL {
    return [[self pathComponentAtIndex:1] isEqualToString:@"produto"] || [[self pathComponentAtIndex:1] isEqualToString:@"products"];
}
- (BOOL)isB2WDepartmentURL { return [[self pathComponentAtIndex:1] isEqualToString:@"loja"] || [[self pathComponentAtIndex:1] isEqualToString:@"categories"]; }
- (BOOL)isB2WSubdepartmentURL { return [[self pathComponentAtIndex:1] isEqualToString:@"subloja"]; }
- (BOOL)isB2WLineURL { return [[self pathComponentAtIndex:1] isEqualToString:@"linha"]; }
- (BOOL)isB2WSublineURL { return [[self pathComponentAtIndex:1] isEqualToString:@"sublinha"]; }

- (NSString *)extractB2WIdentifier
{
    return [self pathComponentAtIndex:2];
}

@end

@interface B2WOfferWebBrowserViewController ()

@property(nonatomic, strong) NSString *headerRemovalJavaScript;

@end

@implementation B2WOfferWebBrowserViewController

+ (B2WOfferWebBrowserViewController *)webBrowserWithInitialURLString:(NSString *)URLString
{
    return [B2WOfferWebBrowserViewController webBrowserWithInitialURL:[NSURL URLWithString:URLString]];
}

+ (B2WOfferWebBrowserViewController *)webBrowserWithInitialURL:(NSURL *)URL
{
    B2WOfferWebBrowserViewController *viewController = [[B2WOfferWebBrowserViewController alloc] init];
    viewController.URL = URL;
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // dismiss
    if (self.isBeingPresentedModally) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Fechar" style:UIBarButtonItemStyleDone target:self action:@selector(_dismissViewController)];
    }
    
    // default webview js
    self.headerRemovalJavaScript = @"$('header, #header, #a-header, #footer, footer, .a-footer, .footerMiolo.cb, #shoptimeNovoFooter, #box-shoptimeMenuServicos, #searchBox, .sitemap-link, .bList, .menu-top-list, .top-header, .content-header, .header-flutuante').remove();";
    [self updateHeaderRemovalJavaScript];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [super dismissViewControllerAnimated:flag completion:completion];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)load
{
    [super load];
}

- (void)_dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Web view delegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [super webViewDidStartLoad:webView];
    [webView stringByEvaluatingJavaScriptFromString:self.headerRemovalJavaScript];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [super webViewDidFinishLoad:webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ( ! [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType] ) {
        return NO;
    }
    
    if ([request.URL isB2WProductURL]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(offerWebBrowserViewController:didSelectProductWithIdentifier:)]) {
            [self.delegate offerWebBrowserViewController:self didSelectProductWithIdentifier:[request.URL extractB2WIdentifier]];
        }
        return NO;
    } else if ([request.URL isB2WDepartmentURL]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(offerWebBrowserViewController:didSelectDepartmentWithIdentifier:)]) {
            [self.delegate offerWebBrowserViewController:self didSelectDepartmentWithIdentifier:[request.URL extractB2WIdentifier]];
        }
        return NO;
    } else if ([request.URL isB2WSubdepartmentURL]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(offerWebBrowserViewController:didSelectSubdepartmentWithIdentifier:)]) {
            [self.delegate offerWebBrowserViewController:self didSelectSubdepartmentWithIdentifier:[request.URL extractB2WIdentifier]];
        }
        return NO;
    } else if ([request.URL isB2WLineURL]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(offerWebBrowserViewController:didSelectLineWithIdentifier:)]) {
            [self.delegate offerWebBrowserViewController:self didSelectLineWithIdentifier:[request.URL extractB2WIdentifier]];
        }
        return NO;
    } else if ([request.URL isB2WSublineURL]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(offerWebBrowserViewController:didSelectSublineWithIdentifier:)]) {
            [self.delegate offerWebBrowserViewController:self didSelectSublineWithIdentifier:[request.URL extractB2WIdentifier]];
        }
        return NO;
    }
    
    // Hotsite detection
    
    if (navigationType == UIWebViewNavigationTypeOther) { // ignore requests that were not generated by the user
        return YES;
    }
    
    if ([self shouldLoadFlagInRequest:request]) { // already determined that this is not a hotsite and we should load it
        return YES;
    }
    
    NSString *encodedURL = [B2WKitUtils stringByAddingPercentEscapes:request.URL.absoluteString];
    NSDictionary *params = @{@"format": @"json", @"url": encodedURL};
    [[AFHTTPSessionManager manager] GET:@"http://b2w-mobile-api.herokuapp.com/parse/v2" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        
        if ([self isHotsite:response]) {
            NSDictionary *params = [self extractHotsiteParameters:response];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(offerWebBrowserViewController:didSelectHotsiteWithTags:productIds:title:)]) {
                [self.delegate offerWebBrowserViewController:self didSelectHotsiteWithTags:params[@"tags"] productIds:params[@"productIds"] title:params[@"title"]];
            }
        } else {
            // add a flag to avoid endless recursion, then load the request
            NSURLRequest *flaggedRequest = [self requestByAddingShouldLoadFlag:request];
            [webView loadRequest:flaggedRequest];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [IDMAlertViewManager showDefaultConnectionFailureAlert];
    }];
    
    return NO;
}

# pragma mark Private methods

- (BOOL)isHotsite:(NSDictionary *)response
{
    if ([response containsObjectForKey:@"contentType"]) {
        NSString *type = response[@"contentType"];
        return [type isEqualToString:@"TAGS"];
    } else {
        return NO;
    }
}

- (NSDictionary *)extractHotsiteParameters:(NSDictionary *)response
{
    NSArray *tags = @[];
    NSArray *productIds = @[];
    NSString *title = @"Promoção";
    
    NSString *contentType = [response objectForKey:@"contentType"];
    NSArray *contentValue = [response objectForKey:@"contentValues"];
    
    if (contentType && contentValue && [contentType isEqualToString:@"TAGS"]) {
        if (contentValue.count > 0) {
            tags = contentValue;
        }
        if ([response containsObjectForKey:@"featuredProductIdentifiers"]) {
            productIds = response[@"featuredProductIdentifiers"];
        }
        // TODO: title?
    }
    
    return @{@"tags": tags, @"productIds": productIds, @"title": title};
}

- (NSURLRequest *)requestByAddingShouldLoadFlag:(NSURLRequest *)request
{
    NSMutableURLRequest *flaggedRequest = [request mutableCopy];
    [flaggedRequest addValue:@"false" forHTTPHeaderField:@"x-b2w-hotsite-detected"];
    return flaggedRequest;
}

- (BOOL)shouldLoadFlagInRequest:(NSURLRequest *)request
{
    return [request.allHTTPHeaderFields containsObjectForKey:@"x-b2w-hotsite-detected"];
}

- (void)updateHeaderRemovalJavaScript
{
    NSString *URLString = @"";
	
    if ([[B2WKitUtils mainAppDisplayName] isEqualToString:@"Americanas"])
		URLString = @"http://iacom.s8.com.br/mktacom/mobile/assets/webview-3.js";
    else if ([[B2WKitUtils mainAppDisplayName] isEqualToString:@"Submarino"]) {
        URLString = @"http://isuba.s8.com.br/mktsuba/mobile/assets/webview-3.js";
    } else if ([[B2WKitUtils mainAppDisplayName] isEqualToString:@"Shoptime"]) {
        URLString = @"http://ishop.s8.com.br/mktshop/mobile/assets/webview-3.js";
    }

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"application/x-javascript"]];
    [manager GET:URLString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"JavaScript updated: %@", [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding]);
        self.headerRemovalJavaScript = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
