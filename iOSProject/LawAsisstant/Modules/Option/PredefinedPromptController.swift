//
//  PredefinedPromptController.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 9/9/24.
//

import UIKit
import RevenueCat

class PredefinedPromptController: BaseViewController {
    @IBOutlet private weak var aiDataModelPromtCollectionView: UICollectionView!
    @IBOutlet private weak var historyTableView: UITableView!
    
    private var jobIDs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        // TableView Setup
        historyTableView.backgroundColor = .clear
        setupCollectionView()
        getJobIds()
    }
    
    @IBAction func onStartMessagePressed(_ sender: Any) {
        navigationController?.pushViewController(router.chatController(), animated: true)
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func getJobIds() {
        self.sharedUtility.startLoadingActivity()
        ApiManager.shared.getJobIds(userId: sharedUserDefaults.userID) { isSuccess, response in
            self.sharedUtility.hideLoadingActivity()
            
            if let ids = response?.adapters.map({ $0.name }) {
                self.jobIDs.append(contentsOf: ids)
                self.aiDataModelPromtCollectionView.reloadData()
            }
        }
    }
    
}

extension PredefinedPromptController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        if let layout = aiDataModelPromtCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal // Set horizontal scrolling
            layout.minimumLineSpacing = 10 // Space between items
        }
        
        aiDataModelPromtCollectionView.delegate = self
        aiDataModelPromtCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jobIDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let controller = router.chatController()
        controller.adapterId = jobIDs[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PromptCell", for: indexPath) as! PromptCell
        cell.promptLabel.text = jobIDs[indexPath.row]
        return cell
    }
    
    // Set the size of the collection view cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 2 - 10
        let height = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }
    
}
