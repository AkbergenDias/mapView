//
//  Place.swift
//  mapView
//
//  Created by Диас Акберген on 03.08.2025.
//

import Foundation
import SwiftyJSON

struct Place: Codable {
    var title: String = ""
    var subtitle: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var details: String = ""
    var image: String = ""
    var rating: Double = 0.0

    init(json: JSON) {
        if let item = json["title"].string {
            title = item
        }
        if let item = json["subtitle"].string {
            subtitle = item
        }
        if let item = json["latitude"].double {
            latitude = item
        }
        if let item = json["longitude"].double {
            longitude = item
        }
        if let item = json["details"].string {
            details = item
        }
        if let item = json["image"].string {
            image = item
        }
    }
}
