//
//  LocationSingleton.swift
//  frameworkTest
//
//  Created by prince jackes on 19/07/2018.
//  Copyright © 2018 prince jackes. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import GeoFire


protocol FleetFollowLocationPortocol {
    func GetLocation(location : CLLocation, km: Int)
}




private class FirebaseUser {
    var firstname: String ;
    var lastname: String ;
    var phoneNumber: String?;
    var lastTimeSeen: String?;
    var LastAdress: String?;
    var InMoveStatus: String?;
    var id: String?;
    
    init(snapshot: DataSnapshot) {
        let userDict = snapshot.value as? NSDictionary
        self.firstname = userDict?["firstname"] as? String ?? ""
        self.lastname = userDict?["lastname"] as? String ?? ""
        self.phoneNumber = userDict?["phoneNumber"] as? String ?? ""
        self.lastTimeSeen = userDict?["lastTimeSeen"] as? String ?? ""
        self.LastAdress = userDict?["LastAdress"] as? String ?? ""
        self.InMoveStatus = userDict?["InMoveStatus"] as? String ?? ""
        self.id = userDict?["id"] as? String ?? ""
        
    }
    
    public func setLastAdress(Adress: String){
        self.LastAdress = Adress
    }
    
    public func setInMoveStatus(Status: String){
        self.InMoveStatus = Status
    }
    
    public func setDate(Date: Date){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        let date = formatter.string(from: Date)
        self.lastTimeSeen = date
    }
    
    func toDictionary() -> Any {
        return ["firstname": self.firstname, "lastname": self.lastname, "phoneNumber": self.phoneNumber, "lastTimeSeen": self.lastTimeSeen, "LastAdress": self.LastAdress, "InMoveStatus": self.InMoveStatus] as Any
    }
}


public class FleetFollow: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    static let LaunchGeolocation = FleetFollow()
    var UserRef: DatabaseReference!
    var geofireRef: DatabaseReference!
    var geoFire: GeoFire!
    static var Lastlocation: CLLocation! = nil
    private static var firUser: FirebaseUser?
    private static var userUid: String? = nil
    
    var firstname: String?;
    var lastname: String?;
    static var delegate : FleetFollowLocationPortocol!
    
    
    // var delegate : FleetFollowLocationPortocol!
    
    private static var SdkIsValid = false;
    
    override init() {
        super.init()
        if(FleetFollow.SdkIsValid){
            print("ive been launched")
        }else{
            print("the sdk is not valid cant play this")
        }
    }
    
    public func InitWithUser(Firstname:  String, Lastname: String){
        self.firstname = Firstname;
        self.lastname = Lastname;
        
        if(Firstname.isEmpty){
            print("the firstname is missing")
        }else if(Lastname.isEmpty){
            print("the lastname is missing")
        }else{
            LoginUser(Firstname: Firstname, LastName: Lastname, id: "crmzfUgCSuefjfJTqBCc20JHQTC2")
            geofireRef = Database.database().reference().child("geofire")
            geoFire = GeoFire(firebaseRef: geofireRef)
            
        }
        
    }
    
    
    
    private func loadUser(UserUID:  String) {
        self.UserRef.child(UserUID).observe(DataEventType.value) { (snapshot) in
            FleetFollow.firUser = FirebaseUser(snapshot: snapshot)
            self.LaunchLocation()
        }
    }
    
    
    private func LoginUser(Firstname: String, LastName: String, id: String) {
        if Auth.auth().currentUser != nil {
            print("im here to stay")
            //            do{
            //              try Auth.auth().signOut()
            //            } catch {
            //
            //            }
            
            
            
            
            self.UserRef = Database.database().reference().child("users")
            let currentUser = Auth.auth().currentUser;
            FleetFollow.userUid = currentUser?.uid
            print("prince est la")
            self.loadUser(UserUID: FleetFollow.userUid!)
        }else{
            print("the kind of thing is happening")
            Auth.auth().signInAnonymously { (User, error) in
                if(error != nil){
                    print(error as Any)
                }else{
                    self.UserRef = Database.database().reference().child("users")
                    self.UserRef.child((User?.uid)!).setValue(["firstname": Firstname, "lastname": LastName, "id": id])
                    self.loadUser(UserUID: (User?.uid)!)
                }
            }
        }
    }
    
    
    private func LaunchLocation() {
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 2
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        // locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    
    
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        geoFire.setLocation(locations[0], forKey: (FleetFollow.userUid)!)
        let last = FleetFollow.Lastlocation == nil ? locations[0] : FleetFollow.Lastlocation
        let distance = last?.distance(from: locations[0])
        let distanceInt = Int(distance!)
        FleetFollow.delegate.GetLocation(location: locations[0], km: distanceInt)
        if(distanceInt > 1) {
            FleetFollow.firUser?.setInMoveStatus(Status: "Actif")
            FleetFollow.firUser?.setDate(Date: Date())
            self.UserRef.child((FleetFollow.userUid)!).setValue(FleetFollow.firUser?.toDictionary())
            FleetFollow.Lastlocation = locations[0];
        }else{
            CLGeocoder().reverseGeocodeLocation(locations[0]) { (placemark, error) in
                if error != nil {
                    
                }else {
                    let place = placemark?[0]
                    FleetFollow.firUser?.setLastAdress(Adress: (place?.subThoroughfare)! + " " + (place?.thoroughfare)! + "," + (place?.locality)!)
                    FleetFollow.firUser?.setInMoveStatus(Status: "Inactif")
                    FleetFollow.firUser?.setDate(Date: Date())
                    FleetFollow.Lastlocation = locations[0];
                    self.UserRef.child((FleetFollow.userUid)!).setValue(FleetFollow.firUser?.toDictionary())
                    print((place?.subThoroughfare)! + " " + (place?.thoroughfare)! + " " + (place?.locality)!)
                }
            }
            
        }
        
    }
    
    
    public static func ConfigureSDK(ApiKey: String) {
        self.SdkIsValid = true
    }
    
    
    
    public static func addCheckpoint(Location: CLLocation, Label: String) {
        //        let CheckPointRef = Database.database().reference().child("checkpoint")
        //        CheckPointRef.setValue(<#T##value: Any?##Any?#>)
    }
    
    
    public static func StartVoyage(Reference: String, Destination: CLLocation) {
        // self.
        //        let DestinationRef = Database.database().reference().child("destination")
    }
    
    
    public static func SetVoyageFinished(Reference: String) {
        //        let DestinationRef = Database.database().reference().child("destination")
        //
        //        DestinationRef.queryOrderedByKey()
        
    }
    
    
}
