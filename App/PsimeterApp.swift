import SwiftUI

@main
struct PsimeterApp: App {
    private let showsGallery = ProcessInfo.processInfo.arguments.contains("-gallery")
    private let showsAgedGallery = ProcessInfo.processInfo.arguments.contains("-gallery-aged")
    private let largeState = UserDefaults.standard.string(forKey: "gallery-large")
    private let smallState = UserDefaults.standard.string(forKey: "gallery-small")

    var body: some Scene {
        WindowGroup {
            if let largeState {
                LargeGalleryView(state: largeState)
            } else if let smallState {
                GalleryView(cases: Demo.cases.filter { $0.id == smallState })
            } else if showsAgedGallery {
                GalleryView(cases: Demo.cases.filter { $0.wear == .aged }, largeCases: Demo.largeCases.filter { $0.wear == .aged })
            } else if showsGallery {
                GalleryView()
            } else {
                HomeView()
            }
        }
    }
}
