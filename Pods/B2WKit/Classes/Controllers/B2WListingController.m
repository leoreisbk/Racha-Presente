//
//  B2WListingController.m
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 12/17/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WListingController.h"
#import "B2WOfferWebBrowserViewController.h"
#import "B2WProductPresenterProtocol.h"
#import "B2WCatalogListingViewController.h"

@interface B2WListingController ()

@property(atomic, readonly) NSDictionary *config;
@property(atomic, strong) void (^presentTagsOrGroups)(NSArray *, NSArray *);
@property(atomic, strong) void (^presentProduct)(B2WProduct *);
@property(atomic, strong) void (^presentProducts)(NSArray *productIdentifiers);
@property(atomic, strong) void (^presentHotsite)(NSArray *, NSArray *);
@property(atomic, strong) void (^presentDepartment)(NSString *identifier);
@property(atomic, strong) void (^presentLine)(NSString *identifier);
@property(atomic, strong) void (^presentSubline)(NSString *identifier);

@end

@implementation B2WListingController

- (id)initWithConfiguration:(NSDictionary *)config
{
    self = [super init];
    if (self) {
        _config = config;
    }
    return self;
}

- (void)setSingleProductPresentationBlock:(void (^)(B2WProduct *))presentProduct
{
    self.presentProduct = presentProduct;
}

- (void)setHotsitePresentationBlock:(void (^)(NSArray *, NSArray *))presentHotsite
{
    self.presentHotsite = presentHotsite;
}

- (void)setMultipleProductsPresentationBlock:(void (^)(NSArray *))presentProducts
{
    self.presentProducts = presentProducts;
}

- (void)setTagsOrGroupsPresentationBlock:(void (^)(NSArray *, NSArray *))presentTagsOrGroups
{
    self.presentTagsOrGroups = presentTagsOrGroups;
}

- (void)setDepartmentPresentationBlock:(void (^)(NSString *))presentDepartment
{
    self.presentDepartment = presentDepartment;
}

- (void)setLinePresentationBlock:(void (^)(NSString *))presentLine
{
    self.presentLine = presentLine;
}

- (void)setSublinePresentationBlock:(void (^)(NSString *))presentSubline
{
    self.presentSubline = presentSubline;
}

- (void)handlePresentationForAttributes:(B2WListingAttributes *)attrs
{
    UIViewController *viewController = [self requireConfig:@"viewController"];
    
    if ((attrs.type == B2WListingAttributesTypeTags || attrs.type == B2WListingAttributesTypeGroups) && (attrs.featuredProductIdentifiers == nil))
    {
        if (self.presentTagsOrGroups) {
            if (attrs.type == B2WListingAttributesTypeTags) {
                self.presentTagsOrGroups(attrs.content, nil);
            } else {
                self.presentTagsOrGroups(nil, attrs.content);
            }
        } else {
            UINavigationController *navigationController = [self requireConfig:@"navigationController"];
            B2WCatalogListingViewController *catalogListingViewController = [self requireConfig:@"catalogListingViewController"];
            if (attrs.type == B2WListingAttributesTypeTags) {
                catalogListingViewController.tags = attrs.content;
            } else {
                catalogListingViewController.groups = attrs.content;
            }
            [navigationController pushViewController:catalogListingViewController animated:YES];
        }
    }
    else if (attrs.type == B2WListingAttributesTypeTags && attrs.featuredProductIdentifiers)
    {
        if (self.presentHotsite) {
            self.presentHotsite(attrs.content, attrs.featuredProductIdentifiers);
        }
    }
    else if (attrs.type == B2WListingAttributesTypeURL)
    {
        if (attrs.content.count > 0) {
            NSString *URLString = attrs.content.firstObject;
            B2WOfferWebBrowserViewController *webVC = [B2WOfferWebBrowserViewController webBrowserWithInitialURLString:URLString];
            webVC.delegate = [self requireConfig:@"webBrowserDelegate"]; //(id<B2WOfferWebBrowserViewControllerDelegate>) viewController;
            UINavigationController *navWebVC = [[UINavigationController alloc] initWithRootViewController:webVC];
            [viewController presentViewController:navWebVC animated:YES completion:nil];
        }
    }
    else if (attrs.type == B2WListingAttributesTypeSingleProduct)
    {
        B2WProduct *product = [[B2WProduct alloc] initWithDictionary:@{@"_prodId": attrs.content.firstObject}];
        if (self.presentProduct) {
            self.presentProduct(product);
        }
    }
    else if (attrs.type == B2WListingAttributesTypeMultipleProducts)
    {
        if (self.presentProducts) {
            self.presentProducts(attrs.content);
        } else {
            UINavigationController *navigationController = [self requireConfig:@"navigationController"];
            B2WCatalogListingViewController *catalogListingViewController = [self requireConfig:@"catalogListingViewController"];
            catalogListingViewController.productIdentifiers = attrs.content;
            [navigationController pushViewController:catalogListingViewController animated:YES];
        }
    }
    else if (attrs.type == B2WListingAttributesTypeDepartment)
    {
        if (self.presentDepartment) { self.presentDepartment(attrs.content.firstObject); }
    }
    else if (attrs.type == B2WListingAttributesTypeLine)
    {
        if (self.presentLine) { self.presentLine(attrs.content.firstObject); }
    }
    else if (attrs.type == B2WListingAttributesTypeSubline)
    {
        if (self.presentSubline) { self.presentSubline(attrs.content.firstObject); }
    }
}

// throws exception if configuration is missing
- (id)requireConfig:(NSString *)key
{
    id object = [self.config objectForKey:key];
    
    if (object == nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Missing '%@' configuration key for B2WListingController", key] userInfo:@{@"providedConfig": self.config}];
    } else return object;
}

@end
