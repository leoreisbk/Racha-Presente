//
//  B2WLoginMenuTableViewController.h
//  B2WKit
//
//  Created by Caio Mello on 08/08/2014.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MZFormSheetController/MZFormSheetController.h>

@interface B2WLoginMenuTableViewController : UITableViewController

@property (nonatomic, strong) MZFormSheetController *formSheetController;

// Use these when you need a one-to-one communication. Otherwise, just listen to notifications directly (one-to-many).
@property (copy)void (^userSignedInHandler)(void);
@property (copy)void (^userSignInFailedHandler)(void);
@property (copy)void (^userSignInCanceledHandler)(void);
@end
