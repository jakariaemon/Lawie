//
//  OptionController.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 6/9/24.
//

import UIKit
import RevenueCat
import RevenueCatUI
import Lottie
import UniformTypeIdentifiers

class OptionController: BaseViewController {
    @IBOutlet private weak var topTitleLabel: UILabel!
    @IBOutlet private weak var dataTrainAnimation: LottieAnimationView!
    @IBOutlet private weak var tagLineLottieView: LottieAnimationView!
    @IBOutlet private weak var trainYourLawieView: CommonBackgroundView!
    @IBOutlet private weak var chatWithCustomTrainedLawieView: RoundedView!
    @IBOutlet private weak var statusLabelForAIGeneration: UILabel!
    @IBOutlet private weak var lawieIsReadyArrowImage: UIImageView!
    
    private var selectedFileData: Data?
    private var isDataUploading = false
    private var status: PdfProgressEnum = .started
    private var adapterName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabelText()
        setupLottiView()
    }
    
    @IBAction func onPredefinedPromptPressed(_ sender: Any) {
        if isDataUploading {
            return
        }
        navigationController?.pushViewController(router.chatController(), animated: true)
    }
    
    @IBAction func onCreatePromptPressed(_ sender: Any) {
        openDocument()
    }
    
    //MARK: -  Action for newly Generated Ai Model
    
    @IBAction func chatWithGeneratedAiModel(_ sender: UIButton) {
        if status == .completed{
            navigationController?.pushViewController(router.predefinedPromptController(), animated: true)
        }
    }
    
    @IBAction func aiModelListButtonPressed(_ sender: UIButton) {
        navigationController?.pushViewController(router.predefinedPromptController(), animated: true)
    }
}

extension OptionController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let selectedUrl = urls.first {
            uploadFile(fileURL: selectedUrl)
        }
    }
}

//MARK: - Private Extension for functions

private extension OptionController {
    func setupLabelText() {
        let startText = "Ask Your\n"
        let middleText = "Legal "
        let endText = "\nQueries To..."
        
        let startAttributedString = NSMutableAttributedString(string: startText, attributes: [
            .foregroundColor: UIColor(named: "ColorWhite") ?? .white,
            .font: UIFont.systemFont(ofSize: 32, weight: .medium)
        ])
        
        let middleAttributedString = NSMutableAttributedString(string: middleText, attributes: [
            .foregroundColor: UIColor(named: "ColorAccent") ?? .white,
            .font: UIFont.systemFont(ofSize: 32, weight: .medium)
        ])
        
        let endAttributedString = NSMutableAttributedString(string: endText, attributes: [
            .foregroundColor: UIColor(named: "ColorWhite") ?? .white,
            .font: UIFont.systemFont(ofSize: 32, weight: .medium)
        ])
        
        startAttributedString.append(middleAttributedString)
        startAttributedString.append(endAttributedString)
        
        topTitleLabel.attributedText = startAttributedString
    }
    
    func openDocument() {
        let contentType: [UTType] = [.pdf]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: contentType, asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.shouldShowFileExtensions = true
        present(documentPicker, animated: true)
    }
    
    func statusInfoForPdfToAi(for status: PdfProgressEnum) {
        self.status = status
        switch status {
            
        case .started:
            self.setStatusAttributedMessage(for: "Lawie is ", lastMessage: "Reading...")
            //            self.tagLineLottieView.pause()
        case .completed:
            self.setStatusMessage(for: "Lawie is Ready!! Chat Now? ", color: .lightGreen)
            self.lawieIsReadyArrowImage.isHidden = false
            self.toggleLottieAnimation()
        case .pdfProcessed:
            self.setStatusAttributedMessage(for: "Finished ", lastMessage: "Reading! ")
        case .qaGenerated:
            
            self.setStatusAttributedMessage(for: "Compiling ", lastMessage: "Knowledge...")
        case .adapterTraining:
            self.setStatusMessage(for: "Lawie is learning!!")
            self.setStatusAttributedMessage(for: "Lawie is ", lastMessage: "learning!!")
        case .failed:
            self.setStatusMessage(for: "Ooppss..Lawie ZONED out !!", color: .primaryYellow)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.trainYourLawieView.isHidden = false
                self.chatWithCustomTrainedLawieView.isHidden = true
            }
            
            let startAttributedString = NSMutableAttributedString(string: "Ooppss..Lawie ", attributes: [
                .foregroundColor: UIColor.primaryYellow.cgColor ,
                .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
            ])
            
            let middleAttributedString = NSMutableAttributedString(string: "ZONED ", attributes: [
                .foregroundColor: UIColor.primaryRed,
                .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
            ])
            
            let endAttributedString = NSMutableAttributedString(string: "out !!", attributes: [
                .foregroundColor: UIColor.primaryYellow,
                .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
            ])
            
            startAttributedString.append(middleAttributedString)
            startAttributedString.append(endAttributedString)
            statusLabelForAIGeneration.attributedText = startAttributedString
            
            // Set the tint color
            let colorProvider = ColorValueProvider(UIColor.primaryYellow.lottieColorValue)
            dataTrainAnimation.setValueProvider(colorProvider, keypath: AnimationKeypath(keypath: "**.Fill 1.Color"))
            toggleLottieAnimation()
            chatWithCustomTrainedLawieView.borderColor =  UIColor.primaryYellow
            chatWithCustomTrainedLawieView.layoutIfNeeded()
            chatWithCustomTrainedLawieView.layoutSubviews()
            self.toggleLottieAnimation()
        }
    }
    
    func setStatusMessage(for message: String, color: UIColor = .white ){
        self.statusLabelForAIGeneration.text = message
        self.statusLabelForAIGeneration.textColor = color
    }
    
    func setStatusAttributedMessage(for FirstMessage: String, lastMessage: String ){
        let startAttributedString = NSMutableAttributedString(string: FirstMessage, attributes: [
            .foregroundColor: UIColor(named: "ColorWhite") ?? .white,
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ])
        
        let middleAttributedString = NSMutableAttributedString(string: lastMessage, attributes: [
            .foregroundColor: UIColor(named: "ColorAccent") ?? .white,
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ])
        
        startAttributedString.append(middleAttributedString)
        
        statusLabelForAIGeneration.attributedText = startAttributedString
    }
    
    //MARK: - UPLOAD FILES PROCESSES -
    
    func uploadFile(fileURL: URL) {
        self.sharedUtility.startLoadingActivity()
        self.adapterName = fileURL.lastPathComponent
        ApiManager.shared.uploadPDF(fileURL: fileURL, userId: sharedUserDefaults.userID, adapterName: fileURL.lastPathComponent) { isSuccess, response in
            self.sharedUtility.hideLoadingActivity()
            self.updateUI(for: .started)
            
            if isSuccess {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if let taskId = response?.task_id {
                        self.checkStatus(taskId: taskId)
                    }
                }
            }
        }
    }
    
    func checkStatus(taskId: Int) {
        self.isDataUploading = true
        ApiManager.shared.checkTaskStatus(userId: sharedUserDefaults.userID, taskId: taskId) { isSuccess, response in
            
            if !isSuccess {
                self.retry(taskId: taskId)
                return
            }
            
            if response?.status == PdfProgressEnum.failed.rawValue {
                self.updateUI(for: .failed)
                self.isDataUploading = false
                return
            }
            
            self.updateUI(for: PdfProgressEnum(rawValue: response?.status ?? "") ?? .started)
            
            if response?.status != PdfProgressEnum.completed.rawValue {
                self.retry(taskId: taskId)
                
            } else {
                self.isDataUploading = false
            }
        }
    }
    
    func retry(taskId: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.checkStatus(taskId: taskId)
        }
    }
    
    func updateUI(for status: PdfProgressEnum) {
        trainYourLawieView.isHidden = true
        chatWithCustomTrainedLawieView.isHidden = false
        statusInfoForPdfToAi(for: status)
    }
    
    //MARK: - Lotti Setups
    func setupLottiView() {
        chatWithCustomTrainedLawieView.isHidden = true
        dataTrainAnimation.animation = LottieAnimation.named("file-searching")
        dataTrainAnimation.loopMode = .loop
        toggleLottieAnimation()
        tagLineLottieView.animation = LottieAnimation.named("koreanTagline")
        tagLineLottieView.loopMode = .loop
        tagLineLottieView.play()
    }
    
    func toggleLottieAnimation() {
        if dataTrainAnimation.isAnimationPlaying {
            dataTrainAnimation.stop()
        }else {
            dataTrainAnimation.play()
        }
        
    }
}


