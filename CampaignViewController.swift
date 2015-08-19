//
//  CampaignViewController.swift
//  CrowdVoucher
//
//  Created by Leonardo Reis on 8/14/15.
//  Copyright (c) 2015 Leonardo Reis. All rights reserved.
//

import UIKit

class CampaignViewController: UITableViewController {
   
    @IBOutlet var campaignTitle: UILabel!{
        didSet{
            campaignTitle.text = campaign.title
        }
    }
    @IBOutlet var totalAmount: UILabel!{
        didSet{
            totalAmount.text = "\(campaign.totalAmount)"
        }
    }
    @IBOutlet var duration: UILabel!{
        didSet{
            duration.text = "\(campaign.duration)"
        }
    }
    @IBOutlet var imageView: UIImageView!{
        didSet{
            imageView.setImageWithURL(NSURL(string: campaign.imageURL))
        }
    }
    
    var campaign: Campaign!
    
    override func viewDidLoad() {
   
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return campaign.contributions.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        var cell = tableView.dequeueReusableCellWithIdentifier("campaignCell", forIndexPath: indexPath) as! UITableViewCell
        
        var price: UILabel = cell.viewWithTag(333) as! UILabel
        var date: UILabel = cell.viewWithTag(334) as! UILabel
        var message = cell.viewWithTag(335) as! UILabel
        
        return cell
        
    }
    
    
    @IBAction func showVoucher() {
        self.performSegueWithIdentifier("voucherCampaign", sender: campaign.voucherID)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "voucherCampaign"{
            let campaignController = (segue.destinationViewController as! UINavigationController).topViewController as! VoucherViewController
            campaignController.imageUrl = sender as! String
            
        }
        
    }

    
}

