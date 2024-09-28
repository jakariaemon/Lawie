//
//  SenderTextCell.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 5/10/23.
//

import UIKit
import Lottie

class SenderTextCell: UITableViewCell {
    static let TAG = "SenderTextCellID"
    
    @IBOutlet private weak var sendMessageLabel: UILabel!
    @IBOutlet private weak var receivedMessageLabel: UILabel!
    @IBOutlet private weak var loadingView: UIView!
    @IBOutlet private weak var responseView: UIView!
    @IBOutlet private weak var animationView: LottieAnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupView(item: ConversationItem) {
        sendMessageLabel.text = item.message
        responseView.isHidden = item.response?.isEmpty ?? true
        loadingView.isHidden = !(item.response?.isEmpty ?? true)
        receivedMessageLabel.text = item.response ?? ""
        
        if item.response?.isEmpty == true {
            animationView.play()
            animationView.loopMode = .loop
            
        } else {
            animationView.stop()
        }
    }
}
