//
//  speechController.swift
//  GP2
//
//  Created by Abanoub S. Ghaly on 6/4/19.
//  Copyright © 2019 Abanoub S. Ghaly. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications


class speechController: UIViewController {


    
    @IBOutlet weak var changeLang: UIButton!
    
    @IBOutlet weak var logout: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.applyRoundCorner(changeLang)
        self.applyRoundCorner(logout)
        changeLang.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "changeLang.normalTitle", comment: " "), for: .normal)
        logout.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "logout.normalTitle", comment: " "), for: .normal)

    
        
    }
    
   
    
    
    /******************** changing language from english to arabic and vice versa**************************/
    
    @IBAction func doChange(_ sender: Any) {
        if LocalizationSystem.sharedInstance.getLanguage() == "ar"{
            LocalizationSystem.sharedInstance.setLanguage(languageCode: "en")
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        else{
            LocalizationSystem.sharedInstance.setLanguage(languageCode: "ar")
            UIView.appearance().semanticContentAttribute = .forceRightToLeft

        }
    
     let vm = self.storyboard?.instantiateViewController(withIdentifier: "vm2")   as! MainTabBarController
       let appDlg = UIApplication.shared.delegate as? AppDelegate
     appDlg?.window?.rootViewController = vm
   




    }
    
  
    
    
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "signOutSegue", sender: nil)
        }catch {
            print(error)
        }
    }
    
    
  
    
    func applyRoundCorner(_ object: AnyObject){
        
        object.layer.cornerRadius = object.frame.height / 2
        object.layer.masksToBounds = true
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
        }
        
        
        
    }

}
