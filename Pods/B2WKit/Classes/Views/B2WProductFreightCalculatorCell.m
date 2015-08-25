//
//  B2WProductFreightCalculatorCell.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#define kDefaultFreightAnimationTime 0.38f

#import "B2WAPIFreight.h"
#import "B2WProductFreightCalculatorCell.h"
#import "B2WProductMarketplacePartner.h"
#import "B2WFreightProduct.h"

#import <IDMAlertViewManager/IDMAlertViewManager.h>

@interface B2WProductFreightCalculatorCell ()

@property (strong, nonatomic) NSString *freightCalculationResultTitle;
@property (strong, nonatomic) NSString *freightCalculationResultMessage;

@property (strong, nonatomic) B2WFreightCalculationProduct *freightResult;

@end

@implementation B2WProductFreightCalculatorCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.cepTextField.delegate = self;
    [self.cepTextField setValue:self.cepTextField.textColor forKeyPath:@"_placeholderLabel.textColor"];
    [self.cepTextField setValue:self.cepTextField.font forKeyPath:@"_placeholderLabel.font"];
    self.cepTextField.placeholder = @"Calcular frete e prazo de entrega";
    self.productFreightCalculatorMessage.hidden = YES;
    self.productFreightCalculatorRecalculateButton.hidden = YES;
    self.sellerIdentifiers = @[@""].mutableCopy;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self _addToolBar];
    }
    else if (!self.shouldHideKeyboard)
    {
        self.cepTextField.returnKeyType = UIReturnKeyGo;
    }
}

#pragma mark - UI Actions

- (IBAction)calculateButtonTouched:(id)sender
{
    if (self.sellerIdentifiers == nil)
    {
        self.sellerIdentifiers = @[@""].mutableCopy;
    }
    
    [self calculateFreightResults];
}

- (void)calculateFreightResults
{
    [self beginFreightCalculate];
    
    NSString *cep = [self.cepTextField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
	
	NSArray *products = [self _productParamsArray:self.sellerIdentifiers];
	NSMutableArray *freightProducts = [NSMutableArray new];
	
	for (NSDictionary *product in products)
	{
		B2WFreightProduct *freightProduct = [[B2WFreightProduct alloc] initWithItemSku:product[@"sku"]
																			  quantity:product[@"quantity"]
																			   storeId:product[@"storeId"]
																	  promotionedPrice:product[@"promotionedPrice"]];
		
		[freightProducts addObject:freightProduct];
	}
	
    self.productFreightRequestOperation = [B2WAPIFreight requestEstimateWithPostalCode:cep productParamsArray:freightProducts block:^(id object, NSError *error) {
        if (error || object == nil)
        {
            [self freightCalculateError:error];
        }
        else
        {
            [self setupFreightResultWithObject:object];
        }
		
        [self endFreightCalculate];
    }];
}

- (void)setupFreightResultWithObject:(id)object
{
    B2WFreightCalculationResult *freightResult = (B2WFreightCalculationResult *) object;
    NSMutableDictionary *result = freightResult.productResults;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (self.isBeingPresentedFromProductView)
        {
            [self showFreightResult:result];
        }
        else if (self.delegate)
        {
            [self.delegate didLoadEstimateWithFreightResultDictionary:result];
        }
    }
    else
    {
        [self showFreightResult:result];
    }
}

- (void)showFreightResult:(NSMutableDictionary *)result
{
    self.freightResult = (B2WFreightCalculationProduct *) [result objectForKey:self.sellerIdentifiers[0]];
    if ([self respondsToSelector:@selector(_showFreightCalculationResult:)])
    {
        [self _showFreightCalculationResult:self.freightResult];
    }
    if (self.delegate)
    {
        [self.delegate didLoadEstimateWithFreightResultDictionary:result];
    }
}

- (void)beginFreightCalculate
{
    if (self.delegate)
    {
        [self.delegate beginCalculateFreight];
    }
    
    [self.freightLoadingIndicator setHidden:NO];
    [self.freightLoadingIndicator startAnimating];
    
    self.cepTextField.enabled = NO;
    self.doneButton.enabled   = YES;
    
    [self _closeKeyboard];
}

- (void)endFreightCalculate
{
    self.cepTextField.enabled = YES;
    [self.freightLoadingIndicator stopAnimating];
    [self.freightLoadingIndicator setHidden:YES];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.delegate && self.isBeingPresentedFromProductView)
    {
        [self.delegate endCalculateFreight];
    }
}

- (void)freightCalculateError:(NSError *)error
{
    DLog(@"Calculate freight error: %@", error);
    if (error.code != NSURLErrorCancelled)
    {
        [self _showCalculateFreightResponseError:error];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.delegate)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(reloadFreight)])
            {
                [self.delegate reloadFreight];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(resetMarketplaceFreightCalculation)])
            {
                [self.delegate resetMarketplaceFreightCalculation];
            }
            
            [self.cepTextField setEnabled:YES];
            [self.cepTextField becomeFirstResponder];
            
            return;
        }
        else
        {
            [self.doneButton setEnabled:NO];
            if (self.delegate)
            {
                [self.delegate didLoadEstimateWithFreightResultDictionary:nil];
            }
        }
    }
}

- (void)cancelFreightRequestOperation
{
    if (self.productFreightRequestOperation && self.productFreightRequestOperation.isExecuting)
    {
        [self.productFreightRequestOperation cancel];
    }
}

- (IBAction)cepTextFieldActive:(id)sender
{
    [self _hideSubviewsInView:self.contentView];
    
    self.cepTextField.hidden = NO;
    
    [self.cepTextField becomeFirstResponder];
}

- (IBAction)pressedCancelButton:(UIBarButtonItem *)sender
{
    [self resetCepTextField];
}

- (void)resetCepTextField
{
    self.cepTextField.text = @"";
    self.cepTextField.placeholder = @"Calcular frete e prazo de entrega";
    [self _changePositionOfCepTextField:@""];
    [self _closeKeyboard];
}

- (void)resetCalculateFreight
{
    [UIView transitionWithView:self duration:kDefaultFreightAnimationTime options:UIViewAnimationOptionTransitionNone animations:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(removeResultView)])
        {
            [self.delegate removeResultView];
        }
		
        [self _hideSubviewsInView:self.contentView];
        self.cepTextField.hidden = NO;
        self.productFreightCalculatorRecalculateButton.hidden = YES;
        [self resetCepTextField];
        
    } completion:nil];
}

#pragma mark - Public Methods

- (IBAction)recalculateFreight:(id)sender
{
    self.productFreightCalculatorRecalculateButton.hidden = YES;
    
    if (self.isMarketplace && self.delegate && [self.delegate respondsToSelector:@selector(resetMarketplaceFreightList)])
    {
        [self.delegate resetMarketplaceFreightList];
    }
    
    [UIView transitionWithView:self duration:kDefaultFreightAnimationTime options:UIViewAnimationOptionTransitionNone animations:^{
        
        if (self.delegate  && [self.delegate respondsToSelector:@selector(removeResultView)])
        {
            [self.delegate removeResultView];
        }
        self.cepTextField.text = @"";
        [self _changePositionOfCepTextField:@""];
        [self.cepTextField becomeFirstResponder];
        
        [self performSelector:@selector(cepTextFieldActive:) withObject:nil afterDelay:0.4];
        
    } completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.cepTextField)
    {
        if (self.cepTextField.text.length == kPRODUCT_MAX_SIZE_CEP)
        {
            [self calculateButtonTouched:nil];
            return YES;
        }
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.cepTextField)
    {
        self.cepTextField.placeholder = @"Digite seu CEP";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.cepTextField && textField.text.length == 0)
    {
        [self pressedCancelButton:nil];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)aText{
    
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:aText];
    if (textField == self.cepTextField)
    {
        if (newText.length > kPRODUCT_MAX_SIZE_CEP) return NO;
        
        self.doneButton.enabled = (newText.length >= kPRODUCT_MAX_SIZE_CEP);
        [self _changePositionOfCepTextField:newText];
        
        if ([self _isAddingNewNumberInCep:newText] && newText.length == kPRODUCT_MIN_SIZE_CEP)
        {
            textField.text = [NSString stringWithFormat:@"%@-", textField.text];
        }
        else if (newText.length > kPRODUCT_MAX_SIZE_CEP)
        {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.cepTextField)
    {
        if (self.productSKU == nil || self.productSKU.length == 0)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(showNilSKUMessage)])
            {
                [self.delegate showNilSKUMessage];
            }
            
            return NO;
        }
        
        if (self.shouldHideKeyboard)
        {
            UIView *clearView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            clearView.backgroundColor = [UIColor clearColor];
            self.cepTextField.inputView = clearView;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self _changePositionOfCepTextField:@""];
    return YES;
}

#pragma mark - Number Pad

- (void)didPressFreightCalculatorNumberPadButton:(id)sender
{
    UIButton *pressedButton = (UIButton *)sender;
    
    if (pressedButton.tag < 10)
    {
        if (self.cepTextField.text.length < kPRODUCT_MAX_SIZE_CEP)
        {
            if (self.cepTextField.text.length == 5)
            {
                self.cepTextField.text = [NSString stringWithFormat:@"%@-%ld", self.cepTextField.text, (long)pressedButton.tag];
            }
            else
            {
                self.cepTextField.text = [NSString stringWithFormat:@"%@%ld",self.cepTextField.text, (long)pressedButton.tag];
            }
        }
    }
    else if (pressedButton.tag == 1001) // limpar
    {
        if ([self.cepTextField.text length] > 0)
        {
            self.cepTextField.text = [self.cepTextField.text substringToIndex:[self.cepTextField.text length]-1];
        }
    }
    else if (pressedButton.tag == 1003) // calcular
    {
        if (self.delegate)
        {
            [self.delegate removeNumberPad];
        }
        [self calculateButtonTouched:pressedButton];
    }
    
    [self _changePositionOfCepTextField:self.cepTextField.text];
}

#pragma mark - Private Methods

- (void)showInexistingPostalCodeAlertForFreightCalculationResult:(B2WFreightCalculationProduct *)freightCalculationResult
{
    if (freightCalculationResult.resultType == B2WAPIFreightCalculationResultInexistingPostalCode)
    {
        [IDMAlertViewManager showAlertWithTitle:@"CEP inexistente"
                                        message:nil
                                       priority:IDMAlertPriorityMedium
                                        success:^(NSUInteger selectedIndex) {
                                            
                                            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                                            {
                                                [self.cepTextField becomeFirstResponder];
                                            }
                                            else if (self.delegate && self.isBeingPresentedFromProductView)
                                            {
                                                [self.delegate resetMarketplaceFreightCalculation];
                                            }
                                            
                                        } failure:nil];
    }
}

- (void)_createFreightCalculationResultViewErrorWithMessage:(NSString *)errorMessage
{
    [UIView transitionWithView:self duration:kDefaultFreightAnimationTime options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
        
        [self _hideSubviewsInView:self.contentView];
        
        self.productFreightCalculatorMessage.text   = errorMessage;
        self.productFreightCalculatorMessage.hidden = NO;
        self.doneButton.enabled                     = NO;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            self.productFreightCalculatorRecalculateButton.hidden = NO;
        }
        
    } completion:nil];
}

- (void)_hideSubviewsInView:(UIView *)viewToHideSubviews
{
    for (UIView *view in viewToHideSubviews.subviews)
    {
        if (view.tag == 0)
        {
            view.hidden = YES;
        }
    }
}

- (void)_createFreightCalculationResultAlertWithErrorTitle:(NSString *)title andMessage:(NSString *)message
{
    self.freightCalculationResultTitle = title;
    self.freightCalculationResultMessage = message;
    
    [self _showWarningAlertWithTitle:self.freightCalculationResultTitle andMessage:self.freightCalculationResultMessage];
}

- (void)_createFreightCalculationResultViewSuccess
{
    [UIView transitionWithView:self duration:kDefaultFreightAnimationTime options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        
        [self _hideSubviewsInView:self.contentView];
        
        self.productFreightCalculatorMessage.text = self.cepTextField.text;
        self.productFreightCalculatorMessage.hidden = NO;
        self.doneButton.enabled = NO;
        
        self.productFreightCalculatorRecalculateButton.hidden = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
        
        if (self.delegate && self.isBeingPresentedFromProductView)
        {
            [self.delegate didLoadEstimateWithFreightResult:self.freightResult];
        }
        
    } completion:nil];
}

- (void)_showFreightCalculationResult:(B2WFreightCalculationProduct *)freightResult
{
    NSError *error = (NSError *)freightResult;
    if (freightResult && [error isKindOfClass:[B2WFreightCalculationProduct class]])
    {
        NSString *errorTitle = nil;
        NSString *errorMessage = nil;
        
        switch (freightResult.resultType)
        {
            case 0:
                [self _createFreightCalculationResultViewSuccess];
                break;
                
            case 1:
                [self showInexistingPostalCodeAlertForFreightCalculationResult:freightResult];
                break;
                
            case 2:
                errorTitle   = @"Não realizamos entregas neste CEP para itens volumosos ou pesados";
                errorMessage = @"Por favor, cadastre outro endereço.";
                break;
                
            case 3:
                errorTitle   = @"Não realizamos entregas neste CEP";
                errorMessage = @"Por favor, cadastre outro endereço.";
                break;
                
            case 4:
                errorTitle   = @"Os Correios não estão mais realizando entregas nesse CEP";
                errorMessage = @"Todas as encomendas destinadas para este endereço serão entregues na agência mais próxima, conforme comunicado dos Correios. Sua encomenda ficará à disposição por até cinco dias úteis. A não retirada implicará na devolução do(s) produto(s). Neste caso, o valor da compra será restituído conforme forma de pagamento utilizada.";
                break;
                
            case 5:
                errorTitle   = @"Atenção";
                errorMessage = @"Ocorreu um erro ao consultar o CEP, por favor tente novamente mais tarde.";
                break;
                
            case 6:
                [self _createFreightCalculationResultViewErrorWithMessage:@"Produto sem estoque"];
                break;
        }
        
        if (errorTitle && errorMessage)
        {
            [self _createFreightCalculationResultAlertWithErrorTitle:errorTitle andMessage:errorMessage];
        }
    }
}

- (void)_showWarningAlertWithTitle:(NSString *) title andMessage:(NSString *) message{
    
    title = [NSString stringWithFormat:@"\u26A0 %@", title];
    
    [IDMAlertViewManager showAlertWithTitle:title
                                    message:message
                                   priority:IDMAlertPriorityMedium
                                    success:^(NSUInteger selectedIndex) {
                                        if (self.freightResult && self.freightResult.resultType == 4)
                                        {
                                            [self _createFreightCalculationResultViewSuccess];
                                        }
                                        else
                                        {
                                            [self resetCalculateFreight];
                                        }
                                    } failure:nil];
}

- (void)_showCalculateFreightResponseError:(NSError *)error
{
    NSString *title = kDefaultConnectionErrorTitle;
    NSString *message = kDefaultConnectionErrorMessage;
    
    if (error.code != kCFURLErrorNotConnectedToInternet && (error.code == kCFURLErrorTimedOut || error.code == kCFURLErrorUnsupportedURL || error.code == kCFURLErrorCannotFindHost))
    {
        title   = kCalculateFreightErrorTitle;
        message = kCalculateFreightErrorMessage;
    }
    
    [self _showWarningAlertWithTitle:title andMessage:message];
}

- (void)_closeKeyboard
{
    [self.cepTextField resignFirstResponder];
}

- (void)_addToolBar
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, screenWidth, 44.0)];
    UIColor *buttonsColor = [UIWindow appearance].tintColor;
    
    self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancelar" style:UIBarButtonItemStylePlain target:self action:@selector(pressedCancelButton:)];
    [self.cancelButton setTitleTextAttributes:@{NSForegroundColorAttributeName:buttonsColor} forState:UIControlStateNormal];
    
    self.spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.doneButton  = [[UIBarButtonItem alloc] initWithTitle:@"Consultar" style:UIBarButtonItemStylePlain target:self action:@selector(calculateButtonTouched:)];
    
    [self.doneButton setTitleTextAttributes:@{NSForegroundColorAttributeName:buttonsColor} forState:UIControlStateNormal];
    [self.doneButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]} forState:UIControlStateDisabled];
    self.doneButton.enabled = NO;
    
    toolBar.items = [NSArray arrayWithObjects:self.cancelButton, self.spaceButton, self.doneButton, nil];
    
    self.cepTextField.inputAccessoryView = toolBar;
}

- (void)_changePositionOfCepTextField:(NSString *)text
{
    int newY = (text.length == 0 ? 0 : 5);
    self.cepTextFieldTopConstraint.constant = newY;
    
    [self layoutIfNeeded];
}

- (BOOL)_isAddingNewNumberInCep:(NSString *)newNumber
{
    return (newNumber.length > self.cepTextField.text.length);
}

- (NSMutableArray *)_productParamsArray:(NSMutableArray *)sellerIdentifiers
{
    NSMutableArray *productParamsArray = [[NSMutableArray alloc] initWithCapacity:sellerIdentifiers.count];
	
    for (NSString *sellerIdentifier in sellerIdentifiers)
	{
        NSMutableDictionary *productParams = [[NSMutableDictionary alloc] initWithDictionary:@{@"sku": self.productSKU,
                                                                                               @"quantity": @1,
                                                                                               @"repackaged": @NO}];
        if (sellerIdentifier && sellerIdentifier.length > 0)
        {
            [productParams setObject:sellerIdentifier forKey:@"storeId"];
			
			for (B2WProductMarketplacePartner *partner in self.sellers)
            {
                if ([partner.identifier isEqualToString:sellerIdentifier])
                {
                    NSString *priceString = [self.productPrice stringByReplacingOccurrencesOfString:@"R$ " withString:@""];
                    priceString = [priceString stringByReplacingOccurrencesOfString:@"." withString:@""];
                    priceString = [priceString stringByReplacingOccurrencesOfString:@"," withString:@"."];
                    [productParams setObject:priceString forKey:@"promotionedPrice"];
                }
            }
        }
        else
        {
            NSString *priceString = [self.productPrice stringByReplacingOccurrencesOfString:@"R$ " withString:@""];
            priceString = [priceString stringByReplacingOccurrencesOfString:@"." withString:@""];
            priceString = [priceString stringByReplacingOccurrencesOfString:@"," withString:@"."];
            [productParams setObject:priceString forKey:@"promotionedPrice"];
        }
		
        [productParamsArray addObject:productParams];
    }
    
    return productParamsArray;
}

@end