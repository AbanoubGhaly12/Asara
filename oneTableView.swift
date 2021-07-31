//
//  oneTableView.swift
//  wholeProject
//
//  Created by phoebeezzat on 6/12/19/Users/pavlyremon/Desktop/wholeProject/wholeProject/oneTableView.swift.
//  Copyright © 2019 phoebe. All rights reserved.
//
import UIKit
import Contacts
import EventKit
import MediaPlayer
import CoreData
import Alamofire
import SwiftyJSON
/*
 this is one table view  passes all functions depend on the string  passed from view controller
 
 */
class oneTableViewController : UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var playListTable = [String]()
    var playListID = [UInt64]()
    var numofSong = [Int]()
    var contArray = [CONTACTS]()
    var results = [JSON]()
    var Seguesty : String = ""
    var smstext2 : String = ""
    var wikiText2 : String = ""
    var selectedIndex : Int = 0
    var remindstoto = [EKReminder]()
    var eventTa = [EKEvent]()
    let eventStore : EKEventStore = EKEventStore()
    var noteTa = [Note]()
    var wikiImages = [UIImage]()
    var image = UIImage.init()
      var calendars: [EKCalendar]?
    var url: NSURL!
    let playlists = MPMediaQuery.playlists().collections
    let myMediaPlayer = MPMusicPlayerApplicationController.applicationQueuePlayer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hor")
        if Seguesty == "wikiSegue"{
            getWikipedia(searchName: wikiText2)}
        else if Seguesty == "noteSegue"{
            loadNotes()}
        else if Seguesty == "musicSegue"{
            
            loadPlaylists()
            
        }
        tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    // return number of cells depend on the name of segue
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Seguesty == "callSegue" || Seguesty == "smsSegue"{
            print("rrf \(contArray.count)")
            return contArray.count
        }else if Seguesty == "ReminderSegue"{
            print(remindstoto.count)
            return remindstoto.count
        }else if Seguesty == "eventSegue" {
            print("slsls")
            return eventTa.count
        }else if Seguesty == "musicSegue" {
            return playListTable.count
        }else if Seguesty == "noteSegue" {
            return noteTa.count
        }else if Seguesty == "wikiSegue"{
            print("\(results.count)")
            return results.count
        }
        return 0
    }
    // cell view changes depend on the name of segue
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "oneCell", for: indexPath) as! TableViewCell
        
        if Seguesty == "callSegue" || Seguesty == "smsSegue"{
            
            cell.MainLabel.text = contArray[indexPath.row].fullname
            cell.secondLabel.text = contArray[indexPath.row].number
            cell.alarmSwitch.isHidden = true
            cell.wikiImage.isHidden = true
            /* cell.alarmSwitch.isHidden = true
             cell.wikiImage.isHidden = true*/
        }else if Seguesty == "ReminderSegue"{
            cell.MainLabel.text = remindstoto[indexPath.row].title
            cell.secondLabel.isHidden = true
            cell.alarmSwitch.isHidden = true
            cell.wikiImage.isHidden = true
        }else if Seguesty == "eventSegue"{
            cell.MainLabel.text = eventTa[indexPath.row].title
            cell.secondLabel.text = "Start: \(eventTa[indexPath.row].startDate ?? Date())"
            cell.alarmSwitch.isHidden = true
            cell.wikiImage.isHidden = true
        }else if Seguesty == "musicSegue"{
            cell.MainLabel.text = playListTable[indexPath.row]
            cell.secondLabel.text = "\(numofSong[indexPath.row]) songs"
            cell.alarmSwitch.isHidden = true
            cell.wikiImage.isHidden = true
        }else if Seguesty == "noteSegue" {
            cell.MainLabel.text = noteTa[indexPath.row].title
            cell.secondLabel.text = noteTa[indexPath.row].content
            cell.alarmSwitch.isHidden = true
            cell.wikiImage.isHidden = true
        }else if Seguesty == "wikiSegue" {
            cell.MainLabel.text = results[indexPath.row]["title"].stringValue
            cell.secondLabel.text = results[indexPath.row]["terms"]["description"][0].stringValue
            cell.alarmSwitch.isHidden = true
            if let url = results[indexPath.row]["thumbnail"]["source"].string {
                fetchImage(url: url, completionHandler: { image in
                    cell.wikiImage.image = image
                })
            }
            
        }
        return cell
    }
    //to make delete button for both notes and reminder
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if Seguesty == "noteSegue"{
            if  editingStyle == UITableViewCell.EditingStyle.delete  {
                context.delete(noteTa[indexPath.row])
                noteTa.remove(at: indexPath.row)
                saveItem()
                self.tableView.reloadData()
            }}else if Seguesty == "ReminderSegue" {
            calendars = eventStore.calendars(for: EKEntityType.reminder)
             let predict = eventStore.predicateForReminders(in: calendars)
            self.eventStore.fetchReminders(matching: predict){(reminders) in
                print("sos\(reminders!.count)")
            for remind in reminders! {
                if self.remindstoto[indexPath.row].title == remind.title {
                    do{
                        // remind.isCompleted = true
                        try self.eventStore.remove(remind, commit: true)
                        self.remindstoto.remove(at: indexPath.row)
                        self.tableView.reloadData()
                    }catch{
                        
                    }
                }
                }}
            
        }
        
        self.tableView.reloadData()
    }
    
    //the action will be happpened when the cell has been pressed
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Seguesty == "callSegue"{
            
            //call selected number
            contArray[indexPath.row].number = contArray[indexPath.row].number.replacingOccurrences(of: " ", with: "")
            url = URL(string: "telprompt://\(contArray[indexPath.row].number)")! as NSURL
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)}
        else if Seguesty == "smsSegue"{
            
            //send sms to selected number
            contArray[indexPath.row].number = contArray[indexPath.row].number.replacingOccurrences(of: " ", with: "")
            url = URL(string: "sms://\(contArray[indexPath.row].number)&body=\(smstext2)")! as NSURL
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            print("\(smstext2)")
        }else if Seguesty == "ReminderSegue"{
            
            // when select reminder it opens reminder application directly
            url = URL(string:
                "x-apple-reminder://\(remindstoto[indexPath.row].calendarItemIdentifier)")! as NSURL
            // print(remindstoto[indexPath.row].calendarItemIdentifier)
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            
        }else if Seguesty == "eventSegue"{
            
            //when select a cell  ,it will open event in calender application
            gotoAppleCalendar(date: eventTa[indexPath.row].startDate as! NSDate)
        }else if Seguesty == "musicSegue"{
            
            // Add a playback queue containing all songs on the device
            myMediaPlayer.setQueue(with: playlists![indexPath.row])
            myMediaPlayer.play()
            print("ssos : \(playListID[indexPath.row])")
           
        }else if Seguesty == "noteSegue" {
            
            //when select it ,it shows the details of nota
            selectedIndex = indexPath.row
            performSegue(withIdentifier: "detailSegue", sender: self)
        }else if Seguesty == "wikiSegue"{
            
            //when select one of each results it open selected result in safary
            var wikiSearch = results[indexPath.row]["title"].stringValue.replacingOccurrences(of: " ", with: "_")
            let url = "https://ar.wikipedia.org/wiki/\(wikiSearch)"
            let wikiurl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let myURL = URL(string: wikiurl!)
            UIApplication.shared.openURL(myURL as! URL)
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! detailViewController
        destination.indexOfSelected = selectedIndex
        destination.Seguesty2 = "detailSegue"
    }
    func gotoAppleCalendar(date: NSDate) {
        let interval = date.timeIntervalSinceReferenceDate
        let url = NSURL(string: "calshow:\(interval)")!
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
    func loadNotes(){
        let request : NSFetchRequest<Note> = Note.fetchRequest()
        do{
            noteTa = try context.fetch(request)
        }catch {
            print("Error fetching")
        }
        for note in noteTa {
            print(note.title)
        }
        //performSegue(withIdentifier: "noteSegue", sender: self)
        tableView.reloadData()    }
    func saveItem(){
        do{
            try context.save()
            
        } catch {
            print("error saving context \(error)")
        }
        
        
    }
    func getWikipedia(searchName : String){
        let wikiURl = "https://ar.wikipedia.org//w/api.php?action=query&format=json&prop=pageimages%7Cpageterms&generator=prefixsearch&redirects=1&formatversion=2&piprop=thumbnail&prop=pageimages|pageterms&pithumbsize=50&pilimit=10&wbptterms=description&gpssearch=\(searchName.replacingOccurrences(of: " ", with: "_"))&gpslimit=10"
        let url = wikiURl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let myURL = URL(string: url!)
        Alamofire.request(myURL! , method: .get ).responseJSON {
            response in
            if response.result.isSuccess {
                let wikiJSON : JSON = JSON(response.result.value!)
                print(wikiJSON)
                
                self.results = wikiJSON["query"]["pages"].arrayValue
                
            }
            self.tableView.reloadData()
        }
    }
    func fetchImage(url: String, completionHandler: @escaping (UIImage?) -> ()) {
        Alamofire.request(url).responseData { responseData in
            
            guard let imageData = responseData.data else {
                completionHandler(nil)
                return
            }
            
            guard let image = UIImage(data: imageData) else {
                completionHandler(nil)
                return
            }
            
            completionHandler(image)
        }
    }
    func loadPlaylists() {
        var PlayListID : String = ""
        for playlist in self.playlists! {
            //print(playlist.value(forProperty: MPMediaPlaylistPropertyName)!)
            self.playListTable.append(playlist.value(forProperty: MPMediaPlaylistPropertyName)! as! String)
            numofSong.append(playlist.count)
            if (playlist.value(forProperty: MPMediaPlaylistPropertyPersistentID) != nil){
                playListID.append(playlist.value(forProperty: MPMediaPlaylistPropertyPersistentID) as! UInt64)
                
            }else{
                playListID.append(0)
            }
            
            
        }
        tableView.reloadData()
    }
    
}
