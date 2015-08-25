//
//  B2WFreightCalculationResult.h
//  B2WKit
//
//  Created by Thiago Peres on 27/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

/**
 *  Result codes for the freight calculation result.
 */
typedef NS_ENUM(NSUInteger, B2WAPIFreightCalculationResultType) {
    /**
     *  Freight calculus occurred successfully.
     */
    B2WAPIFreightCalculationResultOK,
    /**
     *  The given postal code does not exist.
     */
    B2WAPIFreightCalculationResultInexistingPostalCode,
    /**
     *  The product has restrictions concerning its delivery.
     */
    B2WAPIFreightCalculationResultRestrictedDelivery,
    /**
     *  The postal code is blocked to deliveries.
     */
    B2WAPIFreightCalculationResultBlockedDelivery,
    /** TODO: review
     *  Partial delivery for the order.
     */
    B2WAPIFreightCalculationResultPartial,
    /**
     *  An unexpected error occurred when calculating the freight price.
     */
    B2WAPIFreightCalculationResultGenericError,
    /**
     *  There's no stock for the given product.
     */
    B2WAPIFreightCalculationResultNoStock,
};

@interface B2WFreightCalculationResult : B2WObject

@property (nonatomic, readonly) B2WAPIFreightCalculationResultType resultType;

@property (nonatomic, readonly) NSString *postalCode;

@property (nonatomic, readonly) NSString *deliveryAt;

@property (nonatomic, readonly) NSString *contract;

@property (nonatomic, readonly) BOOL isDefault;

@property (nonatomic, readonly) NSString *totalWeekdays;

@property (nonatomic, readonly) NSNumber *totalFreightPrice;

// Usado na tela de um produto
@property (nonatomic, readonly) NSMutableDictionary *productResults;

// Usando no cart
@property (nonatomic, readonly) NSMutableArray *productCartResults;

- (instancetype)initWithDictionary:(NSDictionary *)dict postalCode:(NSString *)postalCode;

- (instancetype)initWithResultMessage:(NSString *)resultMessage productParamsArray:(NSArray *)productParamsArray;

@end