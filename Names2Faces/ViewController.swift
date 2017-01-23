//
//  ViewController.swift
//  Names2Faces2
//
//  Created by Ilija Eftimov on 18/01/17.
//  Copyright © 2017 Ilija Eftimov. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = UIImageJPEGRepresentation(image, 80) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView?.reloadData()
        
        save()
        
        dismiss(animated: true)
    }
    
    internal func addNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
        } else {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        present(picker, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as! PersonCell
        
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        let promptAlertController = UIAlertController(
            title: "Choose action",
            message: "What do you want to do?",
            preferredStyle: .alert
        )
        
        promptAlertController.addAction(UIAlertAction(title: "Rename person", style: .default) { [unowned self] _ in
            let renameAlertController = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
            renameAlertController.addTextField()
            
            renameAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            renameAlertController.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self, renameAlertController, person] _ in
                let newName = renameAlertController.textFields![0]
                person.name = newName.text!
                
                self.collectionView?.reloadData()
            })
            
            self.present(renameAlertController, animated: true)
        })
        
        promptAlertController.addAction(UIAlertAction(title: "Remove person", style: .destructive) { [unowned self, indexPath] _ in
            self.people.remove(at: indexPath.item)
            self.collectionView?.reloadData()
        })
        promptAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(promptAlertController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            people = NSKeyedUnarchiver.unarchiveObject(with: savedPeople) as! [Person]
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func save() {
        let savedData = NSKeyedArchiver.archivedData(withRootObject: people)
        let defaults = UserDefaults.standard
        defaults.set(savedData, forKey: "people")
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

