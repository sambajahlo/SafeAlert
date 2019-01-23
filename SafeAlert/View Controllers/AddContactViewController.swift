//
//  AddContactViewController.swift
//  SafeAlert
//
//  Created by Samba Diallo on 1/23/19.
//  Copyright © 2019 Samba Diallo. All rights reserved.
//

import UIKit


class AddContactViewController: UIViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func submitContact(_ sender: UIButton) {
        
        submitButton.isUserInteractionEnabled = false
        let fName = firstNameField.text
        let lName = lastNameField.text
        let num = phoneNumberField.text
        
        if(fName == "" || fName == nil || lName == "" || lName == nil)
        {
            self.okayAlert(title: "Name Error", message: "Please check that the contact's first and last names are correct!")
        }else if(num == "" || num == nil){
            self.okayAlert(title: "Phone Number Error", message: "Please check that the contact's phone number is correct!")
        }
        else{
            Contact.postContact(first: firstNameField.text, last: lastNameField.text, number: phoneNumberField.text) { (success:Bool, error : Error?) in
                if let error = error{
                    print(error.localizedDescription)
                }
                else {
                    print("Contact created successfully")
                    self.navigationController?.popViewController(animated: true)
                    
                }
            }
        }
        
    }
    func okayAlert(title: String,message : String){
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        submitButton.isUserInteractionEnabled = true
       
    }
    

    

}
