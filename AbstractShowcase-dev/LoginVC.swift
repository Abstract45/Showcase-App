//
//  LoginVC.swift
//  AbstractShowcase-dev
//
//  Created by Miwand Najafe on 2016-05-06.
//  Copyright © 2016 Miwand Najafe. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    @IBAction func fbBtnPressed(sender: UIButton) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions (["email"],fromViewController: self, handler: { (facebookResult, facebookError) in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else {
                let accesstoken = FBSDKAccessToken.currentAccessToken().tokenString
                DataService.instance.REF_BASE.authWithOAuthProvider("facebook", token: accesstoken, withCompletionBlock: { (error, authData) in
                    if error == nil {
                        
                        let user = ["provider": authData.provider!]
                        DataService.instance.createFirebaseUser(authData.uid, user: user)
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: self)
                    } else {
                        print("Login failed: \(error.debugDescription)")
                    }
                })
            }
        })
    }
    
    @IBAction func attemptLogin(sender: UIButton) {
        
        if let email = emailField.text where email != "",
            let password = passwordField.text where password != "" {
            DataService.instance.REF_BASE.authUser(email, password: password, withCompletionBlock: { (error, authData) in
                
                if error != nil {
                    if error.code == STATUS_ACCOUNT_NOEXIST {
                        DataService.instance.REF_BASE.createUser(email, password: password, withValueCompletionBlock: { (error, result) in
                            
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Problem creating account. Try something else")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                DataService.instance.REF_BASE.authUser(email, password: password, withCompletionBlock: { (nil, authData) in
                                    
                                    let user = ["provider": authData.provider!]
                                    DataService.instance.createFirebaseUser(authData.uid, user: user)
                                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                                })
                            }
                        })
                    } else {
                        self.showErrorAlert("Could not log in", msg: "Please check your email or password")
                    }
                } else {
                     NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: self)
                }
            })
        } else {
            showErrorAlert("Email and password required", msg: "You must enter an email and a password")
        }
    }
    
    func showErrorAlert(title:String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
