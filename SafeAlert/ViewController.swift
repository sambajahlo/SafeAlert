//
//  ViewController.swift
//  SafeAlert
//
//  Created by Samba Diallo on 1/15/19.
//  Copyright © 2019 Samba Diallo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import PubNub

class ViewController: UIViewController, CLLocationManagerDelegate,PNObjectEventListener {

    //MARK: Properties
    var client: PubNub!
    var keys : NSDictionary?
    var askedForHelp = false
    let span =  MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var contactView: UITableView!
    //Getting San Francisco Coordinates
    let sanFrancisco = CLLocation(latitude: 37.773972, longitude: -122.431297)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Getting the keys for use
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        setUpLocation()
        
        setUpPubnub()
        
        //Help button
        helpButton.layer.masksToBounds = true
        helpButton.layer.cornerRadius = 80
        
    }
    //MARK: Actions
    @IBAction func sendLocation(_ sender: UIButton) {
        askedForHelp = true
        publishLocation()
    }
    
    //MARK: Location and Map functions
    func getCurrentLocation()-> CLLocation{
        return locationManager.location ?? sanFrancisco
    }
    func setUpLocation(){
        
        //Get user location
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
                //sendText()
            }
        }
        
    }
    func goToLocation(location:CLLocation){
        let reigon = MKCoordinateRegion(center: location.coordinate,span: span)
        mapView.setRegion(reigon, animated: false)
    }
    
    //MARK: Text Methods
    func sendText(phone_number: String,messageCode: Int ){
//        var body = ""
//        switch messageCode {
//        case 1:
//            body = "Help, Claire is in
//        default:
//            message = "
//        }
        let testText = [
            //+61411111111 test number
            "to":"+61411111111",
            "body":"Woah im in danger"
        ]
        self.client.publish(testText, toChannel: "send_text") { (status) in
            if(!status.isError){
                print("SUCCESS sending location")
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
        self.client.publish(locationDict, toChannel: "location_help") { (status) in
            if(!status.isError){
                print("SUCCESS sending location")
            }else{
                print(status)
            }
        }
    }
    func setUpPubnub(){
        //Pubnub Keys
        let configuration = PNConfiguration(publishKey: keys!["publishKey"] as! String, subscribeKey: keys!["subscribeKey"] as! String)
        //Number of seconds which is used by server to track whether client still subscribed on remote data objects live feed or not.
        configuration.presenceHeartbeatValue = 180
        //Number of seconds which is used by client to issue heartbeat requests to PubNub service.
        configuration.presenceHeartbeatInterval = 30
        configuration.stripMobilePayload = false
        configuration.TLSEnabled = true
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client.addListener(self)
        
        // Subscribe to demo channel with presence observation
        self.client.subscribeToChannels(["location_help"], withPresence: true)
    }
    
    // Handle new message from one of channels on which client has been subscribed.
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        
        // Handle new message stored in message.data.message
        if message.data.channel != message.data.subscription {
            
            print("This \(message.data.channel) does not equal \(message.data.subscription ?? " default value")")
            // Message has been received on channel group stored in message.data.subscription.
        }
        else {
            print("This \(message.data.channel) does equal \(message.data.subscription ?? "default value")")
            // Message has been received on channel stored in message.data.channel.
        }
        
        print("Received message: \(message.data.message ?? "default value") on channel \(message.data.channel) " +
            "at \(message.data.timetoken)")
    }
    
    // Handle subscription status change.
    func client(_ client: PubNub, didReceive status: PNStatus) {
        
        if status.operation == .subscribeOperation {
            
            // Check whether received information about successful subscription or restore.
            if status.category == .PNConnectedCategory || status.category == .PNReconnectedCategory {
                
                let subscribeStatus: PNSubscribeStatus = status as! PNSubscribeStatus
                if subscribeStatus.category == .PNConnectedCategory {
                    
                    // This is expected for a subscribe, this means there is no error or issue whatsoever.
                    
                    //                    // Select last object from list of channels and send message to it.
                    //                    let targetChannel = client.channels().last!
                    //                    client.publish("Hello from the PubNub Swift SDK", toChannel: targetChannel,
                    //                                   compressed: false, withCompletion: { (publishStatus) -> Void in
                    //
                    //                                    if !publishStatus.isError {
                    //
                    //                                        // Message successfully published to specified channel.
                    //                                    }else {
                    //
                    //                                        /**
                    //                                         Handle message publish error. Check 'category' property to find out
                    //                                         possible reason because of which request did fail.
                    //                                         Review 'errorData' property (which has PNErrorData data type) of status
                    //                                         object to get additional information about issue.
                    //
                    //                                         Request can be resent using: publishStatus.retry()
                    //                                         */
                    //                                    }
                    //                    })
                }
                else {
                    
                    /**
                     This usually occurs if subscribe temporarily fails but reconnects. This means there was
                     an error but there is no longer any issue.
                     */
                }
            }
            else if status.category == .PNUnexpectedDisconnectCategory {
                
                /**
                 This is usually an issue with the internet connection, this is an error, handle
                 appropriately retry will be called automatically.
                 */
            }
                // Looks like some kind of issues happened while client tried to subscribe or disconnected from
                // network.
            else {let errorStatus: PNErrorStatus = status as! PNErrorStatus
                if errorStatus.category == .PNAccessDeniedCategory {
                    
                    /**
                     This means that PAM does allow this client to subscribe to this channel and channel group
                     configuration. This is another explicit error.
                     */
                }
                else {
                    
                    /**
                     More errors can be directly specified by creating explicit cases for other error categories
                     of `PNStatusCategory` such as: `PNDecryptionErrorCategory`,
                     `PNMalformedFilterExpressionCategory`, `PNMalformedResponseCategory`, `PNTimeoutCategory`
                     or `PNNetworkIssuesCategory`
                     */
                }
            }
        }
    }
    

}

