//
//  LikeViewController.swift
//  listWatchApp
//
//  Created by Alperen Kavuk on 12.03.2023.
//

import UIKit
import FirebaseFirestore
import Firebase
import FirebaseAuth

class LikeViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{

    
    @IBOutlet weak var tableView: UITableView!
    var items = [(title: String, imageUrl: String, postedBy: String)]()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        var down = TableViewCell()
        getDataFromFirestore()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(likeTableViewCell.self, forCellReuseIdentifier: "cell")
          view.addSubview(tableView)
        tableView.reloadData()
               
              

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return items.count
      }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! likeTableViewCell
        let item = items[indexPath.row]
        cell.titleLabel.text = item.title
        // Load image asynchronously
        cell.loadImageFromURL(urlString: item.imageUrl)
        return cell

    }
    func getDataFromFirestore(){
        let db = Firestore.firestore()
        let usersRef = db.collection("Like")
        let query = usersRef.whereField("postedBy", in: [Auth.auth().currentUser?.email!])
        query.addSnapshotListener { [self] snapshot, error in
          if error != nil
              {
              print("error11")
          }
              else
              {
                  if snapshot?.isEmpty != true && snapshot != nil
                  {
                      self.items.removeAll()
                      for document in  snapshot!.documents {
                         
                          let data = document.data()
                          let title = data["movieTitle"] as? String ?? ""
                          print("title\(title)")
                          let imgUrl = data["imgUrl"] as? String ?? ""
                          print("imgurl")
                          let postedBy = data["postedBy"] as? String ?? ""
                          print("posted\(postedBy)")

                        self.items.append((title: title, imageUrl: imgUrl, postedBy: postedBy))
                          
                      

                      }
                      self.tableView.reloadData()
                     
                  }
                 
                  }
          
      }


        
    }
}
