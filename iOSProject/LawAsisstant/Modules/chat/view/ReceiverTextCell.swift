//
//  ReceiverTextCell.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 5/10/23.
//

import UIKit
import WebKit

class ReceiverTextCell: UITableViewCell {
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var chatTextLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    
    static let TAG = "ReceiverTextCellID"
    let shape = CAShapeLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupView(item: ConversationItem) {
        chatTextLabel.text = item.response
        timeLabel.text = "time"
    }
    
}
