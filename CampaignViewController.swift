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
            totalAmount.text = numberFormatter(campaign.totalAmount)
        }
    }
    @IBOutlet var duration: UILabel!{
        didSet{
            duration.text = String(format: "%d dias restantes", campaign.duration)
        }
    }
    @IBOutlet var imageView: UIImageView!{
        didSet{
            imageView.setImageWithURL(NSURL(string: campaign.imageURL))
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
        }
    }
    
    @IBOutlet var totalContribution: UILabel!{
        didSet{
            var quantity = campaign.contributions.count
            totalContribution.text = quantity > 0 ? String(format:"%d contribuição(s)", quantity) : "Não há contribuição ainda"
        }
    }
    var campaign: Campaign!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func numberFormatter(amount: CGFloat) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "pt_BR")
        let number = formatter.stringFromNumber(amount)
        return number!
    }
    
    func dateFormatter() -> NSDateFormatter{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = NSLocale(localeIdentifier: "US_en")
        return dateFormatter
        
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return campaign.contributions.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("campaignCell", forIndexPath: indexPath) as! UITableViewCell
        
        var price   = cell.viewWithTag(333) as! UILabel
        var date    = cell.viewWithTag(334) as! UILabel
        var message = cell.viewWithTag(335) as! UILabel
        
        var dict = campaign.contributions[indexPath.row] as! NSDictionary
        var contribution = Contribution(dict: dict)
    
        let dateStr = dateFormatter().dateFromString(contribution.createdDate)
        
        var stringFormatter = NSDateFormatter()
        stringFormatter.dateFormat = "dd/MM"
        
        price.text   = numberFormatter(contribution.amount)
        date.text = stringFormatter.stringFromDate(dateStr!)
        message.text = contribution.message
        
        return cell
    }
    
    @IBAction func shareCampaign() {
        
        let shareURL = String(format: "https://still-fortress-6278.herokuapp.com/campaigns/%@/contributions/new", campaign.customerID)
        let activityVC = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll]
        
        activityVC.completionWithItemsHandler = {
            (activity, success, items, error) in
            if success {
                var socialAction = "Share"
                var socialNetwork = activity
                
                if socialNetwork == "Twitter"
                {
                    socialAction = "Tweet"
                }
            }
        }
        
        presentViewController(activityVC, animated: true, completion: nil)
    }
    func requestVoucher() {
        let params = ["completed":true]
        let url = String(format: "https://still-fortress-6278.herokuapp.com/campaigns/%@.json",campaign.customerID)
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.PUT(url, parameters: params, success: { (request, JSON) -> Void in
            let campaignDict = JSON as! NSDictionary
            let campaign = Campaign(campaignDict: campaignDict)
            self.performSegueWithIdentifier("voucherCampaign", sender: campaign)
            
            }){ (request, error) -> Void in
                println(error.description)
        }
        
    }
    
    @IBAction func showVoucher() {
        requestVoucher()
    }
    
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "voucherCampaign"{
            let campaignController = (segue.destinationViewController as! UINavigationController).topViewController as! VoucherViewController
            campaignController.campaign = sender as! Campaign
        }
    }
}

