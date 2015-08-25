//
//  B2WCartCustomer.h
//  B2WKit
//
//  Created by rodrigo.fontes on 31/03/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WObject.h"

@interface B2WCartCustomer : B2WObject

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *token;
@property (nonatomic, readonly) BOOL guest;

- (instancetype)initWithIdentifier:(NSString *)identifier
							 token:(NSString *)token;
//							 guest:(BOOL) isGuest;

- (instancetype)initWithCartCustomerDictionary:(NSDictionary*)dictionary;

- (NSDictionary *)dictionaryValue;

+ (NSDictionary *)emptyDictionaryValue;

@end
