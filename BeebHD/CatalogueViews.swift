// SPDX-License-Identifier: GPL-3.0-or-later
import SwiftUI
import TVServices

private enum BeebTab: String, CaseIterable { case home = "Home", browse = "Browse", search = "Search", live = "Live", saved = "Saved", settings = "Settings" }
struct HomeView: View {
    @StateObject private var catalogue = CatalogueStore()
    @StateObject private var index = CatalogueIndexStore()
    @StateObject private var library = Library()
    @StateObject private var history = WatchHistory()
    @State private var tab = BeebTab.home
    @State private var liveLaunch: LiveLaunch?
    @FocusState private var focusedTab: BeebTab?
    @Environment(\.scenePhase) private var phase
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 30) {
                Image("BeebMark").resizable().scaledToFit().frame(width: 64, height: 64).accessibilityLabel("Beeb")
                HStack(spacing: 14) { ForEach(BeebTab.allCases, id: \.self) { value in BeebTabButton(tab: value, selection: $tab, focus: $focusedTab) } }
                Spacer(minLength: 0)
                if catalogue.loading { ProgressView().accessibilityLabel("Updating homepage") }
            }.padding(.horizontal, 64).padding(.vertical, 18)
            NavigationStack {
                switch tab {
                case .home: DiscoveryHome(catalogue: catalogue, library: library)
                case .browse: BrowseView(catalogue: catalogue, library: library, index: index)
                case .search: CatalogueSearchView(index: index, catalogue: catalogue, library: library)
                case .live: LiveView(launch: liveLaunch)
                case .saved: SavedProgrammes(catalogue: catalogue, library: library)
                case .settings: SettingsView(catalogue: catalogue)
                }
            }.id(tab)
        }.environmentObject(history).tint(.pink).defaultFocus($focusedTab, .home)
        .onOpenURL { url in
            guard let id = LiveChannelLink.channelID(from: url) else { return }
            if tab != .live { NotificationCenter.default.post(name: .beebLaunchLive, object: nil) }
            liveLaunch = LiveLaunch(channelID: id)
            tab = .live
        }
        .task {
            TVTopShelfContentProvider.topShelfContentDidChange()
            #if DEBUG
            if ProcessInfo.processInfo.environment["BEEB_LIVE_ROUTE_VALIDATE"] == "1" { return }
            #endif
            catalogue.programmeOpened = { show, sourceID in Task { await index.record(show, replacingID: sourceID) } }
            await index.prepare(); await catalogue.boot()
        }
        .task(id: "\(phase)-\(index.refreshRevision)") {
            #if DEBUG
            if ProcessInfo.processInfo.environment["BEEB_LIVE_ROUTE_VALIDATE"] == "1" || ProcessInfo.processInfo.environment["BEEB_UI_PREVIEW"] == "review" { return }
            #endif
            if phase == .active { await index.maintain() }
        }
        #if DEBUG
        .onAppear { if let value = ProcessInfo.processInfo.environment["BEEB_UI_TAB"], let selected = BeebTab.allCases.first(where: { $0.rawValue.lowercased() == value }) { tab = selected } }
        #endif
        .onChange(of: phase) { _, value in if value == .active { Task { await catalogue.refreshHome() } } }
    }
}
private struct BeebTabButton: View {
    let tab: BeebTab
    @Binding var selection: BeebTab
    let focus: FocusState<BeebTab?>.Binding
    private var focused: Bool { focus.wrappedValue == tab }
    var body: some View {
        Button { selection = tab } label: {
            Text(tab.rawValue).font(.headline).padding(.horizontal, 24).padding(.vertical, 16)
                .foregroundStyle(focused || selection == tab ? .white : .white.opacity(0.7))
                .background(focused ? Color.white.opacity(0.2) : selection == tab ? Color.white.opacity(0.12) : .clear, in: RoundedRectangle(cornerRadius: 12))
        }.buttonStyle(BeebTabStyle()).focused(focus, equals: tab).focusEffectDisabled()
            .accessibilityAddTraits(selection == tab ? .isSelected : [])
    }
}
private struct BeebTabStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View { configuration.label.opacity(configuration.isPressed ? 0.7 : 1) }
}
private struct BannerRotationKey: Hashable { let index: Int; let count: Int; let paused: Bool }
@MainActor final class HomeState: ObservableObject { @Published var banner = 0 }
struct DiscoveryHome: View {
    @ObservedObject var catalogue: CatalogueStore
    @ObservedObject var library: Library
    @StateObject private var state = HomeState()
    @Environment(\.scenePhase) private var phase
    @FocusState private var bannerFocused: Bool
    @FocusState private var focusedCard: String?
    @State private var visible = false
    private var rotationKey: BannerRotationKey {
        BannerRotationKey(index: state.banner, count: catalogue.home?.features.count ?? 0, paused: !visible || bannerFocused || phase != .active)
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 34) {
                if let error = catalogue.error { Text(error).foregroundStyle(.orange).font(.callout) }
                if catalogue.home == nil { ContinueWatchingRow(catalogue: catalogue, library: library) }
                if let feed = catalogue.home {
                    if !feed.features.isEmpty {
                        let index = min(state.banner, feed.features.count - 1)
                        let feature = feed.features[index]
                        NavigationLink { CatalogueShowView(show: feature.show, catalogue: catalogue, library: library) } label: {
                            ZStack(alignment: .bottomLeading) {
                                Color.clear.overlay {
                                    GeometryReader { geometry in
                                        AsyncImage(url: feature.image) { $0.resizable().scaledToFill() } placeholder: { Rectangle().fill(.gray.opacity(0.15)) }
                                            .frame(width: geometry.size.width, height: geometry.size.height).clipped()
                                    }
                                }
                                LinearGradient(colors: [.clear, .black.opacity(0.95)], startPoint: .top, endPoint: .bottom)
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("NEW & TRENDING").font(.caption).tracking(4).foregroundStyle(.pink)
                                    Text(feature.headline).font(.system(size: 48, weight: .bold)).lineLimit(2)
                                    Text(feature.synopsis).font(.title3).lineLimit(2).frame(maxWidth: 1000, alignment: .leading)
                                }.padding(38)
                            }.aspectRatio(2.35, contentMode: .fit).cornerRadius(18)
                        }.buttonStyle(ProgrammeCardStyle()).focused($bannerFocused)
                        .onMoveCommand { direction in
                            guard bannerFocused else { return }
                            switch direction {
                            case .left: advanceBanner(by: -1)
                            case .right: advanceBanner(by: 1)
                            default: break
                            }
                        }
                        .accessibilityAdjustableAction { direction in
                            switch direction {
                            case .increment: advanceBanner(by: 1)
                            case .decrement: advanceBanner(by: -1)
                            @unknown default: break
                            }
                        }
                        // Match the 30-point bottom focus space beneath programme rows.
                        .padding(.bottom, 30)
                    }
                    ContinueWatchingRow(catalogue: catalogue, library: library)
                    ForEach(feed.rows) { row in
                        VStack(alignment: .leading, spacing: 18) {
                            Text(row.title).font(.title2).bold()
                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 28) {
                                    ForEach(row.shows) { show in
                                        NavigationLink { CatalogueShowView(show: show, catalogue: catalogue, library: library) } label: { HomeProgrammeCard(show: show, poster: row.usesPosters).frame(width: row.usesPosters ? 260 : 360) }.buttonStyle(ProgrammeCardStyle()).accessibilityLabel(show.title).focused($focusedCard, equals: "\(row.id):\(show.id)")
                                    }
                                }.padding(.vertical, 30).padding(.horizontal, 24)
                            }.scrollClipDisabled().padding(.horizontal, -24)
                        }
                    }
                } else if catalogue.loading { ProgressView("Getting the latest programmes…") }
                else { Button("Retry homepage") { Task { await catalogue.refreshHome() } } }
            }.padding(.horizontal, 64).padding(.vertical, 26)
        }.scrollClipDisabled()
        .onAppear { visible = true }
        .task(id: phase) {
            #if DEBUG
            guard phase == .active else { return }
            do { try await Task.sleep(nanoseconds: 1_000_000_000) } catch { return }
            if ProcessInfo.processInfo.environment["BEEB_UI_PREVIEW"] == "cards" { focusedCard = "preview:preview-0" }
            if ProcessInfo.processInfo.environment["BEEB_UI_PREVIEW"] == "banner-focused" { bannerFocused = true }
            #endif
        }
        .onDisappear { visible = false }
        .onChange(of: rotationKey) { _, _ in recordBannerValidation() }
        .task(id: rotationKey) {
            guard !rotationKey.paused, rotationKey.count > 1 else { return }
            do { try await Task.sleep(nanoseconds: 8_000_000_000) } catch { return }
            guard !Task.isCancelled, visible, !bannerFocused, phase == .active else { return }
            withAnimation(.easeInOut(duration: 0.4)) { state.banner = (state.banner + 1) % rotationKey.count }
        }
    }
    private func advanceBanner(by offset: Int) {
        let count = catalogue.home?.features.count ?? 0
        guard count > 1 else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            state.banner = (min(state.banner, count - 1) + offset + count) % count
        }
    }
    private func recordBannerValidation() {
        #if DEBUG
        guard ProcessInfo.processInfo.environment["BEEB_UI_PREVIEW"] != nil else { return }
        let values: [String: Any] = ["index": state.banner, "count": rotationKey.count, "focused": bannerFocused, "visible": visible, "active": phase == .active, "timestamp": Date().timeIntervalSince1970]
        let output = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("UI-validation.json")
        if let data = try? JSONSerialization.data(withJSONObject: values) { try? data.write(to: output, options: .atomic) }
        #endif
    }

}
@MainActor final class BrowseState: ObservableObject { @Published var mode = "Categories" }
struct BrowseView: View {
    @ObservedObject var catalogue: CatalogueStore
    @ObservedObject var library: Library
    @ObservedObject var index: CatalogueIndexStore
    @StateObject private var state = BrowseState()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Browse programmes").font(.largeTitle).bold()
                Picker("Browse by", selection: $state.mode) { Text("Categories").tag("Categories"); Text("A–Z").tag("A–Z") }.pickerStyle(.segmented)
                if state.mode == "Categories" {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 330))], spacing: 28) {
                        NavigationLink { UHDCategoryView(index: index, catalogue: catalogue, library: library) } label: {
                            Text("4K UHD").font(.title3).frame(maxWidth: .infinity, minHeight: 90).padding(12)
                        }
                        ForEach(catalogue.genres) { genre in
                            NavigationLink { ProgrammePage(title: genre.title, category: genre.id, letter: nil, catalogue: catalogue, library: library) } label: {
                                Text(genre.title).font(.title3).frame(maxWidth: .infinity, minHeight: 90).padding(12)
                            }
                        }
                    }
                    if catalogue.genres.isEmpty { Button("Reload categories") { Task { await catalogue.refreshHome() } } }
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 24) {
                        ForEach(CatalogueAPI.letters, id: \.self) { letter in
                            NavigationLink { ProgrammePage(title: letter.uppercased(), category: nil, letter: letter, catalogue: catalogue, library: library) } label: {
                                Text(letter.uppercased()).font(.title2).frame(maxWidth: .infinity, minHeight: 75)
                            }
                        }
                    }
                }
                Text("Choose a category or letter. Programme listings load one page at a time; episodes load when you open a programme.")
                    .font(.callout).foregroundStyle(.secondary)
            }.padding(60)
        }
    }
}
struct ProgrammePage: View {
    let title: String
    let category: String?
    let letter: String?
    @ObservedObject var catalogue: CatalogueStore
    @ObservedObject var library: Library
    @StateObject private var page = PageStore()
    @StateObject private var state = PageState()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text(title).font(.largeTitle).bold()
                HStack(spacing: 24) {
                    Button("Previous") { state.page -= 1 }.disabled(state.page <= 1 || page.loading)
                    Text("Page \(state.page) of \(page.totalPages) · \(page.count) programmes").font(.callout)
                    Button("Next") { state.page += 1 }.disabled(state.page >= page.totalPages || page.loading)
                    Spacer()
                }
                if page.loading { ProgressView("Loading programmes…") }
                if let error = page.error { Text(error).foregroundStyle(.orange); Button("Retry") { state.retry += 1 } }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 330), spacing: 28)], spacing: 30) {
                    ForEach(page.shows) { show in
                        NavigationLink { CatalogueShowView(show: show, catalogue: catalogue, library: library) } label: { ShowCard(show: show) }.buttonStyle(ProgrammeCardStyle())
                    }
                }
            }.padding(60)
        }.task(id: "\(state.page)-\(state.retry)") { await page.load(category: category, letter: letter, page: state.page) }
    }
}
@MainActor final class PageState: ObservableObject { @Published var page = 1; @Published var retry = 0 }
/// Give the image a finite proposal before scaledToFill; intrinsic artwork sizes
/// must never determine a row's card width or its focus outline.
struct ProgrammeThumbnail: View {
    let url: URL?
    let uhd: Bool
    var hdr = false
    var body: some View {
        Color.clear.aspectRatio(16 / 9, contentMode: .fit)
            .overlay {
                GeometryReader { geometry in
                    AsyncImage(url: url) { $0.resizable().scaledToFill() } placeholder: {
                        Rectangle().fill(.gray.opacity(0.15)).overlay(Image(systemName: "play.tv").font(.largeTitle))
                    }.frame(width: geometry.size.width, height: geometry.size.height).clipped()
                }
            }.clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(alignment: .topTrailing) { if uhd { UHDListedBadge(hdr: hdr).padding(10) } }
    }
}
struct ProgrammeCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View { ProgrammeCardSurface(content: configuration.label, pressed: configuration.isPressed) }
}
private struct ProgrammeCardSurface<Content: View>: View {
    let content: Content
    let pressed: Bool
    @Environment(\.isFocused) private var focused
    var body: some View {
        content
            .background(focused ? Color.white.opacity(0.16) : Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 16))
            .overlay { RoundedRectangle(cornerRadius: 16).strokeBorder(focused ? .white : .clear, lineWidth: 3) }
            .scaleEffect(pressed ? 0.99 : focused ? 1.045 : 1)
            .shadow(color: .black.opacity(focused ? 0.4 : 0), radius: 16, y: 8)
            .animation(.easeOut(duration: 0.15), value: focused)
            .focusEffectDisabled().zIndex(focused ? 1 : 0)
    }
}
private struct HomeProgrammeCard: View {
    let show: CatalogueShow
    let poster: Bool
    var body: some View {
        if poster {
            AsyncImage(url: show.portraitImage) { phase in
                if let image = phase.image { image.resizable().scaledToFill() }
                else { ZStack { Color(white: 0.12); Text(show.title).font(.title3).multilineTextAlignment(.center).padding(24) } }
            }.frame(width: 260, height: 390).clipped().cornerRadius(12)
                .accessibilityLabel(show.title)
        } else { ShowCard(show: show) }
    }
}
struct ShowCard: View {
    let show: CatalogueShow
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgrammeThumbnail(url: show.image, uhd: show.uhdListed == true, hdr: show.hdrListed == true)
            Text(show.title).font(.headline).lineLimit(2)
                .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60, alignment: .topLeading)

        }.padding(12).frame(maxWidth: .infinity, alignment: .leading)
    }
}
@MainActor final class ShowState: ObservableObject {
    @Published var show: CatalogueShow?
    @Published var seriesID = ""
    @Published var selection: Programme?
    @Published var error: String?
    @Published var retry = 0
    @Published var episodePage = 1
}
struct CatalogueShowView: View {
    let show: CatalogueShow
    @ObservedObject var catalogue: CatalogueStore
    @ObservedObject var library: Library
    var preferUHDSeries = false
    @StateObject private var state = ShowState()
    @FocusState private var focusedEpisode: String?
    var current: CatalogueShow { state.show ?? show }
    var orderedSeries: [CatalogueSeries] { EpisodeSequence.orderedSeries(current.series) }
    var selectedEpisodes: [CatalogueEpisode] {
        let group = orderedSeries.first { $0.id == state.seriesID } ?? orderedSeries.first
        return EpisodeSequence.ordered(group?.episodes ?? [])
    }
    var visibleEpisodes: [CatalogueEpisode] { Array(selectedEpisodes.dropFirst((state.episodePage - 1) * 30).prefix(30)) }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                HStack {
                    Text(current.title).font(.largeTitle).bold(); Spacer()
                    ProgrammeBookmarkButton(show: current, library: library)
                }
                Text(current.summary).font(.title3).foregroundStyle(.secondary)
                if state.show == nil && state.error == nil { ProgressView("Getting series and episodes…") }
                if let error = state.error { Text(error).foregroundStyle(.orange); Button("Retry") { state.retry += 1 } }
                if orderedSeries.count > 1 {
                    ScrollView(.horizontal) {
                        HStack(spacing: 20) {
                            ForEach(orderedSeries) { series in
                                Button(series.title) { state.seriesID = series.id; state.episodePage = 1 }
                                    .tint((state.seriesID.isEmpty ? orderedSeries.first?.id : state.seriesID) == series.id ? .pink : .gray)
                            }
                        }.padding(.vertical, 30).padding(.horizontal, 24)
                    }.scrollClipDisabled().padding(.horizontal, -24)
                }
                if selectedEpisodes.count > 30 {
                    HStack(spacing: 24) {
                        Button("Previous episodes") { state.episodePage -= 1 }.disabled(state.episodePage <= 1)
                        Text("Episodes \((state.episodePage - 1) * 30 + 1)–\(min(state.episodePage * 30, selectedEpisodes.count))")
                        Button("More episodes") { state.episodePage += 1 }.disabled(state.episodePage * 30 >= selectedEpisodes.count)
                    }
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 330), spacing: 30)], spacing: 30) {
                    ForEach(visibleEpisodes) { episode in
                        Button { state.selection = episode.programme } label: { ProgrammeCard(programme: episode.programme) }.buttonStyle(ProgrammeCardStyle()).focused($focusedEpisode, equals: episode.id)
                    }
                }
                if state.show != nil && selectedEpisodes.isEmpty { Text("No episodes are currently available.").foregroundStyle(.secondary) }
            }.padding(60)
        }.task(id: state.retry) {
            state.error = nil
            do {
                state.show = try await catalogue.open(show)
                if preferUHDSeries && state.seriesID.isEmpty {
                    state.seriesID = orderedSeries.first(where: { $0.episodes.contains { $0.programme.uhdListed == true } })?.id ?? ""
                }
            } catch { if !Task.isCancelled { state.error = error.localizedDescription } }
        }.defaultFocus($focusedEpisode, visibleEpisodes.first?.id)
        .task(id: visibleEpisodes.first?.id) {
            guard let first = visibleEpisodes.first?.id else { return }
            do { try await Task.sleep(nanoseconds: 150_000_000) } catch { return }
            focusedEpisode = first
        }.sheet(item: $state.selection) { DetailView(programme: $0, show: current, library: library) }
    }
}
struct SavedProgrammes: View {
    @ObservedObject var catalogue: CatalogueStore
    @ObservedObject var library: Library
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Label("Saved programmes", systemImage: "bookmark.fill").font(.largeTitle).bold()
                if let warning = library.migrationWarning { Text(warning).foregroundStyle(.orange).font(.callout) }
                if library.saved.isEmpty { Text("Save a programme to follow all of its series and episodes here.").foregroundStyle(.secondary) }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 330))], spacing: 30) {
                    ForEach(library.saved) { show in
                        NavigationLink { CatalogueShowView(show: show, catalogue: catalogue, library: library) } label: { ShowCard(show: show) }.buttonStyle(ProgrammeCardStyle())
                    }
                }
            }.padding(60)
        }.task { await library.migrate(); await library.refreshArtwork() }
    }
}
@MainActor final class LiveState: ObservableObject {
    @Published var channels: [LiveChannel] = []
    @Published var error: String?
    @Published var retry = 0
    @Published var playing = false
}
struct LiveView: View {
    var launch: LiveLaunch? = nil
    @Environment(\.scenePhase) private var phase
    @StateObject private var state = LiveState()
    @StateObject private var playback = PlaybackModel()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Live channels").font(.largeTitle).bold()
                Text("Watch now • quality adjusts to the live stream BBC supplies").foregroundStyle(.secondary)
                if state.channels.isEmpty && state.error == nil { ProgressView("Getting channels…") }
                if let error = state.error { Text(error).foregroundStyle(.orange); Button("Retry channels") { state.retry += 1 } }
                if let error = playback.error { Text(error).foregroundStyle(.orange) }
                if playback.loading { HStack { ProgressView("Connecting to live channel…"); Button("Cancel") { playback.stop() } } }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 370))], spacing: 30) {
                    ForEach(state.channels) { channel in
                        Button { playback.startLive(channel) { state.playing = true } } label: {
                            VStack(alignment: .leading, spacing: 12) {
                                ProgrammeThumbnail(url: channel.current?.image, uhd: false)
                                Text(channel.current?.title ?? channel.title).font(.headline).lineLimit(2)
                                    .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60, alignment: .topLeading)
                                Text(channel.title).font(.callout).foregroundStyle(.secondary)
                            }.padding(12).frame(maxWidth: .infinity, alignment: .leading)
                        }.buttonStyle(ProgrammeCardStyle()).disabled(playback.loading)
                    }
                }
            }.padding(60)
        }.task(id: "\(state.retry)-\(phase)-\(state.playing)") {
            guard phase == .active, !state.playing else { return }
            #if DEBUG
            if ProcessInfo.processInfo.environment["BEEB_LIVE_ROUTE_VALIDATE"] == "1" || ProcessInfo.processInfo.environment["BEEB_UI_PREVIEW"] == "review" { return }
            #endif
            state.error = nil
            do {
                let api = DiscoveryAPI()
                if state.channels.isEmpty { state.channels = try await api.channels() }
                while !Task.isCancelled {
                    let channels = await api.nowPlaying(state.channels)
                    try Task.checkCancellation(); state.channels = channels
                    try await Task.sleep(nanoseconds: 60_000_000_000)
                }
            } catch { if !Task.isCancelled { state.error = error.localizedDescription } }
        }.task(id: launch?.id) {
            guard let launch else { return }
            // Allow an existing episode cover to dismiss before the Live page presents.
            do {
                try await Task.sleep(nanoseconds: 400_000_000)
                var channel = state.channels.first { $0.id == launch.channelID }
                if channel == nil, let known = LiveShelfChannel.defaults.first(where: { $0.id == launch.channelID }) {
                    channel = LiveChannel(id: known.id, title: known.title)
                }
                if channel == nil { channel = try await DiscoveryAPI().channels().first { $0.id == launch.channelID } }
                try Task.checkCancellation()
                guard let channel else { state.error = "This channel is not currently available."; return }
                playback.startLive(channel) { state.playing = true }
            } catch { if !Task.isCancelled { state.error = error.localizedDescription } }
        }.fullScreenCover(isPresented: $state.playing, onDismiss: { playback.stop() }) { PlaybackScreen(model: playback) }
        .onDisappear { if !state.playing { playback.stop() } }
    }
}
struct SettingsView: View {
    @ObservedObject var catalogue: CatalogueStore
    @AppStorage("bbcOneRegion") private var bbcOne = "bbc_one_london"
    @AppStorage("bbcTwoRegion") private var bbcTwo = "bbc_two_england"
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Settings").font(.largeTitle).bold()
                Text("Playback automatically selects the best available quality, including 4K HDR when available. Live channel quality adapts to the stream BBC supplies.").foregroundStyle(.secondary)
                NavigationLink {
                    RegionSelectionView(title: "BBC One region", choices: RegionalChannels.bbcOne, selection: $bbcOne)
                } label: { RegionSettingLabel(title: "BBC One region", value: RegionalChannels.bbcOne.first { $0.id == bbcOne }?.title ?? "London") }
                NavigationLink {
                    RegionSelectionView(title: "BBC Two version", choices: RegionalChannels.bbcTwo, selection: $bbcTwo)
                } label: { RegionSettingLabel(title: "BBC Two version", value: RegionalChannels.bbcTwo.first { $0.id == bbcTwo }?.title ?? "England / Scotland") }
                Button("Refresh homepage") { Task { await catalogue.refreshHome() } }.disabled(catalogue.loading)
                Text("Programme listings load only when you select a category or letter. Series and episodes load when you open a programme. Saved programmes include all their series.")
                if let warning = catalogue.storageWarning { Text(warning).foregroundStyle(.orange) }
                UHDSetupView()
                Text("Beeb \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "") • Independent BBC player").font(.caption).foregroundStyle(.secondary)
            }.padding(60)
        }
    }
}

private struct RegionSettingLabel: View {
    let title: String
    let value: String
    var body: some View {
        HStack { Text(title); Spacer(); Text(value).foregroundStyle(.secondary); Image(systemName: "chevron.right") }
            .frame(maxWidth: .infinity).padding(.vertical, 8)
    }
}
private struct RegionSelectionView: View {
    let title: String
    let choices: [RegionalChannelChoice]
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(title).font(.largeTitle).bold()
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(choices) { choice in
                        Button {
                            selection = choice.id
                            dismiss()
                        } label: {
                            HStack {
                                Text(choice.title); Spacer()
                                Image(systemName: selection == choice.id ? "checkmark.circle.fill" : "circle").opacity(selection == choice.id ? 1 : 0.3)
                            }.frame(maxWidth: .infinity).padding(.horizontal, 16).padding(.vertical, 14)
                        }.buttonStyle(OutlinedActionButtonStyle())
                    }
                }.padding(12)
            }
        }.padding(60)
    }
}
