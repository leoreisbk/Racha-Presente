//
//  CreateCampaignViewController.swift
//  CrowdVoucher
//
//  Created by Leonardo Reis on 8/14/15.
//  Copyright (c) 2015 Leonardo Reis. All rights reserved.
//

import UIKit

class CreateCampaignViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var campaignTitle: UITextField!
    @IBOutlet var campaignDescription: UITextView!
    
    @IBOutlet var blurredView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var segmentedControl: UISegmentedControl!{
        didSet{
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.addTarget(self, action:"indexChanged:", forControlEvents: UIControlEvents.ValueChanged)
        }
    }
    
    var imageName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".png")
    var uploadRequests = Array<AWSS3TransferManagerUploadRequest?>()
    var uploadFileURLs = Array<NSURL?>()
    let imagePicker = UIImagePickerController()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }

    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func takePhoto() {
        
        let alertController = UIAlertController(title: "Você deseja usar:", message: "", preferredStyle: .Alert)
        
        let cameraBtn = UIAlertAction(title: "Usar a câmera", style: .Default) { (action) in
        
            self.imagePicker.sourceType = .Camera
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        
        }
        alertController.addAction(cameraBtn)
        
        let albumBtn = UIAlertAction(title: "Escolher do álbum", style: .Default) {(action) in
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        
        }
        alertController.addAction(albumBtn)
        
        let cancelBtn = UIAlertAction(title: "Cancelar", style: .Destructive) {(action) in}
         alertController.addAction(cancelBtn)
        
        self.presentViewController(alertController, animated: true) {}
    }
    
    @IBAction func createCampaign(){
        postCampaign()
    }
    
    func postCampaign(){

        let params = ["title":campaignTitle.text,
                      "description":campaignDescription.text,
                      "duration": 15,
                      "image_URL": String(format:"https://s3.amazonaws.com/racha-presente-acom/%@",imageName),
                      "b2w_customer_id": B2WAccountManager.currentCustomer().identifier
                     ]
        
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.POST("https://still-fortress-6278.herokuapp.com/campaigns.json", parameters: params, success: { (request, JSON) -> Void in

        let dict = JSON as! NSDictionary
    
        self.performSegueWithIdentifier("showCampaign", sender: dict)
        println(dict)
            
        }) { (request, error) -> Void in
            println(error.description)
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let dict = sender as! NSDictionary
        
        if segue.identifier == "showCampaign"{
         
            let campaignController = (segue.destinationViewController as! UINavigationController).topViewController as! CampaignViewController
            campaignController.imageUrl = dict["voucher_id"] as! String
            
        }
    
    }

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        imagePicker.allowsEditing = true;
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        blurredView.hidden = true
        
        if  let image = info[UIImagePickerControllerOriginalImage] as? UIImage {

            let filePath = NSTemporaryDirectory().stringByAppendingPathComponent("temp")
            let imageData = UIImagePNGRepresentation(image)
            imageData.writeToFile(filePath, atomically: true)
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest.body = NSURL(fileURLWithPath: filePath)
            uploadRequest.key =  imageName   //"icon.png"
            uploadRequest.bucket = "racha-presente-acom"
            
            self.uploadRequests.append(uploadRequest)
            self.uploadFileURLs.append(nil)
            
            self.upload(uploadRequest)
        }
        
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func indexChanged(sender : UISegmentedControl) {
        
        switch segmentedControl.selectedSegmentIndex {
            
        case 1:
            println("10 dias")
        case 2:
            println("15 dias")
        default:
            println("5 dias")
        }
    }
    
    func upload(uploadRequest: AWSS3TransferManagerUploadRequest) {
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                if error.domain == AWSS3TransferManagerErrorDomain as String {
                    if let errorCode = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch (errorCode) {
                        case .Cancelled, .Paused:
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.tableView.reloadData()
                            })
                            break;
                            
                        default:
                            println("upload() failed: [\(error)]")
                            break;
                        }
                    } else {
                        println("upload() failed: [\(error)]")
                    }
                } else {
                    println("upload() failed: [\(error)]")
                }
            }
            
            if let exception = task.exception {
                println("upload() failed: [\(exception)]")
            }
            
            if task.result != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let index = self.indexOfUploadRequest(self.uploadRequests, uploadRequest: uploadRequest) {
                        self.uploadRequests[index] = nil
                        self.uploadFileURLs[index] = uploadRequest.body
                        
                        let indexPath = NSIndexPath(forRow: index, inSection: 0)
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }
                })
            }
            return nil
        }
    }
    
    func indexOfUploadRequest(array: Array<AWSS3TransferManagerUploadRequest?>, uploadRequest: AWSS3TransferManagerUploadRequest?) -> Int? {
        for (index, object) in enumerate(array) {
            if object == uploadRequest {
                return index
            }
        }
        return nil
    }
}
