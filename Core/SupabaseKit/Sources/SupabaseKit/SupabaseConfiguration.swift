import Foundation

public struct SupabaseConfiguration: Sendable {
    public let url: URL
    public let key: String

    public init(url: URL, key: String) {
        self.url = url
        self.key = key
    }
}

public extension SupabaseConfiguration {
    static func fromBundle(_ bundle: Bundle = .main) -> SupabaseConfiguration {
        guard
            let urlString = bundle.infoDictionary?["SUPABASE_URL"] as? String,
            let url = URL(string: urlString),
            let key = bundle.infoDictionary?["SUPABASE_KEY"] as? String,
            !urlString.isEmpty, !key.isEmpty
        else {
            fatalError("Missing SUPABASE_URL or SUPABASE_KEY in Info.plist")
        }
        return SupabaseConfiguration(url: url, key: key)
    }
}
