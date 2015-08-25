//
//  B2WFreightCalculationProduct.h
//  B2WKit
//
//  Created by rodrigo.fontes on 18/03/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"
#import "B2WFreightCalculationResult.h"

@interface B2WFreightCalculationProduct : B2WObject

@property (nonatomic, readonly) B2WAPIFreightCalculationResultType resultType;

/// A formatted string containing the store identifier.
@property (nonatomic, readonly) NSString *storeId;

/// A formatted string containing the sku identifier.
@property (nonatomic, readonly) NSString *sku;

@property (nonatomic, readonly) BOOL repackaged;

/// The number of days till delivery.
@property (nonatomic, readonly) NSUInteger days;

/// A formatted string containing the days till delivery.
@property (nonatomic, readonly) NSString *daysString;

/// A formatted string containing the freight price.
@property (nonatomic, readonly) NSString *priceString;

@property (nonatomic, readonly) NSString *decision;

@property (nonatomic, readonly) NSString *warningKey;

@property (nonatomic, readonly) NSString *warningQuantity;

- (instancetype)initWithDictionary:(NSDictionary *)dict resultType:(B2WAPIFreightCalculationResultType)resultType;

- (instancetype)initWithStoreId:(NSString *)storeId resultType:(B2WAPIFreightCalculationResultType)resultType;

@end
