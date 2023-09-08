//
//  filterViewController.swift
//  Keysoc
//
//  Created by Wong Tsz Sang on 8/9/2023.
//

import UIKit

protocol filterViewControllerDelegate
{
    func confirmFilter(return_country : String, return_media: String)
}


class filterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var filter_tableview: UITableView!
    
    var delegate:filterViewControllerDelegate!

    
    var countryCode = ["US", "GB", "HK", "CN"]
    var countryName = ["United States", "United Kingdom", "Hong Kong", "China"]
    var selectedCountry = "US"

    var mediaType = ["Music", "Movie"]
    var mediaName = ["Music", "Movie"]
    var selectedMediaType = "Music"
    
    var labeltext_country = "Country"
    var labeltext_media = "Media"
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        filter_tableview.dataSource = self
        filter_tableview.delegate = self
        
        let language = Bundle.main.preferredLocalizations.first! as NSString
        if language == "zh-Hant" {
            countryCode = ["HK", "CN", "US", "GB"]
            countryName = ["香港", "中國", "美國", "英國"]
            mediaName = ["音樂", "電影"]
            labeltext_country = "地區"
            labeltext_media = "媒體類型"
        } else if language == "zh-Hans" {
            countryCode = ["CN", "HK", "US", "GB"]
            countryName = ["中国", "香港", "美国", "英国"]
            mediaName = ["音乐", "电影"]
            labeltext_country = "地区"
            labeltext_media = "媒体类型"
            
        }
        
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return labeltext_country
        } else if section == 1 {
            return labeltext_media
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return countryCode.count
        } else if section == 1 {
            return mediaType.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell") as! customFilterTableCell
            cell.label.text = "\(countryName[indexPath.row])"
            
            if selectedCountry == countryCode[indexPath.row]{
                cell.imageview_checkmark.isHidden = false
            } else {
                cell.imageview_checkmark.isHidden = true
            }
            
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell") as! customFilterTableCell
            cell.label.text = "\(mediaName[indexPath.row])"
            
            if selectedMediaType == mediaType[indexPath.row]{
                cell.imageview_checkmark.isHidden = false
            } else {
                cell.imageview_checkmark.isHidden = true
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell") as! customFilterTableCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            selectedCountry = countryCode[indexPath.row]
        } else if indexPath.section == 1{
            selectedMediaType = mediaType[indexPath.row]
        }
        tableView.reloadData()
        
        
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        delegate.confirmFilter(return_country: selectedCountry, return_media: selectedMediaType)
        self.dismiss(animated: true)
    }
    
    @IBAction func resetBtnPressed(_ sender: Any) {
        delegate.confirmFilter(return_country: "US", return_media: "Music")
        self.dismiss(animated: true)
    }

}




class customFilterTableCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageview_checkmark: UIImageView!
    
}

