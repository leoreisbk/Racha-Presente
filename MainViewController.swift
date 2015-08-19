//
//  MainViewController.swift
//  CrowdVoucher
//
//  Created by Leonardo Reis on 8/14/15.
//  Copyright (c) 2015 Leonardo Reis. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, SwipeViewDataSource, SwipeViewDelegate {
    
    @IBOutlet var loginButton: UIBarButtonItem!{
        didSet{
            loginButton.title = B2WAPIAccount.isLoggedIn() ? "Logout": "Login"
        }
    }
    @IBOutlet var pageControl: UIPageControl!{
        didSet{
             pageControl.numberOfPages = images.count
        }
    }
    @IBOutlet var imageView: UIImageView!
    
    var images = [UIImage(named: "banner1.png"),UIImage(named: "banner2.png"),UIImage(named: "banner3.png")]
    
    @IBAction func login() {
        
        if B2WAPIAccount.isLoggedIn() {
            B2WAPIAccount.logout()
            loginButton.title = "Login"
            
        } else {
            
            B2WAccountManager.sharedManager().presentLoginViewControllerWithUserSignedInHandler({ () -> Void in
                B2WAccountManager.requestCustomerInformationWithCompletion({ () -> Void in
                    self.loginButton.title = "Logout"
                    self.requestCampaign(B2WAccountManager.currentCustomer().identifier)
                })
                }, failedHandler: nil, canceledHandler: nil)
            
        }
        
    }
    
    @IBAction func showCampaign() {
        
        if B2WAPIAccount.isLoggedIn() {
            B2WAccountManager.requestCustomerInformationWithCompletion({ () -> Void in
                self.performSegueWithIdentifier("createCampaign", sender: nil)
            })
        }else{
            B2WAccountManager.sharedManager().presentLoginViewControllerWithUserSignedInHandler({ () -> Void in
                B2WAccountManager.requestCustomerInformationWithCompletion({ () -> Void in
                    self.loginButton.title = "Logout"
                    self.performSegueWithIdentifier("createCampaign", sender: nil)
                })
                }, failedHandler: nil, canceledHandler: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func requestCampaign(customerID: String){
        //02-36472825-1  Mion
        //02-44336934-1 Leo
        
        let urlString = String(format:"https://still-fortress-6278.herokuapp.com/campaigns/%@.json",customerID)
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.GET(urlString, parameters: nil, success: { (request, JSON) -> Void in
            
            let dict = JSON as! NSDictionary
            
            if let customer: String = dict["b2w_customer_id"] as? String {
                let campaign = Campaign(campaignDict: dict)
                self.performSegueWithIdentifier("campaign", sender: campaign)
            }
            
            println(dict)
            
        }) { (request, error) -> Void in
            println(error.description)
        }
    }
    
    
    // MARK: - SwipeView DataSource
    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        let count = images.count
        return count
    }
    
    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        imageView = UIImageView(frame: CGRectMake(0, 0, 375, 500))
        imageView.image = images[index]
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        return imageView
    }
    
    // MARK: - SwipeView Delegate
    
    func swipeViewDidScroll(swipeView: SwipeView!) {
        pageControl.currentPage = swipeView.currentItemIndex
    }
    
    func swipeViewItemSize(swipeView: SwipeView!) -> CGSize {
        return CGSizeMake(swipeView.itemSize.width, swipeView.itemSize.height)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let campaign = sender as! Campaign
        if segue.identifier == "campaign" {
            let campaignController = (segue.destinationViewController as! UINavigationController).topViewController as! CampaignViewController
            campaignController.campaign = campaign
        }
        else if segue.identifier == "createCampaign" {
            let campaignController = (segue.destinationViewController as! UINavigationController).topViewController as! CreateCampaignViewController
        }
    }
}
