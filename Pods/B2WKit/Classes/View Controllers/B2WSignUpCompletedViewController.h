//
//  B2WSignUpCompletedViewController.h
//  B2WKit
//
//  Created by Eduardo Callado on 7/21/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "B2WKit.h"

@class B2WSignUpCompletedViewController;

@protocol SignUpCompletedViewControllerDelegate <NSObject>

- (void)SignUpCompletedViewControllerDidCancel:(B2WSignUpCompletedViewController *)controller;
- (void)SignUpCompletedViewControllerDidConfirm:(B2WSignUpCompletedViewController *)controller;

@end

@interface B2WSignUpCompletedViewController : UIViewController

@property (nonatomic, weak) id<SignUpCompletedViewControllerDelegate> delegate;

@end
