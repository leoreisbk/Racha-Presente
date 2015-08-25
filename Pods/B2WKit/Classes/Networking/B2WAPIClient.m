//
//  B2WAPIClient.m
//  B2Wkit
//
//  Created by Thiago Peres on 09/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WAPIClient.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import "AFXMLDictionaryResponseSerializer.h"
#import "NSURL+B2WKit.h"
#import "B2WCatalogURLProtocol.h"

NSString *const B2WAPIErrorDomain = @"B2WAPIErrorDomain";

@interface B2WAPIClient ()

@property (nonatomic, strong) NSString *OPNString;
@property (nonatomic, strong) NSString *EPARString;
@property (nonatomic, strong) NSString *FRANQString;
@property (nonatomic, strong) NSString *referrerURLString;

@end

@implementation B2WAPIClient

NSString *_baseURLString;
NSString *_brandCode;
NSString *_apiKey;

+ (void)setOPNString:(NSString*)opnString
{
    [[B2WAPIClient sharedClient] setOPNString:opnString];
    [NSURLProtocol registerClass:[B2WCatalogURLProtocol class]];
}

+ (void)setEPARString:(NSString*)eparString
{
    [[B2WAPIClient sharedClient] setEPARString:eparString];
    [NSURLProtocol registerClass:[B2WCatalogURLProtocol class]];
}

+ (void)setFRANQString:(NSString *)franqString
{
    [[B2WAPIClient sharedClient] setFRANQString:franqString];
}

+ (void)setReferrerURLString:(NSString *)referrerURLString
{
    [[B2WAPIClient sharedClient] setReferrerURLString:referrerURLString];
}

+ (NSString*)OPNString
{
    return [[B2WAPIClient sharedClient] OPNString];
}

+ (NSString*)EPARString
{
    return [[B2WAPIClient sharedClient] EPARString];
}

+ (NSString *)FRANQString
{
    return [[B2WAPIClient sharedClient] FRANQString];
}

+ (NSString *)referrerURLString
{
    return [[B2WAPIClient sharedClient] referrerURLString];
}

+ (NSString*)apiKey
{
    return _apiKey;
}

+ (NSString*)baseURLString
{
    return _baseURLString;
}

+ (NSString *)brandCode
{
    return [_brandCode uppercaseString];
}

+ (void)setBaseURLString:(NSString*)baseURLString brandCode:(NSString *)brandCode apiKey:(NSString*)apiKey
{
    _baseURLString = baseURLString;
    _brandCode = brandCode;
    _apiKey = apiKey;
}

+ (void (^)(AFHTTPRequestOperation *op, id responseObject))completionBlockWithBlock:(B2WAPICompletionBlock)block
{
    return ^(AFHTTPRequestOperation *operation, id responseObject) {
        if (block)
        {
            block(responseObject, nil);
        }
    };
}

+ (void (^)(AFHTTPRequestOperation *op, NSError *error))errorBlockWithBlock:(B2WAPICompletionBlock)block
{
    return ^(AFHTTPRequestOperation *op, NSError *error) {
        if (block)
        {
            block(nil, error);
        }
    };
}

+ (void (^)(AFHTTPRequestOperation *op, NSError *err))defaultAPIFailureBlockWithBlock:(B2WAPICompletionBlock)block
{
    return ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block == nil) return;
        //
        // Checks if the API returned an error message
        //
        if (error && ![error.domain isEqualToString:NSURLErrorDomain])
        {
            NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *e;
            id response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
            
            if (e) {
               block(nil, error);
            } else if (response) {
                block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
                                               code:B2WAPIServiceError
                                           userInfo:@{NSLocalizedDescriptionKey : response}]);
            }
        } else {
            block(nil, error);
        }
    };
}

+ (instancetype)sharedClient
{
    static B2WAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((_baseURLString == nil) || (_baseURLString.length == 0))
        {
            [NSException raise:NSInvalidArgumentException
                        format:@"Base URL string is not set. You must call %@ before making any requests.", NSStringFromSelector(@selector(setBaseURLString:brandCode:apiKey:))];
        }
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        _sharedClient = [[B2WAPIClient alloc] initWithBaseURL:[NSURL URLWithString:_baseURLString]];
        _sharedClient.responseSerializer = [AFXMLDictionaryResponseSerializer serializer];
        _sharedClient.referrerURLString = nil;
#if defined(DEBUG) && defined(TARGET_IPHONE_SIMULATOR)
        [[_sharedClient operationQueue] addObserver:_sharedClient
                                         forKeyPath:@"operations"
                                            options:NSKeyValueObservingOptionNew
                                            context:NULL];
#endif
    });
    
    return _sharedClient;
}

#if defined(DEBUG) && defined(TARGET_IPHONE_SIMULATOR)
- (void)observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if (object == self.operationQueue && [keyPath isEqualToString:@"operations"])
    {
        //NSLog(@"%@", change);
        for (AFHTTPRequestOperation *op in change[@"new"])
        {
            if ([op isKindOfClass:[AFHTTPRequestOperation class]] && [op isReady])
            {
                printf("\n%s - %s\n", [op.request.HTTPMethod cStringUsingEncoding:NSUTF8StringEncoding],
                       [op.request.URL.absoluteString cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}
#endif

@end
