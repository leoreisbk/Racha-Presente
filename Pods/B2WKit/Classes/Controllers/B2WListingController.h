//
//  B2WListingController.h
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 12/17/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WListingAttributes.h"
#import "B2WProduct.h"

@interface B2WListingController : NSObject

- (id)initWithConfiguration:(NSDictionary *)config;
- (void)setTagsOrGroupsPresentationBlock:(void (^)(NSArray *tags, NSArray *groups))presentTagsOrGroups;
- (void)setSingleProductPresentationBlock:(void (^)(B2WProduct *))presentProduct;
- (void)setMultipleProductsPresentationBlock:(void (^)(NSArray *productIdentifiers))presentProducts;
- (void)setHotsitePresentationBlock:(void (^)(NSArray *tags, NSArray *featuredProductIdentifiers))presentHotsite;
- (void)setDepartmentPresentationBlock:(void (^)(NSString *))presentDepartment;
- (void)setLinePresentationBlock:(void (^)(NSString *))presentLine;
- (void)setSublinePresentationBlock:(void (^)(NSString *))presentSubline;
- (void)handlePresentationForAttributes:(B2WListingAttributes *)attributes;

@end
