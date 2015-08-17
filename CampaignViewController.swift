//
//  CampaignViewController.swift
//  CrowdVoucher
//
//  Created by Leonardo Reis on 8/14/15.
//  Copyright (c) 2015 Leonardo Reis. All rights reserved.
//

import UIKit

class CampaignViewController: UITableViewController {
   
    @IBOutlet var campaignTitle: UILabel!
    @IBOutlet var totalAmount: UILabel!
    @IBOutlet var duration: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    
    //Cell
    
    @IBOutlet var priceCell: UILabel!
    @IBOutlet var dateCell: UILabel!
    @IBOutlet var messageCell: UILabel!
    
    var imageUrl: String!
    var contributions = []
    var dict: NSDictionary!
    
    
    override func viewDidLoad() {
   
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contributions.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        var cell = tableView.dequeueReusableCellWithIdentifier("campaignCell", forIndexPath: indexPath) as! UITableViewCell
        return cell
        
    }
    
    
    @IBAction func showVoucher() {
        self.performSegueWithIdentifier("voucherCampaign", sender: imageUrl)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "voucherCampaign"{
            let campaignController = (segue.destinationViewController as! UINavigationController).topViewController as! VoucherViewController
            campaignController.imageUrl = sender as! String
            
        }
        
    }

    
}

