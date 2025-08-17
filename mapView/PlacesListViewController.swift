//
//  PlacesListViewController.swift
//  mapView
//
//  Created by Диас Акберген on 04.08.2025.
//

import UIKit
class PlacesListViewController: UITableViewController {
    
    var places: [Place] = [
        Place(title: "Holland", subtitle: "Luxury by the sea",
              latitude: 43.2389, longitude: 76.8897,
              description: "Spacious rooms, spa, and oceanfront location.", image: "Holland"),

        Place(title: "Auezov city", subtitle: "Cozy rooms, great view",
              latitude: 43.2365, longitude: 76.9090,
              description: "Cozy inn with mountain views and complimentary breakfast.", image: "Auezov_city"),

        Place(title: "Legenda", subtitle: "Budget friendly stay",
              latitude: 43.2220, longitude: 76.8512,
              description: "Budget beds near downtown and public transit.", image: "Legenda"),

        Place(title: "Lamiya", subtitle: "Budget friendly stay",
              latitude: 43.2250, longitude: 76.9200,
              description: "Budget beds near downtown and public transit.", image: "Lamiya")
    ]
    var delegate: ViewController?
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Hotels & Places"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let details = segue.destination as? DetailsViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            details.place = places[indexPath.row]
        }
    }
    private func resizedImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place = places[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        cell.textLabel?.text = place.title
        cell.detailTextLabel?.text = place.subtitle
        if let raw = UIImage(named: place.image) {
            let thumb = resizedImage(raw, targetSize: CGSize(width: 60, height: 60))
            cell.imageView?.image = thumb
        } else {
            cell.imageView?.image = nil
        }
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.imageView?.layer.cornerRadius = 6
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        print("Selected:", place.title, place.latitude, place.longitude)
    }
}
