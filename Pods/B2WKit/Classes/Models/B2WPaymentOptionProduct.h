//
//  B2WPaymentOptionProduct.h
//  B2WKit
//
//  Created by rodrigo.fontes on 31/03/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//


#import "B2WObject.h"

@interface B2WPaymentOptionProduct : B2WObject

@property (nonatomic, readonly) NSString *sku;
@property (nonatomic, readonly) NSString *salesPrice;

- (instancetype)initWithPaymentOptionProductDictionary:(NSDictionary*)dictionary;

- (NSDictionary *)dictionaryValue;

@end