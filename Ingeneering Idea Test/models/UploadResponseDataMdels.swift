

import Foundation

//model for JSON serialization

struct UploadSuccsessfullResponseData: Codable   {
    let data: SuccessfulData
    let success: Bool
    let status: Int

}

struct SuccessfulData: Codable {
//    let id: String?
//    let title: String?
//    let description: String?
//    let datetime: Int?
//    let type: String?
//    let animated: Bool?
//    let width: Int?
//    let height: Int?
//    let size: Int?
//    let views: Int?
//    let bandwidth: Int?
//    let vote: String?
//    let favorite: Bool?
//    let nsfw: String?
//    let section: String?
//    let accountUrl: String?
//    let accountID: Int?
//    let isAd: Bool?
//    let inMostViral: Bool?
//    let tags:[String]?
//    let adType: Int?
//    let adUrl: String?
//    let inGallery: Bool?
//    let deletehash: String?
//    let name: String?
    let link: URL?
    
    
    enum CodingKeys: String, CodingKey {
//        case accountUrl = "account_url"
//        case accountID = "account_id"
//        case isAd = "is_ad"
//        case inMostViral = "in_most_viral"
//        case adType = "ad_type"
//        case adUrl = "ad_url"
//        case inGallery = "in_gallery"
//
//        case id
//        case title
//        case description
//        case datetime
//        case type
//        case animated
//        case width
//        case height
//        case size
//        case views
//        case bandwidth
//        case vote
//        case favorite
//        case nsfw
//        case section
//        case tags
//        case deletehash
//        case name
        case link

    }
    
}



