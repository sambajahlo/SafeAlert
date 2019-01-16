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

class ViewController: UIViewController, CLLocationManagerDelegate {

    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setting location to San Francisco
        let sanFrancisco = CLLocation(latitude: 37.773972, longitude: -122.431297)
        
        //Get user location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.startUpdatingLocation()
        goToLocation(location: locationManager.location ?? sanFrancisco)
        
        
    }

    
    func goToLocation(location:CLLocation){
        let span = MKCoordinateSpan(latitudeDelta: 0.1,longitudeDelta: 0.1)
        let reigon = MKCoordinateRegion(center: location.coordinate,span: span)
        mapView.setRegion(reigon, animated: false)
    }

}

