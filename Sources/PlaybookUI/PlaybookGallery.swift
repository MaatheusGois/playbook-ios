import SwiftUI

/// A view that displays scenarios manged by given `Playbook` instance with
/// gallery-style appearance.
public struct PlaybookGallery: View {
    private let name: String
    private let snapshotColorScheme: ColorScheme
    private let store: GalleryStore

    /// Creates a new view that displays scenarios managed by given `Playbook` instance.
    ///
    /// - Parameters:
    ///   - name: A name of `Playbook` to be displayed on the user interface.
    ///   - playbook: A `Playbook` instance that manages scenarios to be displayed.
    ///   - preSnapshotCountLimit: The limit on the number of snapshot images for preview
    ///                            that can be generated before being displayed.
    ///   - snapshotColorScheme: The color scheme of the snapshot image for preview.
    ///
    /// - Note: If the displaying of this view is heavy, you can delay the generation
    ///         of the snapshot image for preview by lowering `preSnapshotCountLimit`.
    public init(
        name: String = "PLAYBOOK",
        playbook: Playbook = .default,
        preSnapshotCountLimit: Int = 100,
        snapshotColorScheme: ColorScheme = .light
    ) {
        self.name = name
        self.snapshotColorScheme = snapshotColorScheme
        self.store = GalleryStore(
            playbook: playbook,
            preSnapshotCountLimit: preSnapshotCountLimit,
            screenSize: UIScreen.main.fixedCoordinateSpace.bounds.size,
            userInterfaceStyle: snapshotColorScheme.userInterfaceStyle
        )
    }

    /// Declares the content and behavior of this view.
    @ViewBuilder
    public var body: some View {
        PlaybookGalleryIOS14(
            name: name,
            snapshotColorScheme: snapshotColorScheme,
            store: store
        )
    }
}

internal struct PlaybookGalleryIOS14: View {
    var name: String
    var snapshotColorScheme: ColorScheme

    @ObservedObject
    var store: GalleryStore

    @Environment(\.galleryDependency)
    var dependency

    var body: some View {
        GeometryReader { geometry in
            if !self.store.isSearchTreeHidden {
                Drawer(isOpened: isOpened, content: store.searchTree)
                    .environmentObject(store)
            } else {
                NavigationView {
                    ScrollView {
                        LazyVStack(spacing: .zero) {
                            SearchBar(text: $store.searchText, height: 44)
                                .padding(.leading, geometry.safeAreaInsets.leading)
                                .padding(.trailing, geometry.safeAreaInsets.trailing)

                            statefulBody(geometry: geometry)
                        }
                    }
                    .ignoresSafeArea(edges: .horizontal)
                    .navigationBarTitle(name)
                    .navigationBarItems(trailing: Button(action: {
                        self.store.isSearchTreeHidden = false
                    }) {
                        Image(symbol: .menu)
                    })
                    .background(Color(.primaryBackground).ignoresSafeArea())
                    .sheet(item: $store.selectedScenario) { data in
                        ScenarioDisplaySheet(data: data) {
                            store.selectedScenario = nil
                        }
                        .environmentObject(store)
                    }
                }
                .environmentObject(store)
                .onAppear {
                    dependency.scheduler.schedule(on: .main, action: store.prepare)
                }
            }
        }

    }

    var isOpened: Binding<Bool> {
        Binding(
            get: { !self.store.isSearchTreeHidden },
            set: { self.store.isSearchTreeHidden = !$0 }
        )
    }
}

private extension PlaybookGalleryIOS14 {
    @ViewBuilder
    func statefulBody(geometry: GeometryProxy) -> some View {
        switch store.status {
        case .ready where store.result.data.isEmpty:
            message("This filter resulted in 0 results", font: .headline)

        case .ready:
            Counter(numerator: store.result.matchedCount, denominator: store.scenariosCount)
                .padding(.leading, geometry.safeAreaInsets.leading)
                .padding(.trailing, geometry.safeAreaInsets.trailing)

            ForEach(store.result.data, id: \.kind) { data in
                ScenarioDisplayList(
                    data: data,
                    safeAreaInsets: geometry.safeAreaInsets,
                    serialDispatcher: SerialMainDispatcher(
                        interval: 0.2,
                        scheduler: dependency.scheduler
                    ),
                    onSelect: { store.selectedScenario = $0 }
                )
            }

        case .standby:
            VStack(spacing: .zero) {
                message("Preparing snapshots ...", font: .system(size: 24))
                Image(symbol: .book)
                    .imageScale(.large)
                    .font(.system(size: 60))
                    .foregroundColor(Color(.label))
            }
        }
    }

    func message(_ text: String, font: Font) -> some View {
        Text(text)
            .foregroundColor(Color(.label))
            .font(font)
            .bold()
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 44)
            .padding(.horizontal, 24)
    }
}

private extension ColorScheme {
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light:
            return .light

        case .dark:
            return .dark

        @unknown default:
            return .light
        }
    }
}
