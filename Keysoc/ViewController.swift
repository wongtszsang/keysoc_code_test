//
//  ViewController.swift
//  Keysoc
//
//  Created by Wong Tsz Sang on 8/9/2023.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, filterViewControllerDelegate {
    
    
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var songArray: [songObject] = []
    
    var currentPage = -1
    var songPerPage = 20
    
    var favSong: [songObject] = []
    var favSongID: [Int] = []
    
    var selectedCountryCode = "US"
    var selectedMedia = "Music"
    
    var keyword = ""
    
    
    var retrieveMore = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // For removing useless top and bottom border
        searchBar.backgroundImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Reload tableview when display
        // the logic is moved to viewWillAppear to handle data refresh after tab switching
        if let data = UserDefaults.standard.object(forKey: "favSong") as? Data,
           let temparray = try? JSONDecoder().decode([songObject].self, from: data) {
            favSong = temparray
        }
        if let temparray = userDefaults.object(forKey: "favSongID") as? [Int] {
            favSongID = temparray
        }
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(retrieveMore){
            return songArray.count + 1
        }
        else if songArray.count == 0 {
            return 1
        } else {
            return songArray.count
        }
            
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == songArray.count{
            return 75
        } else {
            return 110
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if songArray.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noResultCell", for: indexPath) as! customTableCellNoResult
            
            let language = Bundle.main.preferredLocalizations.first! as NSString
            var noSongText = "No Result"
            if language == "zh-Hant" {
                noSongText = "沒有結果"
            } else if language == "zh-Hans" {
                noSongText = "没有结果"
            }
            cell.label_noresult.text = noSongText
            return cell
        } else if(indexPath.row < songArray.count){
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! customTableCell
            
            cell.label_trackName.text = "\(songArray[indexPath.row].trackName)"
            cell.label_artistName.text = "\(songArray[indexPath.row].artistName)"
            
            if(favSongID.contains(songArray[indexPath.row].trackId)){
                if #available(iOS 13.0, *) {
                    cell.imageview_fav.image = UIImage(systemName: "heart.fill")
                } else {
                    cell.imageview_fav.image = UIImage(named: "heart-fill")
                }
                cell.imageview_fav.tintColor = .red
            } else {
                if #available(iOS 13.0, *) {
                    cell.imageview_fav.image = UIImage(systemName: "heart")
                } else {
                    cell.imageview_fav.image = UIImage(named: "heart")
                }
                cell.imageview_fav.tintColor = .lightGray
            }
            
            cell.button_fav.tag = indexPath.row
            
    //        cell.imageview_thumbnail.image = UIImage(named: "placeholder")
            cell.imageview_thumbnail.downloadImage(link: songArray[indexPath.row].artworkUrl100, contentMode: .scaleAspectFit)

            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadMoreCell", for: indexPath) as! customTableCell2
            cell.loadingIndicator.startAnimating()
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row == songArray.count){
            currentPage += 1
            retrieveSongList()
        }
    }
    @IBAction func favButtonPressed(_ sender: UIButton) {
        
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! customTableCell
        
        var isFav = false
        if let index = favSongID.firstIndex(of: songArray[sender.tag].trackId){
            favSong.remove(at: index)
            favSongID.remove(at: index)
            
            if #available(iOS 13.0, *) {
                cell.imageview_fav.image = UIImage(systemName: "heart")
            } else {
                cell.imageview_fav.image = UIImage(named: "heart")
            }
            cell.imageview_fav.tintColor = .lightGray
        } else {
            isFav = true
            favSong.append(songArray[sender.tag])
            favSongID.append(songArray[sender.tag].trackId)
            
            if #available(iOS 13.0, *) {
                cell.imageview_fav.image = UIImage(systemName: "heart.fill")
            } else {
                cell.imageview_fav.image = UIImage(named: "heart-fill")
            }
            cell.imageview_fav.tintColor = .red
        }
        
        if let encodedFavSong = try? JSONEncoder().encode(favSong) {
            userDefaults.set(encodedFavSong, forKey: "favSong")
        }
        userDefaults.set(favSongID, forKey: "favSongID")
        
        if isFav {
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                cell.imageview_fav.transform = CGAffineTransform.identity.scaledBy(x: 2, y: 2)
             }) { (finished) in
                 UIView.animate(withDuration: 0.2, animations: {
                     cell.imageview_fav.transform = CGAffineTransform.identity
               })
            }
        }
        
    }
    
    
    
    func retrieveSongList(){
        var urlKeyword = keyword
        if urlKeyword.isEmpty{
            urlKeyword = "a"
        }
        
        urlKeyword = urlKeyword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(urlKeyword)&type=songs&media=\(selectedMedia.lowercased())&offset=\(currentPage * songPerPage)&limit=\(songPerPage)&country=\(selectedCountryCode)") else{
            return
        }

        let task = URLSession.shared.dataTask(with: url) {
          (data, response, error) in

        if let data = data {
            do {
                let decodedResponse = try JSONDecoder().decode(songJsonResult.self, from: data)
                DispatchQueue.main.async {
                    if(decodedResponse.results.count > 0){
                        self.songArray.append(contentsOf: decodedResponse.results)

                        self.songArray = self.songArray
                        var indexPaths = [IndexPath]()
                        for i in self.songArray.count-20...self.songArray.count - 1 {
                            indexPaths.append(IndexPath(row: i, section: 0))
                        }
                        self.tableView.insertRows(at: indexPaths, with: .bottom)
                    }
                    
                    // Stop retriving when it reach the end
                    if(decodedResponse.results.count < self.songPerPage){
                        self.retrieveMore = false
                        // remove last row
                        if self.songArray.count > 0 {
                            self.tableView.deleteRows(at: [IndexPath(row: self.songArray.count, section: 0)], with: .bottom)
                        }
                    }
                }
            } catch {
                print("error: ", error)
            }
                return
            }
        }
        task.resume()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        retrieveMore = true
        if #available(iOS 13.0, *) {
            keyword = searchBar.searchTextField.text ?? ""
        } else {
            keyword = searchBar.text ?? ""
        }
        // remove all previous result and perform search
        songArray.removeAll()
        currentPage = -1
        tableView.reloadData()
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.resignFirstResponder()
        } else {
            searchBar.resignFirstResponder()
        }
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showFilter", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFilter" {
            let vc = segue.destination as! filterViewController
            vc.selectedCountry = selectedCountryCode
            vc.delegate = self
        }
    }
    
    func confirmFilter(return_country: String, return_media: String) {
        // set country and media type
        selectedCountryCode = return_country
        selectedMedia = return_media
        
        // remove all previous result and perform search
        songArray.removeAll()
        currentPage = -1
        tableView.reloadData()
    }
    
}



class customTableCell: UITableViewCell {
    @IBOutlet weak var imageview_thumbnail: UIImageView!
    @IBOutlet weak var label_trackName: UILabel!
    @IBOutlet weak var label_artistName: UILabel!
    @IBOutlet weak var imageview_fav: UIImageView!
    @IBOutlet weak var button_fav: UIButton!
}

class customTableCell2: UITableViewCell {
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
}

class customTableCellNoResult: UITableViewCell {
    @IBOutlet weak var label_noresult: UILabel!

}

extension UIImageView {
    func downloadImage(link:String, contentMode: UIView.ContentMode) {
        URLSession.shared.dataTask( with: NSURL(string:link)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                self.contentMode =  contentMode
                if let data = data { self.image = UIImage(data: data) }
            }
        }).resume()
    }
}
