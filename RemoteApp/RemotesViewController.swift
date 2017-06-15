//
//  RemotesViewController.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 31/01/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

class RemotesViewController: UIViewController {
    
    var tableHandler:TableViewHandler!
    

    @IBOutlet var editButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableHandler=TableViewHandler(cellIdentifier: "remote",data: {return Database.shared.getRemoteNames()})
        tableView.dataSource=tableHandler
        tableView.delegate=tableHandler
        tableHandler.selectActionClosure={ index in
            self.performSegue(withIdentifier: "showRemoteDetail", sender: index)
        }
        tableHandler.editActionClosure={index in
            let renameAlert=UIHelper.createAlert(text:"Enter the new name:",result: {newName in
                Database.shared.remotes[index].name=newName
                Database.shared.save()
                self.tableHandler.update()
            })
            self.present(renameAlert, animated: true, completion: nil)
        }
        tableHandler.deleteActionClosure={index in
            Database.shared.remotes.remove(at: index)
        }
        tableHandler.moveActionClosure={from,to in
            let entry=Database.shared.remotes.remove(at: from)
            Database.shared.remotes.insert(entry, at: to)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableHandler.update()
    }
  
    
    @IBAction func editAction(_ sender: Any) {
        if tableView.isEditing==true{
            tableHandler?.isEditing=false
            tableView.setEditing(false, animated: true)
            editButton.setTitle("Edit", for: UIControlState.normal)
            Database.shared.save()
        }else{
            tableHandler?.isEditing=true
            tableView.setEditing(true, animated: true)
            editButton.setTitle("Done", for: UIControlState.normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id=segue.identifier{
            if id == "addRemoteSegue" {
                (segue.destination as! AssistantViewController).type=AssistantType.Remote
            }
            if id == "showRemoteDetail"{
                let controller = segue.destination as! RemoteDetailViewController
                controller.remote=Database.shared.remotes[sender as! Int]
            }
        }
    }
}


