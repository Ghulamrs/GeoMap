//
//  DataStruct.swift
//  GeoMap
//
//  Created by Home on 7/5/18.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
//import Alamofire

struct Response : Decodable {
    let success: Int
    let message: String
    
    init(json: [String: Any]) {
        success = json["success"] as? Int ?? 0
        message = json["message"] as? String ?? ""
    }
}

struct Location : Decodable {
    let id: UInt?
    let time: String?
    let lat:  Int?
    let lng:  Int?
    let alt:  Int?
    let vel:  Int?
    
    init(json: [String: Any]) {
        id   = json["id"] as? UInt ?? 0
        time = json["time"] as? String ?? ""
        lat  = json["lat"] as? Int ?? 0
        lng  = json["lng"] as? Int ?? 0
        alt  = json["alt"] as? Int ?? 0
        vel  = json["vel"] as? Int ?? 0
    }
}

struct CompositeLocation : Decodable {
    let id: UInt?
    let name: String?
    let time: String?
    let lat:  Double?
    let lng:  Double?
    let status: String?
    
    init(dictionary: [String: Any]) {
        self.id   = dictionary["id"] as? UInt ?? 0
        self.name = dictionary["name"] as? String ?? ""
        self.time = dictionary["time"] as? String ?? ""
        self.lat  = dictionary["lat"] as? Double ?? 0.0
        self.lng  = dictionary["lng"] as? Double ?? 0.0
        self.status = dictionary["status"] as? String ?? ""
    }
}

extension CompositeLocation {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case time
        case lat
        case lng
        case status
    }
}
