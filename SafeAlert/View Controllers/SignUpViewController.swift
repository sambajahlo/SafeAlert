//
//  SignUpViewController.swift
//  SafeAlert
//
//  Created by Samba Diallo on 2/11/19.
//  Copyright © 2019 Samba Diallo. All rights reserved.
//

import UIKit
import Parse
class SignUpViewController: UIViewController {

    //MARK: Properties and Outlets
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func signUp(_ sender: UIButton) {
        let newUser = PFUser()
        if(nameField.text == "" || nameField.text == nil || usernameField.text == "" || usernameField.text == nil || passwordField.text == "" || passwordField.text == nil || phoneField.text == nil || phoneField.text == "" ){
            
            self.okayAlert(title: "Missing Field", message: "You must fill out all fields!")
            return
            
        }
        
        newUser.username = usernameField.text
        newUser.password = passwordField.text
        newUser["name"] = nameField.text
        newUser["phone"] = phoneField.text
        
        // call sign up function on the new User object
        newUser.signUpInBackground { (success: Bool, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
                if(error._code == 201){
                    self.okayAlert(title: "Password Error", message: "You must include a password.")
                }
                else if(error._code == 200){
                    self.okayAlert(title: "Username Error", message: "You must include a username.")
                }
                else if(error._code == 202){
                    self.okayAlert(title: "Username Error", message: "Username already taken.")
                }
            } else {
                print("User Registered successfully")
                //set the users uuid
                let uuid = NSUUID.init()
                newUser["uuid"] = uuid.uuidString
                //updates the parse server with it.
                newUser.saveInBackground()
                self.performSegue(withIdentifier: "SignedUpSegue", sender: nil)
                
                
            }
        }
        
    }
    func okayAlert(title: String,message : String){
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
