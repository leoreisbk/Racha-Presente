//
//  B2WCatalogListingViewController.h
//  B2WKit
//
//  Created by Thiago Peres on 23/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WProductListingViewController.h"

@class B2WCatalogController;
@class B2WDepartment;

@interface B2WCatalogListingViewController : B2WProductListingViewController

/**
 *  The department identifier.
 */
@property (nonatomic, strong) B2WDepartment *department;

@property (nonatomic, strong) NSArray *groups;

@property (nonatomic, strong) NSArray *tags;

@property (nonatomic, strong) NSArray *productIdentifiers;

@end
