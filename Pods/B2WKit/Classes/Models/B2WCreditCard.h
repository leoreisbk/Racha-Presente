//
//  B2WCreditCard.h
//  B2WKit
//
//  Created by Mobile on 7/22/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

#import "B2WAPICustomer.h"

@interface B2WCreditCard : B2WObject

@property (nonatomic, readonly) NSString *identifier;

@property (nonatomic, strong) NSString *number;

@property (nonatomic, strong) NSString *criptoNumber;

@property (nonatomic, strong) NSString *verificationCode;

@property (nonatomic, strong) NSString *brand;

//@property (nonatomic, assign) BOOL isB2WCard;

@property (nonatomic, strong) NSString *holderName;

@property (nonatomic, assign) NSUInteger expirationYear;

@property (nonatomic, assign) NSUInteger expirationMonth;

- (AFHTTPRequestOperation *)addNewWithBlock:(B2WAPICompletionBlock)block;
- (AFHTTPRequestOperation *)updateWithBlock:(B2WAPICompletionBlock)block;
- (AFHTTPRequestOperation *)removeWithBlock:(B2WAPICompletionBlock)block;

@end
