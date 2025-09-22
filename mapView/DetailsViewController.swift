//
//  DetailsViewController.swift
//  mapView
//
//  Created by Диас Акберген on 10.08.2025.
//

import UIKit
import MapKit
import SDWebImage
import Cosmos


protocol PlaceDetailsDelegate: AnyObject {
    func didUpdateRating(for place: Place, rating: Double)
}

class DetailsViewController: UIViewController {
    var place: Place?
    weak var delegate: PlaceDetailsDelegate?
    var currentRating: Double = 0
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cosmosView: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let place = place else {
            print("DetailsViewController.place is nil — place was not set before presenting DetailsViewController")
            titleLabel?.text = "No place"
            descriptionLabel?.text = ""
            imageView?.image = nil
            return
        }
        
        titleLabel?.text = place.title
        descriptionLabel?.text = place.details
        
        
        if let url = URL(string: place.image) {
            imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
        imageView?.clipsToBounds = true
        
        let coord = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coord, span: span)
        mapView.setRegion(region, animated: false)
        
        cosmosView.rating = currentRating
        cosmosView.didFinishTouchingCosmos = {
            [weak self] rating in
            guard let self = self, let place = self.place else { return }
            self.delegate?.didUpdateRating(for: place, rating: rating)
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        annotation.title = place.title
        annotation.subtitle = place.subtitle
        mapView.addAnnotation(annotation)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRoute" {
            if let destVC = segue.destination as? ViewController {
                destVC.place = self.place
            }
        }
    }
}
