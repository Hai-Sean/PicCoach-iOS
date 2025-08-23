//
//  SuggestionRequest.swift
//  PicCoach
//
//  Created by Hoang Hai on 23/8/25.
//

struct SuggestionRequest: Codable {
    let type: String
    let data: AdjustmentData
}

struct AdjustmentData: Codable {
    let exposure: Int
    let brightness: Int
    let contrast: Int
    let saturation: Int
}
