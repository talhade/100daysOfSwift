//
//  Petition.swift
//  petitionsProject
//
//  Created by Talha Demirkan on 16.08.2023.
//

import Foundation

struct Petition: Codable{
    var title: String
    var body: String
    var signatureCount: Int
}
