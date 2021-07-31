//
//  aboutUsViewController.swift
//  GP2
//
//  Created by Pavly Remon on 7/9/19.
//  Copyright © 2019 Abanoub S. Ghaly. All rights reserved.
//

import UIKit

class aboutUsViewController: UIViewController {

    @IBOutlet weak var aboutUsText: UITextView!
    
    @IBOutlet weak var tit: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        aboutUsText.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "aboutUs.text", comment: " ")
         tit.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "aboutUs.normalTitle", comment: " ")
        // Do any additional setup after loading the view.
    }
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
