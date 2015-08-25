//
//  B2WMarketplaceController.m
//  B2WKit
//
//  Created by rodrigo.fontes on 27/08/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

#import "B2WMarketplaceController.h"
#import "B2WAPIClient.h"

@implementation B2WProduct (Marketplace)

- (BOOL)shouldDisplayMarketplacePartners
{
    return (self.marketPlaceInformation && self.marketPlaceInformation.partners && self.marketPlaceInformation.partners.count > 0);
}

- (NSString *)defaultPartnerForBrand:(NSString *)brand
{
    if (self.partnerId && self.partnerId.length > 0)
    {
        return self.partnerName;
    }
    return brand;
}

@end

@implementation B2WMarketplaceController

- (id)initWithProduct:(B2WProduct *)product brand:(NSString *)brand
{
    self = [super init];
    if (self)
    {
        self.product = product;
        self.brand = brand;
        
        [self setFullPartnersArray:self.product.marketPlaceInformation.partners.mutableCopy];
        NSMutableArray *sellerIds = [NSMutableArray new];
        for (B2WProductMarketplacePartner *partner in self.fullPartnersArray)
        {
            [sellerIds addObject:partner.identifier];
        }
        self.fullSellerIdsArray = sellerIds;
    }
    return self;
}

- (void)setFullPartnersArray:(NSMutableArray *)partnerArray
{
    NSMutableArray *partners = [partnerArray mutableCopy];
    [partners insertObject:[B2WMarketplaceController featuredProductPartner:self.product brandName:self.brand] atIndex:0];
    _fullPartnersArray = partners;
}

- (B2WMarketplaceProductPartnerCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView withDelegate:(id)delegate
{
    B2WProductMarketplacePartner *partner = self.fullPartnersArray[indexPath.row];
    B2WMarketplaceProductPartnerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MarketplacePartnerCell"];
    if ([cell isKindOfClass:[B2WMarketplaceProductPartnerCell class]])
    {
        [cell setDelegate:delegate];
        [cell setPartner:partner forBrand:self.brand];
        cell.infoButton.tag = indexPath.row;
        
        [self changeStateOfMarketplaceProductPartnerCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

- (void)changeStateOfMarketplaceProductPartnerCell:(B2WMarketplaceProductPartnerCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = self.canShowFullFreightResult ? indexPath.row : indexPath.row - 1;  // removendo 1 da célula de título
    
    cell.freightMessageInfoButton.hidden = YES;
    
    if (self.canShowFreightLoading)
    {
        [cell.loading setHidden:NO];
        [cell.loading startAnimating];
        [cell.freightMessage setText:@"Calculando frete..."];
    }
    else
    {
        [cell.loading setHidden:YES];
        [cell.loading stopAnimating];
        [cell.freightMessage setText:@""];
    }
    
    if (self.freightResultDictionary && self.freightResultDictionary.count > 0)
    {
        [cell.loading stopAnimating];
        
        B2WFreightCalculationProduct *freightCalculationResult = nil;
        if (self.canShowFullFreightResult)
        {
            B2WProductMarketplacePartner *partner = self.fullPartnersArray[index];
            freightCalculationResult = [self.freightResultDictionary objectForKey:partner.identifier];
        }
        else
        {
            freightCalculationResult = [self.freightResultDictionary objectForKey:self.product.marketPlaceInformation.sellerIdentifiers[index]];
        }
        
        NSError *error = (NSError *)freightCalculationResult;
        if (freightCalculationResult && [error isKindOfClass:[B2WFreightCalculationProduct class]])
        {
            if (freightCalculationResult.resultType == B2WAPIFreightCalculationResultPartial)
            {
                cell.isFreightResultPartial = YES;
                cell.freightMessageInfoButton.hidden = NO;
                cell.freightResultErrorTitle   = @"Os Correios não estão mais realizando entregas nesse CEP";
                cell.freightResultErrorMessage = @"Todas as encomendas destinadas para este endereço serão entregues na agência mais próxima, conforme comunicado dos Correios. Sua encomenda ficará à disposição por até cinco dias úteis. A não retirada implicará na devolução do(s) produto(s). Neste caso, o valor da compra será restituído conforme forma de pagamento utilizada.";
            }
        }
        
        if (self.messages && self.messages.count > 0)
        {
            NSMutableAttributedString *currentMessage = self.messages[index];
            cell.freightMessageHeight.constant = [B2WMarketplaceProductPartnerCell heigthForFreightMessageWithText:currentMessage.string forBrand:self.brand];
            cell.freightMessage.attributedText = currentMessage;
        }
    }
    
    [self changeSeparatorLineToPosition:[self heightForRowAtIndexPath:indexPath isFormsheet:NO] inCell:cell];
}

- (void)changeSeparatorLineToPosition:(CGFloat)position inCell:(B2WMarketplaceProductPartnerCell *)cell
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        UIView *separatorLine = [cell viewWithTag:1001];
        if (separatorLine)
        {
            CGRect frame = separatorLine.frame;
            separatorLine.frame = CGRectMake(frame.origin.x, position, frame.size.width, frame.size.height - 1);
        }
    }
}

+ (NSMutableAttributedString *)messageForFreightCalculationResult:(B2WFreightCalculationProduct *)freightResult
{
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:@"Falha ao calcular frete, tente novamente"];
    
    NSError *error = (NSError *)freightResult;
    if (freightResult && [error isKindOfClass:[B2WFreightCalculationProduct class]])
    {
        switch (freightResult.resultType)
        {
            case 0:
                message = [self successMessageForFreightResult:freightResult];
                break;
            case 1:
                message = [[NSMutableAttributedString alloc] initWithString:@"CEP inexistente"];
                break;
            case 2:
                message = [[NSMutableAttributedString alloc] initWithString:@"Não realizamos entregas neste CEP para itens volumosos ou pesados"];
                break;
            case 3:
                message = [[NSMutableAttributedString alloc] initWithString:@"Não realizamos entregas neste CEP"];
                break;
            case 4:
                message = [self successMessageForFreightResult:freightResult];
                break;
            case 5:
                break;
            case 6:
                message = [[NSMutableAttributedString alloc] initWithString:@"Produto sem estoque"];
                break;
        }
    }
    return message;
}

+ (NSMutableAttributedString *)successMessageForFreightResult:(B2WFreightCalculationProduct *)freightResult
{
    NSString *prefix = nil;
    if ([freightResult.priceString.lowercaseString isEqualToString:@"frete grátis"])
    {
        prefix = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? @"Frete grátis em até " : @"Frete grátis com entrega em até ";
    }
    else
    {
        prefix = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? [NSString stringWithFormat:@"+ %@ frete - em até ", freightResult.priceString] : [NSString stringWithFormat:@"+ %@ de frete com entrega em até ", freightResult.priceString];
    }
    
    NSString *text = [NSString stringWithFormat:@"%@%@", prefix, freightResult.daysString];
    NSMutableAttributedString *marketPlaceTitle = [[NSMutableAttributedString alloc] initWithString:text];
    [marketPlaceTitle addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, prefix.length)];
    [marketPlaceTitle addAttribute:NSForegroundColorAttributeName value:[UIWindow appearance].tintColor range:NSMakeRange(prefix.length, text.length - prefix.length)];
    
    return marketPlaceTitle;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath isFormsheet:(BOOL)isFormsheet
{
    CGFloat partnerCellHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) || isFormsheet ? kPARTNER_PRODUCT_CELL_IPHONE_DEFAULT_HEIGHT : kPARTNER_PRODUCT_CELL_IPAD_DEFAULT_HEIGHT;
    NSUInteger index = self.canShowFullFreightResult ? indexPath.row : indexPath.row - 1;  // removendo 1 da célula de título
    NSMutableAttributedString *currentMessage = (self.messages && self.messages.count > 0) ? self.messages[index] : nil;
    partnerCellHeight = self.canShowFreightResult && currentMessage ? [B2WMarketplaceProductPartnerCell heigthForFreightMessageWithText:currentMessage.string forBrand:self.brand] + partnerCellHeight : partnerCellHeight;
    
    return (indexPath.section == 0) ? 50 : partnerCellHeight;
}

- (void)fillMessageArrayWithMessage:(NSString *)message
{
    self.messages = [[NSMutableArray alloc] initWithCapacity:self.fullPartnersArray.count];
    for (int i = 0; i < self.fullPartnersArray.count; i++)
    {
        [self.messages addObject:[[NSMutableAttributedString alloc] initWithString:message]];
    }
}

- (void)resetCalculateFreight
{
    [self fillMessageArrayWithMessage:@""];
    self.freightResultDictionary = nil;
    self.canShowFreightResult = NO;
    self.canShowFreightLoading = NO;
}

- (void)beginCalculateFreight
{
    [self fillMessageArrayWithMessage:@"Carregando frete..."];
    self.freightResultDictionary = nil;
    self.canShowFreightResult = YES;
    self.canShowFreightLoading = YES;
}

- (void)didLoadEstimateWithFreightResultDictionary:(NSDictionary *)freightResultDictionary
{
    self.messages = [NSMutableArray new];
    self.canShowFreightResult = YES;
    self.canShowFreightLoading = NO;
    self.freightResultDictionary = freightResultDictionary;
    
    if (self.freightResultDictionary && self.freightResultDictionary.count > 0)
    {
        B2WProductMarketplacePartner *partner = self.fullPartnersArray.firstObject;
        B2WFreightCalculationProduct *freightCalculationResult = [self.freightResultDictionary objectForKey:partner.identifier];
        
        NSError *error = (NSError *)freightCalculationResult;
        if (freightCalculationResult && [error isKindOfClass:[B2WFreightCalculationProduct class]])
        {
            if (freightCalculationResult.resultType == B2WAPIFreightCalculationResultInexistingPostalCode)
            {
                [self resetCalculateFreight];
            }
            else
            {
                int index = self.canShowFullFreightResult ? 0 : 1;
                for (int i = index; i < self.fullPartnersArray.count; i++)
                {
                    B2WProductMarketplacePartner *partner = self.fullPartnersArray[i];
                    B2WFreightCalculationProduct *freightCalculationResult = [self.freightResultDictionary objectForKey:partner.identifier];
                    [self.messages addObject:[B2WMarketplaceController messageForFreightCalculationResult:freightCalculationResult]];
                }
            }
        }
    }
}

- (void)setupMarketplaceInFreightCalculatorCell:(B2WProductFreightCalculatorCell *)cell
{
    if (self.product.marketPlaceInformation && self.fullPartnersArray.count > 0)
    {
        cell.isMarketplace = YES;
        
        NSMutableArray *sellerIdentifiers = [NSMutableArray new];
        NSUInteger limit = self.fullPartnersArray.count > kMAX_PARTNER_PRODUCTS_IN_PRODUCT_VIEW+1 ? kMAX_PARTNER_PRODUCTS_IN_PRODUCT_VIEW+1 : self.fullSellerIdsArray.count;
        
        for (int i = 0; i < limit; i++)
        {
            B2WProductMarketplacePartner *partner = self.fullPartnersArray[i];
            NSString *sellerIdentifier = partner.identifier;
            [sellerIdentifiers addObject:sellerIdentifier];
        }
        cell.sellerIdentifiers = sellerIdentifiers;
    }
}

+ (B2WProductMarketplacePartner *)featuredProductPartner:(B2WProduct *)product brandName:(NSString *)brandName
{
    return [[B2WProductMarketplacePartner alloc] initWithIdentifier:product.partnerId hasStorePickup:@"false" name:[product defaultPartnerForBrand:brandName] salesPrice:product.price installment:product.installment];
}

@end