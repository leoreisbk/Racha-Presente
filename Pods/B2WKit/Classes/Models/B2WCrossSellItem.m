//
//  B2WCrossSellItem.m
//  B2WKit
//
//  Created by Thiago Peres on 16/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WCrossSellItem.h"

@implementation B2WCrossSellItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self)
    {
        [self setValue:dictionary[@"_name"] forKey:@"name"];
        [self setValue:dictionary[@"_id"] forKey:@"identifier"];
        [self setValue:dictionary[@"_salesPrice"] forKey:@"price"];
        [self setValue:dictionary[@"_price"] forKey:@"priceFrom"];
        [self setValue:[NSURL URLWithString:dictionary[@"_image"]] forKey:@"thumbnailImageURL"];
        [self setValue:dictionary[@"_numReviews"] forKey:@"reviewsCount"];
        [self setValue:dictionary[@"_rating"] forKey:@"reviewsRatingAverage"];
        [self setValue:dictionary[@"_installment"] forKey:@"installment"];
        [self setValue:@YES forKey:@"_inStock"];
        
        _skuIdentifier = dictionary[@"_sku"];
    }
    return self;
}

@end
