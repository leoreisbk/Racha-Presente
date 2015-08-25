//
//  B2WSKUInformation.h
//  B2WKit
//
//  Created by Thiago Peres on 14/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@interface B2WSKUInformation : B2WObject

/// The SKU's name.
@property (nonatomic, readonly) NSString *name;

/// The SKU's catalog identifier.
@property (nonatomic, readonly) NSString *SKUIdentifier;

/// A string containing the SKU's primary color. (OBS: only for fashion products).
@property (nonatomic, readonly) NSString *primaryColorString;

/// A string containing the SKU's secondary color. (OBS: only for fashion products)
@property (nonatomic, readonly) NSString *secondaryColorString;

/// A string containing the SKU's size. (OBS: only for fashion products)
@property (nonatomic, readonly) NSString *sizeString;

/// The SKU's image URL.
@property (nonatomic, readonly) NSURL *imageURL;

#pragma mark - Methods

/**
 *  Whether or not the SKU must be displayed to the end user.
 *
 *  Necessary because the API gives SKUs with unnecessary info.
 */
- (BOOL)isVisible;

@end
