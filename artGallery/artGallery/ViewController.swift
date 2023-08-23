//
//  ViewController.swift
//  artGallery
//
//  Created by Talha Demirkan on 23.08.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedPainting = ""
    var selectedPaintingID : UUID?
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
    @objc func getData(){
        
        nameArray.removeAll()
        idArray.removeAll() 
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false
                 do{
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        self.nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
                    self.tableView.reloadData()
                }
            }
            
        }catch{
            print("Couldn't get the data")
        }
        
    }
    
    @objc func addButtonTapped(){
        selectedPainting = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingID = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.chosenPainting = selectedPainting
            destinationVC.chosenPaintingID = selectedPaintingID
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = nameArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row]{
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                tableView.reloadData()
                                //kaydetmemiz lazım
                                do{
                                    try context.save()
                                }catch{
                                    print("error")
                                }
                                break 
                            }
                        }
                    }
                }
            }catch{
                print("unable to get image to delete")
            }
        }


    }
    

}

