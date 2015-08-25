//
//  B2WSearchListingViewController.h
//  B2WKit
//
//  Created by Thiago Peres on 23/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WProductListingViewController.h"

@interface B2WSearchListingViewController : B2WProductListingViewController

/**
 *  A string containing the desired search query.
 */
@property (strong, nonatomic) NSString *searchQuery;

@end
