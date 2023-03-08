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
    private var images = [UIImage?]()
    
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
        $0.setTitle("Stop", for: .selected)
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
    
    /// 구 버전 GCD방식
    private func loadImage(_ index: IndexPath, _ totalImage: Bool = false, isStop: Bool = false) {
        guard let cell = self.tableView.cellForRow(at: index) as? ImageCell else { return }
        
        NetworkService.shared.request(endPoint: .random, cancelTask: isStop) { (result: Result<Giphy, GiphyError>) in
            switch result {
            case .success(let result):
                guard let imageUrl = URL(string:result.data.images.fixedHeightSmallStill.url) else {
                    print("Url Error"); return
                }
                
                guard let imageData = try? Data(contentsOf: imageUrl) else {
                    print("Data Error: \(imageUrl)"); return
                }
                
                DispatchQueue.main.async {
                    cell.configure(UIImage(data: imageData))
                    cell.loadButton.isSelected = false
                }
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        } value: { data in
            DispatchQueue.main.async {
                cell.setValue = data
            }
        }
    }
    
    /// 신 버전 Async-Await 버전
    private func loadAsyncTask(_ index: IndexPath) {
        Task {
            let randomUrl = "https://api.giphy.com/v1/gifs/random?api_key=0qkSNtNaUL0XRhFBY7ov2q8VEC2FVAFy"
            let imageData = try await NetworkService.shared.downloadImage(url: randomUrl)
            
            guard let cell = self.tableView.cellForRow(at: index) as? ImageCell else { return }
            
            cell.configure(imageData)
        }
    }
    
    // 랜덤(API)을 5번 찌르는 반복문으로 바꿔야 한다.
    private func loadAllData(_ count: Int) {
        NetworkService.shared.request(endPoint: .trend(limit: count), cancelTask: false) { [weak self] (result : Result<GiphyTrend, GiphyError>) in
            guard let self else { return }
            
            switch result {
            case .success(let result):
                self.images = []
                
                result.data.forEach {
                    guard let imageData = try? Data(contentsOf: URL(string: $0.images.fixedHeightSmallStill.url)!) else { return }
                    self.images.append(UIImage(data: imageData))
                }
                DispatchQueue.main.async {
                    self.loadAllButton.isSelected = false
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        } value: { [weak self] data in
            guard let self else { return }
            
            DispatchQueue.main.async {
                for i in 0..<5 {
                    guard let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? ImageCell else { return }
                    cell.setValue = data
                }
            }
        }
    }
    
    private func bind() {
        loadAllButton.tapPublisher
            .sink(receiveValue: { [weak self]  _ in
                guard let self else { return }
                self.loadAllData(5)
                self.loadAllButton.isSelected = !self.loadAllButton.isSelected
            })
            .store(in: &cancellables)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 재사용 셀을 쓰게 될 경우, load 버튼을 누르면 이벤트가 두번 불린다.
        //guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.identifier) as? ImageCell else { return ImageCell() }
        
        let cell = ImageCell()
        
        cell.loadButton.tapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                print("cell button Tapped \(indexPath.row)")
                cell.loadButton.isSelected = !cell.loadButton.isSelected
                self.loadImage(indexPath, isStop: !cell.loadButton.isSelected)
                //self.loadAsyncTask(indexPath)
                
            })
            .store(in: &cancellables)
        
        if !images.isEmpty {
            cell.configure(images[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
}
