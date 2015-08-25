//
//  B2WBVDelegateWrapper.m
//  B2WKit
//
//  Created by Thiago Peres on 09/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WBVDelegateWrapper.h"
#import <objc/runtime.h>

@implementation B2WBVDelegateWrapper

static void * kDelegateKey = "kB2WDelegateKey";

+ (id)wrapperWithCompletionBlock:(B2WAPICompletionBlock)completionBlock
{
    B2WBVDelegateWrapper *wrapper = [[B2WBVDelegateWrapper alloc] init];
    [wrapper setCompletionBlock:completionBlock];
    return wrapper;
}

- (void)didReceiveResponse:(NSDictionary *)response forRequest:(id)request
{
    NSLog(@"%@", [request requestURL]);
    if (self.completionBlock)
    {
        self.completionBlock(response, nil);
    }
    objc_setAssociatedObject(request, kDelegateKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)didFailToReceiveResponse:(NSError *)err forRequest:(id)request
{
    if (self.completionBlock)
    {
        self.completionBlock(nil, err);
    }
    objc_setAssociatedObject(request, kDelegateKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
