//
//  ConcentrationVC.swift
//  concentration
//
//  Created by joe on 26/11/22.
//

import UIKit

class ConcentrationVC: UIViewController {
    // MARK: - Dependencies
    private var viewModel: ConcentrationViewModelProtocol
    
    // MARK: - Stored Properties
    private let concentrationView: ConcentrationView = ConcentrationView()
    private let collectionViewProvider: ConcentrationCollectionProvider = ConcentrationCollectionProvider()
    
    
    // MARK: - Lifecycle
    init(viewModel: ConcentrationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = concentrationView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        concentrationView.newGameButton.addTarget(self, action: #selector(startNewGame(sender:)), for: .touchUpInside)
        
        viewModel.delegate = self
        viewModel.startGame()
        configureCollectionViewDelegates()
        configureNavBar()
    }
    
    deinit {
        print("ConcentrationVC deinit")
    }
}

// MARK: - UI Configurations
extension ConcentrationVC {
    private func configureCollectionViewDelegates() {
        collectionViewProvider.delegate = self
        
        concentrationView.collectionView.dataSource = collectionViewProvider
        concentrationView.collectionView.delegate = collectionViewProvider
    }
    
    private func configureNavBar() {
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.title = "Match All"
    }
}

// MARK: - Target Actions
extension ConcentrationVC {
    @objc
    func startNewGame(sender: UIButton) {
        viewModel.restartGame()
    }
}

// MARK: - CollectionView Provider Delegates
extension ConcentrationVC: ConcentrationCollectionProviderDelegate {
    func didSelectCard(_ provider: ConcentrationCollectionProvider, withIndex index: Int) {
        viewModel.userTappedCard(ofIndex: index)
    }
}

// MARK: - Concentration Game Delegates
extension ConcentrationVC: ConcentrationGameProtocol {
    func concentrationGameDidStart(_ viewModel: ConcentrationViewModel) {
        collectionViewProvider.cards = viewModel.cards
        collectionViewProvider.associatedEmojiss = viewModel.associatedCardEmojiDictionary
        concentrationView.collectionView.reloadData()
    }
    
    func concentrationGameDidEnd(_ viewModel: ConcentrationViewModel) {
        print("Game Over")
    }
    
    func concentrationGame(_ viewModel: ConcentrationViewModel, showCards cardIndices: [Int]) {
        for index in cardIndices {
            let cell = concentrationView.collectionView.cellForItem(at: IndexPath(item: index, section:0)) as! ConcentrationCollectionViewCell
            let card = viewModel.cards[index]
            let emoji = viewModel.associatedCardEmojiDictionary[card]
            cell.showCard(true, with: emoji ?? "❓")
        }
    }
    
    func concentrationGame(_ viewModel: ConcentrationViewModel, hideCards cardIndices: [Int]) {
        for index in cardIndices {
            let cell = concentrationView.collectionView.cellForItem(at: IndexPath(item: index, section:0)) as! ConcentrationCollectionViewCell
            cell.showCard(false, with: nil)
        }
    }
    
    func concentrationGameUpdateValue(_ viewModel: ConcentrationViewModel, flipCount: Int) {
        concentrationView.flipCountLabel.text = "Flips: \(flipCount)"
    }
    
    func concentrationGameUpdateValue(_ viewModel: ConcentrationViewModel, currentScore: Int) {
        concentrationView.currentScoreLabel.text = "Score: \(currentScore)"
    }
}
