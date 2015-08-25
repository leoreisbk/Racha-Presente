//
//  B2WPaymentOption.h
//  B2WKit
//
//  Created by Mobile on 7/17/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@interface B2WPaymentOption : B2WObject

@property (nonatomic, readonly) NSString *identifier;

@property (nonatomic, readonly) NSString *type;

@property (nonatomic, readonly) NSString *name;

@property (nonatomic, readonly) NSUInteger points;

@property (nonatomic, readonly) NSArray *installments;

- (instancetype)initWithPaymentOptionDictionary:(NSDictionary *)dictionary;

@end
