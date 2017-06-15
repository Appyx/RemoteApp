//
//  AccessoriesViewController.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 31/01/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

class AccessoriesViewController: UIViewController {
    
    var tableHandler:TableViewHandler!

    @IBOutlet var editButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableHandler=TableViewHandler(cellIdentifier: "accessory",data: {return Database.shared.getAccessoryNames()})
        tableView.dataSource=tableHandler
        tableView.delegate=tableHandler
        
        tableHandler.deleteActionClosure={index in
            Database.shared.accessories.remove(at: index)
            self.tableHandler.update()
        }
        tableHandler.selectActionClosure={ index in
            self.performSegue(withIdentifier: "showAccessoryDetail", sender: index)
        }
    }
    @IBAction func editAction(_ sender: Any) {
        if tableView.isEditing==true{
            tableHandler.isEditing=false
            tableView.setEditing(false, animated: true)
            editButton.setTitle("Edit", for: UIControlState.normal)
            Database.shared.save()
        }else{
            tableHandler.isEditing=true
            tableView.setEditing(true, animated: true)
            editButton.setTitle("Done", for: UIControlState.normal)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        Database.shared.refresh(callback: {
            DispatchQueue.main.async {
                self.tableHandler.update()
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id=segue.identifier{
            if id == "addAccessorySegue" {
                (segue.destination as! AssistantViewController).type=AssistantType.Accessory
            }
            if id == "showAccessoryDetail"{
                (segue.destination as! AccessoryDetailViewController).accessory=Database.shared.accessories[sender as! Int]
            }
            
        }
    }

}
