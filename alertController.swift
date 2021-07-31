//
//  alertController.swift
//  GP2
//
//  Created by Abanoub S. Ghaly on 6/4/19.
//  Copyright © 2019 Abanoub S. Ghaly. All rights reserved.
//

import UIKit
/*************** alert  for error messages ***********************/
class alertController {
    static func showAlert(_ inViewController : UIViewController , title :String , message : String){
        let alert = UIAlertController( title: title ,message: message, preferredStyle: .alert )
        let action = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(action)
        inViewController.present(alert, animated: true, completion: nil)
    }
}

