//
//  B2WKitUtils.m
//  B2WKit
//
//  Created by Mobile on 7/21/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WKitUtils.h"
#import "B2WKit.h"
#import <IDMAlertViewManager/IDMAlertViewManager.h>

@import MessageUI;

@implementation B2WKitUtils

+ (NSString *)mainAppDisplayName
{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
}

+ (BOOL)isACOM
{
	NSString *CFBundleDisplayName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
	return [CFBundleDisplayName isEqualToString:@"Americanas"];
}

+ (BOOL)isSUBA
{
	NSString *CFBundleDisplayName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
	return [CFBundleDisplayName isEqualToString:@"Submarino"];
}

+ (BOOL)isSHOP
{
	NSString *CFBundleDisplayName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
	return [CFBundleDisplayName isEqualToString:@"Shoptime"];
}

+ (void)openAppStoreWithAppIdentifier:(NSString *)identifier
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id569981824"]];
}

+ (void)presentFeedbackComposerViewControllerFromSender:(UIViewController<MFMailComposeViewControllerDelegate>*)sender
                                              recipient:(NSString *)recipient
{
    NSString *debugInfo = [NSString stringWithFormat:@"%@ %@%@\n%@\n",
                           [[UIDevice currentDevice] systemName],
                           [[UIDevice currentDevice] systemVersion], [B2WKitUtils isJailbroken] ? @"." : @",",
                           [[UIDevice currentDevice] model]];
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *email = [[MFMailComposeViewController alloc] init];
        [email.navigationBar setTintColor:[UIColor whiteColor]];
        if (email)
        {
            [email.navigationBar setBarStyle:UIBarStyleDefault];
            email.mailComposeDelegate = sender;
            [email addAttachmentData:[debugInfo dataUsingEncoding:[NSString defaultCStringEncoding]] mimeType:@"application/appinfo" fileName:@""];
            [email setToRecipients:@[recipient]];
            [email setSubject:[NSString stringWithFormat:@"Feedback do app %@", [B2WKitUtils mainAppDisplayName]]];
            [email.navigationItem setTitle:@"Enviar Feedback"];
            
            UIColor *globalTint = [[[UIApplication sharedApplication] delegate] window].tintColor;
            
            email.navigationBar.tintColor = globalTint;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                email.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            email.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [sender presentViewController:email animated:YES completion:nil];
        }
    }
    else
    {
		[IDMAlertViewManager showAlertWithTitle:@"Falha No Envio"
										message:@"Por favor verifique suas configurações de email em Ajustes."
									   priority:IDMAlertPriorityHigh];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

+ (UIViewController *)topViewController
{
    UIViewController *topViewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
    
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    
    return topViewController;
}

+ (BOOL)isJailbroken
{
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    
    FILE *f = fopen("/bin/bash", "r");
    
    if (errno == ENOENT)
    {
        fclose(f);
        
        NSArray *paths = @[@"/Applications/Cydia.app"];
        
        for (NSString *path in paths)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:path])
            {
                // device IS jailbroken
                return YES;
            }
        }
        
        // device is NOT jailbroken
        return NO;
    }
    else
    {
        // device IS jailbroken
        fclose(f);
        
        return YES;
    }
    
#endif
}

+ (UIImage *)imageNamed:(NSString *)name
{
	UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"B2WKit.bundle/%@.png", name]];
	
	if (!image) image = [UIImage imageNamed:name]; // If it's running from B2WKit project, there is no need to use a bundle prefix
	
	return image;
}

+ (void)registerForAPNS
{
    UIApplication *application = [UIApplication sharedApplication];
    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
	{
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
}

+ (BOOL)isRegisteredForAPNS
{
    UIApplication *application = [UIApplication sharedApplication];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // Running iOS 8
        return [application isRegisteredForRemoteNotifications];
    } else {
        return [application enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone;
    }
}

+ (NSString *)stringByAddingPercentEscapes:(NSString *)unencodedString
{
    return [B2WKitUtils stringByAddingPercentEscapes:unencodedString encodeCharacters:@"^<>{}[];:@&=+$,/?%#"];
}

+ (NSString *)stringByAddingPercentEscapes:(NSString *)unencodedString encodeCharacters:(NSString *)characters
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (CFStringRef)unencodedString,
                                                                                  NULL,
                                                                                  (CFStringRef)characters,
                                                                                  kCFStringEncodingUTF8 ));
    return encodedString;
}

+ (void)presentError:(NSError *)error
{
    // This is bad error handling. According to Apple, the localized description (NSLocalizedDescriptionKey)
    // should be used here as the title and localized recovery suggestion (NSLocalizedRecoverySuggestionErrorKey) should be the message.
    // See: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ErrorHandlingCocoa/ErrorObjectsDomains/ErrorObjectsDomains.html#//apple_ref/doc/uid/TP40001806-CH202-CJBGAIBJ
    // Maybe only using the localized description as the message is enough, the point is we should refactor our NSErrors to use this properly.
    
	NSString *title = kDefaultConnectionErrorTitle;
    NSString *message = @"Por favor, verifique sua conexão com a internet e tente novamente.";
    
    if ((error.domain == B2WAPIErrorDomain) && error.userInfo) {
        title = @"Erro no servidor";
        message = @"Houve um erro ao se conectar com o servidor, tente novamente mais tarde.";
        id localizedDescription = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        if ([localizedDescription isKindOfClass:[NSDictionary class]]) { // TODO: this should never be a dict, but some of our API classes do this so we'll handle it
            NSString *errorCode = [localizedDescription objectForKey:@"errorCode"];
            NSString *errorMessage = [localizedDescription objectForKey:@"message"];
            message = [message stringByAppendingString:[NSString stringWithFormat:@"\n(Erro %@: '%@')", errorCode, errorMessage]];
        } else if ([localizedDescription isKindOfClass:[NSString class]]) {
            NSString *errorMessage = (NSString *) localizedDescription;
            message = [message stringByAppendingString:[NSString stringWithFormat:@"\n(Erro: '%@')", errorMessage]];
        }
    }
    
    [UIAlertView showAlertViewWithTitle:title message:message];
}

@end

@implementation NSBundle (B2WKit)

+ (NSBundle *)B2WKitBundle
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"B2WKit" ofType:@"bundle"];
    NSBundle *bundle     = [NSBundle bundleWithPath:bundlePath];
    
    if (!bundle) bundle = [NSBundle mainBundle];
    
    return bundle;
}

@end
