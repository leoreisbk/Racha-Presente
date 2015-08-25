//
//  B2WProductSelectorProtocol.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "B2WProduct.h"

@protocol B2WProductSelectorProtocol <NSObject>

- (void)didSelectProduct:(B2WProduct*)product sender:(id)sender;

@end
