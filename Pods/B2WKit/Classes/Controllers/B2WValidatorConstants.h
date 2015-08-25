//
//  B2WValidatorConstants.h
//  B2WKit
//
//  Created by Eduardo Callado on 7/22/14.
//  Copyright (c) 2014 Ideais Mobile. All rights reserved.
//

//
// Customer
//
#define kNAME_FIELD_MIN_CHARS 3
#define kNAME_FIELD_MAX_CHARS 60
#define kCPF_FIELD_MAX_CHARS 14
#define kBIRTHDATE_FIELD_MAX_CHARS 10
#define kCNPJ_FIELD_MAX_CHARS 18
#define kEMAIL_FIELD_MIN_CHARS 5
#define kEMAIL_FIELD_MAX_CHARS 50
#define kPASSWORD_FIELD_MIN_CHARS 6
#define kPASSWORD_FIELD_MAX_CHARS 8

//
// Address
//
#define kPOSTALCODE_FIELD_MAX_CHARS 9
#define kEND_NUMBER_FIELD_MIN_CHARS 1
#define kEND_NUMBER_FIELD_MAX_CHARS 10
#define kEND_REFERENCE_FIELD_MIN_CHARS 5
#define kEND_REFERENCE_FIELD_MAX_CHARS 100
#define kEND_PHONE_FIELD_MIN_CHARS 14
#define kEND_PHONE_FIELD_MAX_CHARS 15

//
// Credit Card
//
#define kVISA_TYPE          @"^4[0-9]{3}?"
#define kMASTER_CARD_TYPE   @"^5[1-5][0-9]{2}$"
#define kAMEX_TYPE          @"^3[47][0-9]{2}$"
#define kDINERS_CLUB_TYPE	@"^3(?:0[0-5]|[68][0-9])[0-9]{11}$"
#define kDISCOVER_TYPE		@"^6(?:011|5[0-9]{2})$"

#define kMagicSubtractionNumber 48

#define kCARD_NAME_FIELD_MIN_CHARS 3
#define kCARD_NAME_FIELD_MAX_CHARS 60
#define kCVV_FIELD_MIN_CHARS 3
#define kCVV_FIELD_MAX_CHARS 4
#define kNUMBER_FIELD_MIN_CHARS 4
#define kCARD_NUMBER_FIELD_MAX_CHARS 16
#define kCARD_AMEX_NUMBER_FIELD_MAX_CHARS 15
#define kCARD_AURA_NUMBER_FIELD_MAX_CHARS 19
