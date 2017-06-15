//
//  AccessoryTypeViewController.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 04/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

class AccessoryTypeViewController: UIViewController {

    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var serviceTableView: UITableView!
    @IBOutlet var typeTableView: UITableView!
    
    var typeTableHandler:TableViewHandler!
    var serviceTableHandler:TableViewHandler!
    var accessory:AccessoryConfiguration!
    
    var chosenLevel:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabel.text="Choose an accessory type and then choose a available service:"
        
        let levels=Database.shared.levels
        
        typeTableHandler=TableViewHandler(cellIdentifier: "type",data: {return levels})
        typeTableView.dataSource=typeTableHandler
        typeTableView.delegate=typeTableHandler
        typeTableHandler.isSelectAble=true
        typeTableHandler.selectActionClosure={ index in
            self.chosenLevel=index-2
            self.serviceTableHandler.update()
        }
    
        serviceTableHandler=TableViewHandler(cellIdentifier: "service",data: {return Database.shared.getServiceforType(level: self.chosenLevel)})
        serviceTableHandler.title="Available Services:"
        serviceTableView.dataSource=serviceTableHandler
        serviceTableView.delegate=serviceTableHandler
        serviceTableHandler.selectActionClosure={ index in
            self.accessory.typeName=Database.shared.getServiceforType(level: self.chosenLevel)[index]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if self.chosenLevel < 0 { //sensor
                let controller = storyboard.instantiateViewController(withIdentifier: "ConfigureSensor") as! ConfigureSensorViewController
                controller.accessory=self.accessory
                self.present(controller, animated: true, completion: nil)
            }else{ //device
                let controller = storyboard.instantiateViewController(withIdentifier: "ConfigureDevice") as! ConfigureDeviceViewController
                controller.accessory=self.accessory
                controller.chosenLevel=self.chosenLevel
                self.present(controller, animated: true, completion: nil)
            }
        }

    }


}
