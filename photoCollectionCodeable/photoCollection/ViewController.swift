//
//  ViewController.swift
//  photoCollection
//
//  Created by Talha Demirkan on 21.08.2023.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var photos = [Polaroid]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhoto))
        
        let defaults = UserDefaults.standard
        
        if let savedPhotos = defaults.object(forKey: "photos") as? Data{
            let jsonDecoder = JSONDecoder()
            
            do{
                photos = try jsonDecoder.decode([Polaroid].self, from: savedPhotos)
            }catch{
                print("Unable to load data")
            }
        }
    }
    
    
    @objc func addPhoto(){
         let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentPathDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8){
            try? jpegData.write(to: imagePath)
        }
        
        let photo = Polaroid(name: "Unknown", image: imageName)
        photos.append(photo)
        save()
        collectionView.reloadData()
        
        dismiss(animated: true )
    }
    
    func getDocumentPathDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Polaroid", for: indexPath) as? PolaroidCell else {
            fatalError("Unable to dequeue PolaroidCell")
        }
        let polaroid = photos[indexPath.item]
        cell.name.text = polaroid.name
        let path = getDocumentPathDirectory().appending(path: polaroid.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path())
         
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let polaroid = photos[indexPath.item]
        
        let ac = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] action in
            guard let newName = ac?.textFields?[0].text else { return }
            polaroid.name = newName
            self?.save()
            self?.collectionView.reloadData()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
        
    }
    
    func save(){
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(photos){
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "photos")
        }else{
            print("Unable to Save")
        }
    }


}

