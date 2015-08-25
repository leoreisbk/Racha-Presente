//
//  B2WProductOffer.h
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 1/13/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WOffer.h"
#import "B2WProduct.h"

@interface B2WProductOffer : B2WOffer

@property (nonatomic, readonly) NSString *productIdentifier;
@property (nonatomic, strong) B2WProduct *product;

@end
