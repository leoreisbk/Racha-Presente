//
//  B2WVoucher.h
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 5/18/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@interface B2WVoucher : B2WObject

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSNumber *totalAmount;
@property (nonatomic, readonly) NSNumber *usedAmount;

@end
