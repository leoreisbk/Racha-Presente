//
//  B2WCheckout.h
//  B2WKit
//
//  Created by rodrigo.fontes on 30/03/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "B2WObject.h"
#import "B2WCheckoutFreight.h"

@interface B2WCheckout : B2WObject

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *cartId;
@property (nonatomic, readonly) NSString *billingAddressId;
@property (nonatomic, readonly) NSString *deliveryAddressId;
@property (nonatomic, readonly) NSString *purchaseReason;
@property (nonatomic, readonly) B2WCheckoutFreight *freight;

@property (nonatomic, readonly) NSArray *vouchers;

@property (nonatomic, readonly) NSNumber *total;
@property (nonatomic, readonly) NSNumber *amountDue;

/*- (instancetype)initWithBillingAddressId:(NSDictionary*)billingAddressId
					   deliveryAddressId:(NSDictionary*)deliveryAddressId
						  purchaseReason:(NSDictionary*)purchaseReason
								 freight:(B2WCheckoutFreight *)freight;*/

- (instancetype)initWithCheckoutDictionary:(NSDictionary*)dictionary;

- (NSDictionary *)dictionaryValue;

+ (void)createNewCheckoutWithBlock:(B2WAPICompletionBlock)block;

@end
