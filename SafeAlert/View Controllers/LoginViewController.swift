//
//  LoginViewController.swift
//  SafeAlert
//
//  Created by Samba Diallo on 1/22/19.
//  Copyright © 2019 Samba Diallo. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBAction func signIn(_ sender: UIButton) {
            let username = usernameField.text ?? ""
            let password = passwordField.text ?? ""
            
            PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
                if let error = error {
                    print("User log in failed: \(error.localizedDescription)")
                    if(error._code == 201){
                        self.okayAlert(title: "Password Error", message: "You must include a password.")
                    }
                    else if(error._code == 200){
                        self.okayAlert(title: "Username Error", message: "You must include a username.")
                    }
                } else {
                    print("User logged in successfully")
                    
                    // shows the main view controller
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            }
            
        
    }
    @IBAction func signUp(_ sender: UIButton) {
       
            let newUser = PFUser()
            
            newUser.username = usernameField.text
            newUser.password = passwordField.text
            
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
                    
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                    
                }
            }
        
        
    }
    func okayAlert(title: String,message : String){
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
//    func checkInputs()->Bool{
//        let uText = usernameField.text
//        let pText = passwordField.text
//        if(uText != nil && uText != "" && pText != nil && pText != ""){
//            return true
//        }
//        return true
//    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
