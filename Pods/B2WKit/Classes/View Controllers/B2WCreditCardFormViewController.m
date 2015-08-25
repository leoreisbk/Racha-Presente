//
//  B2WCreditCardFormViewController.m
//  B2WKit
//
//  Created by Eduardo Callado on 7/21/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WCreditCardFormViewController.h"

#import "B2WCardValidator.h"
#import "B2WAPICustomer.h"
#import "B2WFormCell.h"
#import "B2WFormElement.h"
#import "B2WCreditCardCell.h"
#import "B2WValidator.h"
#import "B2WCreditCardCVVViewController.h"

#import "SVProgressHUD.h"
#import "IDMAlertViewManager.h"

@interface CreditCard : NSObject

@property (nonatomic, assign) CreditCardBrand brand;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *CVVImage;
@property (nonatomic, strong) NSString *CVVInstructions;

+ (CreditCard *)creditCardWithBrand:(CreditCardBrand)brand name:(NSString *)name image:(UIImage *)image CVVInstructions:(NSString *)instructions CVVImage:(UIImage *)CVVImage;

@end

@implementation CreditCard

+ (CreditCard *)creditCardWithBrand:(CreditCardBrand)brand name:(NSString *)name image:(UIImage *)image CVVInstructions:(NSString *)instructions CVVImage:(UIImage *)CVVImage{
	CreditCard *card = [CreditCard new];
	[card setBrand:brand];
	[card setName:name];
	[card setImage:image];
	[card setCVVInstructions:instructions];
	[card setCVVImage:CVVImage];
	return card;
}

@end

@interface B2WCreditCardFormViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *lockImageView;
@property (nonatomic, strong) IBOutlet UICollectionView *cardCollectionView;

@property (nonatomic, strong) IBOutlet UITextField *numberTextField;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextField *expirationTextField;
@property (nonatomic, strong) IBOutlet UITextField *CVVTextField;

@property (nonatomic, strong) IBOutlet UIButton *CVVInstructionsButton;

@property (nonatomic, strong) CreditCard *selectedCreditCard;
@property (nonatomic, strong) NSArray *creditCards;

@property (nonatomic, strong) NSArray *formElementGroups;

@end

@implementation B2WCreditCardFormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.lockImageView setImage:[B2WKitUtils imageNamed:@"icn-lock-credit-card"]];
	
	[self.CVVInstructionsButton.layer setCornerRadius:15];
	[self.CVVInstructionsButton.layer setBorderWidth:1];
	[self.CVVInstructionsButton.layer setBorderColor:[B2WAccountManager sharedManager].appPrimaryColor.CGColor];
    
	B2WAccountManager *customerManager = [B2WAccountManager sharedManager];
	
	if (customerManager.isCreatingNewAccount)
	{
		// self.navigationItem.leftBarButtonItem = nil;
		
		// [self refreshFormWithCreditCard:customerManager.creditCard];
	}
	else
	{
//		[self.navigationItem.rightBarButtonItem setTitle:@"Salvar"];
		
//		[SVProgressHUD showWithStatus:@"Carregando..." maskType:SVProgressHUDMaskTypeGradient];
//		
//		void (^completion)(id, NSError *) = ^(NSArray *object, NSError *error) {
//            // NSLog(@"%@", object == nil ? error : object);
//			
//			if (error)
//			{
//				NSLog(@"error = %@", error.localizedDescription);
//				
//				[UIAlertView showAlertViewWithTitle:error.localizedDescription];
//				
//				[self dismissViewControllerAnimated:YES completion:nil];
//				
//				return;
//			}
//			
//			[SVProgressHUD dismiss];
//			
//            [customerManager fillUpCreditCardInfo:object];
//			
//			if (object.count == 0)
//			{
//				// [UIAlertView showAlertViewWithTitle:@"Não há cartão cadastrado."];
//				NSLog(@"Não há cartão cadastrado.");
//			}
//			else
//			{
//				[self refreshFormWithCreditCard:customerManager.creditCard];
//			}
//        };
//		
//		[[B2WAccountManager currentCustomer] requestCreditCardsWithBlock:completion];
	}
	
	self.creditCards = @[[CreditCard creditCardWithBrand:CreditCardBrandVisa
													name:[B2WValidatorCard convertToString:CreditCardBrandVisa]
												   image:[B2WAccountManager cardImageName:@"icn-card-visa"]
										 CVVInstructions:@"Está localizado no verso do cartão e corresponde aos três últimos dígitos da faixa numérica."
												CVVImage:[B2WAccountManager cardImageName:@"icn-3-CVV"]],
						 
						 [CreditCard creditCardWithBrand:CreditCardBrandMasterCard
													name:[B2WValidatorCard convertToString:CreditCardBrandMasterCard]
												   image:[B2WAccountManager cardImageName:@"icn-card-mastercard"]
										 CVVInstructions:@"Está localizado no verso do cartão e corresponde aos três últimos dígitos da faixa numérica."
												CVVImage:[B2WAccountManager cardImageName:@"icn-3-CVV"]],
						 
						 [CreditCard creditCardWithBrand:CreditCardBrandAmex
													name:[B2WValidatorCard convertToString:CreditCardBrandAmex]
												   image:[B2WAccountManager cardImageName:@"icn-card-american"]
										 CVVInstructions:@"Corresponde aos 4 dígitos impressos na frente do cartão. Localizado a direita e acima do número do cartão."
												CVVImage:[B2WAccountManager cardImageName:@"icn-amex-CVV"]],
						 
						 [CreditCard creditCardWithBrand:CreditCardBrandDinersClub
													name:[B2WValidatorCard convertToString:CreditCardBrandDinersClub]
												   image:[B2WAccountManager cardImageName:@"icn-card-diners"]
										 CVVInstructions:@"Está localizado no verso do cartão e corresponde aos quatro últimos dígitos da faixa numérica."
												CVVImage:[B2WAccountManager cardImageName:@"icn-4-CVV"]],
						 
						 [CreditCard creditCardWithBrand:CreditCardBrandAura
													name:[B2WValidatorCard convertToString:CreditCardBrandAura]
												   image:[B2WAccountManager cardImageName:@"icn-card-aura"]
										 CVVInstructions:@"Está localizado na frente do cartão e corresponde aos três últimos dígitos da faixa numérica."
												CVVImage:[B2WAccountManager cardImageName:@"icn-aura-CVV"]],
						 
						 [CreditCard creditCardWithBrand:CreditCardBrandHiperCard
													name:[B2WValidatorCard convertToString:CreditCardBrandHiperCard]
												   image:[B2WAccountManager cardImageName:@"icn-card-hipercard"]
										 CVVInstructions:@"Está localizado no verso do cartão e corresponde aos quatro últimos dígitos da faixa numérica."
												CVVImage:[B2WAccountManager cardImageName:@"icn-4-CVV"]]];
	
	self.formElementGroups = @[@[[B2WFormElement formElementWithKey:@"number" textField:self.numberTextField error:@""],
								 [B2WFormElement formElementWithKey:@"holderName" textField:self.nameTextField error:@""],
								 [B2WFormElement formElementWithKey:@"expirationDate" textField:self.expirationTextField error:@""],
								 [B2WFormElement formElementWithKey:@"verificationCode" textField:self.CVVTextField error:@""]]];
	
	[self refreshCVVInstructions];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackScreenView"
														object:self
													  userInfo:@{@"screenName" : @"Cadastro - Cartão de Crédito"}];
}

#pragma mark - TableView

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return @"• Boleto Bancário\n• Alterar Endereço de Entrega\n• Alterar Cartão de Crédito\n• Usar 2 Cartões de Crédito\n• Aplicar Vale ou Cupom de Desconto";
    } else return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.showingOtherPaymentOptions ? 2 : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1)
    {
		return [super tableView:tableView heightForRowAtIndexPath:indexPath];
	}
	else
    {
		B2WFormElement *formElement = self.formElementGroups[indexPath.section][indexPath.row];
        
        NSString *error = formElement.error;
        
        if (indexPath.row == 2)
		{
            B2WFormElement *CVVFormElement = self.formElementGroups[indexPath.section][indexPath.row + 1];
            
            if (formElement.error.length == 0)
            {
				error = CVVFormElement.error;
            }
            else if ((formElement.error.length > 0 && CVVFormElement.error.length > 0) && (![formElement.error isEqualToString:kEmptyFieldError] && ![CVVFormElement.error isEqualToString:kEmptyFieldError]))
            {
                error = [error stringByAppendingString:[NSString stringWithFormat:@" %@", CVVFormElement.error]];
            }
        }
        
		if (error.length > 0)
		{
			B2WFormCell *cell = (B2WFormCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			
			CGRect errorTextRect = [error boundingRectWithSize:CGSizeMake(cell.errorLabel.bounds.size.width - 10, 50000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cell.errorLabel.font} context:nil];
			return 8 + cell.textField.bounds.size.height + 8 + errorTextRect.size.height + 7; // Top marging + text field height + spacing + error label height + bottom marging
		}
		
		return 54;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.section == 0) {
		B2WFormElement *formElement = self.formElementGroups[indexPath.section][indexPath.row];
		
		B2WFormCell *formCell = (B2WFormCell *)cell;
		[formCell.errorLabel setText:formElement.error];
		[formCell.errorLabel setHidden:formElement.error.length == 0];
		[formCell.errorImageView setHidden:formElement.error.length == 0]; formCell.errorImageView.image = [B2WAccountManager alertImage];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1 && indexPath.row == 0) // Other payment options
	{
		if (self.creditCardFormViewControllerDelegate && [self.creditCardFormViewControllerDelegate respondsToSelector:@selector(showCheckoutViewControllerSelected:)]) {
			[self.creditCardFormViewControllerDelegate showCheckoutViewControllerSelected:self];
		}
	}
}

#pragma mark - CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.creditCards.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	CreditCard *card = self.creditCards[indexPath.row];
	
	B2WCreditCardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
	[cell.imageView setImage:card.image];
	[cell.imageView setAlpha:(self.selectedCreditCard && card != self.selectedCreditCard) ? 0.2 : 1];
	
	return cell;
}

#pragma mark - TextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *finalText = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	if (textField == self.nameTextField)
    {
        [textField setText:finalText.uppercaseString];
		
		return NO;
    }
	else if (textField == self.numberTextField)
	{
		[textField setText:finalText.maskedCardNumberString];
        
        if ([textField.text length] > 6)
        {
            NSString *bin = [[finalText stringByRemovingMask] substringWithRange:NSMakeRange(0, 6)];
            [B2WAPIPayment requestCreditCardIdWithBin:bin block:^(id object, NSError *error) {
                NSString *brandID = [object valueForKey:@"id"];
                [self selectCreditCardWithBrand:brandID];
                [self.cardCollectionView reloadData];
            }];
        }
        else
        {
            self.selectedCreditCard = nil;
            [self.cardCollectionView reloadData];
            
            CATransition *transition = [CATransition animation];
            [transition setType:kCATransitionFade];
            [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            [transition setDuration:0.2];
            [self.cardCollectionView.layer addAnimation:transition forKey:nil];
            
            [self refreshCVVInstructions];
        }
		
		return NO;
	}
	else if (textField == self.expirationTextField)
	{
		[textField setText:finalText.maskedExpirationDateString];
		
		return NO;
	}
	else if (textField == self.CVVTextField)
	{
		[textField setText:finalText.maskedCVVString];
		
		return NO;
	}
	
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	self.selectedCreditCard = nil;
	[self.cardCollectionView reloadData];
	
	CATransition *transition = [CATransition animation];
	[transition setType:kCATransitionFade];
	[transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
	[transition setDuration:0.2];
	[self.cardCollectionView.layer addAnimation:transition forKey:nil];
	
	[self refreshCVVInstructions];
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	B2WFormElement *formElement = [self formElementForTextField:textField];
	
	[self setErrorWithKey:formElement.key message:textField.text.length > 0 ? @"" : kEmptyFieldError overwriteCurrentError:YES];
}

#pragma mark - Customer Manager

- (void)refreshFormWithCreditCard:(B2WCreditCard *)creditCard
{
	self.numberTextField.text = creditCard.number;
    self.nameTextField.text = creditCard.holderName;
    self.CVVTextField.text = creditCard.verificationCode;
    
    if (creditCard.expirationMonth != 0 && creditCard.expirationYear != 0)
    {
        self.expirationTextField.text = [NSString stringWithFormat:@"%ld/%ld", (unsigned long)creditCard.expirationMonth, (unsigned long)creditCard.expirationYear];
    }
}

- (void)setCreditCardFromForm
{
	B2WCreditCard *creditCard = (B2WCreditCard *)[B2WAccountManager sharedManager].creditCard;
    creditCard.number = [self.numberTextField.text stringByRemovingMask];
    creditCard.holderName = self.nameTextField.text;
    creditCard.verificationCode = self.CVVTextField.text;
    creditCard.expirationMonth = [[self.expirationTextField.text componentsSeparatedByString:@"/"].firstObject integerValue];
    creditCard.expirationYear = [[self.expirationTextField.text componentsSeparatedByString:@"/"].lastObject integerValue];
	
	CreditCardBrand brand = [B2WValidatorCard cardBrandWithNumber:creditCard.number];
	creditCard.brand = [B2WValidatorCard convertToString:brand];
	
    //creditCard.isB2WCard = NO;
}

#pragma mark - Errors

- (void)setErrorWithKey:(NSString *)key message:(NSString *)errorMessage overwriteCurrentError:(BOOL)shouldOverwrite
{
	B2WFormElement *formElement = [self formElementForKey:key];
	
	if (formElement && (shouldOverwrite || formElement.error.length == 0))
	{
		[formElement setError:errorMessage];
		
		B2WFormCell *cell = (B2WFormCell *)[self.tableView cellForRowAtIndexPath:[self indexPathForTextField:formElement.textField]];
		[cell.errorLabel setText:formElement.error];
		[cell.errorLabel setHidden:formElement.error.length == 0];
		[cell.errorImageView setHidden:formElement.error.length == 0]; cell.errorImageView.image = [B2WAccountManager alertImage];
		[self.tableView beginUpdates];
		[self.tableView endUpdates];
	}
}

- (void)showValidationErrors:(NSArray *)errors
{
	for (NSDictionary *error in errors)
	{
		NSString *key = error[@"fieldName"];
		NSString *fieldKey = [key componentsSeparatedByString:@"."].lastObject;
		NSString *message = error[@"message"];
		
		if ([fieldKey isEqualToString:@"brand"])
		{
			fieldKey = @"number";
		}
		
		if ([fieldKey isEqualToString:@"month"] || [fieldKey isEqualToString:@"year"])
		{
			fieldKey = @"expirationDate";
		}
		
		[self setErrorWithKey:fieldKey message:message overwriteCurrentError:NO];
		
//        for (B2WFormElement *formElement in self.formElementGroups)
//        {
//            if ([formElement.key isEqualToString:key])
//            {
//                if ([formElement.error isEqualToString:@""])
//                {
//                    formElement.error = error;
//                    
//                    NSInteger formElementIndex = formElement.textField == self.CVVTextField ? [self.formElementGroups indexOfObject:formElement] - 1 : [self.formElementGroups indexOfObject:formElement];
//                    
//                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:formElementIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//                    [self.tableView beginUpdates];
//                    [self.tableView endUpdates];
//                }
//            }
//        }
    }
}

#pragma mark - Networking

- (void)registerCreditCard
{
    void (^completion)(id, NSError *) = ^(id object, NSError *error) {
        if (error)
        {
			[self.navigationItem setRightBarButtonItem:[self activateBarItem] animated:YES];
	
			[self.tableView setUserInteractionEnabled:YES];
			
			NSDictionary *localizedDescription = (NSDictionary *)error.localizedDescription;

			if ([localizedDescription isKindOfClass:[NSString class]])
			{
				[UIAlertView showAlertViewWithTitle:(NSString *)localizedDescription];
			}
			else
			//  if ([localizedDescription isKindOfClass:[NSDictionary class]])
			{
				if (localizedDescription && (! [localizedDescription.allKeys containsObject:@"validationErrors"])) // erro do servidor
				{
					[UIAlertView showAlertViewWithTitle:localizedDescription[@"message"]];
				}
				else // é possível ter erro de validação
				{
					NSMutableArray *validationErrors = [[NSMutableArray alloc] initWithArray:localizedDescription[@"validationErrors"]];
					
					if (validationErrors.count > 0) // há erro de validação
					{
						[self showValidationErrors:validationErrors];
					}
				}
			}
        }
        else
        {
			if ([B2WAccountManager sharedManager].isCreatingNewAccount)
			{
				[self requestAddressInformations];
			}
			else
			{
				[self requestCreditCardInformations];
			}
        }
    };
	
	[self.navigationItem setRightBarButtonItem:[self loadingBarItem] animated:YES];
	[self.tableView setUserInteractionEnabled:NO];
    
	B2WAccountManager *customerManager = [B2WAccountManager sharedManager];

	[B2WAPICustomer setPersistenceEnabled:YES];

	if ([B2WAPIAccount isLoggedIn])
	{
		[[B2WAccountManager currentCustomer] addCreditCard:customerManager.creditCard block:completion];
	}
	else
	{
		// TODO: Tratar erro
	}
}

- (void)requestAddressInformations
{
	[[B2WAccountManager currentCustomer] requestAddressesWithBlock:^(id object, NSError *error) {
		if (error)
		{
			[self.navigationItem setRightBarButtonItem:[self activateBarItem] animated:YES];
			[self.tableView setUserInteractionEnabled:YES];
			
			/*NSData *data = [error.localizedDescription dataUsingEncoding:NSUTF8StringEncoding];
			 NSDictionary *localizedDescription = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;*/
			
			NSDictionary *localizedDescription = (NSDictionary *)error.localizedDescription;
			// NSString *errorCode = localizedDescription[@"errorCode"];
			
			if (localizedDescription && (! [localizedDescription.allKeys containsObject:@"validationErrors"])) // erro do servidor
			{
				[UIAlertView showAlertViewWithTitle:localizedDescription[@"message"]];
			}
			else // é possível ter erro de validação
			{
				NSMutableArray *validationErrors = [[NSMutableArray alloc] initWithArray:localizedDescription[@"validationErrors"]];
				
				if (validationErrors.count > 0) // há erro de validação
				{
					[self showValidationErrors:validationErrors];
				}
			}
		}
		else
		{
			B2WAddress *address = [object firstObject];
			[B2WAccountManager sharedManager].address = address;
			
			[self requestCreditCardInformations];
		}
	}];
}

- (void)requestCreditCardInformations
{
	[[B2WAccountManager currentCustomer] requestCreditCardsWithBlock:^(id object, NSError *error) {
		if (error)
		{
			[self.navigationItem setRightBarButtonItem:[self activateBarItem] animated:YES];
			[self.tableView setUserInteractionEnabled:YES];
			
			/*NSData *data = [error.localizedDescription dataUsingEncoding:NSUTF8StringEncoding];
			 NSDictionary *localizedDescription = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;*/
			
			NSDictionary *localizedDescription = (NSDictionary *)error.localizedDescription;
			// NSString *errorCode = localizedDescription[@"errorCode"];
			
			if (localizedDescription && (! [localizedDescription.allKeys containsObject:@"validationErrors"])) // erro do servidor
			{
				[UIAlertView showAlertViewWithTitle:localizedDescription[@"message"]];
			}
			else // é possível ter erro de validação
			{
				NSMutableArray *validationErrors = [[NSMutableArray alloc] initWithArray:localizedDescription[@"validationErrors"]];
				
				if (validationErrors.count > 0) // há erro de validação
				{
					[self showValidationErrors:validationErrors];
				}
			}
		}
		else
		{
            NSArray *creditCards = object;
			for (B2WCreditCard *card in object)
			{
				if ([[card.number substringToIndex:4] isEqualToString:[self.numberTextField.text substringToIndex:4]])
				{
					if ([card.holderName isEqualToString:self.nameTextField.text])
					{
						[B2WAccountManager sharedManager].creditCard = card;
						break;
					}
				}
			}
            if (self.isOneClickActivation) {
                [self registerOneClick];
            }
            else if (self.creditCardFormViewControllerDelegate) {
				// FIXME: https://fabric.io/ideais/ios/apps/com.b2winc.submarino/issues/55c1405d2f03874947c853a3
                [self.creditCardFormViewControllerDelegate creditCardFormViewController:self didCreateCreditCard:[B2WAccountManager sharedManager].creditCard];
            }
		}
	}];
}

- (void)registerOneClick
{
	void (^completion)(id, NSError *) = ^(id object, NSError *error) {
		[self.navigationItem setRightBarButtonItem:[self activateBarItem] animated:YES];
		[self.tableView setUserInteractionEnabled:YES];
		
		if (error)
		{
			NSDictionary *localizedDescription = (NSDictionary *)error.localizedDescription;
			
			if ([localizedDescription isKindOfClass:[NSString class]])
			{
				[UIAlertView showAlertViewWithTitle:(NSString *)localizedDescription];
			}
			else
			// if ([localizedDescription isKindOfClass:[NSDictionary class]])
			{
				if (localizedDescription && (! [localizedDescription.allKeys containsObject:@"validationErrors"])) // erro do servidor
				{
					[UIAlertView showAlertViewWithTitle:localizedDescription[@"message"]];
				}
				else // é possível ter erro de validação
				{
					NSMutableArray *validationErrors = [[NSMutableArray alloc] initWithArray:localizedDescription[@"validationErrors"]];
					
					if (validationErrors.count > 0) // há erro de validação
					{
						[self showValidationErrors:validationErrors];
					}
				}
			}
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackEvent"
																object:self
															  userInfo:@{@"category" : @"ui_action",
																		 @"action" : @"button_press",
																		 @"label" : @"one_click_activated",
																		 @"value" : @""}];
			
			[B2WAccountManager currentCustomer].oneClickEnabled = YES;
			
			// TODO: Rever condição do if
			if (! [B2WAccountManager sharedManager].isCreatingNewAccount && kIsIpad)
			{
				[self.presentingViewController viewWillAppear:YES];
			}
			
			// [UIAlertView showAlertViewWithTitle:[NSString stringWithFormat:@"%@ Ativado", [B2WAccountManager sharedManager].oneClickBrandName]];
			
			[self dismissViewControllerAnimated:YES completion:^{
				// FIXME: delegate is nil here
                if (self.creditCardFormViewControllerDelegate && [self.creditCardFormViewControllerDelegate respondsToSelector:@selector(oneClickActivationCompleted:)]) {
                    [self.creditCardFormViewControllerDelegate oneClickActivationCompleted:self];
                }
            }];
			
			[B2WAccountManager sharedManager].isCreatingNewAccount = NO;
		}
	};
	
	[B2WAPICustomer setPersistenceEnabled:YES];
	
	//
	//
	
	/*B2WAccountManager *customerManager = [B2WAccountManager sharedManager];

	B2WOneClickRelationship *oneClick = [B2WOneClickRelationship new];
	oneClick.addressIdentifier = [B2WAccountManager sharedManager].address.identifier;
	
	oneClick.creditCardNumber = [self.numberTextField.text stringByRemovingMask];
	oneClick.creditCardHolderName = [B2WAccountManager sharedManager].creditCard.holderName;
	oneClick.creditCardExpirationDate = @"2020-01";
	oneClick.creditCardIdentifier = [B2WAccountManager sharedManager].creditCard.identifier;
	oneClick.active = YES;*/
	
	//[[B2WAccountManager currentCustomer] addOneClickRelationship:oneClick block:completion];
	
	//
	//
	
	NSString *expirationDate = [NSString stringWithFormat:@"%d-%d", [B2WAccountManager sharedManager].creditCard.expirationYear, [B2WAccountManager sharedManager].creditCard.expirationMonth];
	NSDictionary *parameters = @{ @"addressId": [B2WAccountManager sharedManager].address.identifier,
								  @"creditCard": @{ @"number": [self.numberTextField.text stringByRemovingMask],
													@"holderName": [B2WAccountManager sharedManager].creditCard.holderName,
													@"expirationDate": expirationDate },
								  @"creditCardId": [B2WAccountManager sharedManager].creditCard.identifier
								  };
	
	[[B2WAccountManager currentCustomer] associateCreditCard:parameters block:completion];
}

#pragma mark - Custom

- (NSIndexPath *)indexPathForTextField:(UITextField *)textField
{
	for (NSArray *formElementGroup in self.formElementGroups)
	{
		B2WFormElement *formElement = [formElementGroup filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.textField == %@", textField]].firstObject;
	
		if (formElement)
		{
			return [NSIndexPath indexPathForRow:(textField == self.CVVTextField ? [formElementGroup indexOfObject:formElement] - 1 : [formElementGroup indexOfObject:formElement]) inSection:[self.formElementGroups indexOfObject:formElementGroup]];
		}
	}
	
	return nil;
}

- (B2WFormElement *)formElementForTextField:(UITextField *)textField {
	for (NSArray *formElementGroup in self.formElementGroups) {
		B2WFormElement *formElement = [formElementGroup filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.textField == %@", textField]].firstObject;
		
		if (formElement) {
			return formElement;
		}
	}
	
	return nil;
}

- (B2WFormElement *)formElementForKey:(NSString *)key {
	for (NSArray *formElementGroup in self.formElementGroups) {
		B2WFormElement *formElement = [formElementGroup filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.key == %@", key]].firstObject;
		
		if (formElement) {
			return formElement;
		}
	}
	
	return nil;
}

- (void)selectCreditCardWithBrand:(NSString *)brand {
	BOOL found = NO;
	
	for (CreditCard *card in self.creditCards) {
		if (card.brand == [B2WValidatorCard convertToCreditCardBrand:brand]) {
			self.selectedCreditCard = card;
			found = YES;
			break;
		}
	}
	
	if (!found) {
		self.selectedCreditCard = nil;
	}
}

- (void)refreshCVVInstructions {
	if (self.selectedCreditCard) {
		[self.CVVInstructionsButton setHidden:NO];
	}
	else {
		[self.CVVInstructionsButton setHidden:YES];
	}
	
	CATransition *transition = [CATransition animation];
	[transition setType:kCATransitionFade];
	[transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
	[transition setDuration:0.2];
	[self.CVVInstructionsButton.layer addAnimation:transition forKey:nil];
}

- (UIBarButtonItem *)activateBarItem {
	UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"Ativar" style:UIBarButtonItemStyleDone target:self action:@selector(confirmButtonPressed)];
	return barItem;
}

- (UIBarButtonItem *)loadingBarItem {
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[activityIndicator setColor:[B2WAccountManager sharedManager].appLoadingColor];
	[activityIndicator startAnimating];
	
	UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	return barItem;
}

#pragma mark - Popover

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection
{
	return UIModalPresentationNone;
}

#pragma mark - Actions

- (IBAction)CVVInstructionsButtonAction:(UIButton *)sender
{	
	B2WCreditCardCVVViewController *CVVViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreditCardCVVViewController"];
	CVVViewController.modalPresentationStyle = UIModalPresentationPopover;
	CVVViewController.preferredContentSize = CGSizeMake(256, 137);
	CVVViewController.popoverPresentationController.delegate = self;
	CVVViewController.popoverPresentationController.sourceView = sender;
	CVVViewController.popoverPresentationController.sourceRect = sender.bounds;
	CVVViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
	CVVViewController.popoverPresentationController.backgroundColor = [UIColor whiteColor];
	CVVViewController.image = self.selectedCreditCard.CVVImage;
	CVVViewController.instructions = self.selectedCreditCard.CVVInstructions;
	[self presentViewController:CVVViewController animated:YES completion:nil];
}

- (IBAction)cancelBarButtonAction:(UIBarButtonItem *)sender
{
	[B2WAccountManager sharedManager].isCreatingNewAccount = NO;
	
    if (self.isOneClickActivation) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TrackEvent"
                                                            object:self
                                                          userInfo:@{@"category" : @"ui_action",
                                                                     @"action" : @"button_press",
                                                                     @"label" : @"one_click_cancelled",
                                                                     @"value" : @""}];
    }
	
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.isOneClickActivation) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"OneClickActivationCancelled" object:nil];
        }
    }];
}

- (IBAction)confirmButtonPressed
{
	[self.tableView endEditing:YES];
	
	for (NSArray *formElementGroup in self.formElementGroups)
	{
		for (B2WFormElement *formElement in formElementGroup)
		{
			if (formElement.textField.text.length == 0)
			{
				[self setErrorWithKey:formElement.key message:kEmptyFieldError overwriteCurrentError:YES];
			}
		}
	}
    
    // Check for errors
	for (NSArray *formElementGroup in self.formElementGroups)
	{
		for (B2WFormElement *formElement in formElementGroup)
		{
			if (formElement.error.length > 0)
			{
				[self.tableView scrollToRowAtIndexPath:[self indexPathForTextField:formElement.textField] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
				return;
			}
		}
	}
    
    [self setCreditCardFromForm];
    
    [self registerCreditCard];
}

@end
