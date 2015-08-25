//
//  B2WMarketplaceProductsPagingController.h
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "B2WAPICatalog.h"

// Protocols
#import "B2WPagingProtocol.h"

@interface B2WMarketplaceProductsPagingController : NSObject <B2WPagingProtocol>

@property (nonatomic, strong) NSString *query;

@property (nonatomic, assign) B2WAPICatalogOrderType orderType;
@property (nonatomic, strong) NSString *sortType;
@property (nonatomic, weak) id <B2WPagingResultsDelegate> delegate;

- (id)initWithPartnerName:(NSString *)partnerName
                    query:(NSString *)query
           resultsPerPage:(NSUInteger)resultsPerPage
                 sortType:(NSString *)sortType;

@end
