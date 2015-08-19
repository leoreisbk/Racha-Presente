//
//  CreateCampaignViewController.swift
//  CrowdVoucher
//
//  Created by Leonardo Reis on 8/14/15.
//  Copyright (c) 2015 Leonardo Reis. All rights reserved.
//

import UIKit

class CreateCampaignViewController: UITableViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
    
    var campaignExpiration = 5
    var imageName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".png")
    var uploadRequests = Array<AWSS3TransferManagerUploadRequest?>()
    var uploadFileURLs = Array<NSURL?>()
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func showActionSheet(sender: UIButton){
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        actionSheet.actionSheetStyle = .Default
        actionSheet.addButtonWithTitle("Take Photo")
        actionSheet.addButtonWithTitle("Choose Photo")
        actionSheet.addButtonWithTitle("Search Photo")
        actionSheet.showInView(self.view)
    }
    
    // MARK - UIActionSheetDelegate methods
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        switch actionSheet.buttonTitleAtIndex(buttonIndex) {
            
        case "Choose Photo":
            presentImagePickerWithSourceType(UIImagePickerControllerSourceType.PhotoLibrary)
            break
        case "Search Photo":
             photoSearch()
            break
        default:
             presentImagePickerWithSourceType(UIImagePickerControllerSourceType.Camera)
            break
        }
    }
    
    
    @IBAction func createCampaign(){
        postCampaign()
    }
    
    func postCampaign(){
        
        let params = ["title":campaignTitle.text,
            "description":campaignDescription.text,
            "duration": campaignExpiration,
            "image_URL": String(format:"https://s3.amazonaws.com/racha-presente-acom/%@",imageName),
            "b2w_customer_id": B2WAccountManager.currentCustomer().identifier
        ]
        
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.POST("https://still-fortress-6278.herokuapp.com/campaigns.json", parameters: params, success: { (request, JSON) -> Void in
            
            let dict = JSON as! NSDictionary
            let campaign = Campaign(campaignDict: dict)
            self.performSegueWithIdentifier("showCampaign", sender: campaign)
            println(campaign)
            
            }) { (request, error) -> Void in
                println(error.description)
        }
    }
    
    
    func photoSearch() {
        
        let pickerController = DZNPhotoPickerController()
        pickerController.supportedServices = DZNPhotoPickerControllerServices.ServiceGoogleImages
        pickerController.allowsEditing = false
        pickerController.cropMode = DZNPhotoEditorViewControllerCropMode.Square
        pickerController.cropSize = CGSizeMake(imageView.frame.width, imageView.frame.height)
        
        pickerController.finalizationBlock = { (pickerController, info) in
            self.updateImageWithPayload(info)
            self.dismissPickerController(pickerController)
        }
        
        pickerController.cancellationBlock = { (pickerController) in
            self.dismissPickerController(pickerController)
        }
        
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func presentImagePickerWithSourceType(sourceType: UIImagePickerControllerSourceType) {
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = true
        picker.delegate = self
        picker.cropMode = DZNPhotoEditorViewControllerCropMode.Square

        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func updateImageWithPayload(payload:[NSObject : AnyObject]) {
        let image = payload[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.image = image
        blurredView.hidden = true
        
        uploadImageToAWS(image!)
    }
    
    func dismissPickerController(controller: UIViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handlePicker(picker: UIImagePickerController, info:[NSObject : AnyObject]) {
        updateImageWithPayload(info)
        dismissPickerController(picker)
    }
    
    
    // MARK - UIImagePickerControllerDelegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        handlePicker(picker, info: info)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    }
    
    @IBAction func indexChanged(sender : UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            campaignExpiration = 10
        case 2:
            campaignExpiration = 15
        default:
            campaignExpiration = 5
        }
    }
    
    func uploadImageToAWS(image: UIImage) {
        
        let filePath = NSTemporaryDirectory().stringByAppendingPathComponent("temp")
        let imageData = UIImagePNGRepresentation(image)
        imageData.writeToFile(filePath, atomically: true)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = NSURL(fileURLWithPath: filePath)
        uploadRequest.key =  imageName
        uploadRequest.bucket = kAWSBucketName
        
        self.uploadRequests.append(uploadRequest)
        self.uploadFileURLs.append(nil)
        
        self.upload(uploadRequest)
        
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let campaign = sender as! Campaign
        if segue.identifier == "showCampaign"{
            let campaignController = (segue.destinationViewController as! UINavigationController).topViewController as! CampaignViewController
            campaignController.campaign = campaign
        }
    }
}
