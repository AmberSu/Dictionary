//
//  ViewController.swift
//  Dictionary
//
//  Created by MacOS on 22/11/2017.
//  Copyright © 2017 amberApps. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var englishTextField: UITextField!
    
    @IBOutlet weak var norwegianTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var fetchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        englishTextField.delegate = self
        norwegianTextField.delegate = self
        formatButton(saveButton)
        formatButton(fetchButton)
    }
    
     // MARK: UIButton methods
    
    @IBAction func saveWordsToDictionary(_ sender: UIButton) {
        guard let englishWord = englishTextField.text, let norwegianWord =
        norwegianTextField.text, englishWord != "", norwegianWord != "" else {
            let alert = UIAlertController(title: "Empty text field", message: "Please type a word into all text fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .`default`, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        save(englishWord, norwegianWord)
        englishTextField.text = ""
        norwegianTextField.text = ""
    }
    
    @IBAction func fetchDataFromDictionary(_ sender: UIButton) {
        fetchData()
    }
    
    private func formatButton(_ button: UIButton) {
        button.contentEdgeInsets.bottom = 24
        button.contentEdgeInsets.top = 24
        button.contentEdgeInsets.left = 10
        button.contentEdgeInsets.right = 10
        button.layer.cornerRadius = 35
    }
    
     // MARK: Core Data methods
    
    func save(_ englishWord: String, _ norwegianWord: String) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if let entity =
            NSEntityDescription.entity(forEntityName: "Word",
                                       in: managedContext) {
            let word = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
            word.setValue(englishWord, forKey: "english")
            word.setValue(norwegianWord, forKey: "norwegian")
        }
    }
    
    func fetchData() {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Word")
        
        do {
            let words: [Any] = try managedContext.fetch(fetchRequest)
            for word in words {
                print(word)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error)")
        }
    }
    
    // MARK: UITextField methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
