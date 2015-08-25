//
//  B2WMarketplacePartner.h
//  B2WKit
//
//  Created by Flávio Caetano on 7/31/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@interface B2WMarketplacePartner : B2WObject

@property (nonatomic, readonly) NSString *name;

@property (nonatomic, readonly) NSString *CNPJ;

@property (nonatomic, readonly) NSString *aboutStore;

@property (nonatomic, readonly) NSString *deliveryPolicy;

@property (nonatomic, readonly) NSString *returnPolicy;

@property (nonatomic, readonly) NSString *address;

@property (nonatomic, readonly) NSURL *logoURL;

@end
