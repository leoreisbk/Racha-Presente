//
//  B2WImageOffer.m
//  B2WKit
//
//  Created by Gabriel Luis Vieira on 11/7/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WImageOffer.h"

@implementation B2WImageOffer

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	// TODO: validate keys
	self = [super init];
	if (self) {
		if ([dictionary[@"platformsImages"] containsObjectForKey:@"smartphone"] && (dictionary[@"platformsImages"][@"smartphone"] != (id)[NSNull null])) {
			_smartphoneImageURL = [NSURL URLWithString:dictionary[@"platformsImages"][@"smartphone"][@"url"]];
			
			_widthSmartphone = [dictionary[@"platformsImages"][@"smartphone"][@"width"] floatValue];
			_heightSmartphone = [dictionary[@"platformsImages"][@"smartphone"][@"height"] floatValue];
		}
		
		if ([dictionary[@"platformsImages"] containsObjectForKey:@"smartphoneLarge"] && (dictionary[@"platformsImages"][@"smartphoneLarge"] != (id)[NSNull null])) {
			_smartphoneLargeImageURL = [NSURL URLWithString:dictionary[@"platformsImages"][@"smartphoneLarge"][@"url"]];
			
			_widthSmartphoneLarge = [dictionary[@"platformsImages"][@"smartphoneLarge"][@"width"] floatValue];
			_heightSmartphoneLarge = [dictionary[@"platformsImages"][@"smartphoneLarge"][@"height"] floatValue];
		}
		
		if ([dictionary[@"platformsImages"] containsObjectForKey:@"tablet"] && (dictionary[@"platformsImages"][@"tablet"] != (id)[NSNull null])) {
			_tabletImageURL = [NSURL URLWithString:dictionary[@"platformsImages"][@"tablet"][@"url"]];
			
			_widthTablet = [dictionary[@"platformsImages"][@"tablet"][@"width"] floatValue];
			_heightTablet = [dictionary[@"platformsImages"][@"tablet"][@"height"] floatValue];
		}
		
		if (_smartphoneImageURL && !_tabletImageURL) {
			self.platform = B2WOfferPlatformSmartphone;
		} else if (!_smartphoneImageURL && _tabletImageURL) {
			self.platform = B2WOfferPlatformTablet;
		} else if (_smartphoneImageURL && _tabletImageURL) {
			self.platform = B2WOfferPlatformAll;
		} else {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Invalid platforms images content (cannot specify a platform) in API response JSON" userInfo:nil];
		}
	}
	return self;
}

@end
