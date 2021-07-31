//
//  oneCell.swift
//  wholeProject
//
//  Created by phoebeezzat on 6/12/19.
//  Copyright © 2019 phoebe. All rights reserved.
//
/*************** resizing the cell to each function ********************/
import UIKit

class TableViewCell: UITableViewCell{
    var parentViewController: UIViewController?
    
    
    var alarmo = [Alarm]()
    
    @IBOutlet weak var MainLabel: UILabel!
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var wikiImage: UIImageView!
    @IBOutlet weak var secondLabel: UILabel!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @IBAction func alarmSwitched(_ sender: UISwitch) {
 
     //   self.delegatess?.alarmWasToggled(sender: self, ison: alarmSwitch.isOn)
    }
    
    
}

