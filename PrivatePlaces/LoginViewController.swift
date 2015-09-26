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
        self.confirmPassword.hidden = true
        if  createdUser {
            signUp.hidden = true
        }
        
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: Signup & Login Actions
    
    @IBAction private func signUp(sender: UIButton) {
        if self.confirmPassword.hidden {
            //Show hidden field
            self.confirmPassword.hidden = false
        } else {
            
            if password.text == confirmPassword.text {
                println("\(email.text) : \(password.text)")
                if let error = Locksmith.updateData([email.text: password.text], forUserAccount: GlobalConstants.singleUserAccount){
                    println(error)
                } else {
                    createdUser = true
                     self.confirmPassword.hidden = true
                     self.signUp.hidden = true
                    clearInput()
                    performSegueWithIdentifier(StoryBoard.loggingInSegue, sender: nil)
                }
                
                
                
            } else {
                
                var alert = UIAlertController(title: "Sign up Error", message: "Passwords do not match. Please re-enter passwords.", preferredStyle: UIAlertControllerStyle.Alert)
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
        
        
        
        let (dictionary, error) = Locksmith.loadDataForUserAccount(GlobalConstants.singleUserAccount)
        if let result = dictionary {
            if let storedPassword = result[email.text] as? String {
                if storedPassword == password.text {
                    clearInput()
                    self.performSegueWithIdentifier(StoryBoard.loggingInSegue, sender: nil)
                } else{
                    var alert = UIAlertController(title: "Sign up Error", message: "Password and account do not Match!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
            }
            
            
        } else {
            println(error)
        }
        
        
        
        
    }
    
    
    @IBAction func unwind(segue:UIStoryboardSegue){}
    
    
}
