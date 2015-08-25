//
//  B2WOneClickRelation.m
//  B2WKit
//
//  Created by Thiago Peres on 7/22/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WOneClickRelationship.h"

@implementation B2WOneClickRelationship

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _identifier = dictionary[@"id"];
        _main = [dictionary[@"main"] boolValue];
        _active = [dictionary[@"active"] boolValue];
		
		NSDictionary *links = dictionary[@"_links"];
		
		_addressIdentifier = links[@"address"][@"id"];
		_creditCardIdentifier = links[@"creditCard"][@"id"];
		
        /*for (id obj in dictionary[@"_link"])
        {
			if ([obj[@"rel"] isEqualToString:@"address"])
            {
                //_addressIdentifier = obj[@"id"];

				NSString *href = obj[@"href"];
				
				_addressIdentifier = [href componentsSeparatedByString:@"/"].lastObject;
            }
            else if ([obj[@"rel"] isEqualToString:@"credit-card"])
            {
				//_creditCardIdentifier = obj[@"id"];

				NSString *href = obj[@"href"];

				_creditCardIdentifier = [href componentsSeparatedByString:@"/"].lastObject;
            }
        }*/
    }
    return self;
}

/*- (NSDictionary*)dictionaryValue
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    dictionary[@"addressId"] = self.addressIdentifier;
    dictionary[@"creditCardId"] = self.creditCardIdentifier;
    dictionary[@"active"] = @(self.active);
    
    return dictionary;
}*/

@end
