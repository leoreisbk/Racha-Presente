//
//  Campaign.swift
//  CrowdVoucher
//
//  Created by Leonardo Reis on 8/19/15.
//  Copyright (c) 2015 Leonardo Reis. All rights reserved.
//

import UIKit

class Campaign: NSObject {
    var customerID: String
    var completed: Int
    var contributions = []
    var createdDate: String
    var campaignDesciption: String
    var duration: Int
    var endDate: String
    var imageURL: String
    var title: String
    var totalAmount: CGFloat
    var updateDate: String
    var voucherID: String
    
    init(campaignDict: NSDictionary) {
        customerID           = campaignDict["b2w_customer_id"] as! String
        completed            = campaignDict["completed"] as! Int
        contributions        = campaignDict["contributions"] as! NSArray
        createdDate          = campaignDict["created_at"] as! String
        campaignDesciption   = campaignDict["description"] as! String
        duration             = campaignDict["duration"] as! Int
        endDate              = campaignDict["ends_at"] as! String
        imageURL             = campaignDict["image_URL"] as! String
        title                = campaignDict["title"] as! String
        totalAmount          = campaignDict["total_amount"] as! CGFloat
        updateDate           = campaignDict["updated_at"] as! String
        voucherID            = campaignDict["voucher_id"] as! String
    }
  
  init(campain: Campaign){
    customerID           = campain.customerID
    completed            = campain.completed
    contributions        = campain.contributions
    createdDate          = campain.createdDate
    campaignDesciption   = campain.campaignDesciption
    duration             = campain.duration
    endDate              = campain.endDate
    imageURL             = campain.imageURL
    title                = campain.title
    totalAmount          = campain.totalAmount
    updateDate           = campain.updateDate
    voucherID            = campain.voucherID
    
  }
}
