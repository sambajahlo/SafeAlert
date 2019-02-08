//
//  MainViewController.swift
//  SafeAlert
//
//  Created by Samba Diallo on 1/15/19.
//  Copyright © 2019 Samba Diallo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import PubNub
import Parse

class MainViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource,UITableViewDelegate,PNObjectEventListener {

    //MARK: Properties
    var client: PubNub!
    let UUID = PFUser.current()?["uuid"] as! String
    var askedForHelp = false
    var contacts = [Contact]()
    let span =  MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    var locationManager: CLLocationManager!
    //Getting San Francisco Coordinates
    let sanFrancisco = CLLocation(latitude: 37.7739, longitude: -122.4312)
    
    //MARK: Outlets
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var dangerButton: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var contactView: UITableView!
   
    
    override func viewWillAppear(_ animated: Bool) {
        reloadContacts()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting the table view information
        contactTableView.delegate = self
        contactTableView.dataSource = self
        
        setUpLocation()
        
        setUpPubnub()
        
        
    }
    //MARK: Actions
    @IBAction func dangerClicked(_ sender: UITapGestureRecognizer) {
        if(!askedForHelp){
            dangerButton.image = UIImage(named: "finished")
            askedForHelp = true
            publishLocation()
            
            for contact in contacts{
                sendText(phone_number: contact.phoneNumber!)
            }
            self.okayAlert(title: "Alerted", message: "All contacts alerted to your location.")
        }else{
            dangerButton.image = UIImage(named: "danger")
            askedForHelp = false
        }
       
    }
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        PFUser.logOutInBackground { (error) in
             self.performSegue(withIdentifier: "logOutSegue", sender: nil)
        }
        
    }
    
    //MARK: Location and Map functions
    func getCurrentLocation()-> CLLocation{
        return locationManager.location ?? sanFrancisco
    }
    //This function sets up the locationManager to see where the users current location is.
    func setUpLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.requestWhenInUseAuthorization()
        goToLocation(location: locationManager.location ?? sanFrancisco)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            
            let region = MKCoordinateRegion(center: location.coordinate,span: span)
            mapView.setRegion(region, animated: false)
            if(askedForHelp){
                publishLocation()
                
            }
        }
        
    }
    func goToLocation(location:CLLocation){
        let reigon = MKCoordinateRegion(center: location.coordinate,span: span)
        mapView.setRegion(reigon, animated: false)
    }
    
    //MARK: Text Methods
    func sendText(phone_number: String){
        let currentCoordinate = getCurrentLocation().coordinate
        let testText = [
            //+61411111111 test number
            "to":phone_number,
            "lat":currentCoordinate.latitude,
            "lon":currentCoordinate.longitude,
            "uuid": UUID
            ] as [String : Any]
        self.client.publish(testText, toChannel: "send_text") { (status) in
            if(!status.isError){
                print("SUCCESS sending text")
            }else{
                print(status)
            }
        }
    }
    //MARK: Pubnub  Methods
    func publishLocation(){
        let currentCoordinate = getCurrentLocation().coordinate
        let locationDict = [
            "lat": currentCoordinate.latitude,
            "lon": currentCoordinate.longitude
        ]
        self.client.publish(locationDict, toChannel: UUID) { (status) in
            if(!status.isError){
                print("SUCCESS sending location")
            }else{
                print(status)
            }
        }
    }
    func setUpPubnub(){
        //Pubnub Keys
        let configuration = PNConfiguration(publishKey: "pub-c-29fb8b6a-3c2a-43be-8bc6-dcc74275a575", subscribeKey: "sub-c-6d6a767c-112a-11e9-abd1-2a488504b737")
        //Number of seconds which is used by server to track whether client still subscribed on remote data objects live feed or not.
        configuration.presenceHeartbeatValue = 180
        //Number of seconds which is used by client to issue heartbeat requests to PubNub service.
        configuration.presenceHeartbeatInterval = 30
        configuration.stripMobilePayload = false
        configuration.TLSEnabled = true
        //Logged in as this uuid
        configuration.uuid = UUID
        
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client.addListener(self)
        
        
        // Subscribe to uuid channel with presence observation
        self.client.subscribeToChannels([UUID], withPresence: true)
    }
    
    // Handle new message from one of channels on which client has been subscribed.
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        
        print("Received message: \(message.data.message ?? "default value") on channel \(message.data.channel) " +
            "at \(message.data.timetoken)")
    }

    //MARK: Table view methods
    func reloadContacts(){
        let query = PFQuery(className:"Contact")
        query.whereKey("ownerUUID", equalTo:UUID)
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                print("Successfully retrieved \(objects.count) contacts.")
                // Do something with the found objects
                self.contacts = objects as! [Contact]
                print(self.contacts)
                self.contactTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contactTableView.dequeueReusableCell(withIdentifier: "contactCell") as! ContactTableViewCell
        let contact = contacts[indexPath.row]
        cell.firstNameLabel.text = contact.firstName
        
        return cell
    }
    
    func okayAlert(title: String,message : String){
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

}

