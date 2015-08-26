//
//  Contribution.swift
//  CrowdVoucher
//
//  Created by Leonardo Reis on 8/20/15.
//  Copyright (c) 2015 Leonardo Reis. All rights reserved.
//

import UIKit

class Contribution: NSObject {

    var amount: CGFloat
    var cardNumber: String
    var cardExpiration: String
    var cardHolder: String
    var message: String
    var cardCodeSecurity: String
    var createdDate: String
    
    init(dict: NSDictionary) {
        
        amount = dict["amount"] as! CGFloat
        message = dict["message"] as! String
        createdDate = dict["created_at"] as! String
        
        cardNumber = dict["card_number"] as! String
        cardExpiration = dict["expiration_date"] as! String
        cardHolder = dict["holders_name"] as! String
        cardCodeSecurity = dict["security_code"] as! String
        
    }
}
