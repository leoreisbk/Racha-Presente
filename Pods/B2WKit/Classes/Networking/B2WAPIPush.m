//
//  B2WAPIPushTracking.m
//  B2WKit
//
//  Created by Thiago Peres on 25/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WAPIPush.h"

#import "SFHFKeychainUtils.h"
#import "NSURL+B2WKit.h"
#import "NSDictionary+B2WKit.h"
#import "B2WAPIAccount.h"
#import "NSData+B2WKit.h"

static NSString *const kB2WAPIPushDeviceTokenKey = @"kB2WAPIPushDeviceTokenKey";

typedef NS_ENUM(NSUInteger, B2WAPIPushTrackingAction) {
    B2WAPIPushTrackingActionLogin,
    B2WAPIPushTrackingActionUpdate,
    B2WAPIPushTrackingActionStatus,
    B2WAPIPushTrackingActionRegister
};

@implementation B2WAPIPush

+ (NSString*)deviceToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kB2WAPIPushDeviceTokenKey];
}

+ (void)setDeviceToken:(NSData*)deviceToken
{
    [[NSUserDefaults standardUserDefaults] setObject:[deviceToken deviceTokenString]
                                              forKey:kB2WAPIPushDeviceTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (AFHTTPRequestOperation*)enablePushWithTrackingEnabled:(BOOL)trackingEnabled
                                        marketingEnabled:(BOOL)marketingEnabled
                                                   block:(B2WAPICompletionBlock)block
{
    if (![B2WAPIAccount isLoggedIn])
    {
        if (block)
        {
            block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPILoginRequiredError
                                       userInfo:@{NSLocalizedDescriptionKey: @"You must be logged in to perform that request."}]);
        }
        return nil;
    }
    
    NSString *customerIdentifier = [B2WAPIAccount userIdentifier];
    if (customerIdentifier == nil)
    {
        if (block)
        {
            block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPIInvalidParameterError
                                       userInfo:@{NSLocalizedDescriptionKey : @"Could not obtain customer identifier from B2WAPIAuth"}]);
        }
        return nil;
    }
    
    
    if ([B2WAPIPush deviceToken] == nil)
    {
        if (block)
        {
            block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPIInvalidParameterError
                                       userInfo:@{NSLocalizedDescriptionKey: @"You need to call setDeviceToken: prior to calling this method."}]);
        }
        return nil;
    }
    
    return [self requestEloServiceForDevice:[B2WAPIPush deviceToken]
                              action:B2WAPIPushTrackingActionRegister
                         extraParams:@{@"customerID" : customerIdentifier,
                                       @"status" : @(trackingEnabled),
                                       @"statusmkt" : @(marketingEnabled)}
                               block:block];
}

+ (AFHTTPRequestOperation *)updateSettingsWithTrackingEnabled:(BOOL)trackingEnabled
                                             marketingEnabled:(BOOL)mailmktEnabled
                                                        block:(B2WAPICompletionBlock)block
{
    if (![B2WAPIAccount isLoggedIn])
    {
        if (block)
        {
            block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPILoginRequiredError
                                       userInfo:@{NSLocalizedDescriptionKey: @"You must be logged in to perform that request."}]);
        }
        return nil;
    }
    
    NSString *deviceToken = [B2WAPIPush deviceToken];
    if (deviceToken == nil || deviceToken.length == 0)
    {
        if (block)
        {
            block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPILoginRequiredError
                                       userInfo:@{NSLocalizedDescriptionKey: @"You must provide a device token."}]);
        }
        return nil;
    }

    return [B2WAPIPush requestEloServiceForDevice:deviceToken
                                                  action:B2WAPIPushTrackingActionUpdate
                                             extraParams:@{
                                                           @"status": @(trackingEnabled),
                                                           @"statusmkt": @(mailmktEnabled),
                                                           }
                                                   block:block];
}

+ (AFHTTPRequestOperation *):(B2WAPICompletionBlock)block
{
    if (![B2WAPIAccount isLoggedIn])
    {
        if (block)
        {
            block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                           code:B2WAPILoginRequiredError
                                       userInfo:@{NSLocalizedDescriptionKey: @"You must be logged in to perform that request."}]);
        }
        return nil;
    }
    
    NSString *deviceToken = [B2WAPIPush deviceToken];
    
    return [B2WAPIPush requestEloServiceForDevice:deviceToken
                                                  action:B2WAPIPushTrackingActionStatus
                                             extraParams:nil
                                                   block:block];
}

#pragma mark - Private Methods

+ (AFHTTPRequestOperation *)eloServiceRequestForDevice:(NSString*)deviceToken
                                                action:(enum B2WAPIPushTrackingAction)action
                                           extraParams:(NSDictionary*)params
{
    NSString *actionParam;
    
    switch (action) {
        case B2WAPIPushTrackingActionLogin:
            actionParam = @"agrees-up";
            break;
            
        case B2WAPIPushTrackingActionStatus:
            actionParam = @"json-alerts";
            break;
            
        case B2WAPIPushTrackingActionUpdate:
            actionParam = @"notify";
            break;
            
        case B2WAPIPushTrackingActionRegister:
            actionParam = @"agrees";
            break;
            
            
        default:
            break;
    }
    
    NSMutableDictionary *fullParams = [@{
                                         @"token": deviceToken,
                                         @"action": actionParam,
                                         @"bandeira": [B2WAPIClient brandCode],
                                         @"device": @"ios"
                                         } mutableCopy];
    if (params)
    {
        [fullParams addEntriesFromDictionary:params];
    }
    
    NSString *url = [NSURL URLStringWithSubdomain:@"o.mob" options:0 path:@"/push/index.php"];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:url
                                                                                parameters:fullParams
                                                                                     error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    operation.responseSerializer = responseSerializer;
    
    return operation;
}

+ (AFHTTPRequestOperation *)requestEloServiceForDevice:(NSString *)deviceToken
                                                action:(enum B2WAPIPushTrackingAction)action
                                           extraParams:(NSDictionary *)params
                                                 block:(B2WAPICompletionBlock)block
{
    AFHTTPRequestOperation *op = [self eloServiceRequestForDevice:deviceToken
                                                           action:action
                                                      extraParams:params];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (action == B2WAPIPushTrackingActionRegister && [operation.responseString isEqualToString:@"Token jÃ¡ consta na Base de Dados!"])
        {
            [B2WAPIPush updateSettingsWithTrackingEnabled:[params[@"status"] boolValue]
                                         marketingEnabled:[params[@"statusmkt"] boolValue]
                                                    block:block];
        }
        else if (block)
        {
            block(responseObject, nil);
        }
    } failure:[B2WAPIClient errorBlockWithBlock:block]];
    
    [[[B2WAPIClient sharedClient] operationQueue] addOperation:op];
    return op;
}

@end