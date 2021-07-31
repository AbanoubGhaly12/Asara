//
//  WeatherDataModel.swift
//  WeatherApp
//
//  Created by Angela Yu on 24/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit

class WeatherDataModel {

    //Declare your model variables here
    var temp : Int = 0
    var condition : Int = 0
    var city : String = ""
    var weatherIcon : String = ""
    
    //This method turns a condition code into the name of the weather condition image
    
    func updateWeatherIcon(condition: Int) -> String {
        
    switch (condition) {
    
        case 0...300 :
            return "tstorm1"
        
        case 301...500 :
            return "light_rain"
        
        case 501...600 :
            return "shower3"
        
        case 601...700 :
            return "snow4"
        
        case 701...771 :
            return "fog"
        
        case 772...799 :
            return "tstorm3"
        
        case 800 :
            return "sunny"
        
        case 801...804 :
            return "cloudy2"
        
        case 900...903, 905...1000  :
            return "tstorm3"
        
        case 903 :
            return "snow5"
        
        case 904 :
            return "sunny"
        
        default :
            return "dunno"
        }

    }
   
  
}
/********************** resize the image in the alert **************************/
extension UIAlertController {

func addImage(image : UIImage)  {
    let maxsize  = CGSize(width: 350, height: 300)
    let imageSize = image.size
    var ratio : CGFloat!
    if (imageSize.width > imageSize.height){
        ratio = maxsize.width / imageSize.width
    }else{
        ratio = maxsize.height / imageSize.height
    }
    let scaledSize = CGSize(width: imageSize.width * ratio, height: imageSize.height * ratio)
    var resizedImage = image.imageWithSize(scaledSize)
    if (imageSize.height > imageSize.width) {
        let left = (maxsize.width - resizedImage.size.width)/2
        resizedImage = resizedImage.withAlignmentRectInsets(UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0))
    }
    let imageAction = UIAlertAction(title: "", style: .default, handler: nil)
    imageAction.isEnabled = false
    imageAction.setValue(resizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
    addAction(imageAction)
    }}

/*********************** resize the image on the alert ***************************/
extension UIImage {
    func imageWithSize (_ size : CGSize) -> UIImage{
        var scaledImageRect = CGRect.zero
        let aspectwidth : CGFloat = size.width / self.size.width
         let aspectheight : CGFloat = size.height / self.size.height
        let aspectratio : CGFloat = min(aspectwidth , aspectheight)
        scaledImageRect.size.width = self.size.width * aspectratio
        scaledImageRect.size.height = self.size.height * aspectratio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return scaledImage
    }
}
