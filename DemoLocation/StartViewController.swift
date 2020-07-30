//
//  StartViewController.swift
//  DemoLocation
//
//  Created by Berkay Sebat on 7/29/20.
//  Copyright © 2020 SoilConnect. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var data = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadBullshit()
    }
    func loadBullshit() {
        
        let urlString = "https://pokeapi.co/api/v2/pokemon/ditto"
        guard let url = URL.init(string: urlString) else {
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                       print("unable to connect to server")
                       return
                       
                   }
                   if let error = error {
                       print("error connecting to server:\(error.localizedDescription)")
                       return
                   }
           
            do {
                
                if let json = try? JSONSerialization.jsonObject(with: data!, options:[]) as? [String:Any]{
                    if let dict = json["abilities"] as? [Any] {
                        if let array = dict[0] as? [String:AnyObject] {
                            if let ability = array["ability"] as? [String:AnyObject] {
                                if let string = ability["name"] as? String {
                                    self.data.append(string)
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                     self.tableView.reloadData()
                }
            } catch let error as NSError {
                print(error)
            }
        }.resume()
    }
}
extension StartViewController: UITableViewDelegate {
    
}
extension StartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init()
        if indexPath.row <= data.count-1 {
            cell.textLabel?.text = data[indexPath.row]
        }
        return cell
    }
    
    
}
