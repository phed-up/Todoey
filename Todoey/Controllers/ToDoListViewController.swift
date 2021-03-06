//
//  ViewController.swift
//  Todoey
//
//  Created by skwong on 2/10/18.
//  Copyright © 2018 skwong. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //This is to get the path to where the Data is being stored. In this case it is the SQLite DB
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        
    }
    
    //MARK - TableView Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        

        
        return cell
    }

    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        
        self.saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Items
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "New ToDo Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button on our UIAlert
            print(textField.text)
            

            
            let newItem = Item(context: self.context)
            
            newItem.title = textField.text!
            
            newItem.done = false
            
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveItems()
            
            
        
        }
        
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Create new item"
                textField = alertTextField
            
            }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    
    }
    

    func saveItems() {
        
        
        do {
            
            try context.save()
        }
        catch {
            
            print("Error saving context \(error)")
            
        }
        
        self.tableView.reloadData()
    }

    
    func loadItems() {

        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate : NSPredicate? = nil
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
                request.predicate = categoryPredicate
                }
        
        
//        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
//
//        request.predicate = compoundPredicate
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetchinv data from context \(error)")
        }
        
    }
    
    
    
    }


//MARK: - SearchBar Methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.count == 0 {
        
            
            loadItems()
            tableView.reloadData()
            
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
            
            
        }
        
        
    }
    
}



