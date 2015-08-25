//
//  B2WImage.h
//  B2Wkit
//
//  Created by Thiago Peres on 09/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WObject.h"

@interface B2WImage : B2WObject

/// The image's URL.
@property (nonatomic, readonly) NSURL *url;

/// The image's SKU identifier, if any.
@property (nonatomic, readonly) NSString *SKUIdentifier;

@end
