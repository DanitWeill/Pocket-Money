//
//  CurrencyData.swift
//  Pocket Money
//
//  Created by Danit on 07/05/2022.
//

import Foundation

struct CurrencyData: Decodable{
    let asset_id_quote: String
    let rate: Float
}
