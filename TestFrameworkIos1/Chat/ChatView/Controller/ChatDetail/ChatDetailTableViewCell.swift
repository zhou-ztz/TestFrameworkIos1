// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import UIKit

class ChatDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var switcher: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()

        cellTitle.font = UIFont.systemFont(ofSize: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(title: String) {
        cellTitle.text = title
    }
    
}
