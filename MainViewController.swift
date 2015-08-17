//
//  MainViewController.swift
//  CrowdVoucher
//
//  Created by Leonardo Reis on 8/14/15.
//  Copyright (c) 2015 Leonardo Reis. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, SwipeViewDataSource, SwipeViewDelegate {
    

    @IBOutlet var pageControl: UIPageControl!{
        didSet{
             pageControl.numberOfPages = images.count
        }
    }
    @IBOutlet var imageView: UIImageView!
    
    var images = [UIImage(named: "banner1.png"),UIImage(named: "banner2.png"),UIImage(named: "banner3.png")]
    
    @IBAction func login() {
        B2WAccountManager.sharedManager().presentLoginViewControllerWithUserSignedInHandler({ () -> Void in
            B2WAccountManager.requestCustomerInformationWithCompletion({ () -> Void in
            })
            }, failedHandler: nil, canceledHandler: nil)
        
    }
    
    @IBAction func showCampaign() {
        
        if B2WAPIAccount.isLoggedIn() {
            B2WAccountManager.requestCustomerInformationWithCompletion({ () -> Void in
                self.performSegueWithIdentifier("createCampaign", sender: nil)
            })
        }else{
            B2WAccountManager.sharedManager().presentLoginViewControllerWithUserSignedInHandler({ () -> Void in
                B2WAccountManager.requestCustomerInformationWithCompletion({ () -> Void in
                    self.performSegueWithIdentifier("createCampaign", sender: nil)
                })
                }, failedHandler: nil, canceledHandler: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
}
