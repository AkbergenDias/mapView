//
//  ViewController.swift
//  mapView
//
//  Created by Olzhas Akhmetov on 06.11.2024.
//

import UIKit
import MapKit

protocol RouteDelegate: AnyObject {
    func didSelectPlace(_ place: Place)
}

class ViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate, RouteDelegate {
    @IBOutlet weak var mapview: MKMapView!
    var place: Place?
    
    let locationManager = CLLocationManager()
    
    var userLocation = CLLocation()
    
    var followMe = false
    
    var places: [Place] = []
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let place = place {
            let dest = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        }
        
        // Запрашиваем разрешение на использование местоположения пользователя
        locationManager.requestWhenInUseAuthorization()
        
        // delegate нужен для функции didUpdateLocations, которая вызывается при обновлении местоположения (для этого прописали CLLocationManagerDelegate выше)
        locationManager.delegate = self
        
        // Запускаем слежку за пользователем
        locationManager.startUpdatingLocation()
        
        // Настраиваем отслеживания жестов - когда двигается карта вызывается didDragMap
        let mapDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap))
        
        // UIGestureRecognizerDelegate - чтоб мы могли слушать нажатия пользователя по экрану и отслеживать конкретные жесты
        mapDragRecognizer.delegate = self
        
        // Добавляем наши настройки жестов на карту
        mapview.addGestureRecognizer(mapDragRecognizer)
        
        // ______________ Метка на карте ______________
        // Новые координаты для метки на карте
        let lat:CLLocationDegrees = 37.957666//43.2374454
        let long:CLLocationDegrees = -122.0323133//76.909891
        
        // Создаем координта передавая долготу и широту
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)
        
        // Создаем метку на карте
        let anotation = MKPointAnnotation()
        
        // Задаем коортинаты метке
        anotation.coordinate = location
        // Задаем название метке
        anotation.title = "Title"
        // Задаем описание метке
        anotation.subtitle = "subtitle"
        
        // Добавляем метку на карту
        mapview.addAnnotation(anotation)
        
        
        // MKMapViewDelegate - чтоб отслеживать нажатие на метки на карте (метод didSelect)
        mapview.delegate = self
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPlacesList" {
            if let destination = segue.destination as? PlacesListViewController {
                destination.places = self.places
                destination.delegate = self
            }
        }
    }
    
    // Вызывается каждый раз при изменении местоположения нашего пользователя
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        userLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        print(userLocation)
        print("Updated user location:", userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        
        if followMe {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
                    mapview.setRegion(region, animated: true)
        }
        
        if let place = place {
                let dest = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
                drawRoute(to: dest)
            }
    }
    
    @IBAction func showMyLocation(_ sender: Any) {
        followMe = true
    }

    
    // Вызывается когда двигаем карту
    @objc func didDragMap(gestureRecognizer: UIGestureRecognizer) {
        // Как только начали двигать карту
        if (gestureRecognizer.state == UIGestureRecognizer.State.changed) {
            
            // Говорим не следовать за пользователем
            followMe = false
            
            print("Map drag changed")
        }
    }
    
    func drawRoute(to destination: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: userLocation.coordinate)
        let destPlacemark = MKPlacemark(coordinate: destination)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destPlacemark)
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            self.mapview.removeOverlays(self.mapview.overlays)
            self.mapview.addOverlay(route.polyline)
            self.mapview.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40),
                animated: true
            )
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func didSelectPlace(_ place: Place) {
        self.place = place
        let dest = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        drawRoute(to: dest)
    }
}
