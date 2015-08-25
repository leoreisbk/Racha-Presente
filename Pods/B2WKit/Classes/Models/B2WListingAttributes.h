//
//  B2WListingAttributes.h
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 12/11/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

typedef NS_ENUM(NSUInteger, B2WListingAttributesType) {
    B2WListingAttributesTypeUnrecognized,
    B2WListingAttributesTypeSingleProduct,
    B2WListingAttributesTypeMultipleProducts,
    B2WListingAttributesTypeGroups,
    B2WListingAttributesTypeTags,
    B2WListingAttributesTypeDepartment,
    B2WListingAttributesTypeLine,
    B2WListingAttributesTypeSubline,
    B2WListingAttributesTypeURL
};

@interface B2WListingAttributes : B2WObject

@property (atomic, readonly) B2WListingAttributesType type;
@property (atomic, readonly) NSArray *content;
@property (atomic, readonly) NSDictionary *queryParameters;
@property (atomic, readonly) NSString *OPN;
@property (atomic, readonly) NSString *EPAR;
@property (atomic, readonly) NSString *menuIdentifier;
@property (atomic, readonly) NSString *headerIdentifier;
@property (atomic, readonly) NSArray *featuredProductIdentifiers;

@end
