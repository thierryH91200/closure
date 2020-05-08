//
//  ParamSimpleController.swift
//  closure
//
//  Created by thierry hentic on 03/05/2020.
//  Copyright © 2020 thierry hentic. All rights reserved.
//

import AppKit

struct User : Decodable {
    var id: Int?
    var email: String?
    var first_name: String?
    var last_name: String?
    var avatar: String?
}

typealias completionParamSimple = (User?, Error?) -> Void


class ParamSimpleController: NSViewController {
    
    @IBOutlet weak var firstName: NSTextField!
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var emailLabel: NSTextField!
    @IBOutlet weak var image: NSImageView!
    
    var id = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        loadData(id : id)
    }
    
    func loadData(id : Int) {
        
        fetchUser(userID: id, userCompletionHandler: { user, error in
            
            if let user = user {
                DispatchQueue.main.async(execute: {() -> Void in
                    
                    self.nameLabel.stringValue = user.last_name ?? "empty"
                    self.firstName.stringValue = user.first_name ?? "empty"
                    self.emailLabel.stringValue = user.email ?? "empty"
                    let url = URL(string:  user.avatar!)
                    let image = NSImage(contentsOf: url!)
                    self.image.image = image
                })
            }
        })
    }
    
    func fetchUser(userID: Int, userCompletionHandler: @escaping completionParamSimple) {
        let url = URL(string: "https://reqres.in/api/users/\(userID)")!
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            guard let data = data else { return }
            do {
                // parse json data and return it
                let decoder = JSONDecoder()
                let jsonDict = try decoder.decode([String: User].self, from: data)
                if let userData = jsonDict["data"] {
                    userCompletionHandler(userData, nil)
                }
                
            } catch let parseErr {
                print("JSON Parsing Error", parseErr)
                userCompletionHandler(nil, parseErr)
            }
        })
        task.resume()
        // function will end here and return
        // then after receiving HTTP response, the completionHandler will be called
    }
    
    @IBAction func leftAction(_ sender: Any) {
        id -= 1
        loadData(id : id)
    }
    
    @IBAction func rightAction(_ sender: Any) {
        id += 1
        loadData(id : id)
    }
}
