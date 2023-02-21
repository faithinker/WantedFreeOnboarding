//
//  ViewController.swift
//  Concurrency
//
//  Created by jhkim on 2023/02/20.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

class ViewController: UIViewController {
    
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .systemBlue
        $0.separatorStyle = .none
        $0.register(ImageCell.self, forCellReuseIdentifier: ImageCell.identifier)
        $0.rowHeight = 100
        $0.isScrollEnabled = false
    }

    private lazy var loadAllButton = UIButton().then {
        $0.layer.cornerRadius = 10
        $0.setTitle("Load All Images", for: .normal)
        $0.setBackgroundColor(.systemBlue, for: .normal)
        $0.setBackgroundColor(.white.withAlphaComponent(0.5), for: .highlighted)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bind()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupLayout() {
        view.addSubViews([tableView, loadAllButton])
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(500)
        }
        loadAllButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(33)
        }
    }
    
    func loadImage(_ row: Int) {
        NetworkService.shared.request(endPoint: .random) { [weak self] (result: Result<Giphy, GiphyError>) in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let result):
                guard let imageUrl = URL(string:result.data.images.fixedHeightSmallStill.url) else {
                    print("Url Error"); return
                }
                
                guard let imageData = try? Data(contentsOf: imageUrl) else {
                    print("Data Error: \(imageUrl)"); return
                }
                
                DispatchQueue.main.async {
                    guard let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? ImageCell else { return }
                    
                    cell.configure(UIImage(data: imageData))
                }
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
    
    private func bind() {
        loadAllButton.tapPublisher
            .sink(receiveValue: { _ in
                print("button Tapped")
            })
            .store(in: &cancellables)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = ImageCell()
        
        cell.loadButton.tapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                print("cell button Tapped \(indexPath.row)")
                self.loadImage(indexPath.row)
            })
            .store(in: &cancellables)
        
//        imageData.publisher
//            .sink { image in
//
//                print("count", image?.images?.count)
//                cell.configure(image)
//            }.store(in: &cancellables)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
}
