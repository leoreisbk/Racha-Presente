//
//  B2WCatalogController.h
//  B2WKit
//
//  Created by Thiago Peres on 23/10/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WAPICatalog.h"
#import "B2WPagingProtocol.h"

@class B2WDepartment;


@interface B2WCatalogController : NSObject <B2WPagingProtocol>

/**
 An array containing B2WProduct objects fetched on the last request.
 */
@property (nonatomic, readonly) NSArray *lastResults;

/**
 The order type indicating how products should be ordered. Defaults
 to descending if an invalid value is provided.
 */
@property (nonatomic, assign) B2WAPICatalogOrderType orderType;

/**
 The sort string indicating how products should be sorted. Defaults
 to best-seller sorting if an invalid value is provided.
 */
@property (nonatomic, strong) NSString *sortType;

/**
 The delegate object to receive update events.
 */
@property (nonatomic, weak) id <B2WPagingResultsDelegate> delegate;

/**
 *  An array containing the currently selected facet items for the search result.
 */
@property (nonatomic, strong) NSMutableArray *selectedFacetItems;

@property (nonatomic, strong) B2WDepartment *department;
@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSArray *productIdentifiers;

- (id)initWithDepartment:(B2WDepartment*)department
				   order:(B2WAPICatalogOrderType)orderType
					sort:(NSString*)sortType
		  resultsPerPage:(NSUInteger)resultsPerPage;

- (id)initWithGroups:(NSArray*)groups
			   order:(B2WAPICatalogOrderType)orderType
				sort:(NSString*)sortType
	  resultsPerPage:(NSUInteger)resultsPerPage;

- (id)initWithTags:(NSArray*)tags
			 order:(B2WAPICatalogOrderType)orderType
			  sort:(NSString*)sortType
	resultsPerPage:(NSUInteger)resultsPerPage;

- (id)initWithProductIdentifiers:(NSArray*)productIdentifiers;

/**
 Returns a B2WCatalogController object initialized with the provided values
 and prepared to make requests.
 
 @param identifier     The department's identifier.
 @param orderType      The order type indicating how products should be ordered. Defaults to descending if an invalid value is provided.
 @param sortType       The sort string indicating how products should be sorted. Defaults to best-seller sorting if an invalid value is provided.
 @param resultsPerPage An unsigned integer containing the number of desired results per page. Must be greater than zero.
 
 @return A B2WCatalogController object initialized with the provided values
 and prepared to make requests.
 */

@end
