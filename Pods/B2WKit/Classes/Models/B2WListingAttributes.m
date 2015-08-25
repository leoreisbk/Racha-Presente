//
//  B2WListingAttributes.m
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 12/11/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WListingAttributes.h"

@implementation B2WListingAttributes

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
        for (NSString *key in @[@"contentType", @"contentValues"]) {
            if ( ! [dictionary containsObjectForKey:key]) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException
                                               reason:[NSString stringWithFormat:@"Missing key '%@' in B2WListingAttribute dictionary", key] userInfo:dictionary];
            }
        }
        
        _content = dictionary[@"contentValues"];
        
        if ([dictionary[@"contentType"] isEqualToString:@"GROUPS"])
        {
            _type = B2WListingAttributesTypeGroups;
        }
        else if ([dictionary[@"contentType"] isEqualToString:@"TAGS"])
        {
            _type = B2WListingAttributesTypeTags;
        }
        else if ([dictionary[@"contentType"] isEqualToString:@"PRODUCTIDS"])
        {
            if (self.content.count > 1) {
                _type = B2WListingAttributesTypeMultipleProducts;
            } else {
                _type = B2WListingAttributesTypeSingleProduct;
            }
        }
        else if ([dictionary[@"contentType"] isEqualToString:@"URL"])
        {
            _type = B2WListingAttributesTypeURL;
        }
        else if ([dictionary[@"contentType"] isEqualToString:@"DEPARTMENT"])
        {
            _type = B2WListingAttributesTypeDepartment;
        }
        else if ([dictionary[@"contentType"] isEqualToString:@"LINE"])
        {
            _type = B2WListingAttributesTypeLine;
        }
        else if ([dictionary[@"contentType"] isEqualToString:@"SUBLINE"])
        {
            _type = B2WListingAttributesTypeSubline;
        }
        else
        {
            _type = B2WListingAttributesTypeUnrecognized;
        }
        
        _queryParameters = [dictionary objectForKey:@"extractedQueryParameters"];
        _OPN = [dictionary objectForKey:@"opn"];
        _EPAR = [dictionary objectForKey:@"epar"];
        _menuIdentifier = [dictionary objectForKey:@"menuIdentifier"];
        _headerIdentifier = [dictionary objectForKey:@"headerIdentifier"];
        _featuredProductIdentifiers = [dictionary objectForKey:@"featuredProductIdentifiers"];
    }
    return self;
}

- (NSString *)description
{
    NSString *type;
    if (_type == B2WListingAttributesTypeGroups) { type = @"groups"; }
    else if (_type == B2WListingAttributesTypeTags) { type = @"tags"; }
    else if (_type == B2WListingAttributesTypeSingleProduct) { type = @"single product"; }
    else if (_type == B2WListingAttributesTypeMultipleProducts) { type = @"multiple products"; }
    else if (_type == B2WListingAttributesTypeURL) { type = @"url"; }
    else if (_type == B2WListingAttributesTypeDepartment) { type = @"department"; }
    else if (_type == B2WListingAttributesTypeLine) { type = @"line"; }
    else if (_type == B2WListingAttributesTypeSubline) { type = @"subline"; }
    else { type = @"unrecognized"; }
    type = [NSString stringWithFormat:@"type: %@", type];
    
    NSString *menu = [NSString stringWithFormat:@"menu: %@", _menuIdentifier];
    NSString *header = [NSString stringWithFormat:@"header: %@", _headerIdentifier];
    NSString *featured = [NSString stringWithFormat:@"featured: %@", _featuredProductIdentifiers];
    NSString *content = [NSString stringWithFormat:@"content: %@", self.content];
    NSString *opn = [NSString stringWithFormat:@"opn: %@", self.OPN];
    NSString *epar = [NSString stringWithFormat:@"epar: %@", self.EPAR];
    NSString *query = [NSString stringWithFormat:@"query: %@", self.queryParameters];
    
    return [NSString stringWithFormat:@"{%@}", [@[type, content, menu, header, featured, opn, epar, query] componentsJoinedByString:@", "]];
}

@end
