//
//  searchViewController.swift
//  Keysoc
//
//  Created by Wong Tsz Sang on 8/9/2023.
//

import UIKit

class settingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    
    let language = Bundle.main.preferredLocalizations.first! as NSString
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableview.delegate = self
        tableview.dataSource = self
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            var version_string = "Version"
            if language == "zh-Hant" {
                version_string = "版本"
            } else if language == "zh-Hans" {
                version_string = "版本"
            }
            return version_string
        } else {
            var language_string = "Languagae"
            if language == "zh-Hant" {
                language_string = "語言"
            } else if language == "zh-Hans" {
                language_string = "语言"
            }
            return language_string
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! settingTableCell
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.label.text = "1.0"
        } else if indexPath.section == 1 && indexPath.row == 0 {
            var tempString = "Tap and go to setting to switch language"
            if language == "zh-Hant" {
                tempString = "點擊並進入設置以切換語言"
            } else if language == "zh-Hans" {
                tempString = "点击并进入设置以切换语言"
            }
            cell.label.text = tempString
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 0 {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
    }
    
    
    

}


class settingTableCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    

}
