//
//  B2WKitUtils.h
//  B2WKit
//
//  Created by Mobile on 7/21/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#define XLog(fmt, ...) NSLog((@"\n\n\t%s (line %d)\n\n\t [*] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@import MessageUI;

@interface B2WKitUtils : NSObject

+ (NSString *)mainAppDisplayName;

+ (BOOL)isACOM;
+ (BOOL)isSUBA;
+ (BOOL)isSHOP;

+ (BOOL)isJailbroken;

+ (void)openAppStoreWithAppIdentifier:(NSString *)identifier;

+ (void)presentFeedbackComposerViewControllerFromSender:(UIViewController<MFMailComposeViewControllerDelegate> *)sender
                                              recipient:(NSString *)recipient;

+ (UIViewController *)topViewController;

+ (UIImage *)imageNamed:(NSString *)name;

/**
 *  Backward compatible wrapper for isRegisteredForRemoteNotifications (Apple Push Notification Service).
 */
+ (BOOL)isRegisteredForAPNS;

/**
 *  Backward compatible wrapper for registerForRemoteNotifications (Apple Push Notification Service).
 *
 */
+ (void)registerForAPNS;

/**
 *  Unfortunately, stringByAddingPercentEscapesUsingEncoding doesn't always work 100%. 
 *  It encodes non-URL characters but leaves the reserved characters (like slash / and ampersand &) alone.
 *  See: http://stackoverflow.com/questions/8088473/url-encode-an-nsstring
 */
+ (NSString *)stringByAddingPercentEscapes:(NSString *)unencodedString;
+ (NSString *)stringByAddingPercentEscapes:(NSString *)unencodedString encodeCharacters:(NSString *)characters;

/**
 *  Correctly presents a human readble error with UIAlertView.
 */
+ (void)presentError:(NSError *)error;

@end

@interface NSBundle (B2WKit)

+ (NSBundle *)B2WKitBundle;

@end
