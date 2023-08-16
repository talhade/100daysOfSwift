//
//  ViewController.swift
//  shoppingList
//
//  Created by Talha Demirkan on 16.08.2023.
//

import UIKit

class ViewController: UITableViewController {
    
    var listItems = [String]()

    override func viewDidLoad() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped))
        
        super.viewDidLoad()
        
    }
    
    @objc func addTapped(){
        let ac = UIAlertController(title: "Enter a product", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let addProduct = UIAlertAction(title: "Add", style: .default){
            [weak self, weak ac] action in
            guard let product = ac?.textFields?[0].text else { return }
            self?.addProduct(product)
        }
        ac.addAction(addProduct)
        present(ac, animated: true)
    }
    
    func addProduct(_ product:String){
        if !product.isEmpty{
            listItems.insert(product, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }else{
            let ac = UIAlertController(title: "Add a Product", message: "It seems like you didnt add any product. Try again", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(ac, animated: true)
        }
    }
    
    @objc func refreshTapped(){
        listItems.removeAll()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = listItems[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    
}

