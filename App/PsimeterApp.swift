import SwiftUI

@main
struct PsimeterApp: App {
    private let showsGallery = ProcessInfo.processInfo.arguments.contains("-gallery")
    private let largeState = UserDefaults.standard.string(forKey: "gallery-large")

    var body: some Scene {
        WindowGroup {
            if let largeState {
                LargeGalleryView(state: largeState)
            } else if showsGallery {
                GalleryView()
            } else {
                HomeView()
            }
        }
    }
}
