//
//  B2WReviewResource.m
//  B2WKit
//
//  Created by Thiago Peres on 13/12/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#import "B2WReviewResource.h"

@implementation B2WReviewResource

+ (NSDateFormatter*)dateFormatter
{
    static NSDateFormatter *_formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _formatter            = [[NSDateFormatter alloc] init];
        _formatter.locale     = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _formatter.timeZone   = [NSTimeZone timeZoneForSecondsFromGMT:0];
        _formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ";
    });
    return _formatter;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _identifier                 = dictionary[@"Id"];

        id countObj                 = dictionary[@"TotalFeedbackCount"];

        _totalFeedbackCount         = countObj == [NSNull null] ? 0 : [countObj integerValue];
        _totalPositiveFeedbackCount = [dictionary[@"TotalPositiveFeedbackCount"] integerValue];
        _totalNegativeFeedbackCount = [dictionary[@"TotalNegativeFeedbackCount"] integerValue];
        
        if ([dictionary containsObjectForKey:@"CommentText"])
        {
            _text = dictionary[@"CommentText"];
        }
        else
        {
            _text = dictionary[@"ReviewText"];
        }

        _title            = dictionary[@"Title"];
        _authorIdentifier = dictionary[@"AuthorId"];
        _submissionTime   = [[B2WReviewResource dateFormatter] dateFromString:dictionary[@"SubmissionTime"]];
        _userNickName     = dictionary[@"UserNickname"] == [NSNull null] ? @"Anônimo" : dictionary[@"UserNickname"];
    }
    return self;
}

@end
