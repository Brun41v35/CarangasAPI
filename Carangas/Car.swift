//
//  Car.swift
//  Carangas
//
//  Created by Bruno Silva on 06/07/20.
//  Copyright © 2020 Eric Brito. All rights reserved.
//

import Foundation

class Car: Codable {
    
    var id: String
    var brand: String
    var gasType: Int
    var name: String
    var price: Double
    
    var gas: String {
        switch gasType {
        case 0:
            return "Flex"
        case 1:
            return "Alcool"
        default:
            return "Gasolina"
        }
    }
}
