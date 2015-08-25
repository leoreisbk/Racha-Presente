//
//  B2WDailyOffer.h
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 12/11/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"
#import "B2WProduct.h"
#import "B2WListingAttributes.h"

@interface B2WDailyOffer : B2WObject

@property (atomic, readonly) B2WListingAttributes *listingAttributes;
@property (atomic, readonly) NSURL *URL;
@property (atomic, readonly) NSString *productIdentifier;
@property (atomic, strong) B2WProduct *product;

@end
