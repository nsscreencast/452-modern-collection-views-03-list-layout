//
//  ViewController.swift
//  CompositionalEpisodes
//
//  Created by Ben Scheirman on 7/22/20.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    private var cancellables: Set<AnyCancellable> = []
    private var dataLoader = DataLoader()
    
    private var collectionView: UICollectionView!
    private var loadingIndicator: UIActivityIndicatorView!
    
    private var episodeCellRegistration: UICollectionView.CellRegistration<EpisodeCell, Episode>!
    private var listCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Episode>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Episodes"
        
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingIndicator)
        
        configureCollectionView()
        fetchData()
    }
    
    private func configureCollectionView() {
    
        let layout = createLayout()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.dataSource = self
        
        episodeCellRegistration = UICollectionView.CellRegistration { cell, indexPath, episode in
            cell.titleLabel.text = episode.title
            cell.subtitleLabel.text = "#\(episode.episodeNumber)"
            cell.imageView.setImage(with: episode.mediumArtworkUrl)
        }
        
        listCellRegistration = UICollectionView.CellRegistration { cell, indexPath, episode in
            var content = cell.defaultContentConfiguration()
            content.text = episode.title
            content.secondaryText = "#\(episode.episodeNumber)"
            
            cell.contentConfiguration = content
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }

    private func fetchData() {
        dataLoader.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        dataLoader.dataChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        dataLoader.fetchData()
    }
    
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataLoader.episodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let episode = dataLoader.episodes[indexPath.row]
        return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: episode)
    }
}
