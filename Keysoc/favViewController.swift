//
//  ViewController.swift
//  Keysoc
//
//  Created by Wong Tsz Sang on 8/9/2023.
//

import UIKit

class favViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var tableView: UITableView!
    
    var favSong: [songObject] = []
    var favSongID: [Int] = []
    
    var retrieveMore = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favSong.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! customTableCell
        
        cell.label_trackName.text = "\(favSong[indexPath.row].trackName )"
        cell.label_artistName.text = "\(favSong[indexPath.row].artistName)"
        
        cell.imageview_thumbnail.downloadImage(link: favSong[indexPath.row].artworkUrl100, contentMode: .scaleAspectFit)

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            let title = "Confirm to remove song from your favorite list?"
                        
            let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)

            let deleteAction = UIAlertAction(title: "Confirm", style: .destructive) { action in

                self.favSong.remove(at: indexPath.row)
                self.favSongID.remove(at: indexPath.row)
                    
                if let encodedFavSong = try? JSONEncoder().encode(self.favSong) {
                    self.userDefaults.set(encodedFavSong, forKey: "favSong")
                }
                self.userDefaults.set(self.favSongID, forKey: "favSongID")
                tableView.deleteRows(at: [indexPath], with: .left)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
}


