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
                sendAlert(title: "Empty text field", message: "Please type a word into all text fields", buttonTitle: "OK")
                return
        }
        update(englishWord, norwegianWord)
        save(englishWord, norwegianWord)
        englishTextField.text = ""
        norwegianTextField.text = ""
    }
    
    @IBAction func fetchDataFromDictionary(_ sender: UIButton) {
        fetchData()
    }
    
    func formatButton(_ button: UIButton) {
        button.contentEdgeInsets.bottom = 24
        button.contentEdgeInsets.top = 24
        button.contentEdgeInsets.left = 10
        button.contentEdgeInsets.right = 10
        button.layer.cornerRadius = 35
    }
    
    // MARK: Method to send an alert
    
    func sendAlert(title: String, message: String, buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .`default`, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: CoreData methods
    
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
            
            do {
                try managedContext.save()
                words.append(word)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func update(_ englishWord: String, _ norwegianWord: String) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        for word in words {
            if let english = word.value(forKey: "english") as! String?, let norwegian = word.value(forKey: "norwegian") as! String? {
                
                if english == englishWord || norwegian == norwegianWord {
                    word.setValue(englishWord, forKey: "english")
                    word.setValue(norwegianWord, forKey: "norwegian")
                    sendAlert(title: "Word Update", message: "This word was updated", buttonTitle: "OK")
                    
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
    
    func fetchData() {
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
            if let english = word.value(forKey: "english") as! String?, let norwegian = word.value(forKey: "norwegian") as! String? {
                wordsDict[english] = norwegian
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

