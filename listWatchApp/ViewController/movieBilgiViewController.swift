//
//  movieInfoViewController.swift
//  listWatchApp
//
//  Created by Alperen Kavuk on 7.03.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import AVKit
import AVFoundation


extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}


class movieBilgiViewController: UIViewController , AVPlayerViewControllerDelegate{

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    var video:videoPlay?
    var player : AVPlayer?
    var playerViewController: AVPlayerViewController?
    
    var film:Result?
    var api = aramaViewController()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerViewController?.delegate = self
        configureItems()
        movioInfo()
        
        
    }
    
    private func configureItems(){
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "list.bullet.rectangle"), style: UIBarButtonItem.Style.done, target: self, action: #selector(saveWatchData)),
            UIBarButtonItem(image: UIImage(systemName: "heart"), style: UIBarButtonItem.Style.done, target: self, action: #selector(saveLikeData))

        ]
    }
    
    
    
    @IBAction func buttonVideoClicked(_ sender: Any) {
        
        //film!.id
        //505642
        let movieId = 505642
        let apiKey = "d8cc792aeb02fbe6d958a6c58a962a59"
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId)?api_key=\(apiKey)&append_to_response=videos"
        guard let url = URL(string: urlString) else {
            print("IGeçerli URL")
                       return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("Error")
            } else {
                if let content = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any]
                        
                        if let videos = json!["videos"] as? [String:Any] {
                            if let results = videos["results"] as? [[String:Any]] {
                                if let key = results[0]["key"] as? String {
                                    
                                    DispatchQueue.main.async {
                                        let videoURL = URL(string: "https://www.youtube.com/watch?v=\(key)")
                                        self.player = AVPlayer(url: videoURL!)
                                        let playerViewController = AVPlayerViewController()
                                        self.playerViewController?.player = self.player
                                        self.present(playerViewController, animated: true ){
                                            self.player?.play()
                                        }
                                    }
                                    
                                }
                            }
                        }
                        
                    } catch {
                        print("Error")
                    }
                }
            }
        }

        task.resume()
        
        /*player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true ){
            self.player?.play()
        }*/
        
    }
    

    func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        player?.play()
    }
    
    
    
    
    @objc func saveWatchData(){
        let imgurl = "https://image.tmdb.org/t/p/w500/"+((film?.posterPath)!)
        let url = URL(string: imgurl)
        imageView.downloaded(from: url! )
        
        let db = Firestore.firestore()
        let watchRef = db.collection("Watch")
        let query = watchRef.whereField("movieTitle", in: [title])
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                // Hata oluştu
            } else if querySnapshot?.isEmpty == false {
                // Veritabanında belirtilen alana sahip bir belge var
                let alert = UIAlertController(title: "Error", message: "Bu Film listenize kayıtlıdır", preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                
            } else {
                   watchRef.addDocument(data: ["movieTitle": self.film?.originalTitle ?? "Error", "imgUrl": imgurl, "postedBy": Auth.auth().currentUser?.email!]) { error in
                    if let error = error {
                        print("Hata oluştu: \(error.localizedDescription)")
                    } else {
                        print("Veri başarıyla eklendi.")
                        
                        
                    }
                }
            }
        }
        
    }
    
    @objc func saveLikeData(){
        let imgurl = "https://image.tmdb.org/t/p/w500/"+((film?.posterPath)!)
        let url = URL(string: imgurl)
        imageView.downloaded(from: url!)
        let db = Firestore.firestore()
        let watchRef = db.collection("Like")
        let query = watchRef.whereField("movieTitle", in: [title])
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                // Hata oluştu
            } else if querySnapshot?.isEmpty == false {
                // Veritabanında belirtilen alana sahip bir belge var
                let alert = UIAlertController(title: "Error", message: "Bu Film listenize kayıtlıdır", preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
                
            } else {
                watchRef.addDocument(data: ["movieTitle": self.film?.originalTitle ?? "Error", "imgUrl": imgurl, "postedBy": Auth.auth().currentUser?.email!]) { error in
                    if let error = error {
                        print("Hata oluştu: \(error.localizedDescription)")
                    } else {
                        print("Veri başarıyla eklendi.")
                        
                    }
                }
            }
        }
    }
    
    
    
    
    func movioInfo(){
        infoTextView.text = film?.overview
        let populartiyDouble = film?.voteAverage
        label.text = String(populartiyDouble!) ?? ""
        title = film?.originalTitle
        let imgurlString = "https://image.tmdb.org/t/p/w500/"+((film?.posterPath)!)
        let url = URL(string: imgurlString)
        imageView.downloaded(from: url! )
      
    
    

}
}
