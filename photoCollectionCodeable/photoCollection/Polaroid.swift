//
//  Polaroid.swift
//  photoCollection
//
//  Created by Talha Demirkan on 21.08.2023.
//

import UIKit

class Polaroid: NSObject, Codable {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
    

}
