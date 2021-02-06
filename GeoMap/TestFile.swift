//
//  TestFile.swift
//  GeoMap
//
//  Created by Home on 11/20/19.
//  Copyright © 2019 Home. All rights reserved.
//

import GoogleMaps
import GooglePlacesSearchController
import GooglePlaces

extension GMSMapView {
    enum JSONError: String, Error {
        case NoData = "Error: No data"
        case ConversionFailed = "Error: Conversion from JSON failed"
    }

    //MARK:- Call API for polygon points
    
    func drawPolygon1(from lahore: CLLocationCoordinate2D, to islamabad: CLLocationCoordinate2D) {
        
        let Lahore = "\(lahore.latitude)\(lahore.longitude)"
        let Islamabad = "\(islamabad.latitude)\(islamabad.longitude)"
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let address = "https://maps.googleapis.com/maps/api/directions/json?origin=\(Lahore)&destination=\(Islamabad)&key=AIzaSyAvYUMK6UMHPtVBA9hdQt4fI1bgiEO5VlU"
        guard let url = URL(string: address) else {
            print("Error: Cannot create URL")
            return
        }

        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in

            do {
                guard let data = data else {
                    throw JSONError.NoData
                }
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                    throw JSONError.ConversionFailed
                }
                print(json)
                
                DispatchQueue.global(qos: .background).async {
                    let array = json["routes"] as! NSArray
                    let dic = array[0] as! NSDictionary
                    let ovpl = dic["overview_polyline"] as! NSDictionary
                    let points = ovpl["points"] as! String
                    print("points")
                    
                    self.drawPath(with: points)
                }
            } catch let error as JSONError {
                print(error.rawValue)
            } catch let error as NSError {
                print(error.debugDescription)
            }
        })
        task.resume()
    }
    
    //MARK:- Draw polygon
    
    private func drawPath(with points : String) {
        DispatchQueue.main.async {
            let path = GMSPath(fromEncodedPath: points)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.strokeColor = .red
            polyline.map = self
        }
    }
}
