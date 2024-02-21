import SwiftUI

/// A view that displays scenarios manged by given `Playbook` instance with
/// catalog-style appearance.
public struct PlaybookCatalog: View {
    private var underlyingView: PlaybookCatalogInternal

    /// Creates a new view that displays scenarios managed by given `Playbook` instance.
    ///
    /// - Parameters:
    ///   - name: A name of `Playbook` to be displayed on the user interface.
    ///   - playbook: A `Playbook` instance that manages scenarios to be displayed.
    public init(
        name: String = "PLAYBOOK",
        playbook: Playbook = .default
    ) {
        underlyingView = PlaybookCatalogInternal(
            name: name,
            playbook: playbook,
            store: CatalogStore(playbook: playbook)
        )
    }

    /// Declares the content and behavior of this view.
    public var body: some View {
        underlyingView
    }
}

internal struct PlaybookCatalogInternal: View {
    var name: String
    var playbook: Playbook

    @ObservedObject
    var store: CatalogStore

    @WeakReference
    var contentUIView: UIView?

    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    @Environment(\.verticalSizeClass)
    var verticalSizeClass

    var body: some View {
        platformContent()
            .environmentObject(store)
            .onAppear(perform: selectFirstScenario)
            .sheet(item: $store.shareItem) { item in
                ImageSharingView(item: item) { self.store.shareItem = nil }
                    .edgesIgnoringSafeArea(.all)
            }
    }
}

private extension PlaybookCatalogInternal {
    var bottomBarHeight: CGFloat { 44 }

    func platformContent() -> some View {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .regular):
            return AnyView(
                CatalogSplitStyle(
                    name: name,
                    searchTree: ScenarioSearchTree(),
                    content: scenarioContent
                )
            )

        default:
            return AnyView(
                CatalogDrawerStyle(
                    name: name,
                    searchTree: ScenarioSearchTree(),
                    content: scenarioContent
                )
            )
        }
    }

    func displayView() -> some View {
        if let data = store.selectedScenario {
            return AnyView(
                ScenarioContentView(
                    kind: data.kind,
                    scenario: data.scenario,
                    additionalSafeAreaInsets: .only(bottom: bottomBarHeight),
                    contentUIView: _contentUIView
                )
                .edgesIgnoringSafeArea(.all)
            )
        } else {
            return AnyView(emptyContent())
        }
    }

    func emptyContent() -> some View {
        VStack(spacing: 0) {
            HStack {
                Spacer.zero
            }

            Spacer.zero

            Image(symbol: .book)
                .imageScale(.large)
                .font(.system(size: 60))
                .foregroundColor(Color(.label))

            Spacer.fixed(length: 44)

            Text("There are no scenarios")
                .foregroundColor(Color(.label))
                .font(.system(size: 24, weight: .bold))
                .lineLimit(nil)

            Spacer.zero
        }
        .padding(.horizontal, 24)
    }

    func scenarioContent(firstBarItem: CatalogBarItem) -> some View {
        ZStack {
            Color(.scenarioBackground)
                .edgesIgnoringSafeArea(.all)

            displayView()

            VStack(spacing: 0) {
                Spacer.zero

                Divider()
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }

    func selectFirstScenario() {
        guard store.selectedScenario == nil, let store = playbook.stores.first, let scenario = store.scenarios.first else {
            return
        }

        self.store.start()
        self.store.selectedScenario = SearchedData(
            scenario: scenario,
            kind: store.kind,
            shouldHighlight: false
        )
    }
}
