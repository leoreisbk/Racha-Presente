//
//  B2WCrossSellItem.h
//  B2WKit
//
//  Created by Thiago Peres on 16/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WProduct.h"

@interface B2WCrossSellItem : B2WProduct

/// The cross sell item's SKU identifier
@property (nonatomic, readonly) NSString *skuIdentifier;

@end
