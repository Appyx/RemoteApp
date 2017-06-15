//
//  ConfigureSensorViewController.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 04/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

class ConfigureSensorViewController: UIViewController {
    
    
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var analogView: UIView!
    @IBOutlet var pinButton: UIButton!
    @IBOutlet var pinLabel: UILabel!
    @IBOutlet var analogLabel: UILabel!
    @IBOutlet var analogButton: UIButton!
    
    var accessory:AccessoryConfiguration!
    var editMode=false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let states=Database.shared.getType(forName: accessory.typeName)?.possibleStates
        if states! == -1 { //digital
            analogView.isHidden=true
        }
        accessory.usedStates=states
        
        descriptionLabel.text="Choose the correct pin!"
    }

    @IBAction func pinAction(_ sender: Any) {
        let numberAlert=UIHelper.createAlert(keyboard:.numberPad,text:"Enter the pin:",result: {result in
            let pin=Int(result)!
            self.accessory.sensorPin=pin
            self.pinLabel.text="Used Pin: \(pin)"
            self.pinButton.setTitle("Change Value", for: .normal)
        })
        self.present(numberAlert, animated: true, completion: nil) //start pin popup
    }
    
    @IBAction func analogAction(_ sender: Any) {
        let numberAlert=UIHelper.createAlert(keyboard:.numberPad,text:"Enter the pin:",result: {result in
            let reference = Int(result)!
            self.accessory.analogReference=reference
            self.analogLabel.text="Analog Reference: \(reference)"
            self.analogButton.setTitle("Change Value", for: .normal)
        })
        self.present(numberAlert, animated: true, completion: nil) //start reference popup
    }
    @IBAction func finishAction(_ sender: Any) {
        if self.accessory.sensorPin != nil{
            if(!editMode){
                Database.shared.accessories.append(accessory)
            }
            Database.shared.save()
            self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        }
}
    

}
