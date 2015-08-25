//
//  B2WPromoBadgeManager.h
//  B2WKit
//
//  Created by rodrigo.fontes on 11/11/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WObject.h"

@interface B2WPromoBadgeManager : B2WObject

+ (B2WPromoBadgeManager *)sharedManager;

@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) NSString *promoBadgeURL;
@property (nonatomic, strong) UIImageView *promoBadgeImageView;

@property (nonatomic, strong) UIImage *smallImage;
@property (nonatomic, strong) UIImage *mediumImage;
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *largeImage;

- (void)requestPromoBadgeImage;
- (UIImage *)imageForSize:(CGSize)size;

@end