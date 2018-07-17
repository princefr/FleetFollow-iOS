//
//  FleetFollow.swift
//  FleetFollow
//
//  Created by prince ondonda on 12/07/2018.
//  Copyright © 2018 prince ondonda. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import GeoFire
import CoreLocation


public class User {
    var firstname: String ;
    var lastname: String ;
    var phoneNumber: String;
    var id: String;
    var lastTimeSeen: String;
    var LastAdress: String;
    var InMoveStatus: String;
    
    
    init(firstname: String, lastname: String, phoneNumber: String, id: String, lastTimeSeen: String, LastAdress: String, InMoveStatus: String){
        self.firstname = firstname;
        self.lastname = lastname;
        self.phoneNumber = phoneNumber;
        self.id = id;
        self.lastTimeSeen = lastTimeSeen;
        self.LastAdress = LastAdress;
        self.InMoveStatus = InMoveStatus;
    }
    
    
    public func setLastimeSeen(Time: String){
        self.lastTimeSeen = Time
    }
    
    
    public func setLastAdresse(Adress: String){
        self.LastAdress = Adress;
    }
    
    
    public func setInMoveStatus(Status: String){
        self.InMoveStatus = Status
    }
}


open class FleetFollow {
    
   public init(apiKey: String){
        if(apiKey.isEmpty){
            
        }else{
            print("blablabl je suis ici mais tu fais quoi toi ? ")
            FirebaseApp.configure()
            if Auth.auth().currentUser != nil {
                print("j'ai un utilisateurs")
                print(Database.database().reference().url)
                // User is signed in.
                // ...
            } else {
                print("je n'en ai pas un")
                LoginUser()
            }
            
        }
    }
    
    
    
    private func getUserLocation(){
        let locationManager = CLLocationManager()
    
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            // locationManager.delegate = self as! CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    open func LoginUser() {
        Auth.auth().signInAnonymously() {
            (authResult, error) in
            if (error != nil) {
                print("An error occured: \(String(describing: error))")
            } else {
                let UserRef = Database.database().reference().child("users")
                UserRef.observe(DataEventType.value, with: { (snapshot) in
                    // let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                })
                // UserRef.queryEqual(toValue: authResult?.uid).
                print("Logged successfully!")
                // let isAnonymous = authResult?.isAnonymous  // true
                // let uid = authResult?.uid
            }
        }
    }
    
    
    
    private func SendGeolocation(location: CLLocation, key: String, uid: String){
        let geofireRef = Database.database().reference().child("geofire")
        let UserRef = Database.database().reference().child("users")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        geoFire.getLocationForKey(uid) { (userlocation:CLLocation?, error:Error?) in
            if(error != nil){
                
            }else{
//                distance = userlocation.distance(from: location)
//                if(distance > 100){
//                    // set user
//                    geoFire.setLocation(location, forKey: uid)
//                    let user = User(firstname: "String", lastname: "String", phoneNumber: "String")
//                    // user.setLastimeSeen(Time: <#T##String#>)
//                }else{
//
//                }
            }
        }
        
    }
    
    
    private func getAdress(location: CLLocation){
        let geoCoder = CLGeocoder();
        geoCoder.reverseGeocodeLocation(location) { (place, error) in
            // Place details
            var placeMark: CLPlacemark!
            placeMark = place?[0]
            // Address dictionary
            //print(placeMark.addressDictionary ?? "")
            // Location name
            print(placeMark.name!)
            
        }
    }
    
    
    private func DateToString(date: Date) -> String {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    
    public static func Print(data: String) -> String{
        print(data)
        return data;
    }
    
    

}
