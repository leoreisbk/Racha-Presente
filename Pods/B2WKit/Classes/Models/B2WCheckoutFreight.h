//
//  B2WFreight.h
//  B2WKit
//
//  Created by rodrigo.fontes on 30/03/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WObject.h"
#import "B2WCheckoutFreightScheduledDelivery.h"

@interface B2WCheckoutFreight : B2WObject

@property (nonatomic, readonly) NSString *contract;
@property (nonatomic, readonly) NSString *voucher;
@property (nonatomic, readonly) NSString *purchaseReason;
@property (nonatomic, readonly) B2WCheckoutFreightScheduledDelivery *scheduledDelivery;

- (instancetype)initWithCheckoutFreightDictionary:(NSDictionary*)dictionary;

- (NSDictionary *)dictionaryValue;

@end