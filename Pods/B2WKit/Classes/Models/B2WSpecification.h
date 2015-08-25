//
//  B2WSpecification.h
//  B2Wkit
//
//  Created by Thiago Peres on 09/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WObject.h"

@interface B2WSpecification : B2WObject

/// The specification's title.
@property (nonatomic, readonly) NSString *title;

/// The specification's items.
@property (nonatomic, readonly) NSDictionary *items;

@end