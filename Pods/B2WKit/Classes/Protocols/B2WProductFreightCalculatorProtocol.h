//
//  B2WProductFreightCalculatorProtocol.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WFreightCalculationProduct.h"

@protocol B2WProductFreightCalculatorProtocol <NSObject>
@optional

- (void)didLoadEstimateWithFreightResult:(B2WFreightCalculationProduct *)freightResult;
- (void)didLoadEstimateWithFreightResultDictionary:(NSDictionary *)freightResultDictionary;
- (void)resetMarketplaceFreightCalculation;
- (void)resetMarketplaceFreightList;
- (void)removeResultView;
- (void)removeNumberPad;
- (void)beginCalculateFreight;
- (void)endCalculateFreight;
- (void)reloadFreight;

@end
