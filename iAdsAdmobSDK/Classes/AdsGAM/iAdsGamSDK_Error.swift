//
//  iAdsAdmobSDM]]\_Error.swift
//  iKameSDK
//
//  Created by Trung Nguyễn on 25/10/24.
//

import Foundation


enum iAdsGamSDK_Error: Error {
    case adsIdIsLoading
    case noAdsToShow
    case closeNoReward
    case networkError(message: String)
    case parsingError
    case invalidRequest
    case unknownError

    // Hàm cung cấp mô tả chi tiết cho mỗi lỗi
    var errorMessage: String {
        switch self {
        case .adsIdIsLoading:
            return "Ads id is loading..."
        case .noAdsToShow:
            return "No ads to show."
        case .closeNoReward:
            return "Close no reward"
        case .networkError(let message):
            return "Network error occurred: \(message)"
        case .parsingError:
            return "Failed to parse the response data."
        case .invalidRequest:
            return "Invalid request. Please check your parameters."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
