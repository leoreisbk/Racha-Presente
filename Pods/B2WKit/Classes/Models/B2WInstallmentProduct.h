//
//  B2WInstallmentProduct.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/03/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@interface B2WInstallmentProduct : B2WObject

@property (nonatomic, readonly) NSString *itemId;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *storeId;

//
// Init used for products retrieved from the API
//
- (instancetype)initWithInstallmentProductDictionary:(NSDictionary*)dictionary;

//
// Init used for new products to add to a cart
//
- (instancetype)initWithItemId:(NSString *)itemId storeId:(NSString *)storeId;

- (NSDictionary *)dictionaryValue;

@end
