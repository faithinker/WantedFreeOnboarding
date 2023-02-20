//
//  ViewController.swift
//  Concurrency
//
//  Created by jhkim on 2023/02/20.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
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


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = ImageCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
}
