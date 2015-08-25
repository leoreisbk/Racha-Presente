//
//  B2WDeeplink.h
//  B2WKit
//
//  Created by rodrigo.fontes on 23/02/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import "B2WOffer.h"

@interface B2WDeeplink : B2WObject

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) B2WOffer *offer;

- (id)initWithDictionary:(NSDictionary *)dictionary type:(NSString *)type;

@end