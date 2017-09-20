//
//  EditIngViewController.swift
//  Recipe God
//
//  Created by Olivier Butler on 19/09/2017.
//  Copyright © 2017 Olivier Butler. All rights reserved.
//

import UIKit

class EditingIngViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate{
    var delegate:IngredientsViewController?
    var origin:IngEntity?
    @IBOutlet weak var ingNameField: UITextField!
    @IBOutlet weak var ingPictureView: UIImageView!
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        if let _ = delegate{
            delegate!.saveIng(sender: self, origin: origin)
        }
    }
    
    @IBAction func imageButtonPressed(_ sender: UIButton) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = self
        let test = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
        if test {
            print("Preparing image picker")
            pickerController.modalPresentationStyle = .popover
            pickerController.popoverPresentationController?.delegate = self as? UIPopoverPresentationControllerDelegate
            pickerController.popoverPresentationController?.sourceView = view
            present(pickerController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("We've entered the add edit controller. View DID load.")
        if let _ = origin{
            self.title = "Edit Ingredient"
            self.ingNameField.clearsOnBeginEditing = false
            self.ingNameField.text = origin!.name
            if let imageData = origin!.image {
                self.ingPictureView.image = UIImage(data: imageData)
            }
        }
    }
    
    /**************/
    /* Delegation */
    /**************/
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            guard let imageData  = UIImageJPEGRepresentation(originalImage, 1) else {
                print("Couldn't make into image data")
                return
            }
            origin?.image = imageData
            ingPictureView.image = originalImage
        }
        picker.dismiss(animated: true)
    }
}

protocol EditingIngViewControllerDelegate {
    func saveIng(sender: EditingIngViewController, origin: IngEntity?)
}
