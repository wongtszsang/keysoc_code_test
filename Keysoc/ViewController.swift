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
        return songArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! customTableCell
        
        cell.label_title.text = "\(songArray[indexPath.row].trackName)"
        
        return cell
        
    }
    
    func retrieveSongList(){
        guard let url = URL(string: "https://itunes.apple.com/search?term=jack+johnson&offset=20&limit=20") else{
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
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
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
    
    @IBOutlet weak var label_title: UILabel!
    
}

