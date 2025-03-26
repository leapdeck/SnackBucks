//
//  SnackBucksApp.swift
//  SnackBucks
//
//  Created by modview on 3/5/25.
//

//import SwiftUI
//
//@main
//struct CartMeshApp: App {
//    var body: some Scene {
//        WindowGroup {
//            MainView()
//        }
//    }
//}

import SwiftUI

@main
struct SnackBucksApp: App {
    @State private var isShowingSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isShowingSplash {
                    LaunchScreen()
                } else {
                    ContentView()
                }
            }
            .onAppear {
                // Simulate a delay for the launch screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isShowingSplash = false
                    }
                }
            }
        }
    }
}

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image("LaunchLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
