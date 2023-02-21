//
//  ImageCell.swift
//  Concurrency
//
//  Created by jhkim on 2023/02/20.
//

import UIKit
import Combine
import SnapKit

class ImageCell: UITableViewCell {
    static let identifier = String(describing: ImageCell.self)
        
    private lazy var picture = UIImageView().then {
        $0.image = UIImage(systemName: "photo")
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var progressBar = UIView().then {
        $0.backgroundColor = .systemGray
        $0.layer.cornerRadius = 4
    }
    
    private lazy var gageBar = UIView().then {
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 4
    }
    
    lazy var loadButton = UIButton().then {
        $0.layer.cornerRadius = 10
        $0.setTitle("Load", for: .normal)
        $0.setBackgroundColor(.systemBlue, for: .normal)
        $0.setBackgroundColor(.white.withAlphaComponent(0.5), for: .highlighted)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }
    
    private func setupLayout() {
        addSubViews([picture, progressBar, gageBar, loadButton])
        
        picture.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(15)
            $0.height.equalTo(75)
            $0.width.equalTo(130)
        }
        progressBar.snp.makeConstraints {
            $0.leading.equalTo(picture.snp.trailing).offset(10)
            $0.centerY.equalTo(picture.snp.centerY)
            $0.height.equalTo(4)
            $0.width.equalTo(120)
        }
        gageBar.snp.makeConstraints {
            $0.leading.equalTo(picture.snp.trailing).offset(10)
            $0.centerY.equalTo(picture.snp.centerY)
            $0.height.equalTo(4)
            $0.width.equalTo(60)
        }
        loadButton.snp.makeConstraints {
            $0.leading.equalTo(progressBar.snp.trailing).offset(10)
            $0.centerY.equalTo(picture.snp.centerY)
            $0.height.equalTo(35)
            $0.width.equalTo(75)
        }
    }
    
    func configure(_ data: UIImage?) {
        picture.image = data
    }
}
