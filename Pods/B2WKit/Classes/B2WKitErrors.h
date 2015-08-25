//
//  B2WKitErrors.h
//  B2WKit
//
//  Created by Thiago Peres on 04/11/13.
//  Copyright (c) 2013 Ideais Mobile. All rights reserved.
//

#define kB2WAPIInvalidResponseErrorLocalizedDescriptionString @"O servidor retornou uma resposta inválida."

typedef NS_ENUM(NSInteger, B2WAPIErrorCodes) {
    B2WAPIInvalidResponseError,
    B2WAPIServiceError,
    B2WAPIInternalInconsistencyError,
    B2WAPIInvalidParameterError,
    B2WAPIResourceNotFoundError,
    B2WAPIBadCredentialsError,
    B2WAPIAlreadyLoggedInError,
    B2WAPILoginRequiredError,
    B2WAPIInvalidSession,
};
