//
//  ViewController2.swift
//  NatureBookWithCoreData
//
//  Created by EMİN ÇETİN on 8.02.2023.
//

import UIKit
import CoreData

class ViewController2: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate{

    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var targetName = ""
    var targetId:  UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if targetName != "" {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "VC2")
            let idString = targetId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@    ", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    
                    if let name = result.value(forKey: "name") as? String {
                        nameTextField.text = name
                    }
                    if let place = result.value(forKey: "place") as? String {
                        placeTextField .text = place
                    }
                    if let year = result.value(forKey: "year") as? Int {
                        yearTextField.text = String(year)
                    }
                    if let imageData = result.value(forKey: "image") as? Data {
                        let image = UIImage(data: imageData)
                        imageView.image = image
                    }
                    
                }
            }catch {
                print("Error")
            }
     
        }else {
            
            
        }
        
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        imageView.addGestureRecognizer(gestureRecognizer)

    }
    @objc func imageTap() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true ,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true,completion: nil)
    }

    @IBAction func saveButton(_ sender: Any) {
//    MARK: -Core Data Saved Data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let saveData = NSEntityDescription.insertNewObject(forEntityName: "VC2", into: context)
        
        saveData.setValue(nameTextField.text!, forKey: "name")
        saveData.setValue(placeTextField.text!, forKey: "place")
        
        if let year = Int(yearTextField.text!) {
            saveData.setValue(year, forKey: "year")
        }
        let imagePress = imageView.image?.jpegData(compressionQuality: 0.5)
        saveData.setValue(imagePress, forKey: "image")
        
        saveData.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("Succes")
        }catch {
            print("Error")
        }
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
