//
//  likeTableViewCell.swift
//  listWatchApp
//
//  Created by Alperen Kavuk on 12.03.2023.
//

import UIKit

class likeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageV: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    func loadImageFromURL(urlString: String) {
           if let url = URL(string: urlString) {
               DispatchQueue.global().async { [weak self] in
                   if let data = try? Data(contentsOf: url) {
                       if let image = UIImage(data: data) {
                           DispatchQueue.main.async {
                               self?.imageV.image = image
                           }
                       }
                   }
               }
           }
       }

}
