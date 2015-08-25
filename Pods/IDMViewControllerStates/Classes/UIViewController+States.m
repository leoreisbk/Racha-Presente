//
//  UIViewController+States.m
//  IDMLoadingView
//
//  Created by Thiago Peres on 08/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "UIViewController+States.h"
#import "IDMLoadingView.h"
#import <objc/runtime.h>

static char const * const IDMLoadingViewKey = "IDMLoadingViewKey";
static char const * const IDMContentUnavailableViewKey = "IDMContentUnavailableViewKey";

@implementation UIViewController (States)

- (IDMLoadingView*)loadingView
{
    IDMLoadingView *_loadingView = objc_getAssociatedObject(self, IDMLoadingViewKey);

    if (_loadingView == nil)
    {
        _loadingView = [[IDMLoadingView alloc] initWithFrame:self.view.bounds];
        _loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_loadingView];
        
        objc_setAssociatedObject(self, IDMLoadingViewKey, _loadingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return _loadingView;
}

- (IDMContentUnavailableView*)contentUnavailableView
{
    IDMContentUnavailableView *_contentUnavailableView = objc_getAssociatedObject(self, IDMContentUnavailableViewKey);
    if(_contentUnavailableView == nil)
    {
        _contentUnavailableView = [[IDMContentUnavailableView alloc] initWithFrame:self.view.bounds];
        _contentUnavailableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self.view addSubview:_contentUnavailableView];
        
        objc_setAssociatedObject(self, IDMContentUnavailableViewKey, _contentUnavailableView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return _contentUnavailableView;
}

@end
