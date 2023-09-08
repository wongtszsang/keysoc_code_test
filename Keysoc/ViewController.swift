//
//  ViewController.swift
//  Keysoc
//
//  Created by Wong Tsz Sang on 8/9/2023.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var songArray: [songObject] = []
    
    var currentPage = 0
    var songPerPage = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        retrieveSongList()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == songArray.count{
            return 75
        } else {
            return 110
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row < songArray.count){
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! customTableCell
            
            cell.label_trackName.text = "\(songArray[indexPath.row].trackName)"
            cell.label_artistName.text = "\(songArray[indexPath.row].artistName)"
            
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
    
    func retrieveSongList(){
        guard let url = URL(string: "https://itunes.apple.com/search?term=jack+johnson&offset=\(currentPage * songPerPage)&limit=\(songPerPage)") else{
            return
        }
        
//        entity=allArtist&attribute=allArtistTerm

        let task = URLSession.shared.dataTask(with: url) {
          (data, response, error) in

        if let data = data {
            do {
                let decodedResponse = try JSONDecoder().decode(songJsonResult.self, from: data)
                DispatchQueue.main.async {
                    self.songArray = decodedResponse.results
                    self.tableView.reloadData()
                }
            } catch {
                print("error: ", error)
            }
                return
            }
        }

        task.resume()
    }
}



class customTableCell: UITableViewCell {
    @IBOutlet weak var imageview_thumbnail: UIImageView!
    @IBOutlet weak var label_trackName: UILabel!
    @IBOutlet weak var label_artistName: UILabel!
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
