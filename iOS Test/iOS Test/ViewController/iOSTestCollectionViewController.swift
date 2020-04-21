//
//  iOSTestCollectionViewController.swift
//  iOS Test
//
//  Created by MacPro on 16/04/20.
//  Copyright © 2020 Ian Castillo. All rights reserved.
//
import Foundation
import UIKit
import CoreData

private let reuseIdentifier = "ViewCell"

class iOSTestCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var photos = [Photos]()
    var persistentData = [Any]()
    let queue = DispatchQueue(label:"Queue", qos: .userInitiated)
    var retrievedData: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/photos")
        URLSession.shared.dataTask(with: url!) { (data, response,error) in
            if error ==  nil {
                do {
                    try self.photos = JSONDecoder().decode([Photos].self, from: data!)
                    for _ in self.photos {
                        var index = 0
                        let experiment = self.photos[index].title
                        self.persistentData.append(experiment as NSString)
                        print(self.persistentData.count)
                        index = index + 1
                    }
                    self.queue.async{
                        self.saveData(storeVariable: self.persistentData)
                    }
                } catch {
                    print("No se ha podido obtener el JSON: \(Error.self)")
                    
                }
                DispatchQueue.main.sync {
                    self.collectionView.reloadData()
                }
            } else {
                self.getData()
            }
        }.resume()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if photos.count == 0 {
            return 5000
        } else {
            return photos.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! IOSTestCollectionViewCell
        if photos.count == 0 {
            cell.nameLabel.text = "There's no Intenet Connection"
            cell.thumbnail.contentMode = .scaleAspectFill
        } else {
            cell.nameLabel.text = photos[indexPath.row].title.capitalized
            cell.thumbnail.contentMode = .scaleAspectFill
            let completeLink = photos[indexPath.row].thumbnailUrl
            cell.thumbnail.downloaded(from: completeLink)
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "VillainDetailViewController") as! VillainDetailViewController
        detailController.photoObject = self.photos[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
}

extension iOSTestCollectionViewController {
    func saveData(storeVariable: [Any]) {
        queue.async {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Entity", in: context)
            let newEntity = NSManagedObject(entity: entity!, insertInto: context)
            
            newEntity.setValue(storeVariable, forKey: "totalPhotos")
            do {
                try context.save()
                print("saved")
            } catch{
                print("Failed saving")
            }
        }
    }
    
    func getData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        request.returnsObjectsAsFaults = false
        do {
            var result =  try context.fetch(request)
            let last = result.popLast()
            retrievedData = last
            print(last!)
        }  catch{
            print("Failed")
        }
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.sync {
                self.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
