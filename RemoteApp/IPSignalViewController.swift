//
//  IPSignalViewController.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 06/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

class IPSignalViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var nameInput: UITextField!
    @IBOutlet var nextButton: UIButton!
    
    var recordedID:Int?
    var isEasyMode=false
    var remote:Remote!
    var tableHandler:TableViewHandler!
    var tableData:[String]=[]
    var jsonIDs:[Int]=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameInput.delegate=self
        tableHandler=TableViewHandler(cellIdentifier: "ipsignal",data:{return self.tableData})
        tableView.delegate=tableHandler
        tableView.dataSource=tableHandler
        tableHandler.isSelectAble=true
        
        nextButton.isHidden=isEasyMode
        
        tableHandler.selectActionClosure={index in
            self.recordedID=self.jsonIDs[index]
        }
        
        let client=HTTPClient(forType: HTTPClient.RequestType.waitIP)
        client.request(response: {json in
            let data=json["signals"] as! [[String:Any]]
            for entry in data{
                self.tableData.append(entry["name"] as! String)
                self.jsonIDs.append(entry["recordedID"] as! Int)
            }
            DispatchQueue.main.async {
                self.tableHandler.update()
            }
        })
    }

    
    @IBAction func nextAction(_ sender: Any) {
        if recordedID != nil && nameInput.text != nil && nameInput.text != ""{
            let command=Command(nameInput.text!)
            command.signal=recordedID
            remote.addCommand(command)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "IPSignal") as! IPSignalViewController
            controller.remote=remote
            controller.isEasyMode=isEasyMode
            self.present(controller, animated: true, completion: nil)
        }
    }

    @IBAction func finishAction(_ sender: Any) {
        if recordedID != nil && nameInput.text != nil && nameInput.text != ""{
            let command=Command(nameInput.text!)
            command.signal=recordedID
            remote.addCommand(command)
        }
        if isEasyMode{
            Database.shared.save()
            self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        }else{
            if remote.commands.count==0{
                self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
            }else{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "TouchpadConfiguration") as! TouchpadConfigurationViewController
                controller.remote=remote
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.resignFirstResponder()
        return false
    }

}
