//
//  B2WObject.h
//  B2WKit
//
//  Created by Thiago Peres on 10/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "NSDictionary+B2WKit.h"

#pragma mark - Protocols

/**
 *  Every model that inherits from B2WObject must conform to this protocol, given that they all
 *  must be able to initialize objects from given NSArrays.
 */
@protocol B2WObjectSerializing <NSObject>
@required

/**
 *  Initializes the B2WObject with the given NSDictionary.
 *
 *  @param dictionary A NSDictionary built from a JSON object used to populate the B2WObject.
 *
 *  @return An initialized B2WObject.
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

@optional

- (NSDictionary*)dictionaryValue;

@end

#pragma mark - Interfaces


/**
 *  This abstract class implements shared methods among any objects in the framework.
 */
@interface B2WObject : MTLModel <B2WObjectSerializing>

/**
 *  Initializes the object with an NSArray containing NSDictionaries.
 *
 *  For all objects in the array the method `initWithDictionary:` will be called passing the current dictionary object.
 *
 *  @param array An NSArray of NSDictionaries.
 *
 *  @return An NSArray containing initializes B2WObject objects.
 */
+ (NSArray *)objectsWithDictionaryArray:(NSArray *)array;

@end
