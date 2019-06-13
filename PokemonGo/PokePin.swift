//
//  PokePin.swift
//  PokemonGo
//
//  Created by MAC11 on 13/06/19.
//  Copyright © 2019 Carlos Alvarez. All rights reserved.
//

import UIKit
import MapKit


class PokePin:NSObject, MKAnnotation{
    var coordinate:CLLocationCoordinate2D
    var pokemon:Pokemon
    init(coord: CLLocationCoordinate2D, pokemon:Pokemon) {
        self.coordinate = coord
        self.pokemon = pokemon
    }
}
