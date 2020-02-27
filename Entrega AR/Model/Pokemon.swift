//
//  Pokemon.swift
//  Entrega AR
//
//  Created by Matheus Oliveira on 26/02/20.
//  Copyright © 2020 Matheus Oliveira. All rights reserved.
//

import Foundation

class Pokemon {
    
    var name: String
    var number: String
    var weight: String
    var heigth: String
    var type: String
    
    init(name: String, number: String, weight: String,
         height: String,type: String) {
        
        self.name = name
        self.number = number
        self.weight = weight
        self.heigth = height
        self.type = type
    }
}
