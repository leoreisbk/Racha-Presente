//
//  B2WExtendedWarranty.h
//  B2WKit
//
//  Created by Mobile on 7/16/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@interface B2WExtendedWarranty : B2WObject

@property (nonatomic, readonly) NSString *identifier;

@property (nonatomic, readonly) NSUInteger years;

@property (nonatomic, readonly) NSString *installment;

@end
