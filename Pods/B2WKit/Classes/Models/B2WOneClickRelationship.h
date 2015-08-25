//
//  B2WOneClickRelation.h
//  B2WKit
//
//  Created by Thiago Peres on 7/22/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@interface B2WOneClickRelationship : B2WObject

@property (nonatomic, readonly) NSString *identifier;

@property (nonatomic, assign) BOOL main;

@property (nonatomic, assign) BOOL active;

@property (nonatomic, strong) NSString *addressIdentifier;

@property (nonatomic, strong) NSString *creditCardIdentifier;

@end
