//
//  B2WPostalCodeSearchTableViewController.h
//  B2WKit
//
//  Created by Eduardo Callado on 7/21/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "B2WKit.h"

#import "B2WFormTableViewController.h"

@class B2WPostalCodeSearchTableViewController;

@protocol PostalCodeSearchControllerDelegate <NSObject>

- (void)postalCodeSearchController:(B2WPostalCodeSearchTableViewController *)searchController didSelectAddress:(NSDictionary *)addressDictionary;

@end

@interface B2WPostalCodeSearchTableViewController : B2WFormTableViewController

@property (nonatomic, weak) id<PostalCodeSearchControllerDelegate> delegate;

@end
