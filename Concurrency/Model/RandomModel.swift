//
//  RandomModel.swift
//  Concurrency
//
//  Created by jhkim on 2023/02/20.
//

import UIKit


struct Giphy: Codable {
    let data: GiphyData
    let meta: Meta
    
}
struct GiphyData: Codable {
    let type: String
    let url: String
    let username: String
    let images: Images
}

struct Images: Codable {
    let originalStill: SizeInfo
    let fixedHeightSmallStill: SizeInfo
    
    enum CodingKeys: String, CodingKey {
        case originalStill = "original_still"
        case fixedHeightSmallStill = "fixed_height_small_still"
    }
}


struct SizeInfo: Codable {
    let size: String
    let url: String
}


struct Meta: Codable {
    let status: Int
    let msg, responseID: String

    enum CodingKeys: String, CodingKey {
        case status, msg
        case responseID = "response_id"
    }
}
