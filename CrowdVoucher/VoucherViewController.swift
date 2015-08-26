//
//  VoucherViewController.swift
//  CrowdVoucher
//
//  Created by Leonardo Reis on 8/14/15.
//  Copyright (c) 2015 Leonardo Reis. All rights reserved.
//

import UIKit


extension UILeoButton {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

@IBDesignable
class UILeoButton: UIButton {
    //
}

class VoucherViewController: UIViewController {

    @IBOutlet var imageBlurred: UIImageView!{
        didSet{
            imageBlurred.setImageWithURL(NSURL(string: campaign.imageURL))
        }
    }
    @IBOutlet var amountLabel: UILabel!{
        didSet{
            amountLabel.text = numberFormatter(campaign.totalAmount)
        }
    }
    
    var campaign: Campaign!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func copyVoucher() {
    UIPasteboard.generalPasteboard().string = campaign.voucherID
    }
    
    @IBAction func openACOM(){
      UIApplication.sharedApplication().openURL(NSURL(string: "americanas://americanas.com.br/")!)
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
