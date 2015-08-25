//
//  B2WProductDetailsViewController.h
//  B2WKit
//
//  Created by Flávio Caetano on 5/13/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class B2WProduct;


@interface B2WProductDetailsViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) B2WProduct *product;

@end
