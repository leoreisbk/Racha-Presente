//
//  B2WCustomer.h
//  B2WKit
//
//  Created by Mobile on 7/22/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@class AFHTTPRequestOperation, B2WAddress, B2WCreditCard, B2WOneClickRelationship;

@protocol B2WCustomerProtocol <NSObject>
@required

- (AFHTTPRequestOperation *)updateWithBlock:(B2WAPICompletionBlock)block;
- (AFHTTPRequestOperation *)createWithAddress:(B2WAddress*)address block:(B2WAPICompletionBlock)block;

@end

@interface B2WCustomer : B2WObject <B2WCustomerProtocol>

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, strong) NSString *mainPhone;
@property (nonatomic, strong) NSString *secondaryPhone;
@property (nonatomic, strong) NSString *businessPhone;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSDictionary *optIn;
@property (nonatomic, assign) BOOL oneClickEnabled;

- (AFHTTPRequestOperation *)requestAddressesWithBlock:(B2WAPICompletionBlock)block;
- (AFHTTPRequestOperation *)requestAddress:(NSString *)identifier withBlock:(B2WAPICompletionBlock)block;
- (AFHTTPRequestOperation *)addAddress:(B2WAddress*)address block:(B2WAPICompletionBlock)block;

- (AFHTTPRequestOperation *)requestCreditCardsWithBlock:(B2WAPICompletionBlock)block;
- (AFHTTPRequestOperation *)requestCreditCard:(NSString *)identifier withBlock:(B2WAPICompletionBlock)block;
- (AFHTTPRequestOperation *)addCreditCard:(B2WCreditCard*)card block:(B2WAPICompletionBlock)block;
- (AFHTTPRequestOperation *)deleteCreditCard:(NSString *)identifier block:(B2WAPICompletionBlock)block;

- (AFHTTPRequestOperation *)requestOneClickRelationshipsWithBlock:(B2WAPICompletionBlock)block;
- (AFHTTPRequestOperation *)associateCreditCard:(NSDictionary *)params block:(B2WAPICompletionBlock)block;

@end
