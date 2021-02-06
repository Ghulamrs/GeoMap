//
//  ViewController.swift
//  GeoMap
//
//  Created by Home on 6/21/18.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    struct Response : Decodable {
        let success: Int
        let message: String
        
        init(json: [String: Any]) {
            success = json["success"] as? Int ?? 0
            message = json["message"] as? String ?? ""
        }
    }
    var mapView: GMSMapView!
    var camera: GMSCameraPosition!
    var locationManager: CLLocationManager!
    var markers: [GMSMarker] = []
    var responses = [Response]()
    var pid: Int!
    var tid: Int!
    var name = "ahsan"
    let password = "ahs123"
    
    let myUrl = "http://3.92.12.25/system/"
    var location: CLLocation = CLLocation(latitude: 31.90, longitude: 73.61) // village
//    var location: CLLocation = CLLocation(latitude: 35.4780540, longitude: 72.5890814) // Kalam

    override func viewDidLoad() {
        super.viewDidLoad()
        camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                          longitude: location.coordinate.longitude,
                                          zoom: 15)
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        self.view = mapView
        self.pid = 1

        determineMyCurrentLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        if loadUserInfo() == nil { // check! if already stored profile
            loginMessage()         // if not; store a new user profile
        }

        let pakolor1 = UIColor(red:0.85, green:0, blue:0.5, alpha:1)
        let pakland1 = JsonFileLayer(mvc: self, color1: pakolor1, color2: pakolor1)
        pakland1.loadMap(name: "Pakistan1.js")
        let pakolor = UIColor(red:0, green:0.65, blue:0, alpha:1)
        let pakland = JsonFileLayer(mvc: self, color1: pakolor, color2: pakolor)
        pakland.loadMap(name: "pakistan.js")
        let loc = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        PutMarker(loc: loc, id: 3)
    }
    
    func saveUserInfo()
    {
        let userDefaults = UserDefaults.standard
        userDefaults.set(self.pid, forKey: "pid")
        userDefaults.set(self.name, forKey: "name")
        userDefaults.synchronize()
    }
    
    func loadUserInfo() -> Optional<Any>
    {
        if let key = UserDefaults.standard.object(forKey: "pid") {
            self.pid = (key as! Int)
            self.name = UserDefaults.standard.object(forKey: "name") as! String
        }
        
        return self.pid
    }
    
    func loginMessage() {
        let url = URL(string: myUrl+"login.php")
        var urlrequest = URLRequest(url: url!)
        urlrequest.httpMethod = "POST"

        let postString = String("name="+name+"&pswd="+password)
        urlrequest.httpBody = postString.data(using: .utf8, allowLossyConversion: true)
        URLSession.shared.dataTask(with: urlrequest, completionHandler: { (data, response, error) in
            
            if error != nil {
                print("Failed to get data from url")
                return
            }
            
//            if let response=response {
//                print(response)
//            }

            guard let data = data else { return }
            let dataString = String(data: data, encoding: .utf8)
//            print(dataString!)
            
            do {
                let decoder = JSONDecoder()
                self.responses = [try decoder.decode(Response.self, from: data)]
                print(self.responses[0].message)
                self.pid = self.responses[0].success
                if self.pid != 0 {
                    self.saveUserInfo()
                }
            }
            catch {
                print(error)
            }
        }).resume()
    }

    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        
        locationManager.headingFilter = 25.0
        locationManager.startUpdatingHeading()
    }

    func updateMarkers(location: [[String: Any]]) {
        var i = 0
        for loc in location {
            guard let latitude = loc["lat"] as? String else { return }
            guard let longitude = loc["lng"] as? String else { return }
            let lat = Double(latitude)
            let lng = Double(longitude)
            if i < self.markers.count {
                self.markers[i].position = CLLocationCoordinate2DMake(lat!, lng!)
                i+=1
            }
        }
    }
    
    func showAlertWith(title: String, message: String, style: UIAlertControllerStyle = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: title, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

    func sendLocation(loc: CLLocation) {
        let url = URL(string: myUrl + "setLocation.php")
        var urlrequest = URLRequest(url: url!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        urlrequest.httpMethod = "POST"
        let postString = String("pid=") + String(self.pid!) +
                     String("&par=") +
                     String(loc.coordinate.latitude)  + "," +
                     String(loc.coordinate.longitude) + "," +
                     String(loc.altitude.magnitude)   + "," +
                     String(loc.speed.magnitude)
//        print("data: \(postString)")
        urlrequest.httpBody = postString.data(using: .utf8, allowLossyConversion: true)
        URLSession.shared.dataTask(with: urlrequest, completionHandler: { (data, response, error) in

            if error != nil {
                print("Failed to get data from url")
                return
            }
            
//            if let response=response {
//                print(response)
//            }

//           guard let data = data else { return }
//            let dataString = String(data: data, encoding: .utf8)
//            print(dataString!)

            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [AnyObject]
                guard let jsonArray = json as? [[String: Any]] else { return }
                self.updateMarkers(location: jsonArray)
//                print(jsonArray)
            }
            catch let parsingError {
                print("Error: ", parsingError)
            }

        }).resume()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations.last!
        sendLocation(loc: userLocation)
        mapView.animate(toLocation: userLocation.coordinate)
//        print("loc \(userLocation.coordinate)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
    {
        mapView.animate(toBearing: newHeading.trueHeading)
        //print("Error \(newHeading.trueHeading)")
    }

    func PutMarker(loc: CLLocationCoordinate2D, id: UInt) {
        let im = markers.count
        let mark = GMSMarker();
        mark.position = CLLocationCoordinate2DMake(loc.latitude, loc.longitude)
        mark.snippet = self.name // String(id)
        markers.append(mark)
        markers[im].map = mapView
    }
}
