//
//  B2WLoginViewController.h
//  B2WKit
//
//  Created by Eduardo Callado on 7/21/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "B2WKit.h"

@class B2WLoginViewController;

@protocol LoginViewControllerDelegate <NSObject>

- (void)loginViewControllerDidCancel:(B2WLoginViewController *)controller;

@end

@interface B2WLoginViewController : UIViewController

@property (nonatomic, weak) id<LoginViewControllerDelegate> delegate;

@end
