//
//  webViewController.swift
//  GP2
//
//  Created by Abanoub S. Ghaly on 6/19/19.
//  Copyright © 2019 Abanoub S. Ghaly. All rights reserved.
//

import UIKit

class webViewController: UIViewController {
/******************* web view controller to show the link of the shotted photo on the door of the home  **************************/
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mySecurityCam = URL (string:"https://drive.google.com/file/d/1dk4Ph2gzdacIjqGsBfsVyXHZwGao23XU/view?usp=drivesdk&fbclid=IwAR061bf1c6e2r8NMVNRnQjcyLlM3a_RprGOEigYZoXzHl6nWCjNozfmwWPM") else { return  }
        let request = URLRequest(url: mySecurityCam )
        webView.loadRequest(request)
    }
    


}
