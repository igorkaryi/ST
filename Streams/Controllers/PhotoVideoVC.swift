//
//  PhotoVideoVC.swift
//  Streams
//
//  Created by Igor Karyi on 07.05.2018.
//  Copyright © 2018 MIXOFT LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation
import MobileCoreServices
import SDWebImage

class PhotoVideoVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lastWordsLabel: UILabel!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var newsTextView: UITextView!
    @IBOutlet weak var selectedPhohtoImage: UIImageView!
    @IBOutlet weak var topConstraintOpenMenu: NSLayoutConstraint!
    @IBOutlet weak var openMenu: UIView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var refreshControl: UIRefreshControl!
    
    let imagePicker = UIImagePickerController()
    
    var countCharacters = 100
    var photoAndTextArray = [Model]()
    var textArrayCount = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkingConnection()
        self.title = Strings.photoAndVideo
        
        imagePicker.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .white
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView?.addSubview(self.refreshControl)
        
        openViewMenu()
        selectedPhohtoImage.layer.cornerRadius = 10
        selectedPhohtoImage.clipsToBounds = true
        lastWordsLabel.text = "\(Strings.left) 100 \(Strings.characters)"
        newsTextView!.delegate = self
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swipeUp))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.openMenu.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeUp)
    }
    
    @objc func refresh(sender:AnyObject) {
        DispatchQueue.main.async{
            self.getData()
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func swipeUp() {
        print("swipeUp")
        defaultValues()
        moveCloseOpenView()
    }
    
    func defaultValues() {
        newsTextView.text = ""
        countCharacters = 100
        lastWordsLabel.text = "\(Strings.left) \(countCharacters) \(Strings.characters)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        for textPhoto in photoAndTextArray {
            textArrayCount = textPhoto.photoText.count
        }
        return textArrayCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PhotoCell
        for array in photoAndTextArray {
            cell.photoText.text = array.photoText[indexPath.row]
            
            let arrayLink = array.photoLink[indexPath.row]
            cell.photoImage.sd_setImage(with: URL(string: arrayLink))
        }
        
        return cell
    }
    
    func openViewMenu() {
        topConstraintOpenMenu.constant = -Constants.TopConstraintAddDiscussion
        openMenu.clipsToBounds = true
        openMenu.layer.cornerRadius = Constants.CornerRadiusForView
        openMenu.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func moveOpenView() {
        newsTextView.becomeFirstResponder()
        UIView.animate(withDuration: 0.5) {
            self.topConstraintOpenMenu.constant = 0
            self.view.layoutIfNeeded()
        }
        tableView.isUserInteractionEnabled = false
    }
    
    func moveCloseOpenView() {
        newsTextView.resignFirstResponder()
        UIView.animate(withDuration: 0.5) {
            self.topConstraintOpenMenu.constant = -Constants.TopConstraintAddDiscussion
            self.view.layoutIfNeeded()
        }
        
        let deadlineTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.checkingConnection()
            self.tableView.reloadData()
            self.addButton.image = UIImage(named: "plus")
        }
        tableView.isUserInteractionEnabled = true
    }
    
    func addDiscussion() {
        if topConstraintOpenMenu.constant == -Constants.TopConstraintAddDiscussion {
            moveOpenView()
            addButton.image = UIImage(named: "delete")
        } else if topConstraintOpenMenu.constant == 0 {
            moveCloseOpenView()
            addButton.image = UIImage(named: "plus")
        }
    }
    
    //save news
    func performAction() {
        if (newsTextView.text?.isEmpty)! || selectedPhohtoImage.image == nil {
            showAlertWhenFieldsEmpty()
        } else {
            saveNews()
            print("performAction")
        }
    }
    
    func saveNews() {
        print("saveNews")
        postData()
        moveCloseOpenView()
        defaultValues()
    }
    
    //character limit on textView
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            performAction()
            return false
        }
        let newText = (newsTextView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 100
    }
    
    func checkRemainingChars() {
        let allowedChars = countCharacters
        let charsInTextView = -newsTextView.text.count
        let remainingChars = allowedChars + charsInTextView
        if remainingChars <= allowedChars {
            lastWordsLabel.textColor = UIColor.darkGray
        }
        if remainingChars <= 20 {
            lastWordsLabel.textColor = UIColor.orange
        }
        if remainingChars <= 10 {
            lastWordsLabel.textColor = UIColor.red
        }
        lastWordsLabel.text = String(remainingChars)
        lastWordsLabel.text = "\(Strings.left) \(remainingChars) \(Strings.characters)"
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkRemainingChars()
    }
    
    func checkingConnection() {
        if Connectivity.isConnectedToInternet {
            print("Connected")
            getData()
        } else {
            print("No Internet")
            showErrorAlert()
        }
    }
    
    //MARK: ==================ALERTS=====================
    func showAlertWhenFieldsEmpty() {
        let alertController = UIAlertController(title: Strings.attention, message: Strings.fillAllFields, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: Strings.buttonYes, style: .default, handler: { action in
            
            print("Click YES button")
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert() {
        // create the alert
        let uiAlert = UIAlertController(title: Strings.noConnectionServer, message: Strings.checkInternetConnection, preferredStyle: UIAlertControllerStyle.alert)
        self.present(uiAlert, animated: true, completion: nil)
        
        // add an action (Retry)
        uiAlert.addAction(UIAlertAction(title: Strings.retry, style: .default, handler: { action in
            self.checkingConnection()
            print("Click retry button")
        }))
        
        // add an action (Retry)
        uiAlert.addAction(UIAlertAction(title: Strings.retryLater, style: .default, handler: { action in
            
            print("Click retry Later button")
        }))
    }
    
    //MARK: ACTIONS
    @IBAction func openMenuAction(_ sender: UIBarButtonItem) {
        addDiscussion()
    }
    
    @IBAction func addPhotoAction(_ sender: UIButton) {
        openCamera()
    }
    
    @IBAction func galeryAction(_ sender: UIButton) {
        //openPhotoLibrary()
        galleryVideoAndPhoto()
    }
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    //MARK: =========Request============
    func getData() {
            Alamofire.request("http://streams.fm/api8.php", method: .get)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    if (response.result.error == nil) {

                        let json = JSON(response.result.value as Any)
                        
                        var result = [Model]()
                        var photoArray = [String]()
                        var textArray = [String]()
                        
                        if let news = json[].array {
                            for item in news {
                                if let photo = item["photo_link"].string {
                                    photoArray.append(photo)
                                }
                                if let text = item["photo_text"].string {
                                    textArray.append(text)
                                }
                            }
                        }
                        //If succes
                        result.append(Model(photoText: textArray, photoLink: photoArray))
                        self.photoAndTextArray = result
                        print(self.photoAndTextArray)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    else {
                        debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                        //if error
                        
                    }
            }
        }
    
    func postData() {
        let image = selectedPhohtoImage.image
        let imgData = UIImageJPEGRepresentation(image!, 0.2)!
        
        let parameters = ["photo_text": newsTextView.text] //Optional for extra parameter
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "file", fileName: "file", mimeType: "image/png")
            for (key, value) in parameters {
                multipartFormData.append((value?.data(using: String.Encoding.utf8)!)!, withName: key)
            } //Optional for extra parameters
        },
                         to:"http://streams.fm/api7.php")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                    self.getData()
                })
                
                upload.responseJSON { response in
                    print("responseJSON", response.result.value as Any)
                }
                
            case .failure(let encodingError):
                print("encodingError", encodingError)
            }
        }
    }
    
    //MARK: =======Image=====
    func galleryVideoAndPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("This device doesn't have a camera.")
            return
        }
        
        imagePicker.sourceType = .camera
        imagePicker.cameraDevice = .rear
        //        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for:.camera)!
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
}

extension PhotoVideoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            imagePicker.dismiss(animated: true)
        }
        
        print(info)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {

            selectedPhohtoImage.contentMode = .scaleToFill
            selectedPhohtoImage.image = image
        }
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        if (mediaType == kUTTypeMovie as String){
            let tempVideo = info[UIImagePickerControllerMediaURL] as! URL
            if let thumbnail = generateThumnail(url: tempVideo) {
                // Use your thumbnail
                selectedPhohtoImage.contentMode = .scaleToFill
                selectedPhohtoImage.image = thumbnail
            }
        }
        
    }
    
    func generateThumnail(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.maximumSize = CGSize(width: 100, height: 100)
        let time = CMTimeMake(1, 30)
        
        if let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil) {
            return UIImage(cgImage: img)
        }
        return nil
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        defer {
            imagePicker.dismiss(animated: true)
        }
        
        print("did cancel")
    }
}
