import SwiftUI
import WebKit

#if canImport(UIKit)

import UIKit

public struct SwiftUIWKWebView: UIViewRepresentable {
    public typealias NSViewType = WKWebView
    
    @ObservedObject var viewModel: WebViewModel
    
    public let webView: WKWebView = WKWebView()

    public func makeUIView(context: UIViewRepresentableContext<SwiftUIWKWebView>) -> WKWebView {
        self.webView.navigationDelegate = context.coordinator
        self.webView.load(viewModel.request)
        
        captureWebView(completion: { image in
            print("booya")
        })
        return self.webView
    }

    public func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<SwiftUIWKWebView>) { }
    
    private func captureWebView(completion: @escaping (NSImage?) -> Void) {
        let contentRect = webView.bounds

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
}


#if DEBUG
struct SwiftUIWKWebView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIWKWebView(viewModel: WebViewModel(urlString: "https://twitter.com/jkmazur")!)
    }
}
#endif

#endif
