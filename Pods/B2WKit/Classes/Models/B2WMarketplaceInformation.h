//
//  B2WMarketplaceInformation.h
//  B2WKit
//
//  Created by Mobile on 7/16/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@interface B2WMarketplaceInformation : B2WObject

@property (nonatomic, readonly) NSString *smallestPriceOfAllPartners;
@property (nonatomic, readonly) BOOL isMarketplaceExclusive;
@property (nonatomic, readonly) BOOL hasPartnersWithStock;
@property (nonatomic, readonly) NSArray *partners;
@property (nonatomic, readonly) NSArray *sellerIdentifiers;

@end
