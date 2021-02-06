//
//  routeDrawing.swift
//  GeoMap
//
//  Created by Home on 11/21/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import GoogleMaps
//import GooglePlacesSearchController
import GooglePlaces

enum JSONError: String, Error {
    case NoData = "No data"
    case ConversionFailed = "Conversion failed"
}

class routeDrawing: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    var selectedRoute: Dictionary<NSObject, AnyObject>!
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var originAddress: String!
    var destinationAddress: String!
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var routePolyline: GMSPolyline!

    func getDirections(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: AnyObject!, completionHandler: ((_ status: String, _ success: Bool) -> Void)) {
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation
                //directionsURLString = directionsURLString.StringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!

                let directionsURL = NSURL(string: directionsURLString)
                
                dispatch_async(DispatchQueue.main.sync { () -> Void in
                    let directionsData = NSData(contentsOfURL: directionsURL!)
                    
                    var error: NSError?
                    let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as Dictionary<NSObject, AnyObject>
                    
                    if (error != nil) {
                        println(error)
                        completionHandler(status: "", success: false)
                    }
                    else {
                        let status = dictionary["status"] as String
                        
                        if status == "OK" {
                            self.selectedRoute = (dictionary["routes"] as Array<Dictionary<NSObject, AnyObject>>)[0]
                            self.overviewPolyline = self.selectedRoute["overview_polyline"] as Dictionary<NSObject, AnyObject>
                            
                            let legs = self.selectedRoute["legs"] as Array<Dictionary<NSObject, AnyObject>>
                            
                            let startLocationDictionary = legs[0]["start_location"] as Dictionary<NSObject, AnyObject>
                            self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as Double, startLocationDictionary["lng"] as Double)
                            
                            let endLocationDictionary = legs[legs.count - 1]["end_location"] as Dictionary<NSObject, AnyObject>
                            self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as Double, endLocationDictionary["lng"] as Double)
                            
                            self.originAddress = legs[0]["start_address"] as String
                            self.destinationAddress = legs[legs.count - 1]["end_address"] as String
                            
                            self.calculateTotalDistanceAndDuration()
                            
                            completionHandler(status: status, success: true)
                        }
                        else {
                            completionHandler(status: status, success: false)
                        }
                    }
                })
            }
            else {
                completionHandler("Destination is nil.", false)
            }
        }
        else {
            completionHandler("Origin is nil", false)
        }
    }

    func createRoute(sender: AnyObject) {
        let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.alert)
        
        addressAlert.addTextField { (textField) -> Void in
            textField.placeholder = "Origin?"
        }
        
        addressAlert.addTextField { (textField) -> Void in
            textField.placeholder = "Destination?"
        }
        
        let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            let origin = (addressAlert.textFields![0] as UITextField).text as! String
            let destination = (addressAlert.textFields![1] as UITextField).text as! String
            
            getDirections(origin, destination: destination, waypoints: nil, travelMode: nil, completionHandler: { (status, success) -> Void in
                if success {
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                    self.displayRouteInfo()
                }
                else {
                    println(status)
                }
            })
        }
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
            
        }
        
        addressAlert.addAction(createRouteAction)
        addressAlert.addAction(closeAction)
        
        present.ViewController(addressAlert, animated: true, completion: nil)
    }

    func drawRoute() {
        let route = overviewPolyline!["points"] as String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = viewMap
    }
}
