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
    
    class Word {
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
        let dictionaryWord = Word(english: englishTextField.text!, norwegian: norwegianTextField.text!)
        
        update(dictionaryWord)
        save(dictionaryWord)
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
    
    private func save(_ dictionaryWord: Word) {
        if let managedContext = setContext(), let entity =
            NSEntityDescription.entity(forEntityName: "Dictionary",
                                       in: managedContext) {
            let word = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
            
            word.setValue(dictionaryWord.english, forKey: "english")
            word.setValue(dictionaryWord.norwegian, forKey: "norwegian")
            
            do {
                try managedContext.save()
                words.append(word)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    private func update(_ dictionaryWord: Word) {
        for word in words {
            if let englishSaved = word.value(forKey: "english") as! String?, let norwegianSaved = word.value(forKey: "norwegian") as! String?, let managedContext = setContext() {
                
                if englishSaved == dictionaryWord.english || norwegianSaved == dictionaryWord.norwegian {
                    word.setValue(dictionaryWord.english, forKey: "english")
                    word.setValue(dictionaryWord.norwegian, forKey: "norwegian")
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
            NSFetchRequest<NSManagedObject>(entityName: "Dictionary")
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

