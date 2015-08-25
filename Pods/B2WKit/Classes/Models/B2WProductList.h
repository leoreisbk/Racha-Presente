//
//  B2WProductList.h
//  B2WKit
//
//  Created by Flávio Caetano on 12/20/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@class B2WProduct;

/**
 *  A product list with title.
 */
@interface B2WProductList : B2WObject

/**
 *  The list's name.
 *
 *  For product lists parsed from recommendation dictionaries,
 *  name will be an empty string.
 */
@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *titlePrefix;
@property (nonatomic, strong) NSString *titleHint;

@property (nonatomic, strong) NSString *mainProductTitle;
@property (nonatomic, strong) B2WProduct *mainProduct;

/**
 *  The list's identifier. For product lists parsed from
 *  catalog dictionaries, the identifier will be equal to
 *  it's title.
 *
 *  For product lists parsed from recommendation dictionaries,
 *  the identifier will be the same as neemu's internal identifier.
 */
@property (nonatomic, strong) NSString *identifier;

/**
 *  The list's items. Each object is a B2WProduct object.
 */
@property (nonatomic, strong) NSArray *items;

@end
