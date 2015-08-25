//
//  B2WProductDetailsViewController.m
//  B2WKit
//
//  Created by Flávio Caetano on 5/13/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WProductDetailsViewController.h"
#import <B2WAPIClient.h>

// Models
#import "B2WProduct.h"

// Controllers
#import <IDMViewControllerStates/UIViewController+States.h>

// Categories
#import "UIViewController+B2WKit.h"

@interface B2WProductDetailsViewController ()

@end


@implementation B2WProductDetailsViewController

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.webView == nil)
    {
        self.webView = [UIWebView new];
        self.view    = self.webView;
    }
    
    self.navigationItem.title = @"Descrição";
    
    if (self.product.productDescription)
    {
        NSString* descriptionHTML = [NSString stringWithFormat:@"<!doctype html>"
                                     "<html>"
                                     "<head>"
                                     "<meta name='viewport' content='width=device-width' />"
                                     "<meta http-equiv='content-type' content='text/html; charset=UTF-8'  />"
                                     "<style>"
                                     "p {font-family: \"Helvetica Neue\";color: #666666; font-size: 14;}\n"
                                     "@viewport{"
                                     "zoom: 1.0;"
                                     "width: extend-to-zoom;"
                                     "}"
                                     "</style>"
                                     "</head>"
                                     "<body>"
                                     "<p>"
                                     "%@"
                                     "</p>"
                                     "<br>"
                                     "</body> \n"
                                     "</html>", self.product.productDescription];
        
        [self.webView setScalesPageToFit:YES];
        [self.webView loadHTMLString:descriptionHTML baseURL:nil];
    }
    else
	{
        [self.contentUnavailableView showWithTitle:@"Não Há Descrição"
                                           message:@"Não existe nenhuma descrição para este produto."
                          reloadButtonPressedBlock:nil];
    }
    
    if (self.isBeingPresentedModally)
    {
        if (![[B2WAPIClient brandCode] isEqualToString:@"SHOP"])
        {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Fechar"
                                                                                     style:UIBarButtonItemStyleDone
                                                                                    target:self
                                                                                    action:@selector(closeButtonPressed)];
        }
    }
}

- (void)closeButtonPressed
{
    if ([self isBeingPresentedModally])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        if ([self.navigationController.viewControllers firstObject] != self)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.loadingView show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.loadingView dismiss];
}

@end