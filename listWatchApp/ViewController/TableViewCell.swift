//
//  TableViewCell.swift
//  listWatchApp
//
//  Created by Alperen Kavuk on 9.03.2023.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageV: UIImageView!
    
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
