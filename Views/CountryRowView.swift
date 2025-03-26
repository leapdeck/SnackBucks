import SwiftUI

struct CountryRowView: View {
    let country: Country
    @AppStorage("showCountryNames") private var showCountryNames: Bool = true
    
    var body: some View {
        VStack {
            Text(country.flag)  // Flag is always shown
            if showCountryNames {
                Text(country.name)
                    .font(.caption)
            }
        }
    }
} 