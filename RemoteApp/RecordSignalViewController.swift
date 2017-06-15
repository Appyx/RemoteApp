//
//  RecordSignalViewController.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 01/02/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

class RecordSignalViewController: UIViewController, UITextFieldDelegate {
    
    var remote:Remote!
    var recordedID:Int?
    var isEasyMode=false

    @IBOutlet var nextButton: UIButton!
    @IBOutlet var waitingLabel: UILabel!
    @IBOutlet var waitingView: UIView!
    @IBOutlet var nameInput: UITextField!
    @IBOutlet var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client=HTTPClient(forType: HTTPClient.RequestType.wait)
        client.request(response: {json in
            self.recordedID=json["recordedID"] as? Int
            if let type=json["type"] as? String{
                DispatchQueue.main.async {
                    self.waitingLabel.text="Recorded \(type)-Signal"
                    self.waitingView.backgroundColor=UIColor.green
                }
            }
        })
        
        descriptionLabel.text="Please grab your physical remote control and press a key. Make sure to point in the direction of your receiver.\n\nPlease enter a name for the new key:"
        nameInput.delegate=self
        nextButton.isHidden=isEasyMode
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.resignFirstResponder()
        return false
    }
    
    
    @IBAction func finishButton(_ sender: Any) {
        if recordedID != nil && nameInput.text != nil && nameInput.text != ""{
            let command=Command(nameInput.text!)
            command.signal=recordedID
            remote.addCommand(command)
        }else{
            let client=HTTPClient(forType: HTTPClient.RequestType.waitCancel)
            client.request()
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
    
    @IBAction func ipButton(_ sender: Any) {
        let client=HTTPClient(forType: HTTPClient.RequestType.waitCancel)
        client.request()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "IPSignal") as! IPSignalViewController
        controller.remote=remote
        controller.isEasyMode=isEasyMode
        self.present(controller, animated: true, completion: nil)
    }
  
    @IBAction func testButton(_ sender: Any) {
        if let id=recordedID{
            let client=HTTPClient(forType: HTTPClient.RequestType.action,jsonData: ["signalIDs":[id]])
            client.request()
        }
        
    }
    @IBAction func repeatButton(_ sender: Any) {
        
        if recordedID != nil{
            self.waitingView.backgroundColor=UIColor.red
            self.waitingLabel.text="Waiting for Signal..."
            
            let client=HTTPClient(forType: HTTPClient.RequestType.waitAgain)
            client.request(response: {json in
                self.recordedID=json["recordedID"] as? Int
                let type=json["type"] as! String
                
                self.waitingLabel.text="Recorded \(type)-Signal with ID \(self.recordedID ?? 0)."
                self.waitingView.backgroundColor=UIColor.green
            })
        }
    }

    @IBAction func nextButton(_ sender: Any) {
        if recordedID != nil && nameInput.text != nil && nameInput.text != ""{
            let command=Command(nameInput.text!)
            command.signal=recordedID
            remote.addCommand(command)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "RecordSignal") as! RecordSignalViewController
            controller.remote=remote
            
            self.present(controller, animated: true, completion: nil)
        }
    }

}
