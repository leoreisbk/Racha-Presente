//
//  B2WProductMarketplacePartner.h
//  B2WKit
//
//  Created by Mobile on 7/16/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@interface B2WProductMarketplacePartner : B2WObject

/**
 *  The partner's seller identifier.
 */
@property (nonatomic, readonly) NSString *identifier;

/**
 *  The partner's name.
 */
@property (nonatomic, readonly) NSString *name;

/**
 *  A formatted string containing the partner's price for the product.
 */
@property (nonatomic, readonly) NSString *price;

/**
 *  An array of installment options.
 */
@property (nonatomic, readonly) NSArray *installments;

/**
 *  A boolean indicating whether this partner offers store pickup for the product.
 */
@property (nonatomic, readonly) BOOL hasStorePickup;

- (instancetype)initWithIdentifier:(NSString *)identifier
                    hasStorePickup:(NSString *)hasPickupStore
                              name:(NSString *)partnerName
                        salesPrice:(NSString *)salesPrice
                       installment:(NSString *)installment;

@end
