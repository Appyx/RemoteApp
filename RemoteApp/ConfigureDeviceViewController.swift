//
//  ConfigureDeviceViewController.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 04/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

class ConfigureDeviceViewController: UIViewController {

    var accessory:AccessoryConfiguration!
    
    static var state = -1
    var chosenLevel = -1
    var editMode=false;
    
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var maxValueButton: UIButton!
    @IBOutlet var maxValueLabel: UILabel!
    @IBOutlet var maxValueView: UIView!
    @IBOutlet var offButton: UIButton!
    @IBOutlet var onButton: UIButton!
    @IBOutlet var offLabel: UILabel!
    @IBOutlet var onLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    
    let statlessText="Command for triggering the device: "
    let onText="Command for ON: "
    let offText="Command for OFF: "
    let stepUpText="Command for stepping UP: "
    let stepDownText="Command for stepping DOWN: "
    let maxValueText="Max. value for control (optional): "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ConfigureDeviceViewController.state == -1{
            if(chosenLevel == 0){
                ConfigureDeviceViewController.state=0
            }else{
                ConfigureDeviceViewController.state=1
            }
        }
        
        if chosenLevel == ConfigureDeviceViewController.state{
            nextButton.setTitle("Finish", for: .normal)
        }
        
        switch ConfigureDeviceViewController.state {
        case 0:
            descriptionLabel.text="The device will be always on without changing its state. So please choose an action for triggering the device:"
            onLabel.text=statlessText
            maxValueView.isHidden=true
            offButton.isHidden=true
            offLabel.isHidden=true
            break
        case 1:
            maxValueView.isHidden=true
            descriptionLabel.text="Choose the commands for switching the device's state:"
            onLabel.text=onText
            offLabel.text=offText
            break
        case 2:
            descriptionLabel.text="Choose the commands for stepping between 0% and 100%. You can also set a maximum value which conforms to 100%:"
            onLabel.text=stepUpText
            offLabel.text=stepDownText
            maxValueLabel.text=maxValueText
            break
        case 3:
            maxValueView.isHidden=true
            descriptionLabel.text="Choose the commands for switching the device's state:"
            onLabel.text=onText
            offLabel.text=offText
            break
        default:
            break
        }

    }
    
    func startChooser(_ closure:@escaping (Remote)->()){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CommandChooser") as! CommandChooserViewController
        controller.accessory=accessory
        controller.resultClosure={command,remoteName in
            let remote = Remote(withName:remoteName)
            remote.addCommand(command)
            closure(remote)
        }
        self.present(controller, animated: true, completion: nil) //start command chooser
    }

    
    @IBAction func onAction(_ sender: Any) {
        startChooser({remote in
            
            switch ConfigureDeviceViewController.state {
            case 0:
                self.accessory.firstStateOnSignals=remote
                self.onLabel.text=self.onText+remote.commands[0].name
            case 1:
                self.accessory.firstStateOnSignals=remote
                self.onLabel.text=self.onText+remote.commands[0].name
            case 2:
                self.accessory.secondStateIncreaseSignals=remote
                self.onLabel.text=self.stepUpText+remote.commands[0].name
            case 3:
                self.accessory.thirdStateOnSignals=remote
                self.onLabel.text=self.onText+remote.commands[0].name
            default:
                break
            }
        })
    }
    
    

    @IBAction func offAction(_ sender: Any) {
        startChooser({remote in
            
            switch ConfigureDeviceViewController.state {
            case 1:
                self.accessory.firstStateOffSignals=remote
                self.offLabel.text=self.offText+remote.commands[0].name
            case 2:
                self.accessory.secondStateDecreaseSignals=remote
                self.offLabel.text=self.stepDownText+remote.commands[0].name
            case 3:
                self.accessory.thirdStateOffSignals=remote
                self.offLabel.text=self.offText+remote.commands[0].name
            default:
                break
            }
        })
    }
  
    @IBAction func maxValueAction(_ sender: Any) {
        let numberAlert=UIHelper.createAlert(keyboard:.numberPad,text:"Enter a value (default is 100):",result: {result in
            let value = Int(result)!
            self.accessory.secondStateMaxValue=value
            self.maxValueLabel.text="\(self.maxValueText)\(value)"
        })
        self.present(numberAlert, animated: true, completion: nil) //start max value popup
    }
    
    
    @IBAction func nextAction(_ sender: Any) {
        if ConfigureDeviceViewController.state == chosenLevel{
            accessory.usedStates=ConfigureDeviceViewController.state
            ConfigureDeviceViewController.state = -1
            if(!editMode){
                Database.shared.accessories.append(accessory)
            }
            Database.shared.save()
            self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        }else{
            switch ConfigureDeviceViewController.state {
            case 1:
                ConfigureDeviceViewController.state=2
                break
            case 2:
                ConfigureDeviceViewController.state=3
                break
            default:
                break
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ConfigureDevice") as! ConfigureDeviceViewController
            controller.accessory=self.accessory
            controller.chosenLevel=chosenLevel
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    
}
