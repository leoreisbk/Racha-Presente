//
//  NSDictionary+QueryString.m
//  SinglySDK
//
//  Copyright (c) 2012-2013 Singly, Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "NSDictionary+QueryString.h"
#import "NSString+URLEncoding.h"

@implementation NSDictionary (QueryString)

+ (NSDictionary *)dictionaryWithQueryString:(NSString *)queryString
{
    if (queryString == nil || queryString.length <= 0)
    {
        return nil;
    }
    
    if ([queryString characterAtIndex:0] == '?')
    {
        queryString = [queryString substringFromIndex:1];
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *pairs = [queryString componentsSeparatedByString:@"&"];

    for (NSString *pair in pairs)
    {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if (elements.count == 2)
        {
            NSString *key = elements[0];
            NSString *value = elements[1];
            NSString *decodedKey = [key URLDecodedString];
            NSString *decodedValue = [value URLDecodedString];

            if (![key isEqualToString:decodedKey])
                key = decodedKey;

            if (![value isEqualToString:decodedValue])
                value = decodedValue;

            [dictionary setObject:value forKey:key];
        }
    }

    return [NSDictionary dictionaryWithDictionary:dictionary];
}

@end
