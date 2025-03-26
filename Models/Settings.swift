import SwiftUI
import Combine

final class Settings: ObservableObject {
    @Published var isDarkMode = false
    @Published var showPrices = true
    @Published var showCountryNames = true
    
    init() {
        // Initialize with default values
        isDarkMode = false
        showPrices = true
        showCountryNames = true
    }
} 