//
//  LoadLayer.swift
//  Explorer
//
//  Created by Home on 8/20/18.
//  Copyright © 2018 Home. All rights reserved.
//

import GoogleMaps
import CoreFoundation
import CoreLocation
import Foundation

class JsonFileLayer {
    var border: Border?
    var mvc: ViewController
    var color1: UIColor
    var color2: UIColor
    let myUrls = "http://3.92.12.25/system/"

    init(mvc: ViewController, color1: UIColor, color2: UIColor) {
        self.mvc = mvc
        self.color1 = color1
        self.color2 = color2
    }

    func loadMap(name: String) {
        let url = URL(string: self.myUrls + name)
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    return
            }
            
//            guard let data = data else { return }
  //          let dataString = String(data: data, encoding: .utf8)
    //        print(dataString!)
            
            do {
                let decoder = JSONDecoder()
                self.border = try! decoder.decode(Border.self, from: data!)
                DispatchQueue.main.async {
                    self.drawMap()
                }
            }
        }
        task.resume()
    }

    func drawMap()
    {
        let border = GMSMutablePath()
        let layer = self.border?.border
        for loc in layer! {
            let pos = CLLocationCoordinate2DMake(loc.la, loc.ng)
            border.add(pos)
        }
        let country = GMSPolyline(path: border)
        country.geodesic = true
        country.strokeWidth = 2
        country.strokeColor = color1
        let solidRed = GMSStrokeStyle.solidColor(color1)
        let redBlue  = GMSStrokeStyle.gradient(from: color1, to: color2)
        country.spans = [GMSStyleSpan(style: solidRed),
                         GMSStyleSpan(style: solidRed),
                         GMSStyleSpan(style: redBlue)]
        country.map = mvc.mapView
    }
    
    func drawRectangle(west: Double, north: Double, east: Double, south: Double, width: Int, color: UIColor)
    {
        let rect = GMSMutablePath()
        rect.add(CLLocationCoordinate2D(latitude: north, longitude: west))
        rect.add(CLLocationCoordinate2D(latitude: north, longitude: east))
        rect.add(CLLocationCoordinate2D(latitude: south, longitude: east))
        rect.add(CLLocationCoordinate2D(latitude: south, longitude: west))

        // Create the polygon, and assign it to the map.
        let polygon = GMSPolygon(path: rect)
        polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.05);
        polygon.strokeColor = color
        polygon.strokeWidth = CGFloat(width)
        polygon.map = mvc.mapView
    }
    
    func drawCircle(latC: Double, longC: Double, radius: Double, width: Int, color: UIColor) {
        let circleCenter = CLLocationCoordinate2D(latitude: latC, longitude: longC)
        let circ = GMSCircle(position: circleCenter, radius: radius)
        circ.strokeColor = color
        circ.strokeWidth = CGFloat(width)
        circ.map = mvc.mapView
    }
}
