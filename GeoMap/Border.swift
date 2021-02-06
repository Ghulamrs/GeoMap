// Border.swift
//

class Border : Codable {
    let border : [Point]

    init(data : [Point]) {
        self.border = data
    }
}

class Point : Codable {
    let ng:  Double
    let la:  Double

    init(lng: Double, lat: Double) {
        self.ng  = lng
        self.la  = lat
    }
}
