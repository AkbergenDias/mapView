//
//  PlacesListViewController.swift
//  mapView
//
//  Created by Диас Акберген on 04.08.2025.
//

import UIKit
import SDWebImage
import Foundation
import Alamofire
import SwiftyJSON
import SVProgressHUD

class PlacesListViewController: UITableViewController {

    var delegate: ViewController?
    var places: [Place] = []
    
    func loadData() {
        let url = "https://demo8845027.mockable.io/places"
        
        SVProgressHUD.show()
        AF.request(url, method: .get).responseData
        { response in
            SVProgressHUD.dismiss()
            
            if response.response?.statusCode == 200 {
                let json = JSON(response.data!)
                
                print(json)
                
                if let resultArray = json.array {
                    for item in resultArray {
                        let placeItem = Place(json: item)
                        self.places.append(placeItem)
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Hotels & Places"
        loadData()
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
        
        let imageSize = CGSize(width: 80, height: 80)
        
        cell.imageView?.sd_setImage(
                with: URL(string: place.image),
                placeholderImage: UIImage(named: "placeholder"),
                options: [],
                completed: { image, _, _, _ in
                    if let image = image {
                        let resized = image.sd_resizedImage(with: imageSize, scaleMode: .aspectFill)
                        cell.imageView?.image = resized
                        cell.setNeedsLayout()
                    }
                }
            )
        cell.imageView?.clipsToBounds = true
        cell.imageView?.layer.cornerRadius = 6
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        print("Selected:", place.title, place.latitude, place.longitude)
    }
}
