//
//  TBCell_LocInput.swift
//  Jolly
//
//  Created by hasan milli on 25.11.2020.
//  Copyright © 2020 hasan milli. All rights reserved.
//

import UIKit

class tbcell_Item: UITableViewCell {
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblRepoName: UILabel!
    @IBOutlet weak var btnAvatar: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnAvatar.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
