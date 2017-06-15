//
//  HTTPClient.swift
//  RemoteApp
//
//  Created by Robert Gstöttner on 31/01/2017.
//  Copyright © 2017 FH. All rights reserved.
//

import Foundation


class HTTPClient{
    static var serverUrl="10.0.0.97"
    static var serverPort="8888"
    
    private let type:RequestType
    private var json:[String: Any]?=nil
    
    
    init(forType: RequestType){
        type=forType;
    }
    init(forType:RequestType, jsonData:[String: Any]){
        type=forType;
        json=jsonData
    }
    
    func request(){
        request(response: {_ in})
    }
    
    func request(response handler: @escaping (_ json:[String:Any])->()){
        let url=URL(string: "http://\(HTTPClient.serverUrl):\(HTTPClient.serverPort)/\(type.rawValue)")!
        var request=URLRequest(url: url)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let data=json{
            request.httpMethod="POST"
            do{
                let jsonBody = try JSONSerialization.data(withJSONObject: data, options: [])
                request.httpBody = jsonBody
            }catch let error as NSError {
                print(error)
                
            }
        }else{
            request.httpMethod="GET"
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        session.dataTask(with: request, completionHandler: { data,response,error in
            if error == nil {
                do{
                    let parsedJson = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    handler(parsedJson)
                }catch let error as NSError {
                    print(error)
                }
            }else{
                print(error!)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "server_error"), object: nil)

            }
        }).resume()

    }
    
    enum RequestType:String{
        case info="info"
        case wait="wait"
        case waitAgain="waitAgain"
        case waitIP="waitIP"
        case waitCancel="waitCancel"
        case action="action"
        case save="save"
    }
    
}
