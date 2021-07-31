//
//  speechViewController.swift
//  GP2
//
//  Created by Abanoub S. Ghaly & Phoebe Ezzat on 6/9/19.
//  Copyright © 2019 Abanoub S. Ghaly. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import Alamofire
import Contacts
import EventKit
import MediaPlayer
import CoreData
import AVFoundation
import Firebase
import UserNotifications
extension ViewController : UNUserNotificationCenterDelegate{
    func  userNotificationCenter (_ center: UNUserNotificationCenter , willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping(UNNotificationPresentationOptions) -> Void){
        completionHandler([.alert,.sound,.badge])
    }
}
/*in this view controller
 *record sound when button is pressed
 *the recorded sound uploaded to server
 *using result from server to do mapping to do required function*/
class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate ,AVAudioRecorderDelegate{
    
    var pulseLayers = [CAShapeLayer]()
    var soundrecorder : AVAudioRecorder!
    var soundplayer : AVAudioPlayer!
    @IBOutlet weak var myText: UITextField!
    @IBOutlet weak var myOutText: UILabel!
    @IBOutlet weak var micBtn: UIButton!
    var Flag = 1
    var recordFileName : URL!
    var recordWavFile : URL!
    var wavAudioFile : String = "wavAudioFile.wav"
    var musicEffect : AVAudioPlayer = AVAudioPlayer()
    // function when press on button
    @IBAction func micBtnPressed(_ sender: UIButton) {

      if (Flag == 1)
      {
        micBtn.backgroundColor = UIColor.appColor2
            soundrecorder.record()
            myOutText.text = "اهلا انا فركبان, كيف اساعدك؟"
            Flag = 0
        }
      else  if (Flag == 0)
        {
            micBtn.backgroundColor = UIColor.appColor
            soundrecorder.stop()
            musicEffect.play()
            Flag = 1
        }
}
    
    //dictionary to convert string from model to arabic string
    var en_ar :[Character: String] =
        [ "A":"ء","B":"آ","C":"أ","D":"ؤ","E":"إ","F":"ئ","G":"ا",
          "H":"ب","I":"ة","J":"ت","K":"ث","L":"ج","M":"ح","N":"خ","O":"د",
          "P":"ذ","Q":"ر","R":"ز","S":"س","T":"ش","U":"ص","V":"ض","W":"ط","X":"ظ",
          "Y":"ع","Z":"غ","a":"ف","b":"ق","c":"ك","d":"ل","e":"م","f":"ن","g":"ه",
          "h":"و","i":"ى","j":"ي","k":"","l":"","m":"","n":"","o":"","p":"","q":"",
          "r":"","s":""," ":" "]
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var loadORremove : Bool = false //true for Remove
                                    // false  for Load
    var notes = [Note]()
    var playlistTitle: [String] = []
    var numOfSongs : [ Int ] = []
    let locationManager = CLLocationManager()
    var filterdItemsArray = [CONTACTS]()
    var smstext : String = ""
    var wikitext : String = ""
    let eventStore : EKEventStore = EKEventStore()
    var calendars: [EKCalendar]?
    var remindstoto = [EKReminder]()
    var events = [EKEvent]()
    var contactname = [String]()
    var names = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // setup location setting
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
       
        recordWavFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(wavAudioFile)
        setupRecorder()
    
        self.applyRoundCorner(micBtn)
        
       
        
        
        let musicFile = Bundle.main.path(forResource: "to-the-point", ofType: ".mp3")
        do{
            try musicEffect = AVAudioPlayer(contentsOf: URL(fileURLWithPath: musicFile!))
        }catch{
            print(error)
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        let ref1 = Database.database().reference()
        ref1.child("Salon").child("FireSensor").observe(.childChanged) { (snapshot) in
            let warn = snapshot.value as? String
            print ("\(warn)")
            if (warn == "10" ){
                
                self.warningMessage()}}
        
        let ref5 = Database.database().reference()
        ref5.child("Kitchen").child("FireSensor").observe(.childChanged) { (snapshot) in
            let warn = snapshot.value as? String
            if (warn == "11" ){
                self.warningMessage()}}
        
        
        
        let ref4 = Database.database().reference()
        ref4.child("Salon").child("FireSensor").observe(.childChanged) { (snapshot) in
            let temp = snapshot.value as? String
        }
        let ref6 = Database.database().reference()
        ref6.child("Door").child("DoorBell").observe(.childChanged) { (snapshot) in
            _ = snapshot.value as? String
            
            self.doorBell()
        }
        
        
        let ref7 = Database.database().reference()
        ref7.child("Kitchen").child("FireSensor").observe(.value) { (snapshot) in
            let warn = snapshot.value as? String
            if (warn == "11" ){
                self.warningMessage()}}
    }

    //*********************** all function related to mic *****************************************//
    func setupRecorder(){
        
        print(recordFileName as Any)
        //recorded audio setting
        let recordSetting = [AVFormatIDKey : kAudioFormatLinearPCM,
                             AVSampleRateKey:16000,
                             AVLinearPCMBitDepthKey:16,
                             AVNumberOfChannelsKey:1,
                             AVLinearPCMIsBigEndianKey : "false",
                             AVLinearPCMIsFloatKey :"false"] as [String : Any]
        do{
            // let recordedFileName = getDocumentDirector().appendingPathComponent(audioFile)
            soundrecorder = try AVAudioRecorder(url: recordWavFile, settings: recordSetting)
            soundrecorder.delegate=self
            soundrecorder.prepareToRecord()
        }catch{
            print(error)
        }
    }
    //after finishing recorde audio
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        print(recordWavFile!)
       server()
    }
    //************************  functions related to server and decoding  ***********************//
    func server(){
     
        let headers : HTTPHeaders = ["Content-type": "multipart/form-data"]
        let url = "http://35.238.182.105:8888/transcribe" // external ip of server and port 8888
        // request to upload multipart/form data to upload audio file
        Alamofire.upload(multipartFormData: { (MultipartFormData) in
            MultipartFormData.append(self.recordWavFile!, withName: "file")}, to: url,method: .post,headers: headers)
        { (encodingResult) in
            switch encodingResult {
            case .success(let upload , _ ,_):
                upload.responseJSON(completionHandler: { (response) in
                    if response.result.isSuccess{
                        print("success")
                        //response of server in in format JSON
                        let serverJSON : JSON = JSON(response.result.value!)
                        print(serverJSON)
                        // output string from JSON response
                        print(self.conv_to_arab(output: serverJSON["transcription"][0][0].stringValue))
                        self.myText.text = self.conv_to_arab(output: serverJSON["transcription"][0][0].stringValue)
                        if (self.myText.text != ""){
                            self.addReminder()}else{
                            print("failed")
                        }
                    }else{
                        print("failed")
                    }
                })
            case .failure(_):
                print("flkf")
            }
        }
    }
    func conv_to_arab(output : String)-> String{
        var outStr:String = ""
        
        
        for i in output{
            outStr.append(en_ar[i]!)
        }
        return outStr
    }
    // **********************to take photo and save photos **********************************//
    func takePhotosfunc (){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    //action when finish using picker controller is save photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage]as? UIImage{
            picker.dismiss(animated: true, completion: nil)
            UIImageWriteToSavedPhotosAlbum(pickedImage, nil, nil, nil)
            let alert = UIAlertController(title: "saved", message: "yourimage has been saved", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert,animated: true , completion: nil)
        }
    }
    //***************************    open photos   *********************************************//
    func openPhotosfunc (){
        let url : NSURL = URL(string: "photos-redirect://")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    //**************************  GoogleSearch    *********************************************//
    func googleSearch(searchSent : String){
        // removing white spaces are replaced with +
        print(searchSent.replacingOccurrences(of: " ", with: "+"))
        let myURLString =  "http://www.google.com/search?hl=ar&q=\(searchSent.replacingOccurrences(of: " ", with: "+"))"
        let url = myURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let myURL = URL(string: url!)
        UIApplication.shared.open(myURL! , options: [:], completionHandler: nil)
    }
    //***************************   getWeather    **********************************************//
    //get latitude and longitude of current project
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //last value in array will be more accurate
        let App_id = "1aceb2f3462bcbb96bb892abc52ab2cb"
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            print("long = \(location.coordinate.longitude), lat = \(location.coordinate.latitude) ")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params : [String : String ] = [ "lat" : latitude , "lon" : longitude , "appid" : App_id ]
            getWeather( params: params)
        }
    }
    //action when failed to get your location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        createcontactAlert(title: "failed", message: "failed to get your location")
    }
    //make request to website by passing parameters and get JSON response
    func getWeather(params : [String : String]){
        let weatherURl = "http://api.openweathermap.org/data/2.5/weather"
        Alamofire.request(weatherURl,method: .get ,parameters: params).responseJSON {
            response in
            if response.result.isSuccess{
                print("success,got weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.UpdateWeatherData(json: weatherJSON)
                
            }else{
                // alert connection issues
                let alert = UIAlertController(title: "connection loss", message: "there is an issue in your connection", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
                print("error,\(response.result.error ?? 0 as! Error)")
            }
        }
    }
    //function to get temperature , city name and weather icon
    func UpdateWeatherData(json : JSON){
        let weatherModel = WeatherDataModel()
        if let temp = json["main"]["temp"].double{
            weatherModel.temp = Int(temp - 273.15)
            weatherModel.city = json["name"].stringValue
            weatherModel.condition = json["weather"][0]["id"].intValue
            weatherModel.weatherIcon = weatherModel.updateWeatherIcon(condition: weatherModel.condition)
            let alert = UIAlertController(title : "the Weather",message : "today , the weather is \(weatherModel.temp) in  \(weatherModel.city)",preferredStyle: .alert)
            
            alert.addImage(image: UIImage(named: weatherModel.weatherIcon)!)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        }else{
            //alert city.text =  locationUNavailable
            let alert = UIAlertController(title: "Location unavailable", message: "can't reach to your location", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    //*******************************************    call contact     *********************************************************//
    
    func callContact (cont : String){
        print("ys")
     
    //get all contacts stored on iphone and search for the same name
      
        for i in fetchcontacts() {
            names.append(i.fullname)
        }
        var firstName = [String]()
        //get all contacts stored on iphone and search for the same name
        var count: Float = Float(cont.count)
        var dif1:Float = 0.0
        var error:Float = 0.0
        let threshold: Float = 30.0
        for i in fetchcontacts() {
            firstName = i.fullname.components(separatedBy: " ")
            if (firstName[0] == ""){
            var  difference1 = zip(cont , firstName[1]).filter{ $0 != $1 }
            dif1 = Float(difference1.count)
            error = (dif1 / count) * 100
            if (error < threshold) {
                filterdItemsArray.append(i)
                }}else{
                var difference1 = zip(cont , firstName[0]).filter{ $0 != $1 }
                dif1 = Float(difference1.count)
                error = (dif1 / count) * 100
                if (error < threshold){
                     filterdItemsArray.append(i)
                }
            }
        }
        
        print(filterdItemsArray.count)
       // if the application found one contact only it call it
        if filterdItemsArray.count == 1{
            filterdItemsArray[0].number = filterdItemsArray[0].number.replacingOccurrences(of: " ", with: "")
            let url : NSURL = URL(string: "tel://\(filterdItemsArray[0].number)")! as NSURL
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            //if the application found more than one contact ,it loads this contacts on table view
        }else if filterdItemsArray.count > 1 {
            performSegue(withIdentifier: "callSegue", sender: self)}
        else {
           let alert9 = UIAlertController(title: "لايوجد جهة اتصال بهذا الاسم", message: "", preferredStyle: .alert)
            let tryAgain = UIAlertAction(title: "حاول مرة اخري", style: .default){ (action ) in
                self.callContact2()
            }
            let cancel = UIAlertAction(title: "الغي الامر", style: .default, handler: nil)
            alert9.addAction(tryAgain)
            alert9.addAction(cancel)
           present(alert9, animated: true,completion: nil)
            
        }
    }
    // used only when user not found any contacts from search call this function to get it manually
    func callContact2()  {
        //createcontactAlert(title: "not found ", message: "no matched name of contact found")
        var contName : String = ""
        var TextField = UITextField()
        let alert2 = UIAlertController(title: "search for contact", message: "", preferredStyle: .alert)
        let addTitle = UIAlertAction(title: "search", style: .default) { (action) in
            contName = TextField.text!
            for i in self.fetchcontacts() {
                self.names.append(i.fullname)
            }
            var firstName = [String]()
            //get all contacts stored on iphone and search for the same name
            var count: Float = Float(contName.count)
            var dif1:Float = 0.0
            var error:Float = 0.0
            let threshold: Float = 30.0
            for i in self.fetchcontacts() {
                firstName = i.fullname.components(separatedBy: " ")
                if (firstName[0] == ""){
                    var  difference1 = zip(contName , firstName[1]).filter{ $0 != $1 }
                    dif1 = Float(difference1.count)
                    error = (dif1 / count) * 100
                    if (error < threshold) {
                        self.filterdItemsArray.append(i)
                    }}else{
                    var difference1 = zip(contName , firstName[0]).filter{ $0 != $1 }
                    dif1 = Float(difference1.count)
                    error = (dif1 / count) * 100
                    if (error < threshold){
                        self.filterdItemsArray.append(i)
                    }
                }
            }
            
           
            print(self.filterdItemsArray.count)
            if self.filterdItemsArray.count == 1{
                self.filterdItemsArray[0].number = self.filterdItemsArray[0].number.replacingOccurrences(of: " ", with: "")
               let url : NSURL = URL(string: "tel://\(self.filterdItemsArray[0].number)")! as NSURL
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
              //  print("second function is done")
            }else if self.filterdItemsArray.count > 1 {
                self.performSegue(withIdentifier: "callSegue", sender: self)}
            else {
                self.createcontactAlert(title: "not found ", message: "no matched name of contact found")
            }
        }
        alert2.addTextField { (alertTextField) in
            alertTextField.placeholder = "search for name"
            TextField = alertTextField
        }
        alert2.addAction(addTitle)
        
        present(alert2, animated: true,completion: nil)
        
    }
    //alert
    func createcontactAlert (title : String , message : String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    //alert with text field
   
    //function used for to get all contacts from iphone contacts
    func fetchcontacts() -> [CONTACTS]{
        //store it into array type class contact has two element : name of contact and phone number
        var fetcontacts = [CONTACTS]()
        let ContactStore = CNContactStore()
        let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey]
        let fetchreq = CNContactFetchRequest.init(keysToFetch: keys as [CNKeyDescriptor] )
        do{
            try ContactStore.enumerateContacts(with: fetchreq) { (contact, end) in
                let datacontant = CONTACTS(NAME: "\(contact.givenName) \(contact.familyName)", phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "400")
                fetcontacts.append(datacontant)
           
                print(contact.givenName)
                print(contact.phoneNumbers.first?.value.stringValue ?? "")
            }}
        catch{
            print("failed to fetch")
        }
        return fetcontacts
    }
    //*************************************************  sendSMS    *********************************************************
    func sendSMS (cont : String , body : String){
        //same as call contact func to get contacts shared the same name
        for i in fetchcontacts() {
            names.append(i.fullname)
        }
        var firstName = [String]()
        //get all contacts stored on iphone and search for the same name
        var count: Float = Float(cont.count)
        var dif1:Float = 0.0
        var error:Float = 0.0
        let threshold: Float = 30.0
        for i in fetchcontacts() {
            firstName = i.fullname.components(separatedBy: " ")
            if (firstName[0] == ""){
                var  difference1 = zip(cont , firstName[1]).filter{ $0 != $1 }
                dif1 = Float(difference1.count)
                error = (dif1 / count) * 100
                if (error < threshold) {
                    filterdItemsArray.append(i)
                }}else{
                var difference1 = zip(cont , firstName[0]).filter{ $0 != $1 }
                dif1 = Float(difference1.count)
                error = (dif1 / count) * 100
                if (error < threshold){
                    filterdItemsArray.append(i)
                }
            }
        }
        
       
        print(filterdItemsArray.count)
        guard let escapedBody = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return
        }
        smstext = escapedBody
        if filterdItemsArray.count == 1{
            //to make contact number without any white spaces therefore can use it into url
            filterdItemsArray[0].number = filterdItemsArray[0].number.replacingOccurrences(of: " ", with: "")
            //content of message also sent with url
            let url : NSURL = URL(string: "sms://\(filterdItemsArray[0].number)&body=\(escapedBody)")! as NSURL
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }else if filterdItemsArray.count > 1 {
            performSegue(withIdentifier: "smsSegue", sender: self)}
        else {
            let alert9 = UIAlertController(title: "لايوجد جهة اتصال بهذا الاسم", message: "", preferredStyle: .alert)
            let tryAgain = UIAlertAction(title: "حاول مرة اخري", style: .default){ (action ) in
                self.sendSMS()
            }
            let cancel = UIAlertAction(title: "الغي الامر", style: .default, handler: nil)
            alert9.addAction(tryAgain)
            alert9.addAction(cancel)
            present(alert9, animated: true,completion: nil)
        }
    }
    func alertTextField2(titl : String)  {
        var str : String = " "
        var TextField = UITextField()
        let alert7 = UIAlertController(title: titl, message: "", preferredStyle: .alert)
        let addTitle = UIAlertAction(title: "search", style: .default) { (action) in
            str = TextField.text!
            self.wikitext = str
            self.performSegue(withIdentifier: "wikiSegue", sender: self)
        }
        let cancel = UIAlertAction(title: "cancel", style: .default)
        alert7.addTextField { (alertTextField) in
            alertTextField.placeholder = "search for name"
            TextField = alertTextField
        }
        alert7.addAction(addTitle)
        alert7.addAction(cancel)
        present(alert7, animated: true,completion: nil)
        
    }
    func alertTextField3(titl : String){
        var str : String = " "
        var TextField = UITextField()
        let alert7 = UIAlertController(title: titl, message: "", preferredStyle: .alert)
        let addTitle = UIAlertAction(title: "search", style: .default) { (action) in
            str = TextField.text!
            self.googleSearch(searchSent: str)
        }
        let cancel = UIAlertAction(title: "cancel", style: .default)
        alert7.addTextField { (alertTextField) in
            alertTextField.placeholder = "search for name"
            TextField = alertTextField
        }
        alert7.addAction(addTitle)
        alert7.addAction(cancel)
        present(alert7, animated: true,completion: nil)
    }
    //make same function but user sends the name and content manually
    
    func sendSMS(){
        var contName : String = ""
        var TextField = UITextField()
        let alert = UIAlertController(title: "search for contact", message: "", preferredStyle: .alert)
        let addTitle = UIAlertAction(title: "search", style: .default) { (action) in
            contName = TextField.text!
            for i in self.fetchcontacts() {
                self.names.append(i.fullname)
            }
            var firstName = [String]()
            //get all contacts stored on iphone and search for the same name
            var count: Float = Float(contName.count)
            var dif1:Float = 0.0
            var error:Float = 0.0
            let threshold: Float = 30.0
            for i in self.fetchcontacts() {
                firstName = i.fullname.components(separatedBy: " ")
                if (firstName[0] == ""){
                    var  difference1 = zip(contName , firstName[1]).filter{ $0 != $1 }
                    dif1 = Float(difference1.count)
                    error = (dif1 / count) * 100
                    if (error < threshold) {
                        self.filterdItemsArray.append(i)
                    }}else{
                    var difference1 = zip(contName , firstName[0]).filter{ $0 != $1 }
                    dif1 = Float(difference1.count)
                    error = (dif1 / count) * 100
                    if (error < threshold){
                        self.filterdItemsArray.append(i)
                    }
                }
            }
            
            print(self.filterdItemsArray.count)
            if self.filterdItemsArray.count == 1{
                self.filterdItemsArray[0].number = self.filterdItemsArray[0].number.replacingOccurrences(of: " ", with: "")
               let url : NSURL = URL(string: "sms://\(self.filterdItemsArray[0].number)")! as NSURL
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            
            }else if self.filterdItemsArray.count > 1 {
                self.performSegue(withIdentifier: "smsSegue", sender: self)}
            else {
                self.createcontactAlert(title: "not found ", message: "no matched name of contact found")
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "search for name"
            TextField = alertTextField
        }
        alert.addAction(addTitle)
        
        present(alert, animated: true,completion: nil)
    }
    //***************************************************    AddReminder       ****************************************************************
    func addReminder (title : String){
        //first it shows data picker to select date of reminder
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        let alert = UIAlertController(title: "Add date", message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(datePicker)
        let DateTime = datePicker.date
        let ok = UIAlertAction(title: "ok", style: .default) { (action) in
            DispatchQueue.main.async{
                self.eventStore.requestAccess(to: EKEntityType.reminder) { (granted, error) in
                    if (granted) && (error == nil) {
                        let reminder:EKReminder = EKReminder(eventStore: self.eventStore)
                        //store input of function to title of reminder
                        reminder.title = title
                        reminder.priority = 2
                        reminder.notes = "...this is a note"
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
                        //set alarm to reminder
                        let alarm = EKAlarm(absoluteDate: DateTime)
                        reminder.addAlarm(alarm)
                        //store reminder to reminder in iphone
                        reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
                        do {
                            try self.eventStore.save(reminder, commit: true)
                            self.createcontactAlert(title: "the reminder with name \(reminder.title ?? "") has been saved", message: "")
                        } catch {
                            let alert = UIAlertController(title: "Reminder could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(OKAction)
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }}
        alert.addAction(ok)
        let cancel = UIAlertAction(title: "cancel", style: .default, handler: nil)
        alert.addAction(cancel)
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.1, constant: 350)
        alert.view.addConstraint(height)
        self.present(alert, animated: true, completion: nil)
        
    }
    //*************************************************   load Reminders     **************************************************************/
    func loadReminderfunc(){
        prepareToLoadReminders()
        performSegue(withIdentifier: "ReminderSegue", sender: self)
    }
    func prepareToLoadReminders(){
        print("yes")
        calendars = eventStore.calendars(for: EKEntityType.reminder)
        let predict = eventStore.predicateForReminders(in: calendars)
        eventStore.fetchReminders(matching: predict) { (reminders) in
            self .remindstoto = reminders!
        }}
    //*************************************************    Add Event     *****************************************************************
    func addEventfunc(title : String){
        //first show start date by date picker then show a end date of event
        let datePicker1 = UIDatePicker()
        let datePicker2 = UIDatePicker()
        let evet : EKEvent = EKEvent(eventStore: self.eventStore)
        //let datePicker2 = UIDatePicker()
        datePicker1.datePickerMode = .dateAndTime
        datePicker2.datePickerMode = .dateAndTime
        
        let alert = UIAlertController(title: "Add startDate", message: nil, preferredStyle: .actionSheet)
        let alert2 = UIAlertController(title: "Add endDate", message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(datePicker1)
        
        
        
        let Next = UIAlertAction(title: "Next", style: .default) { (action) in
            let DateTime1 = datePicker1.date
            DispatchQueue.main.async{
                self.eventStore.requestAccess(to: .event) { (granted, error) in
                    if (granted) && (error == nil ){
                        //input of function is title of user
                        evet.title = title
                        evet.startDate = DateTime1
                        alert2.view.addSubview(datePicker2)
                        let height: NSLayoutConstraint = NSLayoutConstraint(item: alert2.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.1, constant: 350)
                        alert2.view.addConstraint(height)
                        let ok = UIAlertAction(title: "ok", style: .default){ (action) in
                            let DateTime2 = datePicker2.date
                            DispatchQueue.main.async{
                                evet.endDate = DateTime2
                                evet.addAlarm(.init(relativeOffset: -5*60))
                                evet.notes = "This is note"
                                //store event in calender
                                evet.calendar = self.eventStore.defaultCalendarForNewEvents
                                do{
                                    try self.eventStore.save(evet, span: .thisEvent)
                                }catch let error as NSError{
                                    let alert3 = UIAlertController(title: "Event could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
                                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                    alert3.addAction(OKAction)
                                    
                                    self.present(alert3, animated: true, completion: nil)
                                }
                            }
                            let alert3 = UIAlertController(title: "Event has been saved", message: "", preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert3.addAction(OKAction)
                            
                            self.present(alert3, animated: true, completion: nil)
                        }
                        alert2.addAction(ok)
                        
                        let cancel = UIAlertAction(title: "cancel", style: .default){
                            (action) in
                            let alert3 = UIAlertController(title: "Event could not save", message: "", preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert3.addAction(OKAction)
                            
                            self.present(alert3, animated: true, completion: nil)
                        }
                        alert2.addAction(cancel)
                        self.present(alert2, animated: true, completion: nil)
                        
                    }
                }
            }
        }
        alert.addAction(Next)
        let cancel = UIAlertAction(title: "cancel", style: .default){
            (action) in
            let alert3 = UIAlertController(title: "Event could not save", message: "", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert3.addAction(OKAction)
            
            self.present(alert3, animated: true, completion: nil)
        }
        alert.addAction(cancel)
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.1, constant: 350)
        alert.view.addConstraint(height)
        self.present(alert, animated: true, completion: nil)
    }
    //***********************************************************  Load or remove event     *********************************************************
    func LoadRemoveEvent(){
        //you can add or remove event from the same function
        calendars = eventStore.calendars(for: EKEntityType.event)
        let datePicker1 = UIDatePicker()
        let datePicker2 = UIDatePicker()
        datePicker1.datePickerMode = .dateAndTime
        datePicker2.datePickerMode = .dateAndTime
        let alert = UIAlertController(title: "Add startDate", message: nil, preferredStyle: .actionSheet)
        let alert2 = UIAlertController(title: "Add endDate", message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(datePicker1)
        
        
        let Next = UIAlertAction(title: "Next", style: .default) { (action) in
            let DateTime1 = datePicker1.date
            DispatchQueue.main.async{
                let  startDate = DateTime1
                alert2.view.addSubview(datePicker2)
                let height: NSLayoutConstraint = NSLayoutConstraint(item: alert2.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.1, constant: 350)
                alert2.view.addConstraint(height)
                let ok = UIAlertAction(title: "ok", style: .default){ (action) in
                    let DateTime2 = datePicker2.date
                    DispatchQueue.main.async{
                        let   endDate = DateTime2
                        print(endDate)
                        //by start date and end date can fetch all events in this period to delete it or load it into table view
                        let prediacte = self.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: self.calendars!)
                        
                        self.events = self.eventStore.events(matching: prediacte)
                        print(self.events.count)
                        if self.loadORremove == true {
                            for i in self.events {
                                self.deleteevent(event: i)
                                print("+/")
                            }}
                        
                        if self.loadORremove == true{
                            let alert3 = UIAlertController(title: "all Event in this period has been deleted", message: "", preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert3.addAction(OKAction)
                            
                            self.present(alert3, animated: true, completion: nil)}
                        if self.loadORremove == false{
                            if self.events.count > 0 {
                                self.performSegue(withIdentifier: "eventSegue", sender: self)}
                            else {
                                let alert3 = UIAlertController(title: "No Event in this period ", message: "", preferredStyle: .alert)
                                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert3.addAction(OKAction)
                                
                                self.present(alert3, animated: true, completion: nil)
                            }
                        }
                    }}
                alert2.addAction(ok)
                let cancel = UIAlertAction(title: "cancel", style: .default){
                    (action) in
                    if self.loadORremove == true{
                        let alert3 = UIAlertController(title: "Event could not remove", message: "", preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert3.addAction(OKAction)
                        
                        self.present(alert3, animated: true, completion: nil)
                    }}
                alert2.addAction(cancel)
                self.present(alert2, animated: true, completion: nil)
                
            }
        }
        alert.addAction(Next)
        let cancel = UIAlertAction(title: "cancel", style: .default){
            (action) in
            if self.loadORremove == true{
                let alert3 = UIAlertController(title: "Event could not remove", message: "", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert3.addAction(OKAction)
                
                self.present(alert3, animated: true, completion: nil)}
        }
        alert.addAction(cancel)
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.1, constant: 350)
        alert.view.addConstraint(height)
        self.present(alert, animated: true, completion: nil)
        
    }
    //function is used to delete eventy
    func deleteevent(event : EKEvent){
        do{
            try eventStore.remove(event, span: EKSpan.thisEvent, commit: true)
            print("yes")
        }catch{
            print("Error while deleting event: \(error.localizedDescription)")
        }
    }
    //*********************************************************    add Note     *************************************************************
    func createNote (content : String){
        
        //the input of function in content of note and the user add title by alert contain text field
        var TextField = UITextField()
        let newNote = Note(context: context)
        let alert = UIAlertController(title: "اضف مفكرة جديدة", message: "", preferredStyle: .alert)
        let addTitle = UIAlertAction(title: "اضف عنوان", style: .default) { (action) in
            newNote.content = content
            let textTitle = TextField.text!
            //if user don't want to add title ,the application save it with title "untitled Note"
            if textTitle == "" {
                newNote.title = "لم يتم تحديد اسم للمفكرة"
            }else {
                newNote.title = textTitle
            }
            //store note in core data
            self.saveItem()
            
            let alert3 = UIAlertController(title: "تم حفظ المفكرة", message: "", preferredStyle: .alert)
            let ok = UIAlertAction(title: "تم", style: .default , handler: nil)
            alert3.addAction(ok)
            self.present(alert3 , animated: true , completion: nil)
        }
        let cancel = UIAlertAction(title: "الغاء", style: .default) { (action) in
            let alert5 = UIAlertController(title: "لم يتم حفظ المفكرة ", message: "", preferredStyle: .alert)
            let ok = UIAlertAction(title: "تم", style: .default , handler: nil)
            alert5.addAction(ok)
            self.present(alert5 , animated: true , completion: nil)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "create new note"
            TextField = alertTextField
        }
        alert.addAction(addTitle)
        
        self.present(alert , animated: true, completion: nil)}
    
    
    //*********************  func related to coreData ********************************
    //store any new item or when change any item .this function is used to save it
    func saveItem(){
        do{
            try context.save()
            
        } catch {
            print("error saving context \(error)")
        }
        
        
    }
    
    
    
    
    //******************************** prepare for all segues **********************************
    //this function is used when go to any segue it passes data between the two views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "callSegue"{
            let destination = segue.destination as! oneTableViewController
            print("yes")
            destination.contArray = filterdItemsArray
            destination.Seguesty = segue.identifier!}
        else if segue.identifier == "smsSegue" {
            let destination = segue.destination as! oneTableViewController
            destination.contArray = filterdItemsArray
            destination.Seguesty = segue.identifier!
            destination.smstext2 = smstext
        } else if segue.identifier == "ReminderSegue" {
            let destination = segue.destination as! oneTableViewController
            destination.Seguesty = segue.identifier!
            destination.remindstoto = remindstoto
        } else if segue.identifier == "eventSegue" {
            let destination = segue.destination as! oneTableViewController
            print("hopaaa")
            destination.Seguesty = segue.identifier!
            destination.eventTa = events
        }else if segue.identifier == "musicSegue" {
            let destination = segue.destination as! oneTableViewController
            destination.Seguesty = segue.identifier!
            
        }else if segue.identifier == "noteSegue"{
            let destination = segue.destination as! oneTableViewController
            destination.Seguesty = segue.identifier!
            // destination.noteTa = notes
        }else if segue.identifier == "wikiSegue"{
            let destination = segue.destination as! oneTableViewController
            destination.Seguesty = segue.identifier!
            destination.wikiText2 = wikitext
        }else if segue.identifier == "note2Segue" {
            let destination2 = segue.destination as! detailViewController
            destination2.Seguesty2 = segue.identifier!
            
        }
       
    }


    
   /****************** make a round corner for the buttons and labels in the view *************/
    func applyRoundCorner(_ object: AnyObject){
        
        object.layer.cornerRadius = object.frame.height / 2
        object.layer.masksToBounds = true
    }
    
    /************************* make animation for the button ******************************/
    func createPulse (){

        for _ in 0...2 {
            let circularPath = UIBezierPath(arcCenter: .zero, radius: UIScreen.main.bounds.size.width/2.0, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            let pulseLayer = CAShapeLayer()
            pulseLayer.path = circularPath.cgPath
            pulseLayer.lineWidth = 2.0
            pulseLayer.fillColor = UIColor.appColor2.cgColor
            pulseLayer.strokeColor = UIColor.black.cgColor
            pulseLayer.lineCap = CAShapeLayerLineCap.round
            pulseLayer.position = CGPoint(x: micBtn.frame.size.width/2.0, y: micBtn.frame.size.width/2.0)
            micBtn.layer.addSublayer(pulseLayer)
            pulseLayers.append(pulseLayer)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.animatePulse(index: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.animatePulse(index: 1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.animatePulse(index: 2)
                }
            }
        }
    }
  
    
    func animatePulse(index: Int) {
        pulseLayers[index].strokeColor = UIColor.appColor.cgColor
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 2.0
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue = 0.9
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        scaleAnimation.repeatCount = .greatestFiniteMagnitude
        pulseLayers[index].add(scaleAnimation, forKey: "scale")
        
        let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        opacityAnimation.duration = 2.0
        opacityAnimation.fromValue = 0.9
        opacityAnimation.toValue = 0.0
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        opacityAnimation.repeatCount = .greatestFiniteMagnitude
        pulseLayers[index].add(opacityAnimation, forKey: "opacity")
        
        
        
    }
    func unanimateBtn() {
        micBtn.backgroundColor = UIColor.appColor
    }
    
    
    /*********************************************** mapping input texts********************************************************************************************/
    
    /*********************************************** getting each string and spread it in an array then, check each word with the coming text , if the error is <= 20% it will do the action and if the error  > 20% the it checks about each letter in the word in the array, if the needed number of letters exceeds a certain value, it do the function else it go to another function ******************/
    
    
    func addReminder(){
        let x:String = myText.text!
        let y =   "اضف مذكرة "
        print (x)
        
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        var R3 = " "
        let T1 = z5[1]
        let T2 = z5[2]
        
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 3)
            
        {
            R1 = z[1]
            R2 = z[2]
           
           if (count >= 4 ){
            if (z[3] != z[0]){
            for i in 3 ... (count - 1){
                R3 = R3 + z[i] + " "
            }
            }else {R3 = "بدون عنوان"}}
            else {R3 = "بدون عنوان"}
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            
            
            
            let err:Float = err1 + err2
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {                var tot = 0

                for i in R2 {
                    if (i == "م"  || i == "ذ" || i == "ك"  ){
                        tot = tot + 1
                    }
                }
                if  (tot >= 3){
                myOutText.text = y
                //    loadReminder()
               addReminder(title: R3)
                }else{LoadReminder()}}
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                
                
                for i in R1 {
                    if  ( i == "ض"  || i == "ف" || i == "د"  ){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if (i == "م"  || i == "ذ" || i == "ك"  ){
                        tot = tot + 1
                    }
                }
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                if( tyt >= 2){
                    if (tot >= 3)
                    {
                        myOutText.text = y
                        //  loadReminder()
                        addReminder(title: R3)
                    }
                        
                        
                        
                    else{
                        LoadReminder()
                       // removeReminder()
                    }
                }
                else{
                     LoadReminder()
                   // removeReminder()
                }
            }
            
        }else{
             LoadReminder()
           // removeReminder()
        }
        
    }
    
    
    
    /*************************/
    
  /*  func removeReminder(){
        let x:String = myText.text!
        let y =  "احذف مذكرة "
        print (x)
        
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        
        let T1 = z5[1]
        let T2 = z5[2]
        
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count > 2)
            
        {
            R1 = z[1]
            R2 = z[2]
            
            
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            
            
            
            let err:Float = err1 + err2
            print ("error total = \(err)")
            
            
            if (err <= 15 )
            {
                myOutText.text = y
                //    loadReminder()
                
            }
            else if (err >= 20)
            {
                var tyt = 0
                var tot = 0
                
                
                for i in R1 {
                    if  ( i == "ح" || i == "ذ" || i == "ف"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if (i == "م"  || i == "ذ" || i == "ك"  ){
                        tot = tot + 1
                    }
                }
                
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                if (tyt <= T1.count && tyt >= 2){
                    if (tot <= T2.count && tot >= 3)
                    {
                        
                        myOutText.text = y
                        //  loadReminder()
                        
                    }
                        
                        
                        
                    else{
                        
                        LoadReminder()
                    }
                } else{
                    
                    LoadReminder()
                }
            }
        } else{
            
            LoadReminder()
        }
        
    }*/
    
    
    /*************************/
    
    func LoadReminder(){
        
        let x:String = myText.text!
        let y =   "تحميل مذكرات "
        print (x)
        
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        
        let T1 = z5[1]
        let T2 = z5[2]
        
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count > 2)
            
        {
            R1 = z[1]
            R2 = z[2]
            
            
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            
            
            
            let err:Float = err1 + err2
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {        var tot = 0
                
                for i in R2 {
                    if (i == "م"  || i == "ذ" || i == "ك"  ){
                        tot = tot + 1
                    }
                }
                if  (tot >= 3){
                    myOutText.text = y
                    //    loadReminder()
                    loadReminderfunc()
                }else{addNotes()}
                
            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                
                
                for i in R1 {
                    if  (i == "ت" ||  i == "ح"  || i == "ف" || i == "م" || i == "ي" || i == "ل" ){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if (i == "م"  || i == "ذ" || i == "ك"  ){
                        tot = tot + 1
                    }
                }
                
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                if (tyt <= T1.count && tyt >= 2){
                    if (tot <= T2.count && tot >= 3)
                    {
                        
                        myOutText.text = y
                        //  loadReminder()
                     loadReminderfunc()
                    }
                        
                        
                        
                    else{
                        
                       addNotes()
                    }
                }else{
                    
                    addNotes()
                }
            }
            
            
        }else{
            
            addNotes()
        }
        
        
        
    }
    
    
    /*************************/
    
    func addNotes(){
        let x:String = myText.text!
        let y =   "اضف مفكرة"
        
        print (x)
        
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        var R3 = " "

        let T1 = z5[1]
        let T2 = z5[2]
        
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 3)
            
        {
            R1 = z[1]
            R2 = z[2]
            if (count >= 4){
                if (z[3] != z[0]){
            for i in 3 ... (count - 1){
                R3 = R3 + z[i] + " "
                    }}}
            
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            
            
            
            let err:Float = err1 + err2
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                myOutText.text = y
                //    loadReminder()
                if  R3 == " "{
                    createcontactAlert(title: "لا يوجد محتوي للمفكرة", message: "")
                }else{
                    createNote(content: R3)}
            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                
                
                for i in R1 {
                    if ( i == "ض"  || i == "ف" || i == "د"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if ( i == "ف" ||  i == "م"  || i == "ك"   ){
                        tot = tot + 1
                    }
                }
                
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                if ( tyt >= 2){
                    if ( tot >= 3)
                    {
                        
                        myOutText.text = y
                        //  loadReminder()
                        if  R3 == " "{
                            createcontactAlert(title: "لا يوجد محتوي للمفكرة", message: "")
                        }else{
                            createNote(content: R3)}
                    }
                        
                        
                        
                    else{
                        
                        LoadNotes()
                    }
                }  else{
                    LoadNotes()
                }
            }
            
            
            
            
        }  else{
            LoadNotes()
        }
        
        
    }
    
    
    /*************************/
    
    func LoadNotes(){
        let x:String = myText.text!
        let y =   "تحميل المفكرات "
        
        
        print (x)
        
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
       // var R3 = " "

        let T1 = z5[1]
        let T2 = z5[2]
        
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 3)
            
        {
            R1 = z[1]
            R2 = z[2]
            
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            
            
            
            let err:Float = err1 + err2
            print ("error total = \(err)")
            
            
            if (err <= 20)
            {
                myOutText.text = y
                //    loadReminder()
                performSegue(withIdentifier: "noteSegue", sender: self)
            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                
                
                for i in R1 {
                    if (i == "ت" ||  i == "ح"  || i == "ف" || i == "م" || i == "ي" || i == "ل" ){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if ( i == "ف" ||  i == "م"  || i == "ك"   ){
                        tot = tot + 1
                    }
                }
                
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                if ( tyt >= 3){
                    if ( tot >= 3)
                    {
                        
                        myOutText.text = y
                        //  loadReminder()
                        performSegue(withIdentifier: "noteSegue", sender: self)
                    }
                        
                        
                        
                    else{
                        
                        addEvent()
                    }
                }else{
                    
                    addEvent()
                }
            }
            
            
            
            
            
            
            
            
            
        }else{
            
            addEvent()
        }
        
    }
    
    
    /*************************/
    
    
    func addEvent(){
        
        let x:String = myText.text!
        let y =   "اضف حدث"
        print (x)
        
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        var R3 = " "

        let T1 = z5[1]
        let T2 = z5[2]
        
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 3)
            
        {
            R1 = z[1]
            R2 = z[2]
            
            if (count >= 4){
                if  (z[3] != z[0]){
                    for i in 3 ... (count - 1){
                        R3 = R3 + z[i] + " "
                    }
                }else {R3 = "حدث بدون عنوان"}
            }else {R3 = "حدث بدون عنوان"}
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            
            
            
            let err:Float = err1 + err2
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                myOutText.text = y
                //    loadReminder()
                addEventfunc(title: R3)
            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                
                
                for i in R1 {
                    if (i == "ف"  || i == "ض" || i  == "د" ){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if ( i == "ح"  || i == "د" || i == "ث" || i == "س"  ){
                        tot = tot + 1
                    }
                }
                
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                if (tyt >= 2){
                    if ( tot >= 2)
                    {
                        
                        myOutText.text = y
                        //  loadReminder()
                         addEventfunc(title: R3)
                    }
                        
                        
                        
                    else{
                        
                        removeEvent()
                    }
                }  else{
                    
                    removeEvent()
                }
            }
            
            
        }  else{
            
            removeEvent()
        }
    }
    /*************************/
    func removeEvent(){
        
        let x:String = myText.text!
        let y = "احذف حدث"
        print (x)
        
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        
        let T1 = z5[1]
        let T2 = z5[2]
        
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 3)
            
        {
            R1 = z[1]
            R2 = z[2]
            
            
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            
            
            
            let err:Float = err1 + err2
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                var tyt = 0
              
                
                
                for i in R1 {
                    if ( i == "ذ" || i == "ح" || i ==  "ز"){
                        tyt = tyt + 1
                    }}
                if ( tyt >= 2){
                    myOutText.text = y
                    //    loadReminder()
                    loadORremove = true
                    LoadRemoveEvent()
                }
              
            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                
                
                for i in R1 {
                    if ( i == "ذ" || i == "ح" || i == "ز"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if ( i == "ح"  || i == "د" || i == "ث" || i == "س"){
                        tot = tot + 1
                    }
                }
                
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                if ( tyt >= 2){
                    if ( tot >= 2)
                    {
                        
                        myOutText.text = y
                        //  loadReminder()
                      loadORremove = true
                        LoadRemoveEvent()
                    }
                        
                        
                        
                    else{
                        
                        LoadEvent()
                    }
                }  else{
                    
                    LoadEvent()
                }
            }
            
            
        } else{
            
            LoadEvent()
        }
    }
    
    
    
    
    
    
    
    func LoadEvent(){
        
        let x:String = myText.text!
        let y = "تحميل الاحداث"
        
        print (x)
        
        
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        
        let T1 = z5[1]
        let T2 = z5[2]
        
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 3)
            
        {
            R1 = z[1]
            R2 = z[2]
            
            
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            
            
            
            let err:Float = err1 + err2
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                myOutText.text = y
                //    loadReminder()
               loadORremove = false
                LoadRemoveEvent()
            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                
                
                for i in R1 {
                    if (i == "ف"  || i == "ت"  || i == "ح"  || i == "م" || i == "ل" || i == "ي"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if ( i == "ح"  || i == "د" || i == "ث" || i == "س"){
                        tot = tot + 1
                    }
                }
                
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                if (tyt >= 2){
                    if ( tot >= 3)
                    {
                        
                        myOutText.text = y
                        //  loadReminder()
                        loadORremove = false
                        LoadRemoveEvent()
                    }
                        
                        
                        
                    else{
                        
                        takePhoto()
                    }
                }  else{
                    
                    takePhoto()
                }
            }
            
        }  else{
            
            takePhoto()
        }
        
    }
    
    
    
    func takePhoto(){
        
        let x:String = myText.text!
        let y = "التقط صورة"
        
        
        print (x)
        
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        
        let T1 = z5[1]
        let T2 = z5[2]
        
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 3)
            
        {
            R1 = z[1]
            R2 = z[2]
            
            
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            
            
            
            let err:Float = err1 + err2
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                myOutText.text = y
                //    loadReminder()
              takePhotosfunc()

            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                
                
                for i in R1 {
                    if (i == "ت"   || i == "ق" || i == "ل" || i == "ط" || i == "ك"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if (i == "و" ||  i == "ص" || i == "ر"  || i == "ة" || i == "س" || i == "ث"){
                        tot = tot + 1
                    }
                }
                
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                if ( tyt >= 3){
                    if ( tot >= 3)
                    {
                        
                        myOutText.text = y
                        takePhotosfunc()
                        //  loadReminder()
                        
                    }
                        
                        
                        
                    else{
                        
                        openGallery()
                    }
                } else{
                    
                    openGallery()
                }
            }
            
            
        } else{
            
            openGallery()
        }
        
    }
    func openGallery(){
        
        let x:String = myText.text!
        let y =  "افتح معرض الصور"
        
        
        print (x)
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
            
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        var R3 = " "
        
        let T1 = z5[1]
        let T2 = z5[2]
        let T3 = z5[3]
        
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 4)
            
        {
            R1 = z[1]
            R2 = z[2]
            R3 = z[3]
            
            
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            let difference3 = zip(R3 , T3).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif3:Float =  Float( difference3.count)
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            let err3:Float = Float( ( ( dif3 ) / (ln)  * 100 ) )
            print ("error 3 \(err2)")
            
            
            let err:Float = err1 + err2 + err3
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                myOutText.text = y
                //    loadReminder()
                openPhotosfunc()
            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                var tut = 0
                
                for i in R1 {
                    if (i == "ت"  || i == "ح" || i == "ف" ){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if ( i == "ع" || i == "م" || i == "ر" || i == "ض" || i == "د"){
                        tot = tot + 1
                    }
                }
                for i in R3 {
                    if (i == "و" ||  i == "ص" || i == "ر" || i == "ث" || i == "س" ){
                        tut = tut + 1
                    }
                }
                
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                print ( "discoverd letters 3 is \(tut)")
                if ( tyt >= 2){
                    if (tot >= 3){
                        if ( tut >= 2){
                            
                            myOutText.text = y
                            //  loadReminder()
                           openPhotosfunc()

                        }
                        
                        
                    }
                    else{
                        
                        wiki()
                    }
                }      else{
                    
                    wiki()
                }
            }
            
        }  else{
            
            wiki()
        }
        
    }
    
    
    
    
    
    
    
    
    func wiki(){
        
        
        let y =  "ابحث في ويكيبيديا عن"
        let x:String = myText.text!
        print (x)
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        var R3 = " "
        var R4 = " "
        var R5 = " "
        var R6 = " "
        let T1 = z5[1]
        let T2 = z5[2]
        let T3 = z5[3]
        let T4 = z5[4]
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count > 5)
            
        {
            R1 = z[1]
            R2 = z[2]
            R3 = z[3]
            R4 = z[4]
        
            for i in 5 ... (count - 1){
       
                R5 = R5 + z[i] + " "
                }
            
            for i in 2 ... 4{
                R6 = R6 + z[i]
            }
            print  (R5)
            print (R6)
            
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            let difference3 = zip(R3 , T3).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif3:Float =  Float( difference3.count)
            
            let difference4 = zip(R4 , T4).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif4:Float =  Float( difference4.count)
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            let err3:Float = Float( ( ( dif3 ) / (ln)  * 100 ) )
            print ("error 3 \(err2)")
            
            let err4:Float = Float( ( ( dif4 ) / (ln)  * 100 ) )
            print ("error 4 \(err2)")
            let err:Float = err1 + err2 + err3 + err4
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {                var tut = 0

                for i in R6 {
                    if (  i == "ك" || i == "ب"  || i == "ي"  || i == "د"){
                        tut = tut + 1
                    }
                }
                if (tut >= 3){
                myOutText.text = y
                //    loadReminder()
                wikitext = R5
                
                performSegue(withIdentifier: "wikiSegue", sender: self)
                    createcontactAlert(title: "\(R5)", message: "")
                }else {goog ()}}
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                var tut = 0
                var tat = 0
                var tpt = 0
                for i in R1 {
                    if (i == "ب"  || i == "ح"  || i == "ث" || i == "س" || i == "ص"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if ( i == "ف"  || i == "ي"){
                        tot = tot + 1
                    }
                }
                for i in R3 {
                    if ( i == "ك" || i == "ب"  || i == "ي"  || i == "د"){
                        tut = tut + 1
                    }
                }
                
                
                for i in R4 {
                    if ( i == "ع" || i == "ن" ){
                        tat = tat + 1
                    }
                }
                
                for i in R6 {
                    if (i == "ي" || i == "ك" || i == "ب"   || i == "د"){
                        tpt = tpt + 1
                    }
                }
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                print ( "discoverd letters 3 is \(tut)")
                print ( "discoverd letters 4 is \(tat)")
                if (tyt >= 2){
                    if ( tot >= 1){
                        if ( tut >= 3){
                            if ( tat >= 1){
                                myOutText.text = y
                                //  loadReminder()
                                
                                wikitext = R5
                 
                                performSegue(withIdentifier: "wikiSegue", sender: self)
                            createcontactAlert(title: "\(R5)", message: "")
                            }else if (tpt >= 3){
                                
                                myOutText.text = y
                                //  loadReminder()
                                
                               // wikitext = R5
                               // performSegue(withIdentifier: "wikiSegue", sender: self)
                                alertTextField2(titl: "من فضلك ادخل كلمة البحث مرة اخري")
                                
                              //  createcontactAlert(title: "لم استوعب السيرش", message: "")
                            }else{
                                
                                goog()
                            }
                        }else if (tpt >= 3){
                            
                            myOutText.text = y
                            //  loadReminder()
                           // wikitext = R5
                           // performSegue(withIdentifier: "wikiSegue", sender: self)
                            alertTextField2(titl: "من فضلك ادخل كلمة البحث مرة اخري")
                            //createcontactAlert(title: "لم استوعب السيرش", message: "")

                            //createcontactAlert(title: "\(R5)", message: "")
                        } else{
                            
                            goog()
                        }
                        
                        
                    }else if (tpt >= 3){
                        
                        myOutText.text = y
                        //  loadReminder()
                        //wikitext = R5
                        //performSegue(withIdentifier: "wikiSegue", sender: self)
                        alertTextField2(titl: "من فضلك ادخل كلمة البحث مرة اخري")
                        //createcontactAlert(title: "لم استوعب السيرش", message: "")

                       // createcontactAlert(title: "\(R5)", message: "")
                    }
                    else{
                        
                        goog()
                    }
                } else if (tpt >= 3){
                 
                    myOutText.text = y
                    //  loadReminder()
                    //wikitext = R5
                    //performSegue(withIdentifier: "wikiSegue", sender: self)
                    alertTextField2(titl: "من فضلك ادخل كلمة البحث مرة اخري")
                    //createcontactAlert(title: "لم استوعب السيرش", message: "")

                    //createcontactAlert(title: "\(R5)", message: "")
                }else{
                    
                    goog()
                }
            }
            
            
            
            
        }else{
            
            goog()
        }
    }
    
    func goog(){
        let x:String = myText.text!
        let y = "ابحث في جوجل عن"
        print (x)
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        var R3 = " "
        var R4 = " "
        var R5 = " "
        var R6 = " "
        
        let T1 = z5[1]
        let T2 = z5[2]
        let T3 = z5[3]
        let T4 = z5[4]
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count > 5)
            
        {
            R1 = z[1]
            R2 = z[2]
            R3 = z[3]
            R4 = z[4]
            for i in 5 ... (count - 1){
                R5 = R5 + z[i] + " "
            }
            for i in 3 ... 4 {
                R6 = R6 + z[i]
            }
            print  (R5)
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            let difference3 = zip(R3 , T3).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif3:Float =  Float( difference3.count)
            
            let difference4 = zip(R4 , T4).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif4:Float =  Float( difference4.count)
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            let err3:Float = Float( ( ( dif3 ) / (ln)  * 100 ) )
            print ("error 3 \(err2)")
            
            let err4:Float = Float( ( ( dif4 ) / (ln)  * 100 ) )
            print ("error 4 \(err2)")
            let err:Float = err1 + err2 + err3 + err4
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                myOutText.text = y
                //    loadReminder()
                googleSearch(searchSent: R5)
            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                var tut = 0
                var tat = 0
                var tpt = 0
                for i in R1 {
                    if (i == "ب"  || i == "ح" || i == "ث" || i == "ص" || i == "س"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if ( i == "ف"  || i == "ي"){
                        tot = tot + 1
                    }
                }
                for i in R3 {
                    if (i == "و" ||  i == "ج" || i == "ل" || i == "غ"){
                        tut = tut + 1
                    }
                }
                
                
                for i in R4 {
                    if ( i == "ع" || i == "ن" ){
                        tat = tat + 1
                    }
                }
                
                for i in R6 {
                    if (i == "و" ||  i == "ج" || i == "ل" || i == "غ"){
                        tpt = tpt + 1
                    }
                }
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                print ( "discoverd letters 3 is \(tut)")
                print ( "discoverd letters 4 is \(tat)")
                if ( tyt >= 2){
                    if ( tot >= 1){
                        if ( tut >= 3){
                            if (tat >= 1){
                                myOutText.text = y
                                //  loadReminder()
                                 googleSearch(searchSent: R5)
                            } else if (tpt >= 4){
                                
                                myOutText.text = y
                            // alert Google
                                alertTextField3(titl: "من فضلك ادخل كلمة البحث مرة اخري")
                            }else{
                                
                                smsMessages()
                            }
                        } else if (tpt >= 4){
                            
                            myOutText.text = y
                            //alert google
                            alertTextField3(titl: "من فضلك ادخل كلمة البحث مرة اخري")
                        }else{
                            
                            smsMessages()
                        }
                        
                        
                    }
                    else if (tpt >= 4){
                        
                        myOutText.text = y
                        // alert google
                        alertTextField3(titl: "من فضلك ادخل كلمة البحث مرة اخري")
                    }else{
                        
                        smsMessages()
                    }
                }
                else if (tpt >= 4){
                    
                    myOutText.text = y
                    // alert google
                    alertTextField3(titl: "من فضلك ادخل كلمة البحث مرة اخري")
                }else{
                    
                    smsMessages()
                }
            }
            
            
            
            
            
            
        }  else{
            
            smsMessages()
            
        }
        
        
    }
    
    
    func smsMessages(){
        
        let x:String = myText.text!
        let y =  "ارسال رسالة الي "
        print (x)
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        var R3 = " "
        var R4 = " "
        var R5 = " "
        let T1 = z5[1]
        let T2 = z5[2]
        let T3 = z5[3]
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count > 5)
            
        {
            R1 = z[1]
            R2 = z[2]
            R3 = z[3]
            R4 = z[4]
            for i in 5 ... (count - 1){
                R5 = R5 + z[i] + " "
            }
            print  (R5)
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            let difference3 = zip(R3 , T3).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif3:Float =  Float( difference3.count)
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            let err3:Float = Float( ( ( dif3 ) / (ln)  * 100 ) )
            print ("error 3 \(err2)")
            
            let err:Float = err1 + err2 + err3
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                myOutText.text = y
                //    loadReminder()
               sendSMS(cont: R4, body: R5)
            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                var tut = 0
                var tat = 0
                for i in R1 {
                    if (i == "س"  || i == "ر"  || i == "ل" || i == "ث" || i == "ص"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if (i == "س"  || i == "ر"  || i == "ل" || i == "ة" || i == "ه" || i == "ث" || i == "ص"){
                        tot = tot + 1
                    }
                }
                for i in R3 {
                    if (i == "ي" ||  i == "ا" || i == "ل"){
                        tut = tut + 1
                    }
                }
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                print ( "discoverd letters 3 is \(tut)")
                print ( "discoverd letters 4 is \(tat)")
                if ( tyt >= 3){
                    if ( tot >= 3){
                        if ( tut >= 2){
                            
                            myOutText.text = y
                            //  loadReminder()
                           sendSMS(cont: R4, body: R5)
                        }   else{
                            
                            call()
                        }
                        
                        
                    }
                        
                    else{
                        
                        call()
                    }
                } else{
                    
                    call()
                }
            }
            
            
        }else{
            
            call()
        }
        
        
        
    }
    
    func call(){
        
        let x:String = myText.text!
        let y =  "اتصل بجهة"
        print (x)
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        var R3 = " "
        
        
        let T1 = z5[1]
        let T2 = z5[2]
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 4)
            
        {
            R1 = z[1]
            R2 = z[2]
            R3 = z[3]
           /* if (z[3] != z[0])*/
           /* for i in 3 ... (count - 1){
                R3 = R3 + z[i]
                }*/
         /*   else {
                createcontactAlert(title: "لم تقم بادخال جهة الاتصال", message: "ادخل مرة اخري")
                
            }*/
            
            print  (R3)
            
            
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            
            let err:Float = err1 + err2
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                myOutText.text = y
                //    loadReminder()
                callContact(cont: R3)
                print ("the contact is \(R3) ")

            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                
                for i in R1 {
                    if (i == "ص"  || i == "ت"  || i == "ل"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if (i == "ب" || i == "ة"  || i == "ه"  || i == "ج" || i == "ت" ){
                        tot = tot + 1
                    }
                }
                
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                
                
                
                
                if ( tyt >= 2){
                    if ( tot >= 3){
                        
                        
                        myOutText.text = y
                        //  loadReminder()
                    callContact(cont: R3)
                        print ("the contact is \(R3) ")
                        
                        
                    }
                    else{
                        
                        weather()
                    }
                }else{
                    
                    weather()
                }
            }
            
            
        }else{
            
            weather()
        }
        
        
        
    }
    
    
    
    
    
    func weather(){
        
        let x:String = myText.text!
        let y =  "حالة الطقس"
        print (x)
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        
        
        let T1 = z5[1]
        let T2 = z5[2]
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 3)
            
        {
            R1 = z[1]
            R2 = z[2]
            
            
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            
            let err:Float = err1 + err2
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                myOutText.text = y
                //    loadReminder()
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                
                for i in R1 {
                    if (i == "ة"  || i == "ح"  || i == "ل" || i == "ت"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if ( i == "ط" || i == "ق"  || i == "س" ||  i == "ل" || i == "ت" || i == "ص" ){
                        tot = tot + 1
                    }
                }
                
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                
                
                
                
                if (tyt >= 2){
                    if (tot >= 3){
                        
                        
                        myOutText.text = y
                       locationManager.requestWhenInUseAuthorization()
                        locationManager.startUpdatingLocation()
                        //  loadReminder()
                        
                        
                        
                        
                    }
                    else{
                        
                        openDoor()
                    }
                } else{
                    
                    openDoor()
                }
            }
            
            
        } else{
            
            openDoor()
        }
        
        
        
    }
    
    
    
    
    func openDoor(){
        
        let x:String = myText.text!
        let y =  "افتح الباب"
        print (x)
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        
        
        let T1 = z5[1]
        let T2 = z5[2]
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 3)
            
        {
            R1 = z[1]
            R2 = z[2]
            
            
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            
            let err:Float = err1 + err2
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                myOutText.text = "تم فتح الباب"
                openClose(state: "3")

            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                
                for i in R1 {
                    if (i == "ح"  || i == "ف"  || i == "ت"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if (  i == "ب"  || i == "ل"){
                        tot = tot + 1
                    }
                }
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                
                
                
                
                if ( tyt >= 2){
                    if (tot >= 2){
                        
                        
                        myOutText.text = "تم فتح الباب"
                        openClose(state: "3")

                        
                        
                        
                    }
                    else{
                        
                        closeDoor()
                    }
                }  else{
                    
                    closeDoor()
                }
            }
            
            
        }else{
            
            closeDoor()
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    func closeDoor(){
        
        let x:String = myText.text!
        let y =    "اغلق الباب"
        print (x)
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        
        
        let T1 = z5[1]
        let T2 = z5[2]
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 3)
            
        {
            R1 = z[1]
            R2 = z[2]
            
            
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            
            let err:Float = err1 + err2
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                myOutText.text = "تم غلق الباب"
                openClose(state: "4")

            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                
                for i in R1 {
                    if (i == "ق"  || i == "غ" || i == "ق" || i == "ك"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if (  i == "ب" || i == "ل" ){
                        tot = tot + 1
                    }
                }
                
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                
                
                
                
                if ( tyt >= 2){
                    if ( tot >= 3){
        
                        myOutText.text = "تم غلق الباب"
                        openClose(state: "4")
                    }
                    else{
                        
                         roomsLightOn()
                    }
                }  else{
                    
                     roomsLightOn()
                }
            }
            
            
        } else{
            
             roomsLightOn()
        }
        
        
        
    }
    
    
    
    
    /*
    
    func openCamera(){
        
        let x:String = myText.text!
        let y =   "افتح الكاميرا"
        print (x)
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        
        
        let T1 = z5[1]
        let T2 = z5[2]
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 3)
            
        {
            R1 = z[1]
            R2 = z[2]
            
            
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            
            let err:Float = err1 + err2
            print ("error total = \(err)")
            
            
            if (err <= 15 )
            {
                myOutText.text = y
                //    loadReminder()
                
            }
            else if (err >= 20)
            {
                var tyt = 0
                var tot = 0
                
                for i in R1 {
                    if (i == "ح"  || i == "ف" || i == "ت"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if (  i == "ك" || i == "م" || i == "ي" || i == "ر" ){
                        tot = tot + 1
                    }
                }
                
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                
                
                
                
                if (tyt <= T1.count && tyt >= 3){
                    if (tot <= T2.count && tot >= 3){
                        
                        
                        myOutText.text = y
                        //  loadReminder()
                        
                        
                        
                        
                    }
                    else{
                        
                        closeCamera()
                    }
                } else{
                    
                    closeCamera()
                }
            }
            
            
        }else{
            
            closeCamera()
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    func closeCamera(){
        
        let x:String = myText.text!
        let y =    "اغلق الكاميرا"
        print (x)
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        
        
        let T1 = z5[1]
        let T2 = z5[2]
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 3)
            
        {
            R1 = z[1]
            R2 = z[2]
            
            
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            
            let err:Float = err1 + err2
            print ("error total = \(err)")
            
            
            if (err <= 15 )
            {
                myOutText.text = y
                //    loadReminder()
                
            }
            else if (err >= 20)
            {
                var tyt = 0
                var tot = 0
                
                for i in R1 {
                    if (i == "ق"  || i == "غ"  || i == "ق"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if (   i == "ك" || i == "م" || i == "ي" || i == "ر" ){
                        tot = tot + 1
                    }
                }
                
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                
                
                
                
                if (tyt <= T1.count && tyt >= 3){
                    if (tot <= T2.count && tot >= 3){
                        
                        
                        myOutText.text = y
                        //  loadReminder()
                        
                        
                        
                        
                    }
                    else{
                        
                        roomsLightOn()
                    }
                } else{
                    
                    roomsLightOn()
                }
            }
            
            
        }else{
            
            roomsLightOn()
        }
        
        
        
    }
    */
    
    
    func roomsLightOn(){
        let x:String = myText.text!
        let y = "تشغيل اضاءة غرفة"
        print (x)
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        var R3 = " "
        var R4 = " "
        
        let T1 = z5[1]
        let T2 = z5[2]
        let T3 = z5[3]
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 5)
            
        {
            R1 = z[1]
            R2 = z[2]
            R3 = z[3]
            R4 = z[4]
            
            if (z[4] == z[0]){
                createcontactAlert(title: "المنزل", message: "لم يتم تحديد الغرفة")
            }
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            let difference3 = zip(R3 , T3).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif3:Float =  Float( difference3.count)
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            let err3:Float = Float( ( ( dif3 ) / (ln)  * 100 ) )
            print ("error 3 \(err3)")
            
            
            let err:Float = err1 + err2 + err3
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                var tyt = 0
                var tot = 0
                var tut = 0

                for i in R4 {
                    if (i == "و"  || i == "ح" || i == "د" || i == "ا"){
                        tyt = tyt + 1
                    }}
                for i in R4 {
                    if ( i == "ث" || i == "ن" || i == "ي" || i == "س" ){
                        tot = tot + 1
                    }
                }
                for i in R4 {
                    if ( i == "م" || i == "ع" || i == "ي" || i == "ش" || i == "ة" ){
                        tut = tut + 1
                    }
                }
               
                
                if (tyt >= 3){
                    room1Light(state: "2")
                    myOutText.text = "اضاءة غرفة واحد تعمل"

                }else if (tot >= 3){
                    room2Light(state: "5")
                    myOutText.text = "اضاءة غرفة اثنين تعمل"
                }else if (tut >= 3){
                    salonLight(state: "2")
                    myOutText.text = " اضاءة غرفة المعيشة تعمل"
                }else{
                    myOutText.text = "لم يتم تحديد الغرفة"

                }
            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                var tut = 0
               
                var tet = 0
                var tat = 0
                var tlt = 0

                for i in R1 {
                    if (i == "ت"  || i == "ش" || i == "غ" || i == "ي" || i == "ل"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if ( i == "ض" || i == "ء" || i == "ا" || i == "ة" || i == "د" || i == "ت") {
                        tot = tot + 1
                    }
                }
                for i in R3 {
                    if (i == "غ" ||  i == "ر" || i == "ف" || i == "ة" ){
                        tut = tut + 1
                    }
                }
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                print ( "discoverd letters 3 is \(tut)")
                
                if ( tyt >= 3){
                    if ( tot >= 3){
                        if (tut >= 3){
                            
                            for i in R4 {
                                if (i == "و"  || i == "ح" || i == "د" || i == "ا" ){
                                    tet = tet + 1
                                }}
                            for i in R4 {
                                if ( i == "ث" || i == "ن" || i == "ي" || i == "س" || i == "ا"){
                                    tat = tat + 1
                                }
                            }
                            for i in R4 {
                                if ( i == "م" || i == "ع" || i == "ي" || i == "ش" || i == "ة" ){
                                    tlt = tlt + 1
                                }
                            }
                            
                            
                            if (tet >= 3){
                                room1Light(state: "2")
                                myOutText.text = "اضاءة غرفة واحد تعمل"

                            }else if (tat >= 3){
                                room2Light(state: "5")
                                myOutText.text = "اضاءة غرفة اثنين تعمل"
                            }else if (tlt >= 4){
                                salonLight(state: "2")
                                myOutText.text = " اضاءة غرفة المعيشة تعمل"
                            }else{
                                myOutText.text = "لم يتم تحديد الغرفة"

                            }
                            
                            
                        } else{
                            
                            roomsLightOff()
                        }
                        
                        
                    }
                    else{
                        
                        roomsLightOff()
                    }
                }   else{
                    
                    roomsLightOff()
                    
                }
            }
            
            
            
            
            
            
            
        }
        else{
            
            roomsLightOff()
            
        }
        
        
    }
    
    
    
    
    func roomsLightOff(){
        let x:String = myText.text!
        let y = "اغلق اضاءة غرفة"
        print (x)
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        var R3 = " "
        var R4 = " "
        
        let T1 = z5[1]
        let T2 = z5[2]
        let T3 = z5[3]
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 5)
            
        {
            R1 = z[1]
            R2 = z[2]
            R3 = z[3]
            R4 = z[4]
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            let difference3 = zip(R3 , T3).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif3:Float =  Float( difference3.count)
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            let err3:Float = Float( ( ( dif3 ) / (ln)  * 100 ) )
            print ("error 3 \(err3)")
            
            
            let err:Float = err1 + err2 + err3
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                var tyt = 0
                var tot = 0
                var tut = 0
                
                for i in R4 {
                    if (i == "و"  || i == "ح" || i == "د" || i == "ا" ){
                        tyt = tyt + 1
                    }}
                for i in R4 {
                    if ( i == "ث" || i == "ن" || i == "ي" || i == "س" || i == "ا"){
                        tot = tot + 1
                    }
                }
                for i in R4 {
                    if ( i == "م" || i == "ع" || i == "ي" || i == "ش" || i == "ة" ){
                        tut = tut + 1
                    }
                }
                
                
                if (tyt >= 3){
                    room1Light(state: "0")
                    myOutText.text = " تم اغلاق اضاءة غرفة واحد"
                    
                }else if (tot >= 3){
                    room2Light(state: "3")
                    myOutText.text = "تم اغلاق اضاءة غرفة اثنين"
                }else if (tut >= 3){
                    salonLight(state: "5")
                    myOutText.text = "تم اغلاق اضاءة غرفة المعيشة"
                }else{
                    myOutText.text = "لم يتم تحديد الغرفة"

                }

                
            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                var tut = 0
                
                var tet = 0
                var tat = 0
                var tlt = 0
                for i in R1 {
                    if ( i == "غ" || i == "ق" || i == "ل" || i == "ك"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if (  i == "ض" || i == "ء" || i == "ا" || i == "ة"){
                        tot = tot + 1
                    }
                }
                for i in R3 {
                    if (i == "غ" ||  i == "ر" || i == "ف" || i == "ة"){
                        tut = tut + 1
                    }
                }
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                print ( "discoverd letters 3 is \(tut)")
                
                if ( tyt >= 3){
                    if (tot >= 3){
                        if (tut >= 3){
                            
                            for i in R4 {
                                if (i == "و"  || i == "ح" || i == "د" || i == "ا" ){
                                    tet = tet + 1
                                }}
                            for i in R4 {
                                if ( i == "ث" || i == "ن" || i == "ي" || i == "س" || i == "ا"){
                                    tat = tat + 1
                                }
                            }
                            for i in R4 {
                                if ( i == "م" || i == "ع" || i == "ي" || i == "ش" || i == "ة" ){
                                    tlt = tlt + 1
                                }
                            }
                            
                            if (tet >= 3){
                                room1Light(state: "0")
                                myOutText.text = " تم اغلاق اضاءة غرفة واحد"

                            }else if (tat >= 3){
                                room2Light(state: "3")
                                myOutText.text = "تم اغلاق اضاءة غرفة اثنين"
                            }else if (tlt >= 3){
                                salonLight(state: "5")
                                myOutText.text = "تم اغلاق اضاءة غرفة المعيشة"
                            }else{
                                myOutText.text = "لم يتم تحديد الغرفة"

                            }
                        } else{
                            
                            roomsFanOn()
                        }
                        
                        
                    }
                    else{
                        
                        roomsFanOn()
                    }
                }   else{
                    
                    roomsFanOn()
                    
                }
            }

            
        } else{
            
            roomsFanOn()
            
        }
    }
    
    
    
    
    func roomsFanOn(){
        let x:String = myText.text!
        let y = "تشغيل مروحة غرفة"
        print (x)
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        var R3 = " "
        var R4 = " "
        var R5 = " "

        let T1 = z5[1]
        let T2 = z5[2]
        let T3 = z5[3]
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 7)
            
        {
            R1 = z[1]
            R2 = z[2]
            R3 = z[3]
            R4 = z[4]
            R5 = z[6]

            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            let difference3 = zip(R3 , T3).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif3:Float =  Float( difference3.count)
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            let err3:Float = Float( ( ( dif3 ) / (ln)  * 100 ) )
            print ("error 3 \(err3)")
            
            
            let err:Float = err1 + err2 + err3
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                
                
                var tet = 0
                var tat = 0
                var tlt = 0
                
                var trt = 0
                var tct = 0
                var tst = 0

  
                for i in R4 {
                    if (i == "و"  || i == "ح" || i == "د" || i == "ا" ){
                        tet = tet + 1
                    }}
                for i in R4 {
                    if ( i == "ث" || i == "ن" || i == "ي" || i == "س" || i == "ا"){
                        tat = tat + 1
                    }
                }
                for i in R4 {
                    if ( i == "م" || i == "ع" || i == "ي" || i == "ش" || i == "ة" ){
                        tlt = tlt + 1
                    }
                }
                for i in R5 {
                    if (i == "و"  || i == "ح" || i == "د"  ){
                        trt = trt + 1
                    }}
                for i in R5 {
                   if ( i == "ث" || i == "ن" || i == "ي" || i == "س" ){
                        tct = tct + 1
                    }
                }
                for i in R5 {
                    if ( i == "ث" || i == "ل" || i == "ة" || i == "ه" || i == "ي"){
                        tst = tst + 1
                    }
                }
           
                            
                if (tet  >= 3){
                                
                               
                                if (trt >= 3){
                                    
                                    room1Fan (state: "7")
                                    myOutText.text = "تشغيل مروحة غرفة واحد سرعة واحد"
                                    
                                }else if (tct >= 3){
                                   room1Fan (state: "8")
                                    myOutText.text = "تشغيل مروحة غرفة واحد سرعة اثنين"
                                }else if (tst >= 3){
                                   room1Fan (state: "9")
                                    myOutText.text = "تشغيل مروحة غرفة واحد سرعة ثلاثة"
                                }else{
                                    myOutText.text = "لم يتم تحديد السرعة"
                                    
                    }}else if (tat >= 3){
                    
                    if (trt >= 3){
                        
                        room2Fan (state: "11")
                        myOutText.text = "تشغيل مروحة غرفة اثنين سرعة واحد"
                        
                    }else if (tct >= 3){
                        room2Fan (state: "12")
                        myOutText.text = "تشغيل مروحة غرفة اثنين سرعة اثنين"
                    }else if (tst >= 3){
                        room2Fan (state: "13")
                        myOutText.text = "تشغيل مروحة غرفة اثنين سرعة ثلاثة"
                    }else{
                        myOutText.text = "لم يتم تحديد السرعة"
                        
                    }
                }else if (tlt >= 3){
                    
                   
                    if (trt >= 3){
                        
                        salonFan (state: "7")
                        myOutText.text = "تشغيل مروحة غرفة المعيشة سرعة واحد"
                        
                    }else if (tct >= 3){
                        salonFan (state: "8")
                        myOutText.text = "تشغيل مروحة غرفة المعيشة سرعة اثنين"
                    }else if (tst >= 3){
                        salonFan (state: "9")
                        myOutText.text = "تشغيل مروحة غرفة المعيشة سرعة ثلاثة"
                    }else{
                        myOutText.text = "لم يتم تحديد السرعة"
                        
                    }
                }
                                
                
                
                        }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                var tut = 0
               
                var tet = 0
                var tat = 0
                var tlt = 0
                
                var trt = 0
                var tct = 0
                var tst = 0
                for i in R1 {
                    if (i == "ت"  || i == "ش" || i == "غ" || i == "ي" || i == "ل"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if ( i == "م" || i == "ر" || i == "و" || i == "ح" || i == "ة"){
                        tot = tot + 1
                    }
                }
                for i in R3 {
                    if (i == "غ" ||  i == "ر" || i == "ف" || i == "ة"){
                        tut = tut + 1
                    }
                }
                
                for i in R4 {
                    if (i == "و"  || i == "ح" || i == "د" ){
                        tet = tet + 1
                    }}
                for i in R4 {
                    if ( i == "ث" || i == "ن" || i == "ي" || i == "س" ){
                        tat = tat + 1
                    }
                }
                for i in R4 {
                    if ( i == "م" || i == "ع" || i == "ي" || i == "ش" || i == "ة" ){
                        tlt = tlt + 1
                    }
                }
                for i in R5 {
                    if (i == "و"  || i == "ح" || i == "د" || i == "ا" ){
                        trt = trt + 1
                    }}
                for i in R5 {
                    if ( i == "ث" || i == "ن" || i == "ي" || i == "س"){
                        tct = tct + 1
                    }
                }
                for i in R5 {
                    if ( i == "ث" || i == "ل" || i == "ة" || i == "ه" || i == "س"){
                        tst = tst + 1
                    }
                }

                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                print ( "discoverd letters 3 is \(tut)")
                
                if ( tyt >= 3){
                    if (tot >= 3){
                        if (tut >= 3){
                            if (tet  >= 3){
                                
                                
                                if (trt >= 3){
                                    
                                    room1Fan (state: "7")
                                    myOutText.text = "تشغيل مروحة غرفة واحد سرعة واحد"
                                    
                                }else if (tct >= 3){
                                    room1Fan (state: "8")
                                    myOutText.text = "تشغيل مروحة غرفة واحد سرعة اثنين"
                                }else if (tst >= 3){
                                    room1Fan (state: "9")
                                    myOutText.text = "تشغيل مروحة غرفة واحد سرعة ثلاثة"
                                }else{
                                    myOutText.text = "لم يتم تحديد السرعة"
                                    
                                }}else if (tat >= 3){
                                
                                if (trt >= 3){
                                    
                                    room2Fan (state: "11")
                                    myOutText.text = "تشغيل مروحة غرفة اثنين سرعة واحد"
                                    
                                }else if (tct >= 3){
                                    room2Fan (state: "12")
                                    myOutText.text = "تشغيل مروحة غرفة اثنين سرعة اثنين"
                                }else if (tst >= 3){
                                    room2Fan (state: "13")
                                    myOutText.text = "تشغيل مروحة غرفة اثنين سرعة ثلاثة"
                                }else{
                                    myOutText.text = "لم يتم تحديد السرعة"
                                    
                                }
                            }else if (tlt >= 3){
                                
                                
                                if (trt >= 3){
                                    
                                    salonFan (state: "7")
                                    myOutText.text = "تشغيل مروحة غرفة المعيشة سرعة واحد"
                                    
                                }else if (tct >= 3){
                                    salonFan (state: "8")
                                    myOutText.text = "تشغيل مروحة غرفة المعيشة سرعة اثنين"
                                }else if (tst >= 3){
                                    salonFan (state: "9")
                                    myOutText.text = "تشغيل مروحة غرفة المعيشة سرعة ثلاثة"
                                }else{
                                    myOutText.text = "لم يتم تحديد السرعة"
                                    
                                }
                            }
                            
                        }
                        
                        
                    }
                    else{
                        
                        roomsFanOff()
                    }
                }   else{
                    
                    roomsFanOff()
                    
                }
            }
            
            
            
            
            
            
            
        }  else{
            
            roomsFanOff()
            
        }
        
        
    }
    
    
    
    
    func roomsFanOff(){
        let x:String = myText.text!
        let y = "اغلق مروحة غرفة"
        print (x)
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        var R3 = " "
        var R4 = " "
        
        let T1 = z5[1]
        let T2 = z5[2]
        let T3 = z5[3]
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count > 5)
            
        {
            R1 = z[1]
            R2 = z[2]
            R3 = z[3]
            R4 = z[4]
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            let difference3 = zip(R3 , T3).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif3:Float =  Float( difference3.count)
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            let err3:Float = Float( ( ( dif3 ) / (ln)  * 100 ) )
            print ("error 3 \(err3)")
            
            
            let err:Float = err1 + err2 + err3
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                var tet = 0
                var tat = 0
                var tlt = 0
                
                
                
                for i in R4 {
                    if (i == "و"  || i == "ح" || i == "د" || i == "ا" ){
                        tet = tet + 1
                    }}
                for i in R4 {
                    if ( i == "ث" || i == "ن" || i == "ي" || i == "س" || i == "ا"){
                        tat = tat + 1
                    }
                }
                for i in R4 {
                    if ( i == "م" || i == "ع" || i == "ي" || i == "ش" || i == "ة" ){
                        tlt = tlt + 1
                    }
                }
            
                
                
                if (tet  >= 3){
                    
                        room1Fan (state: "6")
                        myOutText.text = "اغلق مروحة غرفة واحد"
                        
                    }else if (tat >= 3){
                        room2Fan (state: "10")
                        myOutText.text = "اغلق مروحة غرفة اثنين "
                    }else if (tlt >= 3){
                        salonFan (state: "6")
                        myOutText.text = "اغلق مروحة غرفة المعيشة "
                    }else{
                        myOutText.text = "لم يتم تحديد الغرفة"
                        
                    }
                
                
            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                var tut = 0
                
                var tet = 0
                var tat = 0
                var tlt = 0
                for i in R1 {
                    if (i == "ك" || i == "غ" || i == "ق" || i == "ل" || i == "ا"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if (i == "ت" || i == "م" || i == "ر" || i == "و" || i == "ح" || i == "ة"){
                        tot = tot + 1
                    }
                }
                for i in R3 {
                    if (i == "غ" ||  i == "ر" || i == "ف" || i == "ة"){
                        tut = tut + 1
                    }
                }
                
                for i in R4 {
                    if (i == "و"  || i == "ح" || i == "د" || i == "ا" ){
                        tet = tet + 1
                    }}
                for i in R4 {
                    if ( i == "ث" || i == "ن" || i == "ي" || i == "س" || i == "ا"){
                        tat = tat + 1
                    }
                }
                for i in R4 {
                    if ( i == "م" || i == "ع" || i == "ي" || i == "ش" || i == "ة" ){
                        tlt = tlt + 1
                    }
                }
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                print ( "discoverd letters 3 is \(tut)")
                
                if ( tyt >= 3){
                    if ( tot >= 3){
                        if ( tut >= 3){
                            if (tet  >= 3){
                                
                                room1Fan (state: "6")
                                myOutText.text = "اغلق مروحة غرفة واحد"
                                
                            }else if (tat >= 3){
                                room2Fan (state: "10")
                                myOutText.text = "اغلق مروحة غرفة اثنين "
                            }else if (tlt >= 3){
                                salonFan (state: "6")
                                myOutText.text = "اغلق مروحة غرفة المعيشة "
                            }else{
                                myOutText.text = "لم يتم تحديد الغرفة"
                                
                            }

                            
                        }
                        else{
                            openMusic()
                            
                        }

                        
                        
                    }
                    else{
                        openMusic()
                        
                    }
                } else{
                    openMusic()
                    
                    
                }
            }
            
            
            
            
            
            
            
        }else{
            openMusic()
            
            
        }
        
        
        
    }

    func openMusic(){
        
        let x:String = myText.text!
        let y =   "افتح الاغاني"
        print (x)
        let stringOfWordArray1 = x.components(separatedBy: " ")
        let stringOfWordArray2 = y.components(separatedBy: " ")
        var z = [""]
        for word in stringOfWordArray1 {
            z = z + [word]
        }
        var z5 = [""]
        for word in stringOfWordArray2 {
            z5 = z5 + [word]
        }
        print (z)
        print (z5)
        var R1 = " "
        var R2 = " "
        
        
        let T1 = z5[1]
        let T2 = z5[2]
        
        var count = 0
        for _ in z{
            count = count + 1
        }
        print (count)
        if (count >= 3)
            
        {
            R1 = z[1]
            R2 = z[2]
            
            
            
            let difference1 = zip(R1 , T1).filter{ $0 != $1 }
            print("difference between first words is \(difference1.count)")
            let dif1:Float = Float(difference1.count)
            
            let difference2 = zip(R2 , T2).filter{ $0 != $1 }
            print("difference between second words is \(difference2.count)")
            let dif2:Float =  Float( difference2.count)
            
            
            
            
            let ln:Float = Float(y.count)
            print ("length of needed string \(ln)")
            
            let err1:Float = Float( ( ( dif1 ) / (ln)  * 100 ) )
            print ("error 1 \(err1)")
            
            let err2:Float = Float( ( ( dif2 ) / (ln)  * 100 ) )
            print ("error 2 \(err2)")
            
            
            let err:Float = err1 + err2
            print ("error total = \(err)")
            
            
            if (err <= 20 )
            {
                myOutText.text = y
                //    loadReminder()
                performSegue(withIdentifier: "musicSegue", sender: self)
            }
            else if (err > 20)
            {
                var tyt = 0
                var tot = 0
                
                for i in R1 {
                    if (i == "ح"  || i == "ف" || i == "ت"){
                        tyt = tyt + 1
                    }}
                for i in R2 {
                    if (  i == "غ" || i == "ن" || i == "ا" || i == "ي" ){
                        tot = tot + 1
                    }
                }
                
                
                
                
                print ( "discoverd letters 1 is \(tyt)")
                print ( "discoverd letters 2 is \(tot)")
                
                
                
                
                if ( tyt >= 3){
                    if ( tot >= 2){
                        
                        
                        myOutText.text = y
                        //  loadReminder()
                    performSegue(withIdentifier: "musicSegue", sender: self)
                        
                        
                        
                    }
                    else{
                        
                        myOutText.text = "ادخل مرة اخرة"
                    }
                } else{
                    
                    myOutText.text = "ادخل مرة اخرة"
                }
            }
            
            
        }else{
            
            myOutText.text = "ادخل مرة اخرة"
        }
        
        
        
    }
    

/************************************************Firebase Database**************************************/
    func room1Light (state : String)
    {
        let ref = Database.database().reference()
        let post : [String : AnyObject] = ["Light" :state as AnyObject]
        ref.child("Room1").child("Light").setValue(post)
        
        
    }
    func room1Fan (state : String)
    {
        let ref = Database.database().reference()
        let post : [String : AnyObject] = ["Fan" :state as AnyObject]
        ref.child("Room1").child("Fan").setValue(post)
    }
    
    func room2Light (state : String)
    {
        let ref = Database.database().reference()
        let post : [String : AnyObject] = ["Light" :state as AnyObject]
        ref.child("Room2").child("Light").setValue(post)
        
        
    }
    func room2Fan (state : String)
    {
        let ref = Database.database().reference()
        let post : [String : AnyObject] = ["Fan" :state as AnyObject]
        ref.child("Room2").child("Fan").setValue(post)
    }
    
    func room3Light (state : String)
    {
        let ref = Database.database().reference()
        let post : [String : AnyObject] = ["Light" :state as AnyObject]
        ref.child("Room3").child("Light").setValue(post)
        
        
    }
    func room3Fan (state : String)
    {
        let ref = Database.database().reference()
        let post : [String : AnyObject] = ["Fan" :state as AnyObject]
        ref.child("Room3").child("Fan").setValue(post)
    }
    
    func room4Light (state : String)
    {
        let ref = Database.database().reference()
        let post : [String : AnyObject] = ["Light" :state as AnyObject]
        ref.child("Room4").child("Light").setValue(post)
        
        
    }
    func room4Fan (state : String)
    {
        let ref = Database.database().reference()
        let post : [String : AnyObject] = ["Fan" :state as AnyObject]
        ref.child("Room4").child("Fan").setValue(post)
    }
    
    func room5Light (state : String)
    {
        let ref = Database.database().reference()
        let post : [String : AnyObject] = ["Light" :state as AnyObject]
        ref.child("Room5").child("Light").setValue(post)
        
        
    }
    func room5Fan (state : String)
    {
        let ref = Database.database().reference()
        let post : [String : AnyObject] = ["Fan" :state as AnyObject]
        ref.child("Room5").child("Fan").setValue(post)
    }
    
    
    func salonLight (state : String)
    {
        let ref = Database.database().reference()
        let post : [String : AnyObject] = ["Light" :state as AnyObject]
        ref.child("Salon").child("Light").setValue(post)
        
        
    }
    
    
    func salonFan (state : String)
    {
        let ref = Database.database().reference()
        let post : [String : AnyObject] = ["Fan" :state as AnyObject]
        ref.child("Salon").child("Fan").setValue(post)
    }
    
    
    func openClose (state : String)
    {
        let ref = Database.database().reference()
        let post : [String : AnyObject] = ["servo" :state as AnyObject]
        ref.child("mainDoor").setValue(post)
    }
    func fire (state : String)
    {
        let ref = Database.database().reference()
        let post : [String : AnyObject] = ["FireSensor" :state as AnyObject]
        ref.child("Salon").child("FireSensor").setValue(post)
    }
    func fire2 (state : String)
    {
        let ref = Database.database().reference()
        let post : [String : AnyObject] = ["FireSensor" :state as AnyObject]
        ref.child("Kitchen").child("FireSensor").setValue(post)
    }
    func bell (state : String)
    {
        let ref = Database.database().reference()
        let post : [String : AnyObject] = ["DoorBell" :state as AnyObject]
        ref.child("Door").child("DoorBell").setValue(post)
    }



    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textFieldShouldReturn (_ textField : UITextField ) -> Bool {
        textField.resignFirstResponder()
        return(true)
    }
    func warningMessage (){
        let content = UNMutableNotificationContent()
        content.title = "تحذير"
        content.subtitle = "حريق في المنزل"
        content.sound = UNNotificationSound.default
        let triger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
        let request = UNNotificationRequest(identifier: "Identifier", content: content, trigger: triger)
        UNUserNotificationCenter.current().add(request) { (error) in
            print(error as Any)
            self.fire (state: "0")
            self.fire2 (state: "0")
            
        }
        
    }
    
    
    func doorBell (){
        let content = UNMutableNotificationContent()
        content.title = "اشعارات"
        content.subtitle = "هناك شخص علي الباب"
        content.sound = UNNotificationSound.default
        let triger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
        let request = UNNotificationRequest(identifier: "Identifier", content: content, trigger: triger)
        UNUserNotificationCenter.current().add(request) { (error) in
            print(error as Any)
            self.bell (state: "0")
            
        }
        
        
        
    }

}
