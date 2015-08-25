//
//  ACOMBilletViewController.m
//  Americanas
//
//  Created by Thiago Peres on 12/01/14.
//  Copyright (c) 2014 Ideais. All rights reserved.
//

#import "B2WBilletViewController.h"
#import <IDMViewControllerStates/UIViewController+States.h>

@import MobileCoreServices;

@interface B2WBilletViewController ()

@property (nonatomic, strong) NSURL *requestURL;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@end

@implementation B2WBilletViewController

- (id)initWithURL:(NSURL*)url
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"B2WKit" ofType:@"bundle"];
    NSBundle *bundle = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:bundlePath isDirectory:nil])
    {
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:bundle];
    if (self) {
        // Custom initialization
        self.requestURL = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.title = @"Boleto";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Fechar"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(closeButtonPressed)];
    
    [self.webView setScalesPageToFit:YES];
    [self.webView setSuppressesIncrementalRendering:YES];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.requestURL]];
    [self.loadingView show];
}

- (void)closeButtonPressed
{
    [self removeTempPDFFile];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)printButtonPressed:(id)sender
{
    if ([UIPrintInteractionController isPrintingAvailable])
    {
        UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
        
        UIPrintInfo *info = [UIPrintInfo printInfo];
        info.outputType = UIPrintInfoOutputGeneral;
        info.jobName = self.webView.request.URL.absoluteString;
        info.orientation = UIPrintInfoOrientationPortrait;
        info.duplex = UIPrintInfoDuplexLongEdge;
        
        controller.printInfo = info;
        controller.showsPageRange = YES;
        controller.printFormatter = self.webView.viewPrintFormatter;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [controller presentFromBarButtonItem:sender animated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error) {
                
            }];
        }
        else
        {
            [controller presentAnimated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error) {
            }];
        }
    }
    else
    {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.toolbar.items];
        [arr removeObject:self.printBarButtonItem];
        
        self.toolbar.items = arr;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.loadingView dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.loadingView dismiss];
    
#ifdef kDefaultConnectionErrorTitle
    NSString *title = kDefaultConnectionErrorTitle;
#else
    NSString *title = @"Falha na Conexão";
#endif
    
#ifdef kDefaultConnectionErrorMessage
    NSString *message = kDefaultConnectionErrorMessage;
#else
    NSString *message = @"Não foi possível conectar ao servidor. Por favor, verifique sua conexão com a internet.";
#endif
    
    [self.contentUnavailableView showWithTitle:title
                                       message:message
                      reloadButtonPressedBlock:^{
                          [self.contentUnavailableView dismiss];
                          [self.loadingView show];
                          [self.webView reload];
                      }];
}

- (NSString*)tempPDFFilePath
{
    NSString *saveFileName = @"Boleto.pdf";
        
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:saveFileName];
}

- (void)removeTempPDFFile
{
    NSError *error;
    
    [[NSFileManager defaultManager] removeItemAtPath:[self tempPDFFilePath] error:&error];
    
    if (error)
    {
        DLog(@"Error deleting temporary bankslip PDF file: %@", error);
    }
}

- (void)savePDFFromWebView:(UIWebView*)webView completionBlock:(void (^)(NSURL *fileURL))completionBlock
{
    int height, width, header, sidespace;

//
// Original dimensions provided below
//    height = 1754;
//    width = 1240;
//
    
    height = 1052;
    width = 744;
    header = 15;
    sidespace = 30;
    
    // set header and footer spaces
    
    UIEdgeInsets pageMargins = UIEdgeInsetsMake(header, sidespace, header, sidespace);
    
    webView.viewPrintFormatter.contentInsets = pageMargins;
    
    UIPrintPageRenderer *renderer = [[UIPrintPageRenderer alloc] init];
    
    [renderer addPrintFormatter:webView.viewPrintFormatter startingAtPageAtIndex:0];
    
    CGSize pageSize = CGSizeMake(width, height);
    CGRect printableRect = CGRectMake(pageMargins.left,
                                      pageMargins.top,
                                      pageSize.width - pageMargins.left - pageMargins.right,
                                      pageSize.height - pageMargins.top - pageMargins.bottom);
    
    CGRect paperRect = CGRectMake(0, 0, pageSize.width, pageSize.height);
    
    [renderer setValue:[NSValue valueWithCGRect:paperRect] forKey:@"paperRect"];
    [renderer setValue:[NSValue valueWithCGRect:printableRect] forKey:@"printableRect"];
    
    NSData *pdfData = [self printToPDFWithRender:renderer paperRect:paperRect];
    
    [pdfData writeToFile: [self tempPDFFilePath]  atomically: YES];
    
    NSURL *fileURL = [NSURL fileURLWithPath:[self tempPDFFilePath]];
    if (completionBlock)
    {
        completionBlock(fileURL);
    }
}

- (NSData*)printToPDFWithRender:(UIPrintPageRenderer*)renderer paperRect:(CGRect)paperRect
{
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData( pdfData, paperRect, nil );
    
    [renderer prepareForDrawingPages: NSMakeRange(0, renderer.numberOfPages)];
    
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    
    for ( int i = 0 ; i < renderer.numberOfPages ; i++ )
    {
        UIGraphicsBeginPDFPage();
        
        [renderer drawPageAtIndex: i inRect: bounds];
    }
    
    UIGraphicsEndPDFContext();
    
    return pdfData;
}

- (IBAction)actionButtonPressed:(UIBarButtonItem*)sender
{
    [self savePDFFromWebView:self.webView completionBlock:^(NSURL *fileURL) {
        if (self.documentController == nil)
        {
            self.documentController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
            self.documentController.UTI = (__bridge NSString *)(kUTTypePDF);
        }
        
        [self.documentController presentOptionsMenuFromBarButtonItem:sender animated:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
