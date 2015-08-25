//
//  B2WBVDelegateWrapper.h
//  B2WKit
//
//  Created by Thiago Peres on 09/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BVSDK/BVSDK.h>
#import "B2WAPIClient.h"

/**
 *  B2WBVDelegateWrapper adds block support to BazaarVoice SDK 2.1.6
 */
@interface B2WBVDelegateWrapper : NSObject <BVDelegate>

@property (nonatomic, strong) B2WAPICompletionBlock completionBlock;

+ (id)wrapperWithCompletionBlock:(B2WAPICompletionBlock)completionBlock;

@end
