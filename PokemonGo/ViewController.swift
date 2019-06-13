//
//  ViewController.swift
//  PokemonGo
//
//  Created by MAC11 on 13/06/19.
//  Copyright © 2019 Carlos Alvarez. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var ubicacion = CLLocationManager()
    var pokemons:[Pokemon] = []
    var contActualizaciones = 0
    @IBAction func centrarTapped(_ sender: Any) {
        if let coord = ubicacion.location?.coordinate{
            let region = MKCoordinateRegion.init(center: coord, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            contActualizaciones += 1
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if contActualizaciones<1{
        let region = MKCoordinateRegion.init(center: ubicacion.location!.coordinate, latitudinalMeters: 1000, longitudinalMeters: 10000
            )
            mapView.setRegion(region, animated: true)
            contActualizaciones += 1
        }else{
            ubicacion.stopUpdatingLocation()
        }
//        print("Ubicacion actualizada")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ubicacion.delegate = self
        pokemons = obtenerPokemon()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            mapView.delegate = self
            mapView.showsUserLocation = true
            ubicacion.startUpdatingLocation()
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (timer) in
                if let coord = self.ubicacion.location?.coordinate{
//                    let pin = MKPointAnnotation()
//                    pin.coordinate = coord
                    let pokemon = self.pokemons[Int(arc4random_uniform(UInt32(self.pokemons.count)))]
                    let pin = PokePin(coord: coord, pokemon: pokemon)
                    let randomLat = (Double(arc4random_uniform(200))-100.0)/5000.0
                    let randomLon = (Double(arc4random_uniform(200))-100.0)/5000.0
                    pin.coordinate.latitude += randomLat
                    pin.coordinate.longitude += randomLon
                    self.mapView.addAnnotation(pin)
                }
            })
        }else{
            ubicacion.requestWhenInUseAuthorization()
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
        let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pinView.image = UIImage(named: "player")
        var frame = pinView.frame
        frame.size.height = 50
        frame.size.width = 50
        pinView.frame = frame
        return pinView
        }
        let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
//        pinView.image = UIImage(named: "mew")
        let pokemon = (annotation as! PokePin).pokemon
        pinView.image = UIImage(named: pokemon.imagenNombre!)
        var frame = pinView.frame
        frame.size.height = 50
        frame.size.width = 50
        pinView.frame = frame
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        if view.annotation is MKUserLocation{
            return
        }
        let region = MKCoordinateRegion.init(center:(view.annotation?.coordinate)!, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (Timer) in
            if let coord = self.ubicacion.location?.coordinate{
                let pokemon = (view.annotation as! PokePin).pokemon

                if mapView.visibleMapRect.contains(MKMapPoint(coord)){
                    print("Puede atrapar el pokemon \(pokemon.nombre!)")
                    pokemon.atrapado = true
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    mapView.removeAnnotation(view.annotation!)
                    let alertaVC = UIAlertController(title: "Felicidades", message: "Atrapastes al pokemon \(pokemon.nombre!)", preferredStyle: .alert)
                    let pokedexAccion = UIAlertAction(title: "Ver Pokedex", style: .default, handler: {(actiom) in
                        self.performSegue(withIdentifier: "pokedexSegue", sender: nil)
                    })
                    alertaVC.addAction(pokedexAccion)
                    let okAccion = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertaVC.addAction(okAccion)
                    self.present(alertaVC, animated: true, completion: nil)
                }else{
                    print("No se puede atrapar el pokemon")
                    let alertaVC = UIAlertController(title: "Upps Esta demasiado lejos", message: "No puedes atrapar el pokemon \(pokemon.nombre!)", preferredStyle: .alert)
                    let okAccion = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertaVC.addAction(okAccion)
                    self.present(alertaVC, animated: true, completion: nil)
                }
                
            }
//        print("EL PIN FUE PRESIONADO!!!!!!!!!")
            
//        }
    }

}

