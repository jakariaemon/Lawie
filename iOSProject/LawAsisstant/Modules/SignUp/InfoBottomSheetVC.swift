//
//  InfoBottomSheetVC.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/08/31.
//

import UIKit

class InfoBottomSheetVC: UIViewController {
    @IBOutlet private weak var infoTitleLabel: UILabel!
    @IBOutlet private weak var infoDetailsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func okBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    func setupInfo(title: String, description: String) {
        infoTitleLabel.text = title
        infoDetailsLabel.text = description
    }
    
}
