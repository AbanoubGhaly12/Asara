//
//  embeddedController.swift
//  GP2
//
//  Created by Abanoub S. Ghaly on 6/4/19.
//  Copyright © 2019 Abanoub S. Ghaly. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase


extension embeddedController : UNUserNotificationCenterDelegate{
    func  userNotificationCenter (_ center: UNUserNotificationCenter , willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping(UNNotificationPresentationOptions) -> Void){
        completionHandler([.alert,.sound,.badge])
    }
}

class embeddedController: UIViewController {

/*************************************************buttons & label outlets*************************************************************************************************/
    

    @IBOutlet weak var roomOne: UILabel!
    @IBOutlet weak var lampRoomOne: UIButton!
    @IBOutlet weak var cameraRoomOne: UIButton!
    @IBOutlet weak var fanOne: UILabel!
    @IBOutlet weak var fanRoomOne: UISlider!
    
   
    @IBOutlet weak var roomTwo: UILabel!
    @IBOutlet weak var lampRoomTwo: UIButton!
    @IBOutlet weak var cameraRoomTwo: UIButton!
    @IBOutlet weak var fanTwo: UILabel!
    @IBOutlet weak var fanRoomTwo: UISlider!
    
    
    @IBOutlet weak var roomThree: UILabel!
    @IBOutlet weak var lampRoomThree: UIButton!
    @IBOutlet weak var cameraRoomThree: UIButton!
    @IBOutlet weak var fanThree: UILabel!
    @IBOutlet weak var fanRoomThree: UISlider!
    
    
    @IBOutlet weak var roomFour: UILabel!
    @IBOutlet weak var lampRoomFour: UIButton!
    @IBOutlet weak var cameraRoomFour: UIButton!
    @IBOutlet weak var fanFour: UILabel!
    @IBOutlet weak var fanRoomFour: UISlider!
    
    
    
    @IBOutlet weak var roomFive: UILabel!
    @IBOutlet weak var lampRoomFive: UIButton!
    @IBOutlet weak var cameraRoomFive: UIButton!
    @IBOutlet weak var fanFive: UILabel!
    @IBOutlet weak var fanRoomFive: UISlider!
    
    
    @IBOutlet weak var salon: UILabel!
    @IBOutlet weak var lampSalon: UIButton!
    @IBOutlet weak var cameraSalon: UIButton!
    @IBOutlet weak var fanSalon: UILabel!
    @IBOutlet weak var fanInSalon: UISlider!
    
    
    @IBOutlet weak var door: UILabel!
    @IBOutlet weak var openCloseDoor: UIButton!
    @IBOutlet weak var cameraDoor: UIButton!
   
    
    @IBOutlet weak var notifications: UILabel!
    @IBOutlet weak var sensorWarnings: UILabel!
    
    
    @IBOutlet weak var settingForRooms: UIButton!
    @IBOutlet weak var rm2: UIButton!
    @IBOutlet weak var rm3: UIButton!
    @IBOutlet weak var rm4: UIButton!
    @IBOutlet weak var rm5: UIButton!
    
    /************************************************************************************************************************************************************************/
    

    //flags
    var flag0 = 1
    var flag1 = 1
    var flag2 = 1
    var flag3 = 1
    var flag4 = 1
    var flag5 = 1
    var flag6 = 1
 
        
       
    
/********************************** setting of the number of rooms *********************************************/
    
    @IBAction func tworom(_ sender: UIButton) {
        twoRoom()
       
    }
    
    @IBAction func threerom(_ sender: Any) {
        threeRoom()
   
    }
    
    @IBAction func fourrom(_ sender: UIButton) {
        fourRoom()
     
    }
    @IBAction func fiverom(_ sender: UIButton) {
        fiveRoom()
        
    }
    /************************************************************************************************************************************************************************/
    

    

    

    
/****************************************buttons action to control lamps & fans & door***********************************************************************************/
    

    
    @IBAction func lampRoom1(_ sender: UIButton) {
        
        if (flag0 == 1){
            room1Light(state: "2")
            flag0 = 2
        }
        else if (flag0 == 2){
            room1Light(state: "0")
            flag0 = 0
        }
        else if (flag0 == 0){
            room1Light(state: "1")
            flag0 = 1
        }
        
    }

    
    
    @IBAction func fanRoom1(_ sender: UISlider) {
        
        let currentValue = Float(sender.value)
        if (currentValue <= Float(0.25) && currentValue >= Float(0.0))
        {   room1Fan (state: "6")

        }
        else    if (currentValue >= Float(0.25) && currentValue <= Float(0.5))
        {   room1Fan (state: "7")

        }
        else    if (currentValue >= Float(0.5) && currentValue <= Float(0.75))
        {   room1Fan (state: "8")

        }
        else    if (currentValue >= Float(0.75) && currentValue <= Float(1.0))
        {   room1Fan (state: "9")

        }
        
    }
    
    
  
    
    
    @IBAction func lampRoom2(_ sender: UIButton){
        if (flag1 == 2){
            room2Light(state: "5")
            flag1 = 0
        }
        else if (flag1 == 0){
            room2Light(state: "3")
            flag1 = 1
        }
        else if (flag1 == 1){
            room2Light(state: "4")
            flag1 = 2
        }
    }
 
    
    
    @IBAction func fanRoom2(_ sender: UISlider) {
        let currentValue = Float(sender.value)
        if (currentValue <= Float(0.25) && currentValue >= Float(0.0))
        {   room2Fan (state: "10")
        }
        else    if (currentValue >= Float(0.25) && currentValue <= Float(0.5))
        {   room2Fan (state: "11")

        }
        else    if (currentValue >= Float(0.5) && currentValue <= Float(0.75))
        {   room2Fan (state: "12")


        }
        else    if (currentValue >= Float(0.75) && currentValue <= Float(1.0))
        {   room2Fan (state: "13")


        }
    }
    
    
    
    @IBAction func lampRoom3(_ sender: UIButton) {
        if (flag2 == 1){
            room3Light(state: "010101")
            flag2 = 0
        }
        else if (flag2 == 0){
            room3Light(state: "101010")
            flag2 = 1
        }
        
    }

    
    
    @IBAction func fanRoom3(_ sender: UISlider) {
        let currentValue = Float(sender.value)
        if (currentValue <= Float(0.25) && currentValue >= Float(0.0))
        {   room3Fan (state: "010101")
        }
        else    if (currentValue >= Float(0.25) && currentValue <= Float(0.5))
        {   room3Fan (state: "101001")
        }
        else    if (currentValue >= Float(0.5) && currentValue <= Float(0.75))
        {   room3Fan (state: "1001101")
        }
        else    if (currentValue >= Float(0.75) && currentValue <= Float(1.0))
        {   room3Fan (state: "1010220")
        }
    }
    
    
    
    
    @IBAction func lampRoom4(_ sender: UIButton) {
        if (flag3 == 1){
            room4Light(state: "010101")
            flag3 = 0
        }
        else if (flag3 == 0){
            room4Light(state: "101010")
            flag3 = 1
        }
        
    }
 
    
    
    @IBAction func fanRoom4(_ sender: UISlider) {
        let currentValue = Float(sender.value)
        if (currentValue <= Float(0.25) && currentValue >= Float(0.0))
        {   room4Fan (state: "010101")
        }
        else    if (currentValue >= Float(0.25) && currentValue <= Float(0.5))
        {   room4Fan (state: "101001")
        }
        else    if (currentValue >= Float(0.5) && currentValue <= Float(0.75))
        {   room4Fan (state: "1001101")
        }
        else    if (currentValue >= Float(0.75) && currentValue <= Float(1.0))
        {   room4Fan (state: "1010220")
        }
    }
    
    
    
    
    @IBAction func lampRoom5(_ sender: UIButton) {
        if (flag4 == 1){
            room5Light(state: "010101")
            flag4 = 0
        }
        else if (flag4 == 0){
            room5Light(state: "101010")
            flag4 = 1
        }
        
    }
 
    
    
    @IBAction func fanRoom5(_ sender: UISlider) {
        let currentValue = Float(sender.value)
        if (currentValue <= Float(0.25) && currentValue >= Float(0.0))
        {   room5Fan (state: "010101")
        }
        else    if (currentValue >= Float(0.25) && currentValue <= Float(0.5))
        {   room5Fan (state: "101001")
        }
        else    if (currentValue >= Float(0.5) && currentValue <= Float(0.75))
        {   room5Fan (state: "1001101")
        }
        else    if (currentValue >= Float(0.75) && currentValue <= Float(1.0))
        {   room5Fan (state: "1010220")
        }
    }
    
    
    
    
    
    @IBAction func lampSalon(_ sender: UIButton) {
        if (flag5 == 1){
            salonLight(state: "1")
            flag5 = 2
        }
        else if (flag5 == 2){
            salonLight(state: "2")
            flag5 = 0
        }
        else if (flag5 == 0){
            salonLight(state: "5")
            flag5 = 1
        }
    }
 
    
    
    @IBAction func fanSalon(_ sender: UISlider) {
        let currentValue = Float(sender.value)
        if (currentValue <= Float(0.25) && currentValue >= Float(0.0))
        {   salonFan (state: "6")
        }
        else    if (currentValue >= Float(0.25) && currentValue <= Float(0.5))
        {   salonFan (state: "7")
        }
        else    if (currentValue >= Float(0.5) && currentValue <= Float(0.75))
        {   salonFan (state: "8")
        }
        else    if (currentValue >= Float(0.75) && currentValue <= Float(1.0))
        {   salonFan (state: "9")
        }
    }
    
    
    
    
    
    
    @IBAction func openCloseDoor(_ sender: UIButton) {
        if (flag6 == 1){
           openClose(state: "3")
            flag6 = 0
        }
        else if (flag6 == 0){
            openClose(state: "4")
            flag6 = 1
        }
    }

/************************************************************************************************************************************************************************/
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        
        
        
        
        
        
        
        
        
        
        
        /************************************************************** shapping the buttons **************************************************************************************/
        
        self.applyRoundCorner(lampRoomOne)
        self.applyRoundCorner(cameraRoomOne)
        self.applyRoundCorner(fanRoomOne)

        
        self.applyRoundCorner(lampRoomTwo)
        self.applyRoundCorner(cameraRoomTwo)
        self.applyRoundCorner(fanRoomTwo)

        self.applyRoundCorner(lampRoomThree)
        self.applyRoundCorner(cameraRoomThree)
        self.applyRoundCorner(fanRoomThree)

        self.applyRoundCorner(lampRoomFour)
        self.applyRoundCorner(cameraRoomFour)
        self.applyRoundCorner(fanRoomFour)

        self.applyRoundCorner(lampRoomFive)
        self.applyRoundCorner(cameraRoomFive)
        self.applyRoundCorner(fanRoomFive)

        self.applyRoundCorner(lampSalon)
        self.applyRoundCorner(cameraSalon)
        self.applyRoundCorner(fanSalon)

       
        self.applyRoundCorner(openCloseDoor)
        self.applyRoundCorner(cameraDoor)
        self.applyRoundCorner(sensorWarnings)
        
        
        self.applyRoundCorner(rm2)
        self.applyRoundCorner(rm3)
        self.applyRoundCorner(rm4)
        self.applyRoundCorner(rm5)

    /************************************************************************************************************************************************************************/
        

    /****************************************************** localizing outlets ***********************************************************************************************/
        roomOne.text  = LocalizationSystem.sharedInstance.localizedStringForKey(key: "YzQ-if-bXT.text" , comment: " ")
        lampRoomOne.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "P7A-ga-Myf.normalTitle", comment: " "), for: .normal)
        fanOne.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Nxv-SX-w9T.text", comment: " ")
        cameraRoomOne.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "temp.normaltitle", comment: " "), for: .normal)
     
        
        
        roomTwo.text  = LocalizationSystem.sharedInstance.localizedStringForKey(key: "NSN-0q-GoP.text" , comment: " ")
        lampRoomTwo.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "P7A-ga-Myf.normalTitle", comment: " "), for: .normal)
        fanTwo.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Nxv-SX-w9T.text", comment: " ")
        cameraRoomTwo.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "temp.normaltitle", comment: " "), for: .normal)
        
        
        roomThree.text  = LocalizationSystem.sharedInstance.localizedStringForKey(key: "hKL-tq-hPh.text" , comment: " ")
        lampRoomThree.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "P7A-ga-Myf.normalTitle", comment: " "), for: .normal)
        fanThree.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Nxv-SX-w9T.text", comment: " ")
        cameraRoomThree.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "temp.normaltitle", comment: " "), for: .normal)
        
        roomFour.text  = LocalizationSystem.sharedInstance.localizedStringForKey(key: "TXB-rf-fYI.text", comment: " ")
        lampRoomFour.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "P7A-ga-Myf.normalTitle", comment: " "), for: .normal)
        fanFour.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Nxv-SX-w9T.text", comment: " ")
        cameraRoomFour.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "temp.normaltitle", comment: " "), for: .normal)
        
        roomFive.text  = LocalizationSystem.sharedInstance.localizedStringForKey(key: "NSN-0q-GosadadP.text" , comment: " ")
        lampRoomFive.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "P7A-ga-Myf.normalTitle", comment: " "), for: .normal)
        fanFive.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Nxv-SX-w9T.text", comment: " ")
        cameraRoomFive.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "temp.normaltitle", comment: " "), for: .normal)
        
        
        
        salon.text  = LocalizationSystem.sharedInstance.localizedStringForKey(key: "yEk-r9-re3.text" , comment: " ")
        lampSalon.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "P7A-ga-Myf.normalTitle", comment: " "), for: .normal)
        fanSalon.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "Nxv-SX-w9T.text", comment: " ")
        cameraSalon.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "temp.normaltitle", comment: " "), for: .normal)
        
        
        door.text  = LocalizationSystem.sharedInstance.localizedStringForKey(key:"hgV-tR-k1g.text", comment: " ")
        openCloseDoor.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "E9f-eH-9S4.normalTitle", comment: " "), for: .normal)
        cameraDoor.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "TfX-ba-qIA.normalTitle", comment: " "), for: .normal)
        
        
        
      
        
        
         notifications.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "1CW-A6-L6f.text", comment: " ")
         sensorWarnings.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "iQS-VN-0D6.text", comment: " ")
        
        
         settingForRooms.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "setting.normalTitle", comment: " "), for: .normal)
        
         rm2.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "twoRooms.normalTitle", comment: " "), for: .normal)
         rm3.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "threeRooms.normalTitle", comment: " "), for: .normal)
         rm4.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "fourRooms.normalTitle", comment: " "), for: .normal)
         rm5.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "fiveRooms.normalTitle", comment: " "), for: .normal)
        

    /************************************************************************************************************************************************************************/
        

    /********************************************************** Getting warnings **********************************************************************************************/
        
UNUserNotificationCenter.current().delegate = self
        
            let ref1 = Database.database().reference()
            ref1.child("Salon").child("FireSensor").observe(.childChanged) { (snapshot) in
            let warn = snapshot.value as? String
                print ("\(warn)")
                if (warn == "10" ){
            self.sensorWarnings.text = warn

                        self.warningMessage()}}
       
            let ref5 = Database.database().reference()
            ref5.child("Kitchen").child("FireSensor").observe(.childChanged) { (snapshot) in
            let warn = snapshot.value as? String
                if (warn == "11" ){
                self.sensorWarnings.text = warn
                    self.warningMessage()}}
            
        
      
        let ref4 = Database.database().reference()
        ref4.child("Salon").child("FireSensor").observe(.childChanged) { (snapshot) in
            let temp = snapshot.value as? String
        }
            let ref6 = Database.database().reference()
            ref6.child("Door").child("DoorBell").observe(.childChanged) { (snapshot) in
                _ = snapshot.value as? String
            self.sensorWarnings.text = "شخص علي الباب"

            self.doorBell()
        }
        
        
        let ref7 = Database.database().reference()
        ref7.child("Kitchen").child("FireSensor").observe(.value) { (snapshot) in
            let warn = snapshot.value as? String
            if (warn == "11" ){
                self.sensorWarnings.text = warn
                self.warningMessage()}}
        /************************************************************************************************************************************************************************/
        

   
    /************************************************************************************************************************************************************************/
        

    }
    /****************************************** firebase database functions  creation from the app, by creating a parent and a child in each function in each room and  doors **************************/

    func applyRoundCorner(_ object: AnyObject){
        
        object.layer.cornerRadius = object.frame.height / 2
        object.layer.masksToBounds = true
    }
     /********firebase database functions*********/
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
    /************************************************************************************************************************************************************************/
    
    
    
    
    
    
    /*******************************************************  setting functions of number of rooms ************************************************************************************************/
    func twoRoom(){
        roomThree.textColor = .gray
        lampRoomThree.backgroundColor = .gray
        cameraRoomThree.backgroundColor = .gray
        fanThree.textColor = .gray
        fanRoomThree.tintColor = .gray
        fanRoomThree.thumbTintColor = .gray
        
        roomFour.textColor = .gray
        lampRoomFour.backgroundColor = .gray
        cameraRoomFour.backgroundColor = .gray
        fanFour.textColor = .gray
        fanRoomFour.tintColor = .gray
        fanRoomFour.thumbTintColor = .gray
        
        roomFive.textColor = .gray
        lampRoomFive.backgroundColor = .gray
        cameraRoomFive.backgroundColor = .gray
        fanFive.textColor = .gray
        fanRoomFive.tintColor = .gray
        fanRoomFive.thumbTintColor = .gray
    }
    func threeRoom(){
        roomThree.textColor = .black
        lampRoomThree.backgroundColor = UIColor.appColor
        cameraRoomThree.backgroundColor = UIColor.appColor
        fanThree.textColor = .black
        fanRoomThree.tintColor = UIColor.appColor
        fanRoomThree.thumbTintColor = UIColor.appColor
     
        roomFour.textColor = .gray
        lampRoomFour.backgroundColor = .gray
        cameraRoomFour.backgroundColor = .gray
        fanFour.textColor = .gray
        fanRoomFour.tintColor = .gray
        fanRoomFour.thumbTintColor = .gray
        
        roomFive.textColor = .gray
        lampRoomFive.backgroundColor = .gray
        cameraRoomFive.backgroundColor = .gray
        fanFive.textColor = .gray
        fanRoomFive.tintColor = .gray
        fanRoomFive.thumbTintColor = .gray
    }
    func fourRoom(){
        roomThree.textColor = .black
        lampRoomThree.backgroundColor = UIColor.appColor
        cameraRoomThree.backgroundColor = UIColor.appColor
        fanThree.textColor = .black
        fanRoomThree.tintColor = UIColor.appColor
        fanRoomThree.thumbTintColor = UIColor.appColor
        
        roomFour.textColor = .black
        lampRoomFour.backgroundColor = UIColor.appColor
        cameraRoomFour.backgroundColor = UIColor.appColor
        fanFour.textColor = .black
        fanRoomFour.tintColor = UIColor.appColor
        fanRoomFour.thumbTintColor = UIColor.appColor
        
        roomFive.textColor = .gray
        lampRoomFive.backgroundColor = .gray
        cameraRoomFive.backgroundColor = .gray
        fanFive.textColor = .gray
        fanRoomFive.tintColor = .gray
        fanRoomFive.thumbTintColor = .gray
    }
    func fiveRoom(){
        roomThree.textColor = .black
        lampRoomThree.backgroundColor = UIColor.appColor
        cameraRoomThree.backgroundColor = UIColor.appColor
        fanThree.textColor = .black
        fanRoomThree.tintColor = UIColor.appColor
        fanRoomThree.thumbTintColor = UIColor.appColor
        
        roomFour.textColor = .black
        lampRoomFour.backgroundColor = UIColor.appColor
        cameraRoomFour.backgroundColor = UIColor.appColor
        fanFour.textColor = .black
        fanRoomFour.tintColor = UIColor.appColor
        fanRoomFour.thumbTintColor = UIColor.appColor
        
        
        roomFive.textColor = .black
        lampRoomFive.backgroundColor = UIColor.appColor
        cameraRoomFive.backgroundColor = UIColor.appColor
        fanFive.textColor = .black
        fanRoomFive.tintColor = UIColor.appColor
        fanRoomFive.thumbTintColor =  UIColor.appColor
    }
    
    /********************************************************* notification of fire alarm **********************************************************************************************/
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
    
    

