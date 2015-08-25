//
//  B2WCheckoutFreightScheduledDelivery.h
//  B2WKit
//
//  Created by rodrigo.fontes on 30/03/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "B2WObject.h"

@interface B2WCheckoutFreightScheduledDelivery : B2WObject

@property (nonatomic, readonly) NSString *date;
@property (nonatomic, readonly) NSString *shift;

- (instancetype)initWithCheckoutFreightScheduledDeliveryDictionary:(NSDictionary*)dictionary;

- (NSDictionary *)dictionaryValue;

@end