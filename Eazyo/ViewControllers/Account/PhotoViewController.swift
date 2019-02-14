//
//  PhotoViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 5/19/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import MBProgressHUD
import Alamofire
import AlamofireImage

class PhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, WebServiceDelegate {

    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var cameraText: UILabel!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    var loadingAnimator : MBProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if (UserManager.instance.hasAvatar == true) {
            if (UserManager.instance.avatarImage != nil) {
                self.photo.image = UserManager.instance.avatarImage
                hidePhotoViews(true)
            }
            else {
                if (UserManager.instance.avatarUrl != nil) {
                    Alamofire.request(UserManager.instance.avatarUrl!)
                        .responseImage { response in
                            if let image = response.result.value {
                                UserManager.instance.avatarImage = image
                                self.photo.image = image
                            }
                    }
                    hidePhotoViews(true)
                }
            }
        }
        else {
            hidePhotoViews(false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //////////////////////////////
    
    //  NavigationBar
    
    @IBAction func onBack(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func onUpdate(_ sender: AnyObject) {
        loadingAnimator = MBProgressHUD.showAdded(to: self.view.window!, animated: true)
        loadingAnimator!.mode = .indeterminate
        loadingAnimator!.labelText = "Uploading..."
        
        var parameters = [String : Any]()
        
        var imageData: Data?
        if photo.image != nil {
            imageData = UIImagePNGRepresentation(photo.image!)
            let strBase64:String = "data:image/png;base64," + imageData!.base64EncodedString(options: .lineLength64Characters)
            parameters["image_data"] = strBase64
        }
        else {
            parameters["remove_avatar"] = true
        }
        
        WebService.instance.delegate = self
        WebService.instance.updateUser(parameters)
    }
    
    //////////////////////////////
    
    //  WebServiceDelegate
    
    func onSuccess(apiName: String, data: AnyObject) {
        loadingAnimator!.hide(true)
        switch apiName {
        case "updateUser":
            UserManager.instance.setUserData(data as! [String : Any])
            enableUpdateButton(false)
            Util.showAlertMessage(APP_TITLE, message: "Updated successfully!", parent: self)
            break
            
        default:
            break
        }
    }
    
    func onError(apiName: String, errorInfo: [String]) {
        loadingAnimator!.hide(true)
        
        let alertMessage = Util.composeAlertMessage(errorInfo)
        
        switch apiName {
        case "updateUser":
            Util.showAlertMessage(APP_TITLE, message: alertMessage, parent: self)
            break
            
        default:
            break
        }
    }
    
    //////////////////////////////
    
    // UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            photo.image = possibleImage
            hidePhotoViews(true)
            checkImageUpdate()
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            photo.image = possibleImage
            hidePhotoViews(true)
            checkImageUpdate()
        } else {
            return
        }
        
        // do something interesting here!
        
        dismiss(animated: true, completion: nil)
    }
    
    func hidePhotoViews(_ hide: Bool) {
        removeButton.isHidden = !hide
        photoButton.isHidden = hide
        cameraIcon.isHidden = hide
        cameraText.isHidden = hide
    }
    
    //////////////////////////////
    
    // User Photo
    
    @IBAction func onSelectPhoto(_ sender: AnyObject) {
        let photoSelectMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take a photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.takePhoto()
        })
        let libraryAction = UIAlertAction(title: "Photo from library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.selectPicture()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        photoSelectMenu.addAction(cameraAction)
        photoSelectMenu.addAction(libraryAction)
        photoSelectMenu.addAction(cancelAction)
        
        self.present(photoSelectMenu, animated: true, completion: nil)
    }
    
    func selectPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func takePhoto() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            Util.showAlertMessage(APP_TITLE, message: "Camera is not available now.", parent: self)
            return
        }
        
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .camera
        
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func onRemovePhoto(_ sender: AnyObject) {
        photo.image = nil
        hidePhotoViews(false)
        checkImageUpdate()
    }
    
    //////////////////////////////
    
    func checkImageUpdate() {
        var update = false
        if (UserManager.instance.hasAvatar == false) {
            if (photo.image == nil) {
                update = false
            }
            else {
                update = true
            }
        }
        else {
            if (photo.image == nil) {
                update = true
            }
            else {
                let currentPhotoData = UIImagePNGRepresentation(UserManager.instance.avatarImage!)
                let newPhotoData = UIImagePNGRepresentation(photo.image!)
                update = !(currentPhotoData! == newPhotoData!)
            }
        }
        
        enableUpdateButton(update)
    }
    
    func enableUpdateButton(_ enable: Bool) {
        if (enable == true) {
            updateButton.setTitleColor(UIColor.eazyoOrangeColor(), for: UIControlState())
            updateButton.alpha = 1.0
            updateButton.isEnabled = true
        }
        else {
            updateButton.setTitleColor(UIColor.eazyoCoolGreyColor(), for: UIControlState())
            updateButton.alpha = 0.4
            updateButton.isEnabled = false
        }
    }
    
    //////////////////////////////
}
