import Foundation

/// A launchable Smart TV app, identified by its Tizen application id.
/// Launched over the REST API (`/api/v2/applications/{id}`).
struct TVApp: Identifiable, Hashable {
    var id: String { appID }
    let name: String
    let appID: String
    let symbolName: String

    /// Common apps and their Tizen ids. Ids are stable across most models,
    /// but if one isn't installed the TV replies with an error we surface.
    static let presets: [TVApp] = [
        TVApp(name: "YouTube",     appID: "111299001912",  symbolName: "play.rectangle.fill"),
        TVApp(name: "Netflix",     appID: "11101200001",   symbolName: "film.fill"),
        TVApp(name: "Prime Video", appID: "3201512006785", symbolName: "play.tv.fill"),
        TVApp(name: "Disney+",     appID: "3201901017640", symbolName: "sparkles.tv.fill"),
        TVApp(name: "Hulu",        appID: "3201601007625", symbolName: "tv.fill"),
        TVApp(name: "Spotify",     appID: "3201606009684", symbolName: "music.note"),
    ]
}
