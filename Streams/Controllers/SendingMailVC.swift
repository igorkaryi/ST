//
//  SendingMailVC.swift
//  Streams
//
//  Created by Igor Karyi on 23.04.2018.
//  Copyright © 2018 Igor Karyi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SendingMailVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var buttonSend: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Strings.feedback
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        nameLabel.text = Strings.yourName
        emailLabel.text = Strings.yourEmail
        messageLabel.text = Strings.message
        
        buttonSend.setTitle(Strings.send, for: .normal)
        
        nameField.delegate = self
        emailField.delegate = self
        messageTextView.delegate = self
        
        registerForKeyboardNotifications()
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func kbWillShow(_ notification: Notification) {
        scrollView.contentOffset = CGPoint(x: 0, y: 80)
    }
    
    @objc func kbWillHide() {
        scrollView.contentOffset = CGPoint.zero
    }
    
    //MARK: - Controlling the Keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameField {
            textField.resignFirstResponder()
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            textField.resignFirstResponder()
            messageTextView.becomeFirstResponder()
            NotificationCenter.default.post(name: NSNotification.Name("kbWillShow"), object: nil)
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        NotificationCenter.default.post(name: NSNotification.Name("kbWillShow"), object: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            messageTextView.resignFirstResponder()
            checkingConnection()
        }
        return true
    }
    
    //MARK: ACTIONS
    @IBAction func sendAction(_ sender: UIButton) {
        checkingConnection()
    }
    
    func checkValidName() {
        if (emailField.text?.isValidEmail())! {
            sendMail()
        } else {
            incorrectEmailAlert()
        }
    }
    
    func checkingConnection() {
        if Connectivity.isConnectedToInternet {
            print("Connected")
            checkFields()
        } else {
            print("No Internet")
            showErrorAlert()
        }
    }
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkFields() {
        if (nameField.text?.isEmpty)! || (emailField.text?.isEmpty)! || (messageTextView.text?.isEmpty)! {
            
            showAlertWhenFieldsEmpty()
        } else {
            checkValidName()
        }
    }
    
    func sendMail() {
        //add our field to request
        let nameText = nameField.text
        let emailText = emailField.text
        let messageText = messageTextView.text
        
        // Add URL parameters
        let urlParams = [
            "name": nameText ?? String(),
            "email": emailText ?? String(),
            "message": messageText ?? String()
        ]
        
        // Fetch Request
        Alamofire.request("http://streams.fm/sendmail.php", method: .post, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    let json = JSON(response.result.value as Any)
                    print(json)
                    
                    let answer = json["answer"].string
                    print(answer!)
                    
                    if answer == "Your letter has been sent" {
                        self.successAlert()
                    } else {
                        self.errorAlert()
                    }
                }
                else {
                    debugPrint("HTTP Request failed: \(String(describing: response.result.error))")
                }
        }
    }
    
    //MARK: ALERTS
    func successAlert() {
        let alertController = UIAlertController(title: Strings.yourLetterHasBeenSent, message: "", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: Strings.buttonYes, style: .default, handler: { action in
            print("Click YES button")
            self.nameField.text = ""
            self.emailField.text = ""
            self.messageTextView.text = ""
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func errorAlert() {
        let alertController = UIAlertController(title: Strings.yourLetterHasBeenNoSent, message: "", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: Strings.buttonYes, style: .default, handler: { action in
            self.checkFields()
            print("Click YES button")
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func incorrectEmailAlert() {
        let alertController = UIAlertController(title: Strings.incorrectEmail, message: "", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: Strings.buttonYes, style: .default, handler: { action in

            print("Click YES button")
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
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
    
}

extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
