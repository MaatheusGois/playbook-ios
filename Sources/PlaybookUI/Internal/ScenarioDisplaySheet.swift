import SwiftUI

internal struct ScenarioDisplaySheet: View {
    var data: SearchedData
    var onClose: () -> Void

    @EnvironmentObject
    private var store: GalleryStore

    @WeakReference
    private var contentUIView: UIView?

    init(
        data: SearchedData,
        onClose: @escaping () -> Void
    ) {
        self.data = data
        self.onClose = onClose
    }

    var body: some View {
        ZStack {
            ScenarioContentView(
                kind: data.kind,
                scenario: data.scenario,
                additionalSafeAreaInsets: .only(top: .zero),
                contentUIView: _contentUIView
            )
            .edgesIgnoringSafeArea(.all)
            .background(
                Color(.scenarioBackground)
                    .edgesIgnoringSafeArea(.all)
            )
        }
        .sheet(item: $store.shareItem) { item in
            ImageSharingView(item: item) { self.store.shareItem = nil }
                .edgesIgnoringSafeArea(.all)
        }
        .background(
            Color(.scenarioBackground)
                .edgesIgnoringSafeArea(.all)
        )
    }
}
