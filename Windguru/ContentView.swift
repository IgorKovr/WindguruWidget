import SwiftUI
import WebKit
import Cocoa
import WebKit

struct ContentView: View {
    private static let url = "https://www.windguru.cz/48134"
    private var filePath: URL {
        let filename = "windguru_screnshot_image.png"
        do {
            let downloadsURL = try FileManager.default.url(for: .downloadsDirectory,
                                                           in: .userDomainMask,
                                                           appropriateFor: nil,
                                                           create: true)
            return downloadsURL.appendingPathComponent(filename)
        } catch {
            let path = URL(fileURLWithPath: "./\(filename))")
            print("Error: couldn't locate Downloads folder \(error), saving to a custom path: \(path)")
            return path
        }
    }
    private let webViewVM: WebViewModel
    private let webView: SwiftUIWKWebView
    
    init() {
        self.webViewVM = WebViewModel(urlString: Self.url)!
        self.webView = SwiftUIWKWebView(viewModel: self.webViewVM)
    }
    
    var body: some View {
        VStack {
            webView
                .onReceive(webViewVM.$didFinishLoading) { didFinish in
                    if didFinish {
                        print("The web content has finished loading")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            //                    DispatchQueue.main.async {
                            captureWebView(webView.webView, rect: .init(x: 10, y: 150, width: 800, height: 400)) { image in
                                guard let image = image else {
                                    print("failed to generate screenshot")
                                    return
                                }
                                saveImage(image)
                            }
                        }
                    } else {
                        print("waiting to finish loading")
                    }
            }
        }

    }
    
    private func saveImage(_ image: NSImage) {
        guard let data = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: data),
              let imageData = bitmapImage.representation(using: .png, properties: [:]) else { return }
        do {
            try imageData.write(to: filePath)
            print("Image succesfully saved to \(filePath)")
        }
        catch {
            print("Failed to save image \(error)")
        }
    }
    
    private func captureWebView(_ webView: WKWebView, completion: @escaping (NSImage?) -> Void) {
        // Ensure the web content is fully loaded and laid out
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                webView.takeSnapshot(with: nil) { (image, error) in
                    guard let image = image, error == nil else {
                        print("Snapshot error: \(String(describing: error))")
                        completion(nil)
                        return
                    }
                    completion(image)
                }
            }
        })
    }
    
    func captureWebView(_ webView: WKWebView, rect: CGRect?, completion: @escaping (NSImage?) -> Void) {
        // Check if the web content is fully loaded
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                let configuration = WKSnapshotConfiguration()
                if let rect = rect {
                    // Specify the rect of the page to snapshot
                    configuration.rect = rect
                }

                // Take a snapshot of the specified area
                webView.takeSnapshot(with: configuration) { (image, error) in
                    guard let image = image, error == nil else {
                        print("Snapshot error: \(String(describing: error))")
                        completion(nil)
                        return
                    }
                    completion(image)
                }
            }
        })
    }
}

#Preview {
    ContentView()
}
