//
//  SingleIngTableViewController.swift
//  Recipe God
//
//  Created by Olivier Butler on 19/09/2017.
//  Copyright © 2017 Olivier Butler. All rights reserved.
//

import UIKit
import CoreData

class SingleIngTableViewController: UITableViewController{
    var delegate: IngredientsViewController?
    var original: IngEntity?
    var recipes = [RecipeEntity]()
    @IBAction func addRecipePressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Recipe",
                                      message: "Add a new recipe you can use this ingredient with.",
                                      preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        
        let saveAction = UIAlertAction(title: "Save", style: .default)
        {
            _ in
            let textField = alert.textFields![0]
            let newRecipeEntity = RecipeEntity(context: self.delegate!.context!)
            newRecipeEntity.name = textField.text!
            let newJoinEntity = IngRecipeJoinEntity(context: self.delegate!.context!)
            newJoinEntity.ingUsedInRecipe = self.original!
            newRecipeEntity.addToIngredients(newJoinEntity)
            self.delegate!.saveData()
            self.getRecipes()
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func getRecipes() {
        if let recipesJoin = original!.recipes {
            recipes = []
            for join in recipesJoin.allObjects{
                let theJoin = join as! IngRecipeJoinEntity
                recipes.append(theJoin.recipesUsingIng!)
            }
            print("Recipies loaded, x\(recipes.count)")
        } else {
            print("Recipe load failed")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = original?.name
        getRecipes()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as! UITableViewCell
        newCell.textLabel?.text = recipes[indexPath.row].name
        return newCell
    }
}
