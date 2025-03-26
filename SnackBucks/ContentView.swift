//  ContentView.swift
//  SnackBucks
//
//  Created by modview on 3/5/25.
//

import SwiftUI

// Add new enum for Currency options
enum Currency: String, CaseIterable {
    case usd = "U.S. $"
    case cad = "CA $"
    case eur = "EUR"
    case peso = "Peso"
    case yen = "Yen"
    case franc = "Franc"
    
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .cad: return "$"
        case .eur: return "€"
        case .peso: return "₱"
        case .yen: return "¥"
        case .franc: return "₣"
        }
    }
    
    var conversionRate: Double {
        switch self {
        case .usd: return 1.0
        case .cad: return 1.42
        case .eur: return 1.08
        case .peso: return 20.28
        case .yen: return 147.82
        case .franc: return 0.88
        }
    }
}

// 1. First, move the enums outside of PricesContentView to make them accessible
enum SortOrder: String, CaseIterable {
    case original = "Select"
    case ascending = "A to Z"
    case descending = "Z to A"
}

enum NumberSortOrder: String, CaseIterable {
    case none = "Price\nOrder"
    case ascending = "Low\nto\nHigh"
    case descending = "High\nto\nLow"
}

struct ContentView: View {
    var body: some View {
        TabView {
            PricesContentView()
                .tabItem {
                    Label("Food", systemImage: "cart.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

// Rename the current ContentView to PricesContentView
struct PricesContentView: View {
    @AppStorage("countries") private var countriesData: Data = try! JSONEncoder().encode(["Brazil", "U.S.", "Mexico", "Japan", "Thailand", "Denmark", "Senegal", "Fiji", "New Zealand", "France", "Spain", "Argentina", "Eritrea", "Ukraine", "India","Taiwan",  "Finland"])
    @AppStorage("priceData") private var priceDataData: Data = try! JSONEncoder().encode([
        [15, 6, 3, 6, 1, 1, 4, 6, 6, 1],
        [20, 15, 6, 10, 1, 2, 1, 10, 18, 2],
        [9, 5, 2, 5, 1, 1, 2, 5, 15, 1],
        [20, 5, 2, 11, 2, 2, 2, 7, 10, 2],
        [9, 2, 2, 5, 1, 1, 1, 3, 7, 1],
        [15, 10, 5, 17, 1, 2, 5, 11, 17, 2],
        [9, 2, 2, 4, 1, 1, 2, 2, 5, 2],
        [6, 10, 5, 7, 3, 1, 2, 12, 3, 1],
        [9, 9, 6, 14, 1,1, 5, 3 ,10,2 ],
        [15, 4, 4, 18, 1, 1, 1, 1, 10, 1],
        [4,5, 3, 10, 1, 1, 5, 7, 12, 1],
        [15, 5, 3, 4, 1, 1, 1, 4, 10,1 ],
        [10, 2, 5, 15, 5, 1, 1, 1, 10, 1],
        [7, 2, 1,2 , 1, 1, 1, 1, 2, 1],
        [4, 2, 4, 4, 1, 1, 1, 1, 3,1 ],
        [17, 6, 6, 10, 2, 2, 2, 2, 5,1 ],
        [16, 10, 4, 20 , 1, 1, 4, 4, 16,2 ]
    ])
    @AppStorage("sortOrder") private var sortOrderRawValue: String = SortOrder.original.rawValue
    @AppStorage("numberSortOrder") private var numberSortOrderRawValue: String = NumberSortOrder.none.rawValue
    @AppStorage("selectedCurrency") private var selectedCurrencyRawValue: String = Currency.usd.rawValue
    @AppStorage("pinnedCountryIndex") private var pinnedCountryOriginalIndex: Int = -1
    @AppStorage("showFoodNames") private var showFoodNames: Bool = true // Changed back to true
    @AppStorage("showCountryNames") private var showCountryNames: Bool = true
    
    //"pizza", "sandwich", "eggs","burrito","oranges/lb","apples/lb","bagel", "pancakes", "chicken", "green pepper"
    
    @State private var countries: [String] = ["Brazil", "U.S.", "Mexico", "Japan", "Thailand", "Denmark", "Senegal", "Fiji", "New Zealand", "France", "Spain", "Argentina", "Eritrea", "Ukraine","India", "Taiwan","Finland"]
    @State private var priceData: [[Int]] = [
        [15, 6, 3, 6, 1, 1, 4, 6, 6, 1],
        [20, 15, 6, 10, 1, 2, 1, 10, 18, 2],
        [9, 5, 2, 5, 1, 1, 2, 5, 15, 1],
        [20, 5, 2, 11, 2, 2, 2, 7, 10, 2],
        [9, 2, 2, 5, 1, 1, 1, 3, 7, 1],
        [15, 10, 5, 17, 1, 2, 5, 11, 17, 2],
        [9, 2, 2, 4, 1, 1, 2, 2, 5, 2],
        [6, 10, 5, 7, 3, 1, 2, 12, 3, 1],
        [9, 9, 6, 14, 1,1, 5, 3 ,10,2 ],
        [15, 4, 4, 18, 1, 1, 1, 1, 10, 1],
        [4,5, 3, 10, 1, 1, 5, 7, 12, 1],
        [15, 5, 3, 4, 1, 1, 1, 4, 10,1 ],
        [10, 2, 5, 15, 5, 1, 1, 1, 10, 1],
        [7, 2, 1,2 , 1, 1, 1, 1, 2, 1],
        [4, 2, 4, 4, 1, 1, 1, 1, 3,1 ],
        [17, 6, 6, 10, 2, 2, 2, 2, 5,1 ],
        [16, 10, 4, 20 , 1, 1, 4, 4, 16,2 ]
    ]
    @State private var editingIndex: Int? = nil
    @State private var editingNumber: String = ""
    @State private var editingColumn: Int = 1  // 1, 2, or 3
    @State private var sortOrder: SortOrder = .original
    @State private var numberSortOrder: NumberSortOrder = .none
    @State private var currentScrollPage: Int = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var columnOffset: Int = 0
    @State private var selectedCurrency: Currency = .usd
    @State private var pinnedCountryIndex: Int? = nil
    @State private var sharedScrollPosition: CGFloat = 0
    @State private var selectedColumnIndex: Int? = nil
    @GestureState private var translation: CGFloat = 0
    @State private var editingItem: EditingItem? = nil
    
    private static let columnTitles = [
        "pizza",
        "sandwich",
        "eggs/dozen",
        "burrito",
        "oranges/lb",
        "apples/lb",
        "bagel",
        "pancakes",
        "chicken",
        "green pepper"
    ]
    
    private func updateSortOrderStorage() {
        sortOrderRawValue = sortOrder.rawValue
        numberSortOrderRawValue = numberSortOrder.rawValue
        selectedCurrencyRawValue = selectedCurrency.rawValue
    }
    
    private func loadSavedData() {
        print("Starting loadSavedData...")
        
        // Set initial values
        countries = ["Brazil", "U.S.", "Mexico", "Japan", "Thailand", "Denmark", "Senegal", "Fiji", "New Zealand", "France", "Spain", "Argentina", "Eritrea", "Ukraine","India", "Taiwan","Finland"]
        priceData = [
            [15, 6, 3, 6, 1, 1, 4, 6, 6, 1],
            [20, 15, 6, 10, 1, 2, 1, 10, 18, 2],
            [9, 5, 2, 5, 1, 1, 2, 5, 15, 1],
            [20, 5, 2, 11, 2, 2, 2, 7, 10, 2],
            [9, 2, 2, 5, 1, 1, 1, 3, 7, 1],
            [15, 10, 5, 17, 1, 2, 5, 11, 17, 2],
            [9, 2, 2, 4, 1, 1, 2, 2, 5, 2],
            [6, 10, 5, 7, 3, 1, 2, 12, 3, 1],
            [9, 9, 6, 14, 1,1, 5, 3 ,10,2 ],
            [15, 4, 4, 18, 1, 1, 1, 1, 10, 1],
            [4,5, 3, 10, 1, 1, 5, 7, 12, 1],
            [15, 5, 3, 4, 1, 1, 1, 4, 10,1 ],
            [10, 2, 5, 15, 5, 1, 1, 1, 10, 1],
            [7, 2, 1,2 , 1, 1, 1, 1, 2, 1],
            [4, 2, 4, 4, 1, 1, 1, 1, 3,1 ],
            [17, 6, 6, 10, 2, 2, 2, 2, 5,1 ],
            [16, 10, 4, 20 , 1, 1, 4, 4, 16,2]
        ]
        // Only load saved data if it's not empty
        if let decodedCountries = try? JSONDecoder().decode([String].self, from: countriesData),
           !decodedCountries.isEmpty {
            countries = decodedCountries
        }
        
        if let decodedPriceData = try? JSONDecoder().decode([[Int]].self, from: priceDataData),
           !decodedPriceData.isEmpty {
            priceData = decodedPriceData
        }
        
        print("After loading:")
        print("Countries count: \(countries.count)")
        print("PriceData count: \(priceData.count)")
        print("First row: \(priceData.first?.first ?? 0)")
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(countries) {
            countriesData = encoded
        }
        if let encoded = try? JSONEncoder().encode(priceData) {
            priceDataData = encoded
        }
    }
    
    private func debugPrint() {
        print("Rendering view with \(countries.count) countries")
    }
    
    // Add helper function to get the current column at a position
    private func getColumnAtPosition(_ position: Int) -> [Int] {
        let allColumns = priceData
        let index = (currentScrollPage + position + allColumns.count) % allColumns.count
        return allColumns[index]
    }
    
    // Update currentSortNumbers to use the selected column
    private var currentSortNumbers: [Int] {
        if let selectedIndex = selectedColumnIndex {
            // Use the selected column's numbers for sorting
            let allColumns = priceData
            return allColumns[selectedIndex]
        } else {
            // Default to first visible column if no column is selected
            let effectiveIndex = columnOffset % 10
            let allColumns = priceData
            return allColumns[effectiveIndex]
        }
    }
    
    // Update isEdited to handle scrolled positions
    private func isEdited(_ index: Int, column: Int) -> Bool {
        let defaultValues = [
            [15, 6, 3, 6, 1, 1, 4, 6, 6, 1],
            [20, 15, 6, 10, 1, 2, 1, 10, 18, 2],
            [9, 5, 2, 5, 1, 1, 2, 5, 15, 1],
            [20, 5, 2, 11, 2, 2, 2, 7, 10, 2],
            [9, 2, 2, 5, 1, 1, 1, 3, 7, 1],
            [15, 10, 5, 17, 1, 2, 5, 11, 17, 2],
            [9, 2, 2, 4, 1, 1, 2, 2, 5, 2],
            [6, 10, 5, 7, 3, 1, 2, 12, 3, 1],
            [9, 9, 6, 14, 1,1, 5, 3 ,10,2 ],
            [15, 4, 4, 18, 1, 1, 1, 1, 10, 1],
            [4,5, 3, 10, 1, 1, 5, 7, 12, 1],
            [15, 5, 3, 4, 1, 1, 1, 4, 10,1 ],
            [10, 2, 5, 15, 5, 1, 1, 1, 10, 1],
            [7, 2, 1,2 , 1, 1, 1, 1, 2, 1],
            [4, 2, 4, 4, 1, 1, 1, 1, 3,1 ],
            [17, 6, 6, 10, 2, 2, 2, 2, 5,1 ],
            [16, 10, 4, 20 , 1, 1, 4, 4, 16,2 ]
        ]
        
        let columnIndex = (currentScrollPage + column - 1 + 10) % 10
        let currentColumn = getColumnAtPosition(column - 1)
        
        // Don't show green border for moved rows that haven't been edited
        let originalIndex = sortedIndices[index]
        return currentColumn[index] != defaultValues[columnIndex][originalIndex]
    }
    
    // Create a helper function to get visible columns
    private func visibleColumns(_ index: Int) -> [(Int, [Int])] {
        let allColumns = priceData
        
        // Show only three columns at a time
        var columns: [(Int, [Int])] = []
        for i in 0...2 {  // Still show only 3 columns
            let columnIndex = (currentScrollPage + i) % allColumns.count
            columns.append((columnIndex, allColumns[columnIndex]))
        }
        return columns
    }
    
    // Update the helper function for currency formatting
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let value = Double(number)
        let convertedValue = value * selectedCurrency.conversionRate
        let formattedNumber = formatter.string(from: NSNumber(value: convertedValue)) ?? "0.00"
        
        // Add the currency symbol in front of the number
        return "\(selectedCurrency.symbol)\(formattedNumber)"
    }
    
    // Add this computed property to calculate opacity for each column
    private func columnOpacity(_ columnIndex: Int) -> Double {
        let scrollThreshold: CGFloat = 50.0
        let opacity = 1.0 + Double(scrollOffset / scrollThreshold)
        
        // Only apply fade to the leftmost visible column
        if columnIndex == 0 {
            return max(0.0, min(1.0, opacity))
        }
        return 1.0
    }
    
    // Simplify the columnTitle function
    private func columnTitle(_ columnNumber: Int) -> String {
        return Self.columnTitles[columnNumber]
    }
    
    // Add this helper function to get flag emoji
    private func flagEmoji(for country: String) -> String {
        let countryToFlag = [
            "Brazil": "🇧🇷",
            "U.S.": "🇺🇸",
            "Mexico": "🇲🇽",
            "Japan": "🇯🇵",
            "Thailand": "🇹🇭",
            "Denmark": "🇩🇰",
            "Senegal": "🇸🇳",
            "Fiji":"🇫🇯",
            "New Zealand": "🇳🇿",
            "France": "🇫🇷",
            "Spain": "🇪🇸",
            "Argentina": "🇦🇷",
            "Eritrea": "🇪🇷",
            "Ukraine": "🇺🇦",
            "India": "🇮🇳",
            "Taiwan": "🇹🇼",
            "Finland": "🇫🇮"
        ]
        
        return countryToFlag[country] ?? "🏳️"
    }
    
    var body: some View {
        VStack {
            // Replace HorizontalPriceColumnsView with GridSpreadsheetView
            GridSpreadsheetView(
                countries: countries,
                getColumnNumbers: getColumnNumbers,
                formatNumber: formatNumber,
                columnTitle: columnTitle,
                showFoodNames: showFoodNames,
                showCountryNames: showCountryNames,
                pinnedCountryIndex: pinnedCountryIndex,
                flagEmoji: flagEmoji,
                unpinCountry: unpinCountry,
                moveCountryToTop: moveCountryToTop,
                sortedIndices: sortedIndices,
                updateNumber: updateNumber,
                editingIndex: $editingIndex,
                editingNumber: $editingNumber,
                editingColumn: $editingColumn
            )
            .frame(maxHeight: .infinity)
        }
        .onAppear {
            loadSavedData()
            sortOrder = SortOrder(rawValue: sortOrderRawValue) ?? .original
            numberSortOrder = NumberSortOrder(rawValue: numberSortOrderRawValue) ?? .none
            selectedCurrency = Currency(rawValue: selectedCurrencyRawValue) ?? .usd
        }
                    .onChange(of: sortOrder) { _ in
            updateSortOrderStorage()
        }
        .onChange(of: numberSortOrder) { _ in
            updateSortOrderStorage()
        }
        .onChange(of: selectedCurrency) { _ in
            updateSortOrderStorage()
        }
    }
    
    var sortedIndices: [Int] {
        let indices = Array(0..<countries.count)
        var sortedIndices = indices
        
        // Apply text sort to all items (ignore pinning)
        switch sortOrder {
        case .original:
            sortedIndices = indices
        case .ascending:
            sortedIndices = indices.sorted { countries[$0] < countries[$1] }
        case .descending:
            sortedIndices = indices.sorted { countries[$0] > countries[$1] }
        }
        
        // Then apply number sort if active (ignore pinning)
        if selectedColumnIndex != nil {
            switch numberSortOrder {
            case .ascending:
                sortedIndices.sort { currentSortNumbers[$0] < currentSortNumbers[$1] }
            case .descending:
                sortedIndices.sort { currentSortNumbers[$0] > currentSortNumbers[$1] }
            case .none:
                break
            }
        }
        
        return sortedIndices
    }
    
    // Update the numberColumn computed property
    private var numberColumn: some View {
        VStack {
            // Sorting controls at the top
            HStack(spacing: 8) {
                Picker("Sort by Name", selection: $sortOrder) {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Text(order.rawValue)
                            .tag(order)
                            .font(.custom("NotoSans-Regular", size: 13))
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: sortOrder) { _ in
                    if sortOrder != .original {
                        numberSortOrder = .none
                    }
                }
                
                Picker("Sort by Price", selection: $numberSortOrder) {
                    ForEach(NumberSortOrder.allCases, id: \.self) { order in
                        Text(order.rawValue)
                            .tag(order)
                            .font(.custom("NotoSans-Regular", size: 13))
                    }
                }
                .pickerStyle(.menu)
            }
//            .padding(.bottom, 20)
            
            // Scrollable cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<10) { columnIndex in
                        let effectiveIndex = columnIndex
                        let columnNumbers = priceData[effectiveIndex]
                        
                        VStack(spacing: 10) {
                            // Summary card
                            SummaryCard(
                                columnTitle: columnTitle(effectiveIndex),
                                averagePrice: Double(columnNumbers.reduce(0, +)) / Double(columnNumbers.count),
                                columnIndex: columnIndex,
                                showFoodNames: showFoodNames
                            )
                            
                            // Price card
                            PriceColumnCard(
                                columnTitle: columnTitle(effectiveIndex),
                                prices: columnNumbers.map { formatNumber($0) },
                                countries: countries,
                                onEditPrice: { index in
                                    editingIndex = sortedIndices[index]
                                    let decimal = Double(columnNumbers[sortedIndices[index]])
                                    editingNumber = String(format: "%.2f", decimal)
                                    editingColumn = effectiveIndex + 1
                                },
                                columnIndex: columnIndex,
                                isSelected: selectedColumnIndex == columnIndex,
                                onToggle: { index in
                                    if selectedColumnIndex == index {
                                        selectedColumnIndex = nil  // Deselect if already selected
                                    } else {
                                        selectedColumnIndex = index  // Select new column
                                    }
                                }
                            )
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    // Update the SummaryCard view
    struct SummaryCard: View {
        let columnTitle: String
        let averagePrice: Double
        let columnIndex: Int
        let showFoodNames: Bool
        
        private var foodEmoji: String {
            switch columnIndex {
            case 0: return "🍕"
            case 1: return "🥪"
            case 2: return "🥚"
            case 3: return "🌯"
            case 4: return "🍊"
            case 5: return "🍎"
            case 6: return "🥯"
            case 7: return "🥞"
            case 8: return "🍗"
            case 9: return "🫑"
            default: return ""
            }
        }
        
        var body: some View {
            ZStack {
                Color.white
                    .cornerRadius(12)
                
                VStack(spacing: 4) {
                    Text(foodEmoji)
                        .font(.system(size: 20))
                    
                    if showFoodNames {
                        Text(columnTitle)
                            .font(.custom("NotoSans-Regular", size: 13))
                            .foregroundColor(.gray)
                    }
                    
                    Text("Avg: $\(String(format: "%.2f", averagePrice))")
                        .font(.custom("NotoSans-Regular", size: 15))
                        .foregroundColor(.blue)
                }
                .padding(8)
            }
            .frame(width: 120, height: 60)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    // Update the PriceColumnCard structure
    struct PriceColumnCard: View {
        let columnTitle: String
        let prices: [String]
        let countries: [String]
        let onEditPrice: (Int) -> Void
        let columnIndex: Int
        let isSelected: Bool
        let onToggle: (Int) -> Void
        
        var body: some View {
            ZStack {
                Color.white
                    .cornerRadius(12)
                
                VStack(spacing: 0) {
                    // Toggle button at the top
                    ToggleIconButton(
                        columnIndex: columnIndex,
                        isSelected: isSelected,
                        onToggle: onToggle
                    )
                    .scaleEffect(0.7)
                    .padding(.top, 8)
                    
                    VStack(spacing: 0) {
                        ForEach(Array(zip(countries.prefix(5).indices, countries.prefix(5))), id: \.0) { index, country in
                            HStack(spacing: 4) {
                                Text(prices[index])
                                    .font(.custom("NotoSans-Regular", size: 13.5))
                                    .frame(width: 60, alignment: .trailing)
                                
                                Button(action: { onEditPrice(index) }) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 12))
                                }
                            }
                            .frame(height: 60)  // Match the country row height exactly
                        }
                    }
                }
            }
            .padding(.vertical, 8)
            .frame(width: 120, height: 300)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .clipped()
        }
    }
    
    // Update the moveCountryToTop function
    private func moveCountryToTop(from index: Int) {
        // Get the actual index from the sorted indices
        let actualIndex = sortedIndices[index]
        
        print("\n=== Moving Row to Top ===")
        print("Moving country: \(countries[actualIndex])")
        print("From position: \(actualIndex)")
        
        // If there's already a pinned country, unpin it first
        if pinnedCountryIndex != nil {
            print("\nUnpinning current top row first:")
            print("Moving country \(countries[0]) back to position \(pinnedCountryOriginalIndex)")
            
            // Get the currently pinned country's data
            let pinnedCountry = countries[0]
            let pinnedPrices = priceData[0] // Store the entire row of prices
            
            // Remove pinned country from top
            countries.remove(at: 0)
            priceData.remove(at: 0)
            
            // Insert pinned country at its original position
            let originalPinnedIndex = min(pinnedCountryOriginalIndex, countries.count)
            countries.insert(pinnedCountry, at: originalPinnedIndex)
            priceData.insert(pinnedPrices, at: originalPinnedIndex)
        }
        
        // Now move the new row to the top
        print("\nMoving new row to top:")
        
        // Get the values to move
        let country = countries[actualIndex]
        let prices = priceData[actualIndex] // Store the entire row of prices
        
        // Remove from current position
        countries.remove(at: actualIndex)
        priceData.remove(at: actualIndex)
        
        // Insert at the top
        countries.insert(country, at: 0)
        priceData.insert(prices, at: 0)
        
        // Update pinned state for new row
        pinnedCountryIndex = 0
        pinnedCountryOriginalIndex = actualIndex
        
        saveData()
    }
    
    // Update the unpinCountry function
    private func unpinCountry() {
        if pinnedCountryIndex != nil {
            print("\n=== Unpinning Row ===")
            print("Moving country: \(countries[0])")
            print("Back to position: \(pinnedCountryOriginalIndex)")
            print("Values being moved: $\(priceData[0][0]), $\(priceData[0][1]), $\(priceData[0][2]), $\(priceData[0][3]), $\(priceData[0][4]), $\(priceData[0][5]), $\(priceData[0][6]), $\(priceData[0][7]), $\(priceData[0][8]), $\(priceData[0][9])")
            
            // Get the country and its data
            let country = countries[0]
            let number = priceData[0][0]
            let number2 = priceData[0][1]
            let number3 = priceData[0][2]
            let number4 = priceData[0][3]
            let number5 = priceData[0][4]
            let number6 = priceData[0][5]
            let number7 = priceData[0][6]
            let number8 = priceData[0][7]
            let number9 = priceData[0][8]
            let number10 = priceData[0][9]
            
            // Remove from top
            countries.remove(at: 0)
            priceData.remove(at: 0)
            
            // Insert at original position
            let originalIndex = min(pinnedCountryOriginalIndex, countries.count)
            countries.insert(country, at: originalIndex)
            priceData.insert([number, number2, number3, number4, number5, number6, number7, number8, number9, number10], at: originalIndex)
            
            // Print debug info BEFORE saving
            print("\n=== After Unpin ===")
            for i in 0..<countries.count {
                print("\(countries[i]): $\(priceData[i][0]), $\(priceData[i][1]), $\(priceData[i][2]), $\(priceData[i][3]), $\(priceData[i][4]), $\(priceData[i][5]), $\(priceData[i][6]), $\(priceData[i][7]), $\(priceData[i][8]), $\(priceData[i][9])")
            }
            print("==================\n")
            
            // Clear the pinned state
            pinnedCountryIndex = nil
            pinnedCountryOriginalIndex = -1
            
            saveData()
        }
    }
    
    // Update the getColumnNumbers function to handle out-of-range indices
    private func getColumnNumbers(_ columnIndex: Int) -> [Int] {
        // Return all values for the given column across all countries
        // Safely handle the case where columnIndex is out of range
        return priceData.map { row in
            // If the columnIndex is within range, return the value, otherwise return 0
            columnIndex < row.count ? row[columnIndex] : 0
        }
    }
    
    // Update the updateNumber function
    private func updateNumber(_ number: Int, at index: Int, column: Int) {
        // Ensure the index and column are valid
        guard index >= 0, index < priceData.count, 
              column > 0, column <= 10 else {
            print("Invalid index or column: \(index), \(column)")
            return
        }
        
        // Ensure the row has enough elements
        while priceData[index].count < column {
            priceData[index].append(0)
        }
        
        // Update the value
        priceData[index][column - 1] = number
        
        // Save the updated data
        if let encoded = try? JSONEncoder().encode(priceData) {
            priceDataData = encoded
        }
        
        // Debug print to verify the data was updated
        print("Updated priceData[\(index)][\(column-1)] to \(number)")
        print("Current value: \(priceData[index][column-1])")
    }
}

struct EditingItem: Identifiable {
    let id: Int
    
    init(id: Int = 0) {
        self.id = id
    }
}

struct DropViewDelegate: DropDelegate {
    let item: String
    @Binding var items: [String]
    @Binding var priceData: [[Int]]
    @Binding var numbers: [Int]
    @Binding var numbers2: [Int]
    @Binding var numbers3: [Int]
    @Binding var numbers4: [Int]
    @Binding var numbers5: [Int]
    @Binding var numbers6: [Int]
    @Binding var numbers7: [Int]
    @Binding var numbers8: [Int]
    @Binding var numbers9: [Int]
    @Binding var numbers10: [Int]
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let fromIndex = items.firstIndex(of: item) else { return }
        
        if let fromItem = info.itemProviders(for: [.text]).first {
            fromItem.loadObject(ofClass: NSString.self) { string, _ in
                guard let identifier = string as? String,
                      let toIndex = items.firstIndex(of: identifier) else { return }
                
                DispatchQueue.main.async {
                    let fromItem = items[fromIndex]
                    let fromNumber = priceData[fromIndex][0]
                    let fromNumber2 = priceData[fromIndex][1]
                    let fromNumber3 = priceData[fromIndex][2]
                    let fromNumber4 = priceData[fromIndex][3]
                    let fromNumber5 = priceData[fromIndex][4]
                    let fromNumber6 = priceData[fromIndex][5]
                    let fromNumber7 = priceData[fromIndex][6]
                    let fromNumber8 = priceData[fromIndex][7]
                    let fromNumber9 = priceData[fromIndex][8]
                    let fromNumber10 = priceData[fromIndex][9]
                    
                    items.remove(at: fromIndex)
                    priceData.remove(at: fromIndex)
                    
                    items.insert(fromItem, at: toIndex)
                    priceData.insert([fromNumber, fromNumber2, fromNumber3, fromNumber4, fromNumber5, fromNumber6, fromNumber7, fromNumber8, fromNumber9, fromNumber10], at: toIndex)
                }
            }
        }
    }
}

// First, create the two views for the tabs
struct PricesView: View {
    var body: some View {
        PricesContentView()
    }
}

struct CheckmarkToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Rectangle()
                .foregroundColor(configuration.isOn ? .green : .gray)
                .frame(width: 51, height: 31, alignment: .center)
                .overlay(
                    Circle()
                        .foregroundColor(.white)
                        .padding(.all, 3)
                        .overlay(
                            Image(systemName: configuration.isOn ? "checkmark" : "xmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .font(Font.title.weight(.black))
                                .frame(width: 8, height: 8, alignment: .center)
                                .foregroundColor(configuration.isOn ? .green : .gray)
                        )
                        .offset(x: configuration.isOn ? 11 : -11, y: 0)
                        .animation(Animation.linear(duration: 0.1))
                        
                ).cornerRadius(20)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}

struct SettingsView: View {
    @AppStorage("showFoodNames") private var showFoodNames: Bool = true
    @AppStorage("showCountryNames") private var showCountryNames: Bool = true
    @AppStorage("selectedCurrency") private var selectedCurrencyRawValue: String = Currency.usd.rawValue
    
    var body: some View {
        NavigationView {
        Form {
            Section(header: Text("Display Options")) {
                    Toggle("Show Country Names", isOn: $showCountryNames)
                    Toggle("Show Food Names", isOn: $showFoodNames)
                }
                
                Section(header: Text("Currency")) {
                    Picker("Currency", selection: $selectedCurrencyRawValue) {
                        ForEach(Currency.allCases, id: \.self) { currency in
                            Text("\(currency.rawValue) (\(currency.symbol))").tag(currency.rawValue)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        }
    }
}

// Create a new main view to handle the tab navigation
struct MainView: View {
    var body: some View {
        TabView {
            PricesView()
                .tabItem {
                    Label("Prices", systemImage: "dollarsign.circle.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

// Add the ToggleIconButton view
struct ToggleIconButton: View {
    let columnIndex: Int
    let isSelected: Bool
    let onToggle: (Int) -> Void
    
    var body: some View {
        ZStack {
            // Background and border
            RoundedRectangle(cornerRadius: 15)
                .fill(isSelected ? Color.black : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.black, lineWidth: 1)
                )
            
            // Custom three-line icon with circles
            HStack(spacing: 6) {
                VerticalLineWithDot()
                VerticalLineWithDot()
                VerticalLineWithDot()
            }
            .foregroundColor(isSelected ? .white : .black)
        }
        .frame(width: 40, height: 40)
        .onTapGesture {
            withAnimation {
                onToggle(columnIndex)
            }
        }
    }
}

// Helper view for the vertical line with circle
struct VerticalLineWithDot: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(width: 2, height: 10)
            Circle()
                .frame(width: 6, height: 6)
            Rectangle()
                .frame(width: 2, height: 10)
        }
    }
}

#Preview {
    MainView()
}

// Add these helper views
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CountryRow: View {
    let index: Int
    let countries: [String]
    let showCountryNames: Bool
    let pinnedCountryIndex: Int?
    let flagEmoji: (String) -> String
    let unpinCountry: () -> Void
    let moveCountryToTop: (Int) -> Void
    let pinnedCountryOriginalIndex: Int
    
    var body: some View {
        VStack(spacing: 2) {
            Text(flagEmoji(countries[index]))
                .font(.system(size: 20))
            
            HStack(spacing: 4) {
                if index == 0 && pinnedCountryIndex != nil {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                        .onTapGesture {
                            unpinCountry()
                        }
                }
                Text(showCountryNames ? countries[index] : "")
                    .font(.custom("NotoSans-Regular", size: 15))
                    .frame(width: 72, height: 20, alignment: .leading)
            }
        }
        .padding(.vertical, 9)
        .onLongPressGesture {
            moveCountryToTop(index)
        }
    }
}

struct PriceRow: View {
    let index: Int
    let columnIndex: Int
    let getNumbers: (Int) -> [Int]
    let onEditPrice: (Int) -> Void
    let formatNumber: (Int) -> String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(formatNumber(getNumbers(columnIndex)[index]))
                .font(.custom("NotoSans-Regular", size: 15))
                .frame(width: 60, alignment: .trailing)
            
            Button(action: { onEditPrice(index) }) {
                Image(systemName: "pencil")
                    .font(.system(size: 12))
            }
        }
        .frame(height: 68)  // Increased by 70% from 60
    }
}

// Add this view to handle the synchronized scrolling
struct ScrollingSectionView: View {
    let sortedIndices: [Int]
    let countries: [String]
    let showCountryNames: Bool
    let pinnedCountryIndex: Int?
    let flagEmoji: (String) -> String
    let unpinCountry: () -> Void
    let moveCountryToTop: (Int) -> Void
    let pinnedCountryOriginalIndex: Int
    @Binding var sharedScrollPosition: CGFloat
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(sortedIndices, id: \.self) { index in
                        GeometryReader { geometry in
                            CountryRow(
                                index: index,
                                countries: countries,
                                showCountryNames: showCountryNames,
                                pinnedCountryIndex: pinnedCountryIndex,
                                flagEmoji: flagEmoji,
                                unpinCountry: unpinCountry,
                                moveCountryToTop: moveCountryToTop,
                                pinnedCountryOriginalIndex: pinnedCountryOriginalIndex
                            )
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                        }
                        .frame(height: 60)
                        .id(index)
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                sharedScrollPosition = offset
            }
        }
    }
}

// 1. First, let's create a SortingControlsView
struct SortingControlsView: View {
    @Binding var sortOrder: SortOrder
    @Binding var numberSortOrder: NumberSortOrder
    
    var body: some View {
        HStack(spacing: 8) {
            Picker("Sort by Name", selection: $sortOrder) {
                ForEach(SortOrder.allCases, id: \.self) { order in
                    Text(order.rawValue)
                        .tag(order)
                        .font(.custom("NotoSans-Regular", size: 13))
                }
            }
            .pickerStyle(.menu)
            .onChange(of: sortOrder) { _ in
                if sortOrder != .original {
                    numberSortOrder = .none
                }
            }
            
            Picker("Sort by Price", selection: $numberSortOrder) {
                ForEach(NumberSortOrder.allCases, id: \.self) { order in
                    Text(order.rawValue)
                        .tag(order)
                        .font(.custom("NotoSans-Regular", size: 13))
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.top, 110)
        .padding(.bottom, 10)
    }
}

// 2. Create a SummaryCardView
struct SummaryCardView: View {
    let title: String
    let average: Double
    let columnIndex: Int
    let showFoodNames: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            if showFoodNames {
                Text(title)
                    .font(.custom("NotoSans-Regular", size: 13))
                    .foregroundColor(.gray)
            }
            Text(String(format: "%.1f", average))
                .font(.custom("NotoSans-Regular", size: 15))
                .foregroundColor(.blue)
        }
        .frame(width: 80)
        .padding(.vertical, 8)
        .background(Color.white)
    }
}

// 3. Create a PriceColumnView
struct PriceColumnView: View {
    let columnIndex: Int
    let sortedIndices: [Int]
    let getNumbers: (Int) -> [Int]
    let formatNumber: (Int) -> String
    let onEditPrice: (Int) -> Void
    @Binding var sharedScrollPosition: CGFloat
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(sortedIndices, id: \.self) { index in
                        PriceRow(
                            index: index,
                            columnIndex: columnIndex,
                            getNumbers: getNumbers,
                            onEditPrice: onEditPrice,
                            formatNumber: formatNumber
                        )
                        .frame(height: 60)
                        .id(index)
                    }
                }
            }
            .onChange(of: sharedScrollPosition) { newPosition in
                withAnimation {
                    if let firstIndex = sortedIndices.first {
                        proxy.scrollTo(firstIndex, anchor: .top)
                    }
                }
            }
        }
    }
}

// 4. Create a HorizontalPriceColumnsView
struct GridSpreadsheetView: View {
    let countries: [String]
    let getColumnNumbers: (Int) -> [Int]
    let formatNumber: (Int) -> String
    let columnTitle: (Int) -> String
    let showFoodNames: Bool
    let showCountryNames: Bool
    let pinnedCountryIndex: Int?
    let flagEmoji: (String) -> String
    let unpinCountry: () -> Void
    let moveCountryToTop: (Int) -> Void
    let sortedIndices: [Int]
    let updateNumber: (Int, Int, Int) -> Void
    @Binding var editingIndex: Int?
    @Binding var editingNumber: String
    @Binding var editingColumn: Int
    @AppStorage("selectedCurrency") private var selectedCurrencyRawValue: String = Currency.usd.rawValue
    @State private var localSortOrder: SortOrder = .original
    @State private var localNumberSortOrder: NumberSortOrder = .none
    @State private var selectedPriceColumn: Int = 0
    
    // Add a function to reset prices to initial values
    private func resetPrices() {
        // Default values for each food item across countries
        let defaultPrices = [
            [15, 6, 3, 6, 1, 1, 4, 6, 6, 1],
            [20, 15, 6, 10, 1, 2, 1, 10, 18, 2],
            [9, 5, 2, 5, 1, 1, 2, 5, 15, 1],
            [20, 5, 2, 11, 2, 2, 2, 7, 10, 2],
            [9, 2, 2, 5, 1, 1, 1, 3, 7, 1],
            [15, 10, 5, 17, 1, 2, 5, 11, 17, 2],
            [9, 2, 2, 4, 1, 1, 2, 2, 5, 2],
            [6, 10, 5, 7, 3, 1, 2, 12, 3, 1],
            [9, 9, 6, 14, 1,1, 5, 3 ,10,2 ],
            [15, 4, 4, 18, 1, 1, 1, 1, 10, 1],
            [4,5, 3, 10, 1, 1, 5, 7, 12, 1],
            [15, 5, 3, 4, 1, 1, 1, 4, 10,1 ],
            [10, 2, 5, 15, 5, 1, 1, 1, 10, 1],
            [7, 2, 1,2 , 1, 1, 1, 1, 2, 1],
            [4, 2, 4, 4, 1, 1, 1, 1, 3,1 ],
            [17, 6, 6, 10, 2, 2, 2, 2, 5,1 ],
            [16, 10, 4, 20 , 1, 1, 4, 4, 16,2 ]
        ]
        
        // Reset each country's prices to default
        for (countryIndex, _) in countries.enumerated().prefix(min(countries.count, defaultPrices.count)) {
            for (foodIndex, defaultPrice) in defaultPrices[countryIndex].enumerated().prefix(10) {
                updateNumber(defaultPrice, countryIndex, foodIndex + 1)
            }
        }
    }
    
    // Get indices based on current sort option
    private var displayIndices: [Int] {
        // Start with indices based on text sorting
        var indices: [Int]
        
        // Sort all countries (ignore pinning)
        switch localSortOrder {
        case .original:
            indices = Array(0..<countries.count)
        case .ascending:
            indices = countries.indices.sorted { countries[$0].lowercased() < countries[$1].lowercased() }
        case .descending:
            indices = countries.indices.sorted { countries[$0].lowercased() > countries[$1].lowercased() }
        }
        
        // Then apply price sorting if active (ignore pinning)
        if localNumberSortOrder != .none {
            switch localNumberSortOrder {
            case .ascending:
                indices.sort { getColumnNumbers(selectedPriceColumn)[$0] < getColumnNumbers(selectedPriceColumn)[$1] }
            case .descending:
                indices.sort { getColumnNumbers(selectedPriceColumn)[$0] > getColumnNumbers(selectedPriceColumn)[$1] }
            case .none:
                break
            }
        }
        
        return indices
    }
    
    // Main body
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            VStack(spacing: 0) {
                // Add extra top padding - reduced in landscape
                Spacer()
                    .frame(height: isLandscape ? 30 : 60) // Reduced by 30px in landscape
                
                // Sort dropdown in a card above the grid
                ZStack {
                    // Card background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Sort controls
                    VStack(spacing: 0) {
                        // Country sort picker
                        SortPickerView(localSortOrder: $localSortOrder)
                            .onChange(of: localSortOrder) { newValue in
                                // If alphabetical sorting is selected, reset price sorting to default
                                if newValue != .original {
                                    localNumberSortOrder = .none
                                }
                            }
                            .padding(.bottom, isLandscape ? 5 : 10) // Reduced padding in landscape
                        
                        // Price sort picker - REVISED
                        VStack {
                            Text("Sort Price:\n")
                                .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                            
                            // Price order picker (high to low, low to high)
                            Picker("Order", selection: $localNumberSortOrder) {
                                Text("Select").tag(NumberSortOrder.none)
                                Text("High to Low").tag(NumberSortOrder.descending)
                                Text("Low to High").tag(NumberSortOrder.ascending)
                            }
                            .pickerStyle(.menu)
                            .frame(width: 150)
                            .onChange(of: localNumberSortOrder) { newValue in
                                // If price sorting is selected, reset country sorting to default
                                if newValue != .none {
                                    localSortOrder = .original
                                }
                            }
                        }
                        .padding(.horizontal, 15)
                        
                        // Add a separate row for the column selection
                        VStack {
                            Text("On Column:\n")
                                .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                        
                            
                            // Column picker (1-7)
                            Picker("", selection: $selectedPriceColumn) {
                                ForEach(0..<7, id: \.self) { index in
                                    Text("\(index + 1)")
                                        .tag(index)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 120)
                            .disabled(localNumberSortOrder == .none) // Only enable when sorting is active
                        }
                        .padding(.horizontal, 15)
                        .padding(.top, isLandscape ? 4 : 8) // Reduced spacing in landscape
                        
                        // Add spacer to push button to bottom
                        Spacer()
                        
                        // Reset prices button at the bottom
//                        Button(action: {
//                            resetPrices()
//                        }) {
//                            Text("Reset Initial Prices")
//                                .font(.system(size: 15, weight: .medium))
//                                .foregroundColor(.white)
//                                .padding(.vertical, isLandscape ? 6 : 8) // Smaller button in landscape
//                                .padding(.horizontal, 20)
//                                .background(Color.blue)
//                                .cornerRadius(8)
//                        }
//                        .padding(.bottom, isLandscape ? 10 : 15) // Reduced bottom padding in landscape
                    }
                    .padding(.top, isLandscape ? 10 : 15) // Reduced top padding in landscape
                }
                .frame(height: isLandscape ? 150 : 170) // Reduced height in landscape
                .padding(.horizontal, 80)
                .padding(.bottom, isLandscape ? 20 : 40) // Reduced bottom padding in landscape
                .padding(.top, 10)
                
                // Scrollable content
                MainContentView(
                    countries: countries,
                    displayIndices: displayIndices,
                    showCountryNames: showCountryNames,
                    pinnedCountryIndex: pinnedCountryIndex,
                    flagEmoji: flagEmoji,
                    unpinCountry: unpinCountry,
                    moveCountryToTop: moveCountryToTop,
                    getColumnNumbers: getColumnNumbers,
                    formatNumber: formatNumber,
                    columnTitle: columnTitle,
                    showFoodNames: showFoodNames,
                    editingIndex: $editingIndex,
                    editingNumber: $editingNumber,
                    editingColumn: $editingColumn
                )
            }
            .background(Color.white)
        }
    }
    
    // Helper function to get food emoji
    private func getFoodEmoji(_ columnIndex: Int) -> String {
        switch columnIndex {
        case 0: return "🍕"
        case 1: return "🥪"
        case 2: return "🥚"
        case 3: return "🌯"
        case 4: return "🍊"
        case 5: return "🍎"
        case 6: return "🥯"
        case 7: return "🥞"
        case 8: return "🍗"
        case 9: return "🫑"
        default: return ""
        }
    }
}

// MARK: - Subcomponents for GridSpreadsheetView

// Sort picker component
struct SortPickerView: View {
    @Binding var localSortOrder: SortOrder
    
    var body: some View {
        VStack {
            Text("Sort Countries:\n")
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            Picker("Sort", selection: $localSortOrder) {
                ForEach(SortOrder.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.horizontal, 15)
    }
}

// Main content view component
struct MainContentView: View {
    let countries: [String]
    let displayIndices: [Int]
    let showCountryNames: Bool
    let pinnedCountryIndex: Int?
    let flagEmoji: (String) -> String
    let unpinCountry: () -> Void
    let moveCountryToTop: (Int) -> Void
    let getColumnNumbers: (Int) -> [Int]
    let formatNumber: (Int) -> String
    let columnTitle: (Int) -> String
    let showFoodNames: Bool
    @Binding var editingIndex: Int?
    @Binding var editingNumber: String
    @Binding var editingColumn: Int
    @AppStorage("selectedCurrency") private var selectedCurrencyRawValue: String = Currency.usd.rawValue
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            HStack(spacing: 0) {
                // Fixed country column
                CountryColumnView(
                    countries: countries,
                    displayIndices: displayIndices,
                    showCountryNames: showCountryNames,
                    pinnedCountryIndex: pinnedCountryIndex,
                    flagEmoji: flagEmoji,
                    unpinCountry: unpinCountry,
                    moveCountryToTop: moveCountryToTop
                )
                
                // Horizontal scrollable content with Grid
                PriceGridView(
                    displayIndices: displayIndices,
                    getColumnNumbers: getColumnNumbers,
                    formatNumber: formatNumber,
                    columnTitle: columnTitle,
                    showFoodNames: showFoodNames,
                    selectedCurrencyRawValue: selectedCurrencyRawValue,
                    editingIndex: $editingIndex,
                    editingNumber: $editingNumber,
                    editingColumn: $editingColumn
                )
            }
        }
    }
}

// Country column component
struct CountryColumnView: View {
    let countries: [String]
    let displayIndices: [Int]
    let showCountryNames: Bool
    let pinnedCountryIndex: Int?
    let flagEmoji: (String) -> String
    let unpinCountry: () -> Void
    let moveCountryToTop: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 1) {
            // Empty transparent cell in place of "Food Items →"
            Rectangle()
                .fill(Color.clear)
                .frame(width: 100, height: 82) // Increased by 20% from 68
                .border(Color.gray, width: 0.5)
            
            // Country rows
            ForEach(displayIndices, id: \.self) { index in
                VStack(spacing: 4) {
                    // Flag row (removed pin icon)
                    HStack(alignment: .center, spacing: 4) {
                        Text(flagEmoji(countries[index]))
                            .font(.system(size: 24))
                    }
                    
                    // Country name (only if showCountryNames is true)
                    if showCountryNames {
                        Text(countries[index])
                            .lineLimit(1)
                            .font(.system(size: 17))
                    }
                }
            }
            .frame(width: 100, height: 82) // Increased by 20% from 68
            .background(Color.white)
            .border(Color.gray, width: 0.5)
            .id("country_\(index)")
        }
        .padding(.leading, 10)
    }
}

// Price grid component
struct PriceGridView: View {
    let displayIndices: [Int]
    let getColumnNumbers: (Int) -> [Int]
    let formatNumber: (Int) -> String
    let columnTitle: (Int) -> String
    let showFoodNames: Bool
    let selectedCurrencyRawValue: String
    @Binding var editingIndex: Int?
    @Binding var editingNumber: String
    @Binding var editingColumn: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            Grid(alignment: .center, horizontalSpacing: 1, verticalSpacing: 1) {
                // Food names header row
                FoodHeaderRow(columnTitle: columnTitle, showFoodNames: showFoodNames)
                
                // Price data rows
                ForEach(displayIndices, id: \.self) { index in
                    GridRow {
                        ForEach(0..<10, id: \.self) { colIndex in
                            Text(formatNumber(getColumnNumbers(colIndex)[index]))
                                .font(.system(size: 17))
                                .frame(width: 100, height: 82) // Increased by 20% from 68
                                .background(Color.white)
                                .border(Color.gray, width: 0.5)
                                .onTapGesture {
                                    // Use the actual index from displayIndices, not the loop index
                                    let actualIndex = displayIndices[index]
                                    editingIndex = actualIndex
                                    editingColumn = colIndex + 1
                                    
                                    // Format the initial value correctly based on the current currency
                                    let rawValue = getColumnNumbers(colIndex)[actualIndex]
                                    let currentCurrency = Currency(rawValue: selectedCurrencyRawValue) ?? .usd
                                    let convertedValue = Double(rawValue) * currentCurrency.conversionRate
                                    
                                    // Format without the currency symbol for editing
                                    let formatter = NumberFormatter()
                                    formatter.numberStyle = .decimal
                                    formatter.minimumFractionDigits = 2
                                    formatter.maximumFractionDigits = 2
                                    editingNumber = formatter.string(from: NSNumber(value: convertedValue)) ?? "0.00"
                                }
                                .id("cell_\(index)_\(colIndex)")
                        }
                    }
                }
            }
            .padding(.trailing)
        }
    }
}

// Food header row component
struct FoodHeaderRow: View {
    let columnTitle: (Int) -> String
    let showFoodNames: Bool
    
    var body: some View {
        GridRow {
            ForEach(0..<10, id: \.self) { colIndex in
                VStack(spacing: 4) {
                    Text(getFoodEmoji(colIndex))
                        .font(.system(size: 24))
                    if showFoodNames {
                        Text(columnTitle(colIndex))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                .frame(width: 100, height: 82) // Increased by 20% from 68
                .background(Color.white)
                .border(Color.gray, width: 0.5)
            }
        }
    }
    
    // Helper function to get food emoji
    private func getFoodEmoji(_ columnIndex: Int) -> String {
        switch columnIndex {
        case 0: return "🍕"
        case 1: return "🥪"
        case 2: return "🥚"
        case 3: return "🌯"
        case 4: return "🍊"
        case 5: return "🍎"
        case 6: return "🥯"
        case 7: return "🥞"
        case 8: return "🍗"
        case 9: return "🫑"
        default: return ""
        }
    }
}

// Update the NumberEditView to handle currency conversion
struct NumberEditView: View {
    @Binding var number: String
    let onSave: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("selectedCurrency") private var selectedCurrencyRawValue: String = Currency.usd.rawValue
    
    // Get the current currency
    private var currentCurrency: Currency {
        Currency(rawValue: selectedCurrencyRawValue) ?? .usd
    }
    
    // Convert the entered value back to USD
    private func convertToUSD() -> Int? {
        // Remove currency symbol and any non-numeric characters except decimal point
        let cleanedNumber = number.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        
        if let value = Double(cleanedNumber) {
            // Convert from current currency to USD
            let usdValue = value / currentCurrency.conversionRate
            // Round to nearest integer since our data model stores integers
            return Int(round(usdValue))
        }
        return nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Enter number", text: $number)
                    .keyboardType(.decimalPad)
                
                // Show the conversion information
                if currentCurrency != .usd {
                    HStack {
                        Text("Will be saved as:")
                        Spacer()
                        if let usdValue = convertToUSD() {
                            Text("$\(String(format: "%.2f", Double(usdValue)))")
                                .foregroundColor(.secondary)
                        } else {
                            Text("Invalid number")
                                .foregroundColor(.red)
                        }
                    }
                    .font(.caption)
                    .padding(.top, 4)
                }
            }
            .navigationTitle("Edit Price")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
