//
//  B2WAddress.h
//  B2WKit
//
//  Created by Mobile on 7/22/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

#import "B2WAPICustomer.h"

typedef NS_ENUM(NSInteger, B2WAddressType) {
    B2WAddressTypePersonal,
    B2WAddressTypeStore,
    B2WAddressTypeHeadOffice,
    B2WAddressTypeWeddingList,
    B2WAddressTypeGift
};

@interface B2WAddress : B2WObject

@property (nonatomic, readonly) NSString *identifier;

@property (nonatomic, strong) NSString *recipientName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *additionalInfo;
@property (nonatomic, strong) NSString *neighborhood;
@property (nonatomic, strong) NSString *reference;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *postalCode;

@property (nonatomic, assign) BOOL main;
@property (nonatomic, assign) B2WAddressType addressType;
@property (nonatomic, readonly) BOOL active;
@property (nonatomic, readonly) BOOL blockedDelivery;
@property (nonatomic, readonly) NSArray *warnings;

- (AFHTTPRequestOperation *)addNewWithBlock:(B2WAPICompletionBlock)block;
- (AFHTTPRequestOperation *)updateWithBlock:(B2WAPICompletionBlock)block;
- (AFHTTPRequestOperation *)removeWithBlock:(B2WAPICompletionBlock)block;
- (AFHTTPRequestOperation *)setAsMainWithBlock:(B2WAPICompletionBlock)block;

@end
