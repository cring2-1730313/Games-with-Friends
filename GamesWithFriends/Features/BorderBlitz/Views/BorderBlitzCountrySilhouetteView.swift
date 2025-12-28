//
//  CountrySilhouetteView.swift
//  BorderBlitz
//

import SwiftUI

struct BorderBlitzCountrySilhouetteView: View {
    let country: BorderBlitzCountry
    let size: CGSize

    var body: some View {
        Image(country.imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size.width, height: size.height)
    }
}
