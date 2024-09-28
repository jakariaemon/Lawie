//
//  ChatController.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 5/10/23.
//

import UIKit
import PKHUD

class ChatController: BaseViewController {
    static let TAG = "ChatControllerID"
    
    @IBOutlet private weak var containerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var chatListView: UITableView!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var textField: UITextView!
    @IBOutlet private weak var attachmentButton: UIButton!
    @IBOutlet private weak var attachmentConstraint: NSLayoutConstraint!
    
    private let viewModel = ChatViewModel()
    private var deviceId = Utility.shared.getDeviceId()
    private let chatFieldPlaceholder = "Start new chat"
    private var selectedStar = 0
    private var reasonText = ""
    
    private var currentRequestId = 0
    
    var adapterId = ""
    var isChatTrial = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupTableView()
        
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        setupViewModel()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.isChatTrial && self.sharedUserDefaults.freeTrialCount >= 5 {
                self.showFreeTrialOver()
                return
            }
            self.textField.becomeFirstResponder()
        }
    }
    
    private func showFreeTrialOver() {
        let title = "Warning"
        let message = "Your free trial of 5 messages is over. Please subscribe to interact more."
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let messageAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        let attributedMessage = NSAttributedString(string: message, attributes: messageAttributes)
        
        // Set the attributed strings to the alert controller
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        let backgroundColor = UIColor.primaryBackground
        let backView = alertController.view.subviews.first?.subviews.first?.subviews.first
        backView?.backgroundColor = backgroundColor
        
        let okAction = UIAlertAction(title: "OK", style: .default ) {_ in
            alertController.dismiss(animated: true) {
                self.goBack()
            }
        }
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupViewModel() {
        viewModel.bindMessagesToController = {
            Utility.shared.hideLoadingActivity()
            self.chatListView.reloadData()
        }
        viewModel.bindResponseToController = {
            self.chatListView.reloadData()
        }
    }
    
    private func setupTableView() {
        chatListView.register(UINib(nibName: "SenderTextCell", bundle: nil), forCellReuseIdentifier: SenderTextCell.TAG)
        chatListView.register(UINib(nibName: "ReceiverTextCell", bundle: nil), forCellReuseIdentifier: ReceiverTextCell.TAG)
        
        chatListView.delegate = self
        chatListView.dataSource = self
        
        chatListView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    private func disableSendButton() {
        sendButton.isEnabled = false
        sendButton.backgroundColor = UIColor(named: "ColorWhite10")
    }
    
    private func enableSendButton() {
        sendButton.isEnabled = true
        sendButton.backgroundColor = UIColor(named: "ColorAccent")
    }
    
    private func showAttachment() {
        attachmentButton.isHidden = false
        attachmentConstraint.constant = 38
    }
    
    private func hideAttachment() {
        attachmentButton.isHidden = true
        attachmentConstraint.constant = 0
    }
    
    @IBAction func onSendPressed(_ sender: Any) {
        if self.isChatTrial {
            if self.sharedUserDefaults.freeTrialCount >= 5 {
                self.showFreeTrialOver()
                return
            }
            
            self.sharedUserDefaults.freeTrialCount = self.sharedUserDefaults.freeTrialCount + 1
        }
        
        currentRequestId += 1
        
        let message = ConversationItem(
            userId: "\(sharedUserDefaults.userID)",
            conversationId: "\(sharedUserDefaults.userID)",
            requestId: "\(currentRequestId)",
            deviceId: deviceId,
            subscription: false,
            message: textField.text,
            adapterId: adapterId,
            response: "",
            timestamp: "")
        
        viewModel.messages.insert(message, at: 0)
        viewModel.sendMessage(message: message)
        
        textField.text = ""
        textViewDidChange(textField)
        chatListView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}


extension ChatController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: SenderTextCell.TAG, for: indexPath) as! SenderTextCell
        cell.setupView(item: item)
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}


extension ChatController: UIViewControllerTransitioningDelegate {
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let offset = keyboardSize.height - 32
            
            UIView.animate(withDuration: 0.6) {
                self.containerBottomConstraint.constant = offset
                self.view.layoutSubviews()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.6) {
            self.containerBottomConstraint.constant = 0
        }
    }
}


extension ChatController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight()
        
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if sendButton.isEnabled {
                disableSendButton()
            }
            return
        }
        
        if !sendButton.isEnabled {
            enableSendButton()
        }
    }
    
    func adjustTextViewHeight() {
        let fixedWidth = textField.frame.size.width
        let newSize = textField.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        if newSize.height > 100 {
            textField.isScrollEnabled = true
            
        } else {
            textField.isScrollEnabled = false
            containerHeightConstraint.constant = newSize.height + 24
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        hideAttachment()
        
        if textView.text == chatFieldPlaceholder {
            textView.text = ""
            textView.textColor = UIColor(named: "ColorWhite")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        showAttachment()
        
        if textView.text.isEmpty {
            textView.text = chatFieldPlaceholder
            textView.textColor = UIColor(named: "ColorBorder")
        }
    }
    
}
