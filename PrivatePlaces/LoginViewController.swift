//
//  LoginViewController.swift
//  PrivatePlaces
//
//  Created by Zackery leman on 8/19/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var signUp: UIButton!
    
    struct StoryBoard {
        static let loggingInSegue = "loggingIn"
    }
    
    private struct Const {
        static let CreatedUser = "Settings.CreatedUser"
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var createdUser: Bool {
        get { return defaults.objectForKey(Const.CreatedUser) as? Bool ?? false }
        set { defaults.setObject(newValue, forKey: Const.CreatedUser) }
    }
    
    
    
    // MARK: VC LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        password.delegate = self
        
        if  createdUser {
            signUp.hidden = true
            confirmPassword.hidden = true
        } else {
            loginButton.hidden = true
        }
        
    }
    
    
    
    // MARK: Signup & Login Actions
    
    @IBAction private func signUp(sender: UIButton) {
        if self.confirmPassword.hidden {
            //Show hidden field
            self.confirmPassword.hidden = false
        } else {
            
            if password.text == confirmPassword.text {
                print("\(email.text) : \(password.text)")
                do {
                    
                    try Locksmith.updateData([self.email.text!: self.password.text!], forUserAccount: GlobalConstants.singleUserAccount)
                    createdUser = true
                    self.confirmPassword.hidden = true
                    self.signUp.hidden = true
                    clearInput()
                    performSegueWithIdentifier(StoryBoard.loggingInSegue, sender: nil)
                } catch _ {
                    print("error")
                }
                
                
                
            } else {
                let alert = UIAlertController(title: "Sign up Error", message: "Passwords do not match. Please re-enter passwords.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
            
        }
    }
    
    func clearInput(){
        email.text = ""
        password.text = ""
        confirmPassword.text = ""
    }
    
    @IBAction func didTapLoginButton(sender: AnyObject) {
        
        let dictionary = Locksmith.loadDataForUserAccount(GlobalConstants.singleUserAccount)
        if let result = dictionary {
            if let storedPassword = result[email.text!] as? String {
                if storedPassword == password.text {
                    clearInput()
                    self.performSegueWithIdentifier(StoryBoard.loggingInSegue, sender: nil)
                    return
                }
            }
        }
        let alert = UIAlertController(title: "Sign up Error", message: "Password and account do not Match!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func unwind(segue:UIStoryboardSegue){}
    
}

extension LoginViewController: UITextFieldDelegate {
    
    /**
    * Called when 'return' key pressed. return NO to ignore.
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    /**
    * Called when the user click on the view (outside the UITextField).
    */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
