//
//  B2WKit-Constants.h
//  B2WKit
//
//  Created by Thiago Peres on 11/23/13.
//

//
// General
//

#define B2W_DEPRECATED(message) __attribute__((deprecated(message)))

#define kABSTRACT_METHOD { @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil]; }

//
// User Defaults Keys
//

#define kUSER_DEFAULTS_PUSH_NOTIFICATION_SETTINGS  @"B2WPushNotificationsSettings"
#define kUSER_DEFAULTS_PRICE_NOTIFICATION_SETTINGS @"B2WPriceNotificationsSettings"
#define kUSER_DEFAULTS_STOCK_NOTIFICATION_SETTINGS @"B2WStockNotificationsSettings"

//
// Misc
//

#define kB2WDefaultNumberOfProductsPerPage 20

#define kAnimationDuration 0.28

#define kPRODUCT_MIN_SIZE_CEP 6
#define kPRODUCT_MAX_SIZE_CEP 9

#define kMAX_PARTNER_PRODUCTS_IN_PRODUCT_VIEW 3
#define kPARTNER_PRODUCT_CELL_IPHONE_DEFAULT_HEIGHT 80.f
#define kPARTNER_PRODUCT_CELL_IPAD_DEFAULT_HEIGHT 65.f

typedef void (^B2WAPICompletionBlock)(id object, NSError *error);

//
// Messages
//

#define kDefaultErrorTitle				 @"Falha na Operação"
#define kDefaultErrorMessage			 @"Identificamos um problema em nossos servidores. Por favor, tente novamente em alguns instantes."

#define kDefaultConnectionErrorTitle	 @"Falha na Conexão"
#define kDefaultConnectionErrorMessage	 @"Não foi possível conectar ao servidor. Por favor, verifique sua conexão com a internet."

#define kLoadProductErrorTitle			 @"Falha ao Carregar Produto"
#define kLoadProductErrorMessage		 @"Não foi possível carregar o produto no momento. Tente novamente em alguns instantes."

#define kGetFeaturedProductsErrorTitle   @"Falha ao Carregar Destaques"
#define kGetFeaturedProductsErrorMessage @"Não foi possível carregar a lista de produtos em destaque no momento. Tente novamente em alguns instantes."

#define kCalculateFreightErrorTitle      @"CEP Inválido"
#define kCalculateFreightErrorMessage    @"Não foi possível calcular o frete com o CEP informado."

#define kGetDepartmentsErrorTitle        @"Falha ao Carregar Departamentos"
#define kGetDepartmentsErrorMessage      @"Não foi possível carregar a lista de departamentos no momento. Tente novamente em alguns instantes."

#define kLoadBasketErrorTitle            @"Falha no Carregamento"
#define kLoadBasketErrorMessage          @"Não foi possível carregar o carrinho de compras no momento. Tente novamente em alguns instantes."

#define kLoadWishListErrorTitle          @"Falha ao Carregar Favoritos"
#define kLoadWishListErrorMessage        @"Não foi possível carregar favoritos no momento. Tente novamente em alguns instantes."

#define kLoadReviewstErrorTitle          @"Falha ao Carregar Avaliações"
#define kLoadReviewsErrorMessage         @"Não foi possível carregar as avaliações no momento. Tente novamente em alguns instantes."

#define kLoadOrdersErrorTitle            @"Falha ao Carregar Pedidos"
#define kLoadOrdersErrorMessage          @"Não foi possível carregar os pedidos no momento. Tente novamente em alguns instantes."

#define kDefaultOutOfStockMessage		 @"Item indisponível no momento."

#define kDefaultBadLoginTitle			 @"Falha ao Logar"
#define kDefaultBadLoginMessage			 @"Usuário e/ou senha inválidos. Tente novamente."

//
// Device
//

#define kIsIphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kIsIpad   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kIsIphone4InchDisplay (([[UIScreen mainScreen] bounds].size.height-568) ? NO : YES)

//
// System Versioning Preprocessor Macros
//

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

//
// Alternatives to NSLog
//

// DLog() will output like NSLog only when the DEBUG variable is set
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
