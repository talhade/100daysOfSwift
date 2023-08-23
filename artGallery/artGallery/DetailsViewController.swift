//
//  DetailsViewController.swift
//  artGallery
//
//  Created by Talha Demirkan on 23.08.2023.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameText: UITextField!
    @IBOutlet var artistText: UITextField!
    @IBOutlet var yearText: UITextField!
    @IBOutlet var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            saveButton.isHidden = true
            //Core Data'dan data çekilecek
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idString = chosenPaintingID?.uuidString
            //idsi sağdakine eşit olanı bul.
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
             
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }catch{
                print("unable to load existing art")
            }
            
        }else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameText.text = ""
            artistText.text = ""
            
        }
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageGestureRecognizer )
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        imageView.image = image
        saveButton.isEnabled = true
        self.dismiss(animated: true)
        
    }
    

    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.8)
        newPainting.setValue(data, forKey: "image")
        
        do{
            try
            context.save()
            print("succesfully saved")
        }catch{
            print("unable to save")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil )
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    

}
