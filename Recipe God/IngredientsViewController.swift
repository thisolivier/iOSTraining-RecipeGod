//
//  ViewController.swift
//  Recipe God
//
//  Created by Olivier Butler on 19/09/2017.
//  Copyright © 2017 Olivier Butler. All rights reserved.
//

import UIKit
import CoreData

class IngredientsViewController: UICollectionViewController, EditingIngViewControllerDelegate {
    
    //***********************//
    // Core setup            //
    //***********************//
    
    var delegate:IngredientsViewController?
    var context:NSManagedObjectContext?
    var allIng:[IngEntity]?
    var toDelete = [IndexPath]()
    
    @IBAction func IngEditPressed(_ sender: UIBarButtonItem) {
    }
    @IBAction func IngDeletePressed(_ sender: UIBarButtonItem) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = delegate{
            print("I am an ingredients controller, I have a delegate.")
            self.navigationItem.rightBarButtonItems = nil
        } else {
            print("I am the master ingredients controller.")
            context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            allIngGenerator()
        }
    }
    
    func allIngGenerator(){
        let requestObject = NSFetchRequest<NSFetchRequestResult>(entityName: "IngEntity")
        do {
            allIng = try context!.fetch(requestObject) as? [IngEntity]
            print ("Loaded ingredients from database")
        } catch {
            print ("Failed to load ingrtedients from database")
            print (error)
        }
    }
    
    func saveData() {
        do {
            try context!.save()
            print("Successfully saved from initial view saveData")
        } catch {
            print("Error when saving from initial view saveData")
            print(error)
        }
        allIngGenerator()
    }
    
    //***********************//
    // Segues                //
    //***********************//
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier!{
        case "ingEditSegue":
            let destination = segue.destination as! IngredientsViewController
            destination.title = "Edit Ingredients"
            destination.delegate = self
            print(sender!)
        case "ingDeleteSegue":
            let destination = segue.destination as! IngredientsViewController
            destination.title = "Delete Ingredients"
            destination.delegate = self
            destination.toDelete = [IndexPath]()
        case "ingAddSegue":
            let destination = segue.destination as! EditingIngViewController
            if self.title == "Edit Ingredients" {
                destination.origin = sender as? IngEntity
            }
            destination.delegate = self
        case "gotoIngSegue":
            let destination = segue.destination as! SingleIngTableViewController
            destination.delegate = self
            destination.original = (sender as! IngEntity)
        default:
            print ("Segue not matched to any preparation, must be showing")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Going from IngredientsViewController")
        super.viewWillDisappear(animated)
        if self.title == "Delete Ingredients" {
            self.delegate?.deleteItems()
        }
    }
    
    //***********************//
    // Setting up collection //
    //***********************//
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _ = delegate{
            return delegate!.allIng!.count
        }
        return allIng!.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let newCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ingredientCell", for: indexPath) as! IngCell
        let source = (delegate) == nil ? allIng!: delegate!.allIng!
        if let imageData = source[indexPath.row].image{
            newCell.ingCellImage.image = UIImage(data: imageData)
        }
        newCell.IngCellLabel.text = source[indexPath.row].name
        newCell.layer.cornerRadius = 60
        print("I'm here")
        return newCell
    }
    
    
    // Item was selected
    // Needs to know if it was triggered by the original, or subview
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.title {
        case "Edit Ingredients"?:
            let senderEntity = self.delegate!.allIng![indexPath.row]
            performSegue(withIdentifier: "ingAddSegue", sender: senderEntity)
        case "Delete Ingredients"?:
            if let _ = self.delegate{
                self.collectionView?.cellForItem(at: indexPath)?.backgroundColor = UIColor.black
                self.delegate!.toDelete.append(indexPath)
            }
        default:
            let senderEntity = self.allIng![indexPath.row]
            performSegue(withIdentifier: "gotoIngSegue", sender: senderEntity)
        }
    }
    
    //***********************//
    // Delegated functions   //
    //***********************//
    
    // Will create or get the current model entity, and save the changes
    func saveIng(sender: EditingIngViewController, origin: IngEntity?) {
        // Need to make this conditional on whether the view has a sender
        var newEntity:IngEntity {
            return NSEntityDescription.insertNewObject(forEntityName: "IngEntity", into: self.context!) as! IngEntity
        }
        let currentEntity:IngEntity?
        if let _ = sender.origin{
            currentEntity = sender.origin!
        } else {
            currentEntity = newEntity
            self.allIng!.append(currentEntity!)
        }
        
        currentEntity!.name = sender.ingNameField.text
        do {
            if let _ = context{
                try context!.save()
            } else {
                try delegate!.context!.save()
            }
            print("Saving ingredient success!")
        } catch {
            print("Saving ingredient failed")
            print(error)
        }
        self.collectionView?.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
    // This is called on the parent of the current instance to delete things
    // If that sounds confusing, it's because this class produces the initial view AND two subviews.
    // Also those subviews should really not be using the same controller. Like, at all.
    func deleteItems(){
        print("We made it to the master!")
        toDelete.sort(by: >)
        print(toDelete)
        for path in toDelete{
            let deadElement = allIng!.remove(at: path.row)
            self.context!.delete(deadElement)
        }
        self.collectionView?.deleteItems(at: toDelete)
        
        do{
            try self.context!.save()
            self.collectionView?.reloadData()
            self.toDelete = []
            print("Ingredients have been been deleted")
        } catch {
            print("Error while trying to delete the ingredients")
            print(error)
        }
    }
}

