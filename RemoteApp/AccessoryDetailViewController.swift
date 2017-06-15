//
//  AccessoryDetailViewController.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 31/01/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

class AccessoryDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var accessory:AccessoryConfiguration!
    var tableData:[(String,[String])]=[]
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource=self
        tableView.delegate=self
        
        let generalInfo=("General Info",[
            "Name: \(accessory.name!)",
            "Type: \(accessory.typeName!)",
            "Level: \(Database.shared.levels[accessory.usedStates+2])",
            "UUID: \(accessory.uuid!)",
            "Username: \(accessory.username!)",
            "Port: \(accessory.port!)",
            ])
        tableData.append(generalInfo)
        
        switch accessory.usedStates {
        case -2:
            tableData.append(("State Info",[
                "Arduino Pin: \(accessory.sensorPin!)",
                "Analog Reference: \(accessory.analogReference ?? 0)",
                "Sensor Value: \(accessory.sensorValue ?? 0)",
                ]))
        case -1:
            tableData.append(("State",[
                "Arduino Pin: \(accessory.sensorPin!)",
                "Sensor Value: \(accessory.sensorValue!)",
                ]))
        case 3:
            var entry:[String]=[]
            if let value=accessory.thirdStateOnSignals{
                entry.append("ON: \(value.name).\(value.commands[0].name)")
            }else{
                entry.append("ON: No command has been set!")
            }
            if let value=accessory.thirdStateOffSignals{
                entry.append("OFF: \(value.name).\(value.commands[0].name)")
            }else{
                entry.append("OFF: No command has been set!")
            }
            tableData.append(("Level 3",entry))
            fallthrough
        case 2:
            var entry:[String]=[]
            if let value=accessory.secondStateIncreaseSignals{
                entry.append("Step UP: \(value.name).\(value.commands[0].name)")
            }else{
                entry.append("Step UP: No command has been set!")
            }
            if let value=accessory.secondStateDecreaseSignals{
                entry.append("Step DOWN: \(value.name).\(value.commands[0].name)")
            }else{
                entry.append("Step DOWN: No command has been set!")
            }
            entry.append("Max Value: \(accessory.secondStateMaxValue ?? 100)")
            tableData.append(("Level 2",entry))
            fallthrough
        case 1:
            var entry:[String]=[]
            if let value=accessory.firstStateOffSignals{
                entry.append("OFF: \(value.name).\(value.commands[0].name)")
            }else{
                entry.append("OFF: No command has been set!")
            }
            if let value=accessory.firstStateOnSignals{
                entry.append("ON: \(value.name).\(value.commands[0].name)")
            }else{
                entry.append("ON: No command has been set!")
            }
            tableData.append(("Level 1",entry))
        case 0:
            if let value=accessory.firstStateOnSignals{
                tableData.append(("Level 0",["ON: \(value.name).\(value.commands[0].name)"]))
            }else{
                tableData.append(("Level 0",["ON: No command has been set!"]))
            }
            fallthrough
        default:
            break
        }
        let first=tableData[0]
        tableData.remove(at: 0)
        tableData.reverse()
        tableData.insert(first, at: 0)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return tableData[section].1.count;
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell=tableView.dequeueReusableCell(withIdentifier: "accessoryInfo")! as UITableViewCell
        let label=cell.contentView.viewWithTag(100) as! UILabel
        label.text=tableData[indexPath.section].1[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableData[section].0
    }
    
    @IBAction func edit(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if self.accessory.usedStates < 0 { //sensor
            let controller = storyboard.instantiateViewController(withIdentifier: "ConfigureSensor") as! ConfigureSensorViewController
            controller.accessory=self.accessory
            controller.editMode=true
            self.present(controller, animated: true, completion: nil)
        }else{ //device
            let controller = storyboard.instantiateViewController(withIdentifier: "ConfigureDevice") as! ConfigureDeviceViewController
            controller.accessory=self.accessory
            controller.chosenLevel=self.accessory.usedStates
            controller.editMode=true
            self.present(controller, animated: true, completion: nil)
        }

    }
  
   
    
    
    
}
