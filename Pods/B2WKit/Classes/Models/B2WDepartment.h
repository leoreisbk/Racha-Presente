//
//  B2WDepartment.h
//  B2Wkit
//
//  Created by Thiago Peres on 09/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WObject.h"

@interface B2WDepartment : B2WObject

/// The department's name.
@property (nonatomic, readonly) NSString *name;

/// The department's catalog identifier.
@property (nonatomic, readonly) NSString *identifier;

/// The department's group number.
@property (nonatomic, readonly) NSString *group;

/// The department's tag number.
@property (nonatomic, readonly) NSString *tag;

/// The department's haveChildren boolean.
@property (nonatomic, readonly) BOOL haveChildren;

@end
