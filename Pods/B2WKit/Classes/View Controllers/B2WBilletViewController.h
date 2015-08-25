//
//  ACOMBilletViewController.h
//  Americanas
//
//  Created by Thiago Peres on 12/01/14.
//  Copyright (c) 2014 Ideais. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface B2WBilletViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *printBarButtonItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (id)initWithURL:(NSURL*)url;

@end
