//
//  B2WReviewComment.h
//  B2WKit
//
//  Created by Thiago Peres on 13/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WReviewResource.h"

@interface B2WReviewComment : B2WReviewResource

/// The review comment's catalog identifier.
@property (nonatomic, readonly) NSString *reviewIdentifier;

@end
