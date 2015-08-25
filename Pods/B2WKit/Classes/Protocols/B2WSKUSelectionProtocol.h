//
//  B2WSKUSelectionProtocol.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WSKUInformation.h"

@protocol B2WSKUSelectionProtocol <NSObject>

@optional
- (void)didSelectSKU:(B2WSKUInformation*)sku;
- (void)didSelectColorWithSKUIdentifier:(NSString *)SKUIdentifier;
- (void)didSelectSizeWithDescription:(NSString *)sizeDescription;
- (void)showNilSKUMessage;

@end