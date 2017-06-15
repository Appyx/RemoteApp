//
//  AssistantViewController.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 01/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

class AssistantViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var nameInput: UITextField!
    @IBOutlet var welcomeLabel: UILabel!
    var type:AssistantType?

    override func viewDidLoad() {
        super.viewDidLoad()

        nameInput.delegate=self
        
        welcomeLabel.text="The Assistant will guide you through the process of configuring your \(type!.rawValue).\nPlease make sure that you are in range of your physical remote control.\n\nPlease enter a name for your device:"
    }
    
    @IBAction func startAction(_ sender: Any) {
        
        if(type==AssistantType.Remote){
            let remote=Remote(withName: nameInput.text ?? "UNDEFINED")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "RecordSignal") as! RecordSignalViewController
            controller.remote=remote
            self.present(controller, animated: true, completion: nil)
        }
        if(type==AssistantType.Accessory){
            let accessory=AccessoryConfiguration(withName: nameInput.text ?? "UNDEFINED")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "AccessoryType") as! AccessoryTypeViewController
            controller.accessory=accessory
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.resignFirstResponder()
        return false
    }

}

enum AssistantType:String{
    case Remote="remote"
    case Accessory="accessory"
}
