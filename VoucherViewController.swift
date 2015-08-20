//
//  VoucherViewController.swift
//  CrowdVoucher
//
//  Created by Leonardo Reis on 8/14/15.
//  Copyright (c) 2015 Leonardo Reis. All rights reserved.
//

import UIKit

class VoucherViewController: UIViewController {

    @IBOutlet var amountLabel: UILabel!{
        didSet{
            amountLabel.text = numberFormatter(campaign.totalAmount)
        }
    }
    @IBOutlet var voucher: UILabel!{
        didSet{
         voucher.text = campaign.voucherID
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
    
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentedViewController?.presentedViewController
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {})
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
