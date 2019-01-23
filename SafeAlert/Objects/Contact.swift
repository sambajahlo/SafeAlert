//
//  Contact.swift
//  SafeAlert
//
//  Created by Samba Diallo on 1/23/19.
//  Copyright © 2019 Samba Diallo. All rights reserved.
//

import UIKit
import Parse

class Contact: PFObject, PFSubclassing {
    
    @NSManaged var firstName :String?
    @NSManaged var lastName :String?
    @NSManaged var phoneNumber :String?
    @NSManaged var ownerUUID :String?
    
    // returns the Parse name that should be used
    class func parseClassName() -> String {
        return "Contact"
    }
    //to auto post a contact from the add contact page
    class func postContact(first: String?,  last: String?,number : String?, withCompletion completion: PFBooleanResultBlock?) {
        
        let contact = Contact()
        
        // assinging desired information to contact
        contact.firstName = first
        contact.ownerUUID = PFUser.current()?["uuid"] as? String // Pointer column type that points to PFUser
        contact.lastName = last
        contact.phoneNumber = number
        
        contact.saveInBackground(block: completion)
    }

}
