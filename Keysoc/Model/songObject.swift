//
//  song.swift
//  Keysoc
//
//  Created by Wong Tsz Sang on 8/9/2023.
//

import Foundation

struct songJsonResult: Codable{
    let resultCount: Int
    let results: [songObject]
}

struct songObject:Codable{
//    let wrapperType: String
//    let kind: String
//    let artistId: Int
//    let collectionId: Int
    let trackId: Int
    let artistName: String
    let collectionName: String?
    let trackName: String
//    let collectionCensoredName: String
//    let trackCensoredName: String
//    let collectionArtistId: Int?
//    let collectionArtistName: String?
//    let collectionArtistViewUrl: String?
//    let artistViewUrl: String
//    let collectionViewUrl: String
//    let trackViewUrl: String
//    let previewUrl: String
    let artworkUrl30: String
    let artworkUrl60: String
    let artworkUrl100: String
//    let collectionPrice: Float
//    let trackPrice: Float
//    let releaseDate: String
//    let collectionExplicitness: String
//    let trackExplicitness: String
//    let discCount: Int
//    let discNumber: Int
//    let trackCount: Int
//    let trackNumber: Int
//    let trackTimeMillis: Int
//    let country: String
//    let currency: String
//    let primaryGenreName: String
//    let isStreamable: Bool
    
}
