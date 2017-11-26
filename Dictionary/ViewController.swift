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
    
    var words: [NSManagedObject] = []
    
    class Vocabulary {
        var english: String
        var norwegian: String
        
        init(english: String, norwegian: String) {
            self.english = english
            self.norwegian = norwegian
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        englishTextField.delegate = self
        norwegianTextField.delegate = self
    }
    
    // MARK: UIButton methods
    
    @IBAction func saveWordsToDictionary(_ sender: UIButton) {
        guard englishTextField.text != "", norwegianTextField.text != "" else {
                sendAlert(title: "Empty text field", message: "Please type a word into all text fields")
                return
        }
        let vocabulary = Vocabulary(english: englishTextField.text!, norwegian: norwegianTextField.text!)
        
        update(vocabulary)
        save(vocabulary)
        englishTextField.text = ""
        norwegianTextField.text = ""
    }
    
    @IBAction func fetchDataFromDictionary(_ sender: UIButton) {
        fetchData()
    }
    
    // MARK: Method to send an alert
    
    private func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .`default`, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: CoreData methods
    
    private func setContext() -> NSManagedObjectContext? {
        if let appDelegate =
            UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.persistentContainer.viewContext
        }
        return nil
    }
    
    private func save(_ vocabulary: Vocabulary) {
        if let managedContext = setContext(), let entity =
            NSEntityDescription.entity(forEntityName: "Word",
                                       in: managedContext) {
            let word = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
            
            word.setValue(vocabulary.english, forKey: "english")
            word.setValue(vocabulary.norwegian, forKey: "norwegian")
            
            do {
                try managedContext.save()
                words.append(word)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    private func update(_ vocabulary: Vocabulary) {
        for word in words {
            if let englishSaved = word.value(forKey: "english") as! String?, let norwegianSaved = word.value(forKey: "norwegian") as! String?, let managedContext = setContext() {
                
                if englishSaved == vocabulary.english || norwegianSaved == vocabulary.norwegian {
                    word.setValue(vocabulary.english, forKey: "english")
                    word.setValue(vocabulary.norwegian, forKey: "norwegian")
                    sendAlert(title: "Word Update", message: "This word was updated")
                    
                    do {
                        try managedContext.save()
                        words.append(word)
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }
            }
        }
    }
    
    private func fetchData() {
        var wordsDict = [String:String]()
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Word")
        do {
            words = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for word in words {
            if let englishSaved = word.value(forKey: "english") as! String?, let norwegianSaved = word.value(forKey: "norwegian") as! String? {
                wordsDict[englishSaved] = norwegianSaved
            }
        }
        print(wordsDict)
    }
    
    // MARK: UITextField methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

