//
//  B2WPostalCodeHistoryManager.m
//  B2WKit
//
//  Created by Eduardo Callado on 6/24/15.
//
//

#import "B2WPostalCodeHistoryManager.h"

#define _kB2WPostalCodetHistoryUserDefaultsKey @"kB2WPostalCodeHistoryUserDefaultsKey"
#define _kB2WPostalCodeHistoryMaximumNumberOfPostalCodes 100

@implementation B2WPostalCodeHistoryManager

+ (NSArray *)history
{
	id obj = [[NSUserDefaults standardUserDefaults] objectForKey:_kB2WPostalCodetHistoryUserDefaultsKey];
	return obj ? obj : @[];
}

+ (void)addPostalCode:(NSString *)postalCode
{
	if (postalCode == nil || [postalCode isEqualToString:@""])
	{
		return;
	}
	
	NSArray *postalCodes = [[NSUserDefaults standardUserDefaults] objectForKey:_kB2WPostalCodetHistoryUserDefaultsKey];
	
	NSMutableArray *mutable = [NSMutableArray arrayWithArray:postalCodes];
	
	//
	// Remove any previous occurences of the postalCode
	// and moves it to the beginning of the list
	//
	[mutable removeObject:postalCode];
	[mutable insertObject:postalCode atIndex:0];
	
	while (mutable.count > _kB2WPostalCodeHistoryMaximumNumberOfPostalCodes)
	{
		[mutable removeObjectAtIndex:mutable.count-1];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:mutable forKey:_kB2WPostalCodetHistoryUserDefaultsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
