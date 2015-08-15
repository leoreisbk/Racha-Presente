//
//  MainViewController.swift
//  CrowdVoucher
//
//  Created by Leonardo Reis on 8/14/15.
//  Copyright (c) 2015 Leonardo Reis. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, SwipeViewDataSource, SwipeViewDelegate {
    
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var imageView: UIImageView!
    
    var images = [UIImage(named: "img1.png"),UIImage(named: "img2.png"),UIImage(named: "img3.png")]
    
    
    @IBAction func login() {
        self.performSegueWithIdentifier("", sender: nil)
    }
    
    @IBAction func showCampaign() {
        self.performSegueWithIdentifier("createCampaign", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - SwipeView DataSource
    
    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        let count = images.count
        pageControl.numberOfPages = count
        return count
    }
    
    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        imageView = UIImageView(frame: CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height))
        imageView.image = images[index]
        //imageView.contentMode = UIViewContentMode.ScaleAspectFit
        return imageView
    }
    
    // MARK: - SwipeView Delegate
    
    func swipeViewDidScroll(swipeView: SwipeView!) {
        pageControl.currentPage = swipeView.currentItemIndex
    }
    
    func swipeViewItemSize(swipeView: SwipeView!) -> CGSize {
        return CGSizeMake(swipeView.itemSize.width, swipeView.itemSize.height)
    }

    func swipeView(swipeView: SwipeView!, didSelectItemAtIndex index: Int) {
        println("Tapppp")
    }
}
