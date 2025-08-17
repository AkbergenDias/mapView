//
//  ViewController.swift
//  mapView
//
//  Created by Olzhas Akhmetov on 06.11.2024.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapview: MKMapView!
    var place: Place?
    
    let locationManager = CLLocationManager()
    
    var userLocation = CLLocation()
    
    var followMe = false
    
    var places: [Place] = []
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    func savePlaces() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(places) {
            UserDefaults.standard.set(data, forKey: "places")
        }
    }
    func loadPlaces() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "places") {
            if let savedPlaces = try? decoder.decode([Place].self, from: data) {
                self.places = savedPlaces
                
                for place in savedPlaces {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
                    annotation.title = place.title
                    annotation.subtitle = place.subtitle
                    self.mapview.addAnnotation(annotation)
                }
            }
        }
    }
    override func viewDidLoad() {
        loadPlaces()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let place = place {
            let dest = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            drawRoute(to: dest)
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
        
        // Настраиваем долгое нажатие - добавляем новые метки на карту
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressAction))
        // минимально 2 секунды
        longPress.minimumPressDuration = 2
        mapview.addGestureRecognizer(longPress)
        
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
        
        userLocation = CLLocation(latitude: 43.2389, longitude: 76.8897)
        
        print(userLocation)
        print("Updated user location:", userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        
        if followMe {
            // Дельта - насколько отдалиться от координат пользователя по долготе и широте
            let latDelta:CLLocationDegrees = 0.01
            let longDelta:CLLocationDegrees = 0.01
            
            // Создаем область шириной и высотой по дельте
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
            
            // Создаем регион на карте с моими координатоми в центре
            let region = MKCoordinateRegion(center: userLocation.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapview.setRegion(region, animated: true)
            
            // Приближаем карту с анимацией в данный регион
            mapview.setRegion(region, animated: true)
        }
    }
    
    @IBAction func showMyLocation(_ sender: Any) {
        followMe = true
    }
    func centerMap(on place: Place) {
        let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        let region = MKCoordinateRegion(center: coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapview.setRegion(region, animated: true)
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
    
    // Долгое нажатие на карту - добавляем новые метки
    @objc func longPressAction(gestureRecognizer: UIGestureRecognizer) {
        print("gestureRecognizer")
        
        // Получаем точку нажатия на экране
        let touchPoint = gestureRecognizer.location(in: mapview)
        
        // Конвертируем точку нажатия на экране в координаты пользователя
        let newCoor: CLLocationCoordinate2D = mapview.convert(touchPoint, toCoordinateFrom: mapview)
        
        let alert = UIAlertController(title: "New Place", message: "Enter details", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Title"}
        alert.addTextField { $0.placeholder = "Description"}
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let title = alert.textFields?[0].text ?? "Untitled"
            let subtitle = alert.textFields?[1].text ?? ""
            
            let descriptionText = alert.textFields?[1].text ?? ""
            let imageName = "placeholder"

            let place = Place(
                title: title,
                subtitle: descriptionText,
                latitude: newCoor.latitude,
                longitude: newCoor.longitude,
                description: descriptionText,
                image: imageName
            )
            self.places.append(place)
            self.savePlaces()
            
            // Создаем метку на карте
            let anotation = MKPointAnnotation()
            anotation.coordinate = newCoor
            
            anotation.title = title
            anotation.subtitle = subtitle
            
            self.mapview.addAnnotation(anotation)
        }
            
            alert.addAction(saveAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        
        
        // MARK: -  MapView delegate
        // Вызывается когда нажали на метку на карте
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            
            print(view.annotation?.title)
            
            // Получаем координаты метки
            let location:CLLocation = CLLocation(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
            
            // Считаем растояние до метки от нашего пользователя
            let meters:CLLocationDistance = location.distance(from: userLocation)
            distanceLabel.text = String(format: "Distance: %.2f m", meters)
            
            
            // Routing - построение маршрута
            // 1 Координаты начальной точки А и точки B
            let sourceLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            
            let destinationLocation = CLLocationCoordinate2D(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
            
            // 2 упаковка в Placemark
            let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
            let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
            
            // 3 упаковка в MapItem
            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            
            // 4 Запрос на построение маршрута
            let directionRequest = MKDirections.Request()
            // указываем точку А, то есть нашего пользователя
            directionRequest.source = sourceMapItem
            // указываем точку B, то есть метку на карте
            directionRequest.destination = destinationMapItem
            // выбираем на чем будем ехать - на машине
            directionRequest.transportType = .automobile
            
            // Calculate the direction
            let directions = MKDirections(request: directionRequest)
            
            // 5 Запускаем просчет маршрута
            directions.calculate {
                (response, error) -> Void in
                
                // Если будет ошибка с маршрутом
                guard let response = response else {
                    if let error = error {
                        print("Error: \(error)")
                    }
                    
                    return
                }
                
                // Берем первый машрут
                let route = response.routes[0]
                // Удалить все существующие маршруты
                self.mapview.removeOverlays(self.mapview.overlays)
                // Рисуем на карте линию маршрута (polyline)
                self.mapview.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
                
                // Приближаем карту с анимацией в регион всего маршрута
                let rect = route.polyline.boundingMapRect
                        self.mapview.setVisibleMapRect(
                            rect,
                            edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                            animated: true
                        )

                        // ✅ EXTRA FIX: force a smaller span (street/city level)
                        let region = MKCoordinateRegion(center: destinationLocation,
                                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        self.mapview.setRegion(region, animated: true)
                    }

        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            // Настраиваем линию
            let renderer = MKPolylineRenderer(overlay: overlay)
            // Цвет красный
            renderer.strokeColor = UIColor.red
            // Ширина линии
            renderer.lineWidth = 2.0
            
            return renderer
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
}
