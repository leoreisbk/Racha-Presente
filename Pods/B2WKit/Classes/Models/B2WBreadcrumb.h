//
//  B2WBreadcrumb.h
//  B2WKit
//
//  Created by rodrigo.fontes on 08/01/15.
//  Copyright (c) 2015 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WObject.h"

@interface B2WBreadcrumb : B2WObject

@property (nonatomic, readonly) NSString *label;

@property (nonatomic, readonly) NSString *link;

@end