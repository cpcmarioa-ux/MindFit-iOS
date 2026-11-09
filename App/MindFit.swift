import SwiftUI
import WebKit

private let site = URL(string: "https://fitforever-habitos.silkymanatee.chatgpt.site")!

@main
struct MindFitApp: App {
    var body: some Scene {
        WindowGroup { TodayView() }
    }
}

struct TodayView: View {
    @StateObject private var session = PlanBrowser()

    var body: some View {
        VStack(spacing: 0) {
            if session.failed {
                ContentUnavailableView {
                    Label("MindFit", systemImage: "wifi.exclamationmark")
                } description: {
                    Text("Comprueba tu conexión para abrir tu plan.")
                } actions: {
                    Button("Volver a intentar") { session.retry() }
                }
            } else {
                PlanView(session: session)
            }
            Divider()
            HStack {
                Button { session.web.goBack() } label: { Label("Volver", systemImage: "chevron.left") }
                    .disabled(!session.canReturn)
                Spacer()
                ShareLink(item: site) { Label("Compartir MindFit", systemImage: "square.and.arrow.up") }
            }.padding(.horizontal).padding(.vertical, 8)
        }.tint(.teal)
    }
}

final class PlanBrowser: NSObject, ObservableObject, WKNavigationDelegate {
    let web = WKWebView()
    @Published var failed = false
    @Published var canReturn = false
    private var lastPage: URL

    override init() {
        lastPage = site
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--demo") {
            lastPage = site.appendingPathComponent("demo")
        }
        #endif
        super.init()
        web.navigationDelegate = self
        web.allowsBackForwardNavigationGestures = true
        retry()
    }

    func retry() {
        failed = false
        web.load(URLRequest(url: lastPage))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        canReturn = webView.canGoBack
        if let url = webView.url { lastPage = url }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code != NSURLErrorCancelled { failed = true }
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) { failed = true }
}

struct PlanView: UIViewRepresentable {
    let session: PlanBrowser
    func makeUIView(context: Context) -> WKWebView { session.web }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
