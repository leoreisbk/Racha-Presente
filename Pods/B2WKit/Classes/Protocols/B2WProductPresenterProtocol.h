//
//  B2WProductPresenterProtocol.h
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 12/17/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WProduct.h"

@protocol B2WProductPresenterProtocol <NSObject>

- (void)presentProduct:(B2WProduct *)product withReferenceViewController:(UIViewController *)referenceViewController;

@end
