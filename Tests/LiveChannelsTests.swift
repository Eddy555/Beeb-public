// SPDX-License-Identifier: GPL-3.0-or-later
import Foundation
@main struct LiveChannelsTests {
    static func main() throws {
        func check(_ value: Bool, _ message: String) { if !value { fatalError(message) } }
        for channel in LiveShelfChannel.defaults {
            check(LiveChannelLink.url(for: channel.id).flatMap { LiveChannelLink.channelID(from: $0) } == channel.id, "Every channel has a playable route")
        }
        check(Set(LiveShelfChannel.defaults.map(\.id)).count == LiveShelfChannel.defaults.count, "No duplicate shelf IDs")
        for raw in ["https://live/bbc_one_london", "beeb://live/a/b", "beeb://other/bbc_one_london", "beeb://live/bbc_one_london?stream=https://example.org", "beeb://live/bbc_one_london#x", "beeb://user@live/bbc_one_london"] {
            check(LiveChannelLink.channelID(from: URL(string: raw)!) == nil, "Reject malformed or externally supplied stream URLs")
        }
        let prefs = UserDefaults(suiteName: "RegionalChannelsTests")!
        prefs.removePersistentDomain(forName: "RegionalChannelsTests")
        check(RegionalChannels.bbcOne.count == 16 && RegionalChannels.bbcTwo.count == 3, "Verified BBC regional directory")
        prefs.set("bbc_one_northern_ireland", forKey: "bbcOneRegion")
        check(RegionalChannels.selectedID(for: "bbc_one_london", defaults: prefs) == "bbc_one_northern_ireland", "Generic Top Shelf route follows the selected region")
        prefs.set("https://invalid.example", forKey: "bbcTwoRegion")
        check(RegionalChannels.selectedID(for: "bbc_two_england", defaults: prefs) == "bbc_two_england", "Corrupt preference safely falls back")
        check(RegionalChannels.selectedID(for: "bbc_news24", defaults: prefs) == "bbc_news24", "Other channels unaffected")
        prefs.removePersistentDomain(forName: "RegionalChannelsTests")
        let now = ISO8601DateFormatter().date(from: "2026-10-19T12:30:00Z")!
        let data = Data(#"{"broadcasts":{"elements":[{"scheduled_start":"2026-10-19T12:00:00Z","scheduled_end":"2026-10-19T13:00:00Z","episode":{"images":{"standard":"https://ichef.bbci.co.uk/images/ic/{recipe}/p0000001.jpg"}}}]}}"#.utf8)
        check(LiveShelfArtwork.current(data, now: now)?.absoluteString.contains("1280x720") == true, "Current programme uses landscape imagery")
        check(LiveShelfArtwork.current(data, now: now.addingTimeInterval(3600)) == nil, "Expired programmes do not supply current artwork")
        print("PASS: all channel routes, invalid links, landscape current-programme artwork and expiry")
    }
}
