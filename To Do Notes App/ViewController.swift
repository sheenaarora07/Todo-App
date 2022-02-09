//
//  ViewController.swift
//  To Do Notes App
//
//  Created by Sheena on 31/01/22.
//

import UIKit
import RealmSwift
import SwiftUI

class ViewController: UITableViewController {

    let realm = try! Realm()
    
    var items: Results<Todoitem>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "To Do App"
        navigationController?.navigationBar.prefersLargeTitles = true
        
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        loadItem()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        cell.textLabel?.text = item?.name ?? "No Item Added Yet"
        cell.accessoryType = item!.done ? .checkmark : .none
//        cell.detailTextLabel?.text = items?[indexPath.row].date
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = items?[indexPath.row] {
            do {
                try realm.write({
                    item.done = !item.done
                })
            } catch{
                print(error.localizedDescription)
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { action in
            let newItem = Todoitem()
            newItem.name = textField.text!
            newItem.id = UUID().hashValue
            self.saveItem(item: newItem)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(action)
        alert.addTextField { alertTextField in
            textField = alertTextField
            alertTextField.placeholder = "Add Item"
        }
        tableView.reloadData()
        present(alert, animated: true, completion: nil)
    }
    
    func saveItem(item: Todoitem) {
        do {
            try realm.write({
                realm.add(item)
            })
        } catch {
            print("error in saving")
        }
        tableView.reloadData()
    }
    
    func loadItem() {
        items = realm.objects(Todoitem.self)
        tableView.reloadData()
    }
    
    func deleteItem(at indexpath: IndexPath) {
        if let itemForDeletion = items?[indexpath.row] {
            do {
                try realm.write({
                    self.realm.delete(itemForDeletion)
                })
            } catch {
                print("error in deletion")
            }
        }
        tableView.reloadData()
    }
    
    func updateItem(at indexPath: IndexPath, with newName: String) {
        if let itemForUpdation = items?[indexPath.row]{
            do {
                            try realm.write({
                                realm.add(itemForUpdation, update: .all)
                                realm.create(Todoitem.self, value: ["id": itemForUpdation.id, "name": newName], update: .modified)
                              })
            } catch {
                print("error in updating")
            }
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { action, view, completion in
            let item = self.items?[indexPath.row]
                let updateAlert = UIAlertController(title: "Update", message: "", preferredStyle: .alert)
                let updateAction = UIAlertAction(title: "Update", style: .default) { action in
                    guard let field = updateAlert.textFields?.first, let newName = field.text, !newName.isEmpty else {return}
                    self.updateItem(at: indexPath, with: newName)
                    
                }
                updateAlert.addAction(updateAction)
                updateAlert.addTextField(configurationHandler: nil)
                updateAlert.textFields?.first?.text = item?.name
                
                self.present(updateAlert, animated: true, completion: nil)
            
            completion(true)
        }
        
        edit.backgroundColor = .gray
        
        let config = UISwipeActionsConfiguration(actions: [edit])
        return config
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { action, view, completion in
            self.deleteItem(at: indexPath)
            completion(true)
        }
        delete.backgroundColor = .red
        let config = UISwipeActionsConfiguration(actions: [delete])
        return config
    }
}
