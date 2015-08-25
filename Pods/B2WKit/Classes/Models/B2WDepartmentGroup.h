//
//  B2WDepartmentGroup.h
//  B2WKit
//
//  Created by Thiago Peres on 18/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@interface B2WDepartmentGroup : B2WObject

/// The department group's name.
@property (nonatomic, readonly) NSString *name;

/// An array containing B2WDepartment objects.
@property (nonatomic, readonly) NSArray *departments;

@end
