//
//  ViewController.swift
//  GP2
//
//  Created by Abanoub S. Ghaly on 6/4/19.
//  Copyright © 2019 Abanoub S. Ghaly. All rights reserved.
//

import UIKit
import Firebase
class SignInController: UIViewController {
   
    
    
    
    
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var loginLogo: UIButton!
    @IBOutlet weak var Logo: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBAction func Login(_ sender: Any) {
        
        guard let email = emailTF.text,
            email != " "  ,
            let password = passwordTF.text,
            password != " "
            else  {
                
                alertController.showAlert(self, title: "missing info", message: "please fill out all required fields")
                
                return
                
        }
        /************************** takes the email and the password and send request to the firebase to chech if the email or the password vaild or not, if not, an alert is sent "not vaild email or password" ***********************/
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            guard error == nil else{
                
                alertController.showAlert(self, title: "Error", message: error!.localizedDescription )
                return
            }
            guard let user = user  else {return}
            
            print( user.user.email ?? "MISSING EMAIL" )
            print(user.user.displayName ?? "MISSING DISPLAY NAME")
            print(user.user.uid)
            
            self.performSegue(withIdentifier: "signInSegue", sender: nil)
        }
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let emailImage = UIImage(named: "email-7")
        addLeftImageToTextField(txtField: emailTF, andImage: emailImage! )
        
        let passwordImage = UIImage(named: "lock-8")
        addLeftImageToTextField(txtField: passwordTF, andImage: passwordImage! )
        
        
        Logo.text  = LocalizationSystem.sharedInstance.localizedStringForKey(key: "9SK-x3-uK0.text", comment: " ")
        signUpBtn.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "4nR-8L-GrG.normalTitle", comment: " "), for: .normal)
        loginLogo.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "MAK-Cb-VAo.normalTitle", comment: " "), for: .normal)
        emailTF.placeholder  = LocalizationSystem.sharedInstance.localizedStringForKey(key: "8fv-nj-wKn.placeholder", comment: " ")
        passwordTF.placeholder  = LocalizationSystem.sharedInstance.localizedStringForKey(key: "7Jx-Ro-PHb.placeholder", comment: " ")

    }
    /***************** adding photo to the text field ******************/
    func addLeftImageToTextField(txtField: UITextField, andImage img: UIImage){
        let leftImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: img.size.width, height: img.size.height))
        leftImageView.image = img
        txtField.leftView = leftImageView
        txtField.leftViewMode = .always
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
   func textFieldShouldReturn (_ textField : UITextField ) -> Bool {
    textField.resignFirstResponder()
    return(true)
    }
}

