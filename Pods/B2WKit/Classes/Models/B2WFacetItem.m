//
//  B2WFacetItem.m
//  B2WKit
//
//  Created by Thiago Peres on 14/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WFacetItem.h"

// Models
#import "B2WFacet.h"
#import "NSDictionary+QueryString.h"

@implementation B2WFacetItem

+ (NSNumberFormatter*)numberFormatter
{
    static NSNumberFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"pt-BR"];
    });
    
    return formatter;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        if ([dictionary containsObjectForKey:@"title"])
        {
            _title = dictionary[@"title"];
        }
        else
        {
            if ([dictionary[@"unit"] isEqualToString:@"R$"])
            {
                _title = [NSString stringWithFormat:@"%@ a %@",
                          [[B2WFacetItem numberFormatter] stringFromNumber:dictionary[@"title_min"]],
                          [[B2WFacetItem numberFormatter] stringFromNumber:dictionary[@"title_max"]]];
            }
            else
			{
				if ([[dictionary[@"title_min"] stringValue] isEqualToString:[dictionary[@"title_max"] stringValue]])
				{
					_title = [NSString stringWithFormat:@"%@ %@",
							  [dictionary[@"title_max"] stringValue],
							  dictionary[@"unit"]];
				}
				else
				{
					_title = [NSString stringWithFormat:@"%@ a %@ %@",
							  [dictionary[@"title_min"] stringValue],
							  [dictionary[@"title_max"] stringValue],
							  dictionary[@"unit"]];
				}
			}
        }
        
        _parameters = [NSDictionary dictionaryWithQueryString:dictionary[@"params"]];
        _productCount = [dictionary[@"count"] integerValue];
        _enabled = [dictionary[@"enabled"] boolValue];
        _selected = [dictionary[@"selected"] boolValue];
    }
    return self;
}

- (BOOL)isEqual:(B2WFacetItem *)object
{
    if (![object isKindOfClass:[B2WFacetItem class]])
    {
        return NO;
    }
    
    return [object.title isEqualToString:self.title];
}

@end
