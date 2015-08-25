//
//  B2WAPIRecommendation.m
//  B2WKit
//
//  Created by Thiago Peres on 18/02/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WAPIRecommendation.h"
#import "B2WProductHistoryManager.h"
#import "B2WSearchHistoryManager.h"
#import "B2WAPICatalog.h"
#import "NSDictionary+B2WKit.h"
#import "B2WProduct.h"
#import "B2WProductList.h"
#import "NSArray+B2WKit.h"
#import "B2WKitUtils.h"
#import "B2WAccountManager.h"
#import "B2WAPIAccount.h"

static NSString *const B2WAPIRecommendationBrandCodeACOM = @"ACOM";
static NSString *const B2WAPIRecommendationBrandCodeSUBA = @"SUBA";
static NSString *const B2WAPIRecommendationBrandCodeSHOP = @"SHOP";

@implementation B2WAPIRecommendation

+ (NSString*)_urlPrefixForCurrentBrandCode
{
	NSString *brandCode = [[B2WAPIClient brandCode] uppercaseString];
	if ([brandCode isEqualToString:B2WAPIRecommendationBrandCodeACOM])
	{
		return @"recomendacao.americanas";
	}
	else if ([brandCode isEqualToString:B2WAPIRecommendationBrandCodeSUBA])
	{
		return @"recomendacao.submarino";
	}
	return nil;
}

//
// Returns a dictionary containing recommendation list parameters
//
+ (NSMutableDictionary*)recommendationListDictionaryWithType:(NSString*)type
{
	return [NSMutableDictionary dictionaryWithDictionary:@{ @"type" : type,
														    @"prefixTitle" : @"",
														    @"mainProductTitle" : @"",
														    @"categoryFilter" : @[],
														    @"enableMainProduct" : [NSNumber numberWithBool:false],
														    @"gid" : @"1",
														    @"enableMainProductRefresh" : [NSNumber numberWithBool:false],
														    @"minResult" : @3,
														    @"maxResult" : @10 }];
}

//
// Returns a dictionary containing the recommendation lists
// and the reserve recommendation lists
// for the featured (home) page
//
+ (NSDictionary*)_recommendationListDictionariesForFeaturedPage
{
	NSMutableArray *recs = [NSMutableArray array];
	NSMutableArray *reserveRecs = [NSMutableArray array];
	
	for (int i = 1; i < 7; i++)
	{
		NSMutableDictionary *dic = [B2WAPIRecommendation recommendationListDictionaryWithType:[NSString stringWithFormat:@"home%d", i]];
		dic[@"vid"] = [NSNumber numberWithInteger:i];
		[recs addObject:[dic mutableCopy]];
		[dic removeObjectForKey:@"vid"];
		dic[@"type"] = [NSString stringWithFormat:@"homer%d", i];
		[reserveRecs addObject:[dic mutableCopy]];
	}
	
	return @{ @"recList":recs, @"recListReserve":reserveRecs };
}

//
// Returns a dictionary containing the recommendation lists
// and the reserve recommendation lists
// for the product page
//
+ (NSDictionary*)_recommendationListDictionariesForProductPageWithIdentifier:(NSString*)identifier
{
	NSMutableArray *recs = [NSMutableArray array];
	NSMutableArray *reserveRecs = [NSMutableArray array];
	
	for (int i = 1; i < 4; i++)
	{
		NSMutableDictionary *dic = [B2WAPIRecommendation recommendationListDictionaryWithType:[NSString stringWithFormat:@"produto%d", i]];
		dic[@"pid"] = identifier;
		dic[@"vid"] = [NSNumber numberWithInteger:i];
		[recs addObject:[dic mutableCopy]];
		[dic removeObjectForKey:@"vid"];
		dic[@"type"] = [NSString stringWithFormat:@"produtor%d", i];
		[reserveRecs addObject:[dic mutableCopy]];
	}
	
	return @{ @"recList":recs, @"recListReserve":reserveRecs };
}

//
// Returns a dictionary containing the default parameters
// that are used to build the base64 encoded parameters
// in every request to the recommendation API
//
+ (NSMutableDictionary*)_defaultParameters
{
	return [NSMutableDictionary dictionaryWithDictionary:@{ @"storeId" : [B2WKitUtils mainAppDisplayName],
														    @"blackList" : @[],
														    @"queryList" : [B2WSearchHistoryManager history],
														    @"clickList" : [B2WProductHistoryManager history],
														    @"categoryList" : @[],
														    @"refresh": @NO,
														    @"cartList" : @[] }];
}

+ (AFHTTPRequestOperation*)_requestWithParameters:(NSDictionary*)params completionBlock:(B2WAPICompletionBlock)block
{
	NSString *urlPrefix = [B2WAPIRecommendation _urlPrefixForCurrentBrandCode];
	if (urlPrefix == nil)
	{
		block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
									   code:B2WAPIInternalInconsistencyError
								   userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Domain %@ with brand code %@ is not supported by B2WAPIRecommendation.", [B2WAPIClient baseURLString], [B2WAPIClient brandCode]]}]);
		return nil;
	}
	
	NSString *urlString = [NSString stringWithFormat:@"http://%@.com.br/scripts/rec_server.php", urlPrefix];
	NSError *error;
	NSMutableURLRequest *request = [[[B2WAPIClient sharedClient] requestSerializer] requestWithMethod:@"GET"
																							URLString:urlString
																						   parameters:params
																								error:&error];
	
	if (error)
	{
		block(nil, error);
		return nil;
	}
	
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (![responseObject containsObjectForKey:@"recList"])
		{
			if (block)
			{
				block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
											   code:B2WAPIInvalidResponseError
										   userInfo:nil]);
			}
			return;
		}
		
		//
		// Remove sections with no products
		//
		NSMutableArray *recommendations = [NSMutableArray arrayWithArray:responseObject[@"recList"]];
		for (int i = 0; i < recommendations.count; i++)
		{
			if ([recommendations[i][@"totalResult"] integerValue] <= 0)
			{
				[recommendations removeObjectAtIndex:i];
				i = -1;
				continue;
			}
		}
		
		//
		// Retrieve all products in all lists distinctively to save the amount of requests we need to make
		//
		NSMutableArray *identifiers = [[recommendations valueForKeyPath:@"productList.@distinctUnionOfArrays.id"] mutableCopy];
		
		//
		// Do the same for main products
		//
		NSArray *mainProductsIdentifiers = [[recommendations valueForKeyPath:@"mainProduct.@distinctUnionOfObjects.id"] sanitizedArray];
		
		[identifiers addObjectsFromArray:mainProductsIdentifiers];
		if (identifiers == nil)
		{
			return;
		}
		
		//
		// Request full product information for recommendation products
		//
		[B2WAPICatalog requestProductsWithIdentifiers:identifiers block:^(NSArray *parsedProducts, NSError *error) {
			if (error)
			{
				if (block)
				{
					block(nil, error);
				}
				
				return;
			}
			
			if (parsedProducts.count <= 0)
			{
				if (block)
				{
					block(nil, [NSError errorWithDomain:B2WAPIErrorDomain
												   code:B2WAPIInvalidResponseError
											   userInfo:nil]);
					return;
				}
			}
			
			@autoreleasepool {
				//
				// Get product identifiers that don't have product information
				//
				// EXPLANATION:
				//
				// Certain product identifiers might be hidden/blocked/etc at the server level
				// so they might appear in the recommendation request but not in the product request.
				//
				NSMutableArray *diff = [identifiers mutableCopy];
				[diff removeObjectsInArray:[parsedProducts valueForKeyPath:@"identifier"]];
				
				[identifiers removeObjectsInArray:diff];
				
				//
				// Map product ids to product objects for faster retrieval
				//
				NSMutableDictionary *productsDict = [NSMutableDictionary dictionary];
				
				for (NSString *identifier in identifiers)
				{
					for (B2WProduct *product in parsedProducts)
					{
						if ([product.identifier isEqualToString:identifier])
						{
							[productsDict setObject:product forKey:identifier];
						}
					}
				}
				
				//
				// Replace incomplete product dictionaries with B2WProduct objects
				//
				for (int i = 0; i < recommendations.count; i++)
				{
					id list = recommendations[i];
					
					NSMutableArray *products = list[@"productList"];
					NSMutableArray *filteredProducts = [NSMutableArray new];
					
					for (int i = 0; i < products.count; i++)
					{
						//
						// Add special recommendation parameters to product object
						//
						
						id productObject = products[i];
						B2WProduct *product = [productsDict[products[i][@"id"]] copy];
						if (product == nil)
						{
							continue;
						}
						
						NSString *percentKey = @"percent";
						if ([productObject containsObjectForKey:percentKey])
						{
							NSString *recommendationType = list[@"type"];
							
							product.userInfo = @{ percentKey: productObject[percentKey],
												  @"recommendationType": recommendationType} ;
						}
						
						//
						// Only add product if it has in stock
						//
						if (product.inStock)
						{
							[filteredProducts addObject:product];
						}
					}
					
					list[@"productList"] = filteredProducts;
					//
					// Replace incomplete main product dictionary with B2WProduct object
					//
					// IMPORTANT:
					// If no B2WProduct is found, the recommendation list will be removed
					//
					if ([list containsObjectForKey:@"mainProduct"])
					{
						if (list[@"mainProduct"] != [NSNull null])
						{
							NSString *mainProductIdentifier = list[@"mainProduct"][@"id"];
							
							B2WProduct *product = productsDict[mainProductIdentifier];
							
							if (product == nil)
							{
								//
								// Remove the entire list!
								//
								[recommendations removeObjectAtIndex:i];
								i--;
								continue;
							}
							
							list[@"mainProduct"] = productsDict[mainProductIdentifier];
						}
						else
						{
							[list removeObjectForKey:@"mainProduct"];
						}
					}
				}
			}
			
			if (block)
			{
				block([B2WProductList objectsWithDictionaryArray:recommendations], nil);
			}
		}];
	} failure:[B2WAPIClient errorBlockWithBlock:block]];
	
	AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves];
	NSMutableSet *ct = [serializer.acceptableContentTypes mutableCopy];
	[ct addObject:@"text/html"];
	serializer.acceptableContentTypes = ct;
	[operation setResponseSerializer:serializer];
	[[[B2WAPIClient sharedClient] operationQueue] addOperation:operation];
	
	return operation;
}

+ (AFHTTPRequestOperation*)requestProductRecommendationsWithProductIdentifier:(NSString*)product
																		block:(B2WAPICompletionBlock)block
{
	if (product == nil || product.length == 0)
	{
		if (block)
		{
			NSError *error = [NSError errorWithDomain:B2WAPIErrorDomain
												 code:B2WAPIInvalidParameterError
											 userInfo:nil];
			block(nil, error);
		}
		return nil;
	}
	
	NSMutableDictionary *params = [B2WAPIRecommendation _defaultParameters];
	params[@"page"] = @"produto";
	[params addEntriesFromDictionary:[B2WAPIRecommendation _recommendationListDictionariesForProductPageWithIdentifier:product]];
	
	return [B2WAPIRecommendation _requestWithParameters:@{ @"j" : [params base64EncodedJSONString],
														   @"page" : @"produto",
														   @"json" : @1 }
										completionBlock:block];
}

+ (AFHTTPRequestOperation*)requestCartRecommendationsWithBlock:(B2WAPICompletionBlock)block
{
	return nil;
}

+ (AFHTTPRequestOperation*)requestFeaturedRecommendationsWithBlock:(B2WAPICompletionBlock)block
{
    NSMutableDictionary *params = [B2WAPIRecommendation _defaultParameters];
    params[@"page"] = @"home";
    [params addEntriesFromDictionary:[B2WAPIRecommendation _recommendationListDictionariesForFeaturedPage]];
    
    [B2WAPIRecommendation addB2WUID:params];
    
    return [B2WAPIRecommendation _requestWithParameters:@{ @"j" : [params base64EncodedJSONString],
                                                           @"page" : @"home",
                                                           @"json" : @1 }
                                        completionBlock:block];
}

+ (void)addB2WUID:(NSMutableDictionary *)params
{
    NSString *B2WUID = [B2WAPIAccount B2WUID];
    
    if (B2WUID)
    {
        if ([B2WAPIAccount isAnonymousB2WUID:B2WUID])
        {
            params[@"sid"] = B2WUID;
        }
        else
        {
            B2WUID = [@"neemu" stringByAppendingString:B2WUID];
            params[@"uid"] = B2WUID;
        }
    }
    else // old logic when B2WUID was not used
    {
        if (! [B2WAPIAccount isLoggedIn])
        {
            params[@"sid"] = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }
        else
        {
            params[@"uid"] = [B2WAPIAccount username];
        }
    }
}

@end
