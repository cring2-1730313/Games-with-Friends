//
//  CountryDataProvider.swift
//  BorderBlitz
//
//  Provides country data with map images
//

import Foundation

struct BorderBlitzCountryDataProvider {
    /// Returns all available countries that have map images
    static func getAllCountries() -> [BorderBlitzCountry] {
        return [
            BorderBlitzCountry(
                id: "ITA",
                name: "ITALY",
                imageName: "ITA",
                alternateNames: ["Repubblica Italiana"]
            ),

            BorderBlitzCountry(
                id: "FRA",
                name: "FRANCE",
                imageName: "FRA",
                alternateNames: ["République française"]
            ),

            BorderBlitzCountry(
                id: "ESP",
                name: "SPAIN",
                imageName: "ESP",
                alternateNames: ["España", "Kingdom of Spain"]
            ),

            BorderBlitzCountry(
                id: "DEU",
                name: "GERMANY",
                imageName: "DEU",
                alternateNames: ["Deutschland"]
            ),

            BorderBlitzCountry(
                id: "JPN",
                name: "JAPAN",
                imageName: "JPN",
                alternateNames: ["Nippon", "Nihon"]
            ),

            BorderBlitzCountry(
                id: "AUS",
                name: "AUSTRALIA",
                imageName: "AUS",
                alternateNames: []
            ),

            BorderBlitzCountry(
                id: "CAN",
                name: "CANADA",
                imageName: "CAN",
                alternateNames: []
            ),

            BorderBlitzCountry(
                id: "IND",
                name: "INDIA",
                imageName: "IND",
                alternateNames: ["Bharat"]
            ),

            BorderBlitzCountry(
                id: "CHN",
                name: "CHINA",
                imageName: "CHN",
                alternateNames: ["PRC", "People's Republic of China"]
            ),

            BorderBlitzCountry(
                id: "MEX",
                name: "MEXICO",
                imageName: "MEX",
                alternateNames: ["México"]
            )
        ]
    }
}
