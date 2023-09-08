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
    var filteredSongArray: [songObject] = []
    
    var currentPage = -1
    var songPerPage = 20
    
    var favSong: [songObject] = []
    var favSongID: [Int] = []
    
    var country_All: [String] = []
    var country_Filter: [String] = []
    var keyword = ""
    
    
    var retrieveMore = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if let data = UserDefaults.standard.object(forKey: "favSong") as? Data,
           let temparray = try? JSONDecoder().decode([songObject].self, from: data) {
            favSong = temparray
        }
        if let temparray = userDefaults.object(forKey: "favSongID") as? [Int] {
            favSongID = temparray
        }
        
        print(favSong)
        
        print(favSongID)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(retrieveMore){
            return filteredSongArray.count + 1
        }
        else {
            return filteredSongArray.count
        }
            
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == filteredSongArray.count{
            return 75
        } else {
            return 110
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row < filteredSongArray.count){
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! customTableCell
            
            cell.label_trackName.text = "\(filteredSongArray[indexPath.row].trackName)"
            cell.label_artistName.text = "\(filteredSongArray[indexPath.row].artistName)"
            
            if(favSongID.contains(filteredSongArray[indexPath.row].trackId)){
                cell.imageview_fav.image = UIImage(systemName: "heart.fill")
                cell.imageview_fav.tintColor = .red
            } else {
                cell.imageview_fav.image = UIImage(systemName: "heart")
                cell.imageview_fav.tintColor = .lightGray
            }
            
            cell.button_fav.tag = indexPath.row
            
    //        cell.imageview_thumbnail.image = UIImage(named: "placeholder")
            cell.imageview_thumbnail.downloadImage(link: filteredSongArray[indexPath.row].artworkUrl100, contentMode: .scaleAspectFit)

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
        if(indexPath.row == filteredSongArray.count){
            currentPage += 1
            retrieveSongList()
        }
    }
    @IBAction func favButtonPressed(_ sender: UIButton) {
        
        if let index = favSongID.firstIndex(of: filteredSongArray[sender.tag].trackId){
            favSong.remove(at: index)
            favSongID.remove(at: index)
            
        } else {
            favSong.append(filteredSongArray[sender.tag])
            favSongID.append(filteredSongArray[sender.tag].trackId)
        }
        
        if let encodedFavSong = try? JSONEncoder().encode(favSong) {
            userDefaults.set(encodedFavSong, forKey: "favSong")
        }
        userDefaults.set(favSongID, forKey: "favSongID")
        
        tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .fade)
    }
    
    
    
    func retrieveSongList(){
        var urlKeyword = keyword
        if urlKeyword.isEmpty{
            urlKeyword = "a"
        }
        
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(urlKeyword)&entity=song&offset=\(currentPage * songPerPage)&limit=\(songPerPage)") else{
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

                        self.filteredSongArray = self.songArray
                        var indexPaths = [IndexPath]()
                        for i in self.songArray.count-20...self.songArray.count - 1 {
                            indexPaths.append(IndexPath(row: i, section: 0))
                        }
                        self.tableView.insertRows(at: indexPaths, with: .bottom)
                    }
                    
                    if(decodedResponse.results.count < self.songPerPage){
                        self.retrieveMore = false
                        self.tableView.deleteRows(at: [IndexPath(row: self.songArray.count, section: 0)], with: .bottom)
                    }
                    self.songArray[5].country = "UK"
                    
                    self.country_All = Array(Set(self.songArray.map { $0.country }))
                    self.country_Filter = self.country_All
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
        keyword = searchBar.searchTextField.text ?? ""
        songArray.removeAll()
        currentPage = -1
        tableView.reloadData()
        searchBar.searchTextField.resignFirstResponder()
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showFilter", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFilter" {
            let vc = segue.destination as! filterViewController
            vc.country_All = self.country_All
            vc.country_Filter = self.country_Filter
            vc.delegate = self
        }
    }
    
    func confirmFilter(return_country: [String]) {
        country_Filter = return_country
        retrieveMore = false
        filteredSongArray = songArray.filter({country_Filter.contains($0.country)})
        tableView.reloadData()
    }
    func resetFilter() {
        country_Filter = country_All
        retrieveMore = true
        filteredSongArray = songArray
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
