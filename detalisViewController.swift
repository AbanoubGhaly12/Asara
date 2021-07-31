//
//  detalisViewController.swift
//  GP2
//
//  Created by Abanoub S. Ghaly on 6/23/19.
//  Copyright © 2019 Abanoub S. Ghaly. All rights reserved.
//

import UIKit
import CoreData
/*************************** edit notes *********************************/
class detailViewController: UIViewController{
     var Seguesty2 : String = ""
    var indexOfSelected : Int = 0
    var notes = [Note]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var contentText: UITextView!
    @IBOutlet weak var titlee: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNotes()
        if Seguesty2 == "detailSegue"{
            titlee.text = notes[indexOfSelected].title
            contentText.text = notes[indexOfSelected].content}
        else if Seguesty2 == "note2Segue" {
            titlee.text = ""
            contentText.text = ""
        }
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        notes[indexOfSelected].title = titlee.text
        notes[indexOfSelected].content = contentText.text
        saveItem()
        let alert = UIAlertController(title: "saved", message: "note has been saved", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert,animated: true , completion: nil)
    }
    func loadNotes(){
        let request : NSFetchRequest<Note> = Note.fetchRequest()
        do{
            notes = try context.fetch(request)
        }catch {
            print("Error fetching")
        }
        for note in notes {
            print(note.title)
        }
        //
    }
    //*********************  func related to coreData ********************************
    func saveItem(){
        do{
            try context.save()
            
        } catch {
            print("error saving context \(error)")
        }
        
        
        
        
    }
}
