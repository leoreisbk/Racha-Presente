//
//  B2WOffer.h
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 11/6/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WObject.h"
#import "B2WListingAttributes.h"

@interface B2WOffer : B2WObject

@property (nonatomic, readonly) NSString *shortDescription;
@property (nonatomic, readonly) B2WListingAttributes *listingAttributes;

@end
