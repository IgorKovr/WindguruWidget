import Foundation

/// Can be used as `ObservedObject` for `WKNavigationDelegate`
public class WebViewModel: ObservableObject {
    /// `URLRequest` renderable inside `WKWebView`
    @Published public var request: URLRequest
    /// `didFinishLoading` is being called from `WKNavigationDelegate`
    @Published public var didFinishLoading: Bool = false
//    public var onDidFinishLoading: ()->Void = {}

    /// If URL cannot be created from string using `URL(string:)` will return nil and print error in console
    public convenience init?(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("cannot create valid `URL` from \(urlString)")
            return nil
        }
        self.init(url: url)
    }
    
    public convenience init(url: URL) {
        self.init(request: URLRequest(url: url))
    }
    
    public init(request: URLRequest) {
        self.request = request
    }
}


// Common
import WebKit

extension SwiftUIWKWebView {
    public class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: WebViewModel

        init(_ viewModel: WebViewModel) {
            self.viewModel = viewModel
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
            self.viewModel.didFinishLoading = true
        }
    }

    public func makeCoordinator() -> SwiftUIWKWebView.Coordinator {
        Coordinator(viewModel)
    }
    
    /// Init `SwiftUIWebView` and create `WebViewModel` with URL.
    /// If URL cannot be created from string using `URL(string:)` will return nil
    /// - Parameter urlString: URLString, ex: `https://apple.com`
    public init?(urlString: String) {
        guard let viewModel = WebViewModel(urlString: urlString) else {
            return nil
        }
        self.init(viewModel: viewModel)
    }
    
    /// Init `SwiftUIWebView` and create `WebViewModel` with URL.
    /// - Parameter url: URL, ex: URL(string: "https://apple.com")
    public init(url: URL) {
        self.init(viewModel: .init(url: url))
    }
    
    /// Init `SwiftUIWebView` and create `WebViewModel` with URL.
    /// - Parameter request: `URLRequest` that can be represent as webpage
    public init(request: URLRequest) {
        self.init(viewModel: .init(request: request))
    }
}

// AppKit

import SwiftUI
import WebKit

#if canImport(AppKit)
import AppKit

public struct SwiftUIWKWebView : NSViewRepresentable {
    public typealias NSViewType = WKWebView
    
    @ObservedObject var viewModel: WebViewModel
    
    public let webView: WKWebView = WKWebView()
            
    public func makeNSView(context: Context) -> WKWebView {
        self.webView.navigationDelegate = context.coordinator
        self.webView.load(viewModel.request)
        return self.webView
    }

    public func updateNSView(_ nsView: WKWebView, context: Context) { }
}

#if DEBUG
struct SwiftUIWKWebView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIWKWebView(viewModel: WebViewModel(urlString: "https://www.windguru.cz/48134")!)
    }
}
#endif

#endif
