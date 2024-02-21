import SwiftUI

internal struct ScenarioSearchTree: View {
    @EnvironmentObject
    var store: GalleryStore

    @ViewBuilder
    var body: some View {
        VStack(spacing: .zero) {
            searchBar()

            if store.result.data.isEmpty {
                emptyContent()
            } else {
                ScrollView {
                    LazyVStack(spacing: .zero) {
                        ForEach(store.result.data, id: \.kind) { data in
                            let isOpened = currentOpenedKindsBinding().wrappedValue.contains(data.kind)

                            kindRow(
                                data: data,
                                isOpened: isOpened
                            )

                            if isOpened {
                                ForEach(data.scenarios, id: \.id) { data in
                                    scenarioRow(
                                        data: data,
                                        isSelected: data.id == store.selectedScenario?.id
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(
            Color(.secondaryBackground).ignoresSafeArea()
        )
    }
}

private extension ScenarioSearchTree {
    func searchTextBinding() -> Binding<String?> {
        Binding(
            get: { store.searchText },
            set: { newValue in
                let isEmpty = newValue.map { $0.isEmpty } ?? true
                store.openedSearchingKinds = isEmpty ? nil : Set(store.result.data.map { $0.kind })
                store.searchText = newValue
            }
        )
    }

    func currentOpenedKindsBinding() -> Binding<Set<ScenarioKind>> {
        Binding($store.openedSearchingKinds) ?? $store.openedKinds
    }

    func kindRow(data: SearchedListData, isOpened: Bool) -> some View {
        Button(
            action: {
                if isOpened {
                    currentOpenedKindsBinding().wrappedValue.remove(data.kind)
                } else {
                    currentOpenedKindsBinding().wrappedValue.insert(data.kind)
                }
            },
            label: {
                VStack(spacing: .zero) {
                    HStack(spacing: 8) {
                        Image(symbol: .chevronRight)
                            .imageScale(.small)
                            .foregroundColor(Color(.label))
                            .rotationEffect(.radians(isOpened ? .pi / 2 : 0))

                        Image(symbol: .bookmarkFill)
                            .imageScale(.medium)
                            .foregroundColor(Color(.primaryBlue))

                        Text(data.kind.rawValue)
                            .bold()
                            .font(.system(size: 20))
                            .lineSpacing(4)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color(.label))
                            .background(Highlight(data.shouldHighlight))

                        Spacer(minLength: 16)
                    }
                    .padding(.vertical, 24)

                    HorizontalSeparator()
                }
                .padding(.leading, 16)
            }
        )
    }

    func scenarioRow(data: SearchedData, isSelected: Bool) -> some View {
        Button(
            action: {
                store.selectedScenario = data
            },
            label: {
                VStack(spacing: .zero) {
                    HStack(spacing: 8) {
                        Image(symbol: .circleFill)
                            .font(.system(size: 10))
                            .foregroundColor(Color(isSelected ? .primaryBlue : .tertiarySystemFill))

                        Text(data.scenario.name.rawValue)
                            .font(.subheadline)
                            .bold()
                            .lineLimit(nil)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color(.label))
                            .background(Highlight(data.shouldHighlight))

                        Spacer(minLength: 16)
                    }
                    .padding(.vertical, 16)

                    HorizontalSeparator()
                }
                .padding(.leading, 56)
            }
        )
        .show(style: store.selectedScenario?.scenario.presentationStyle ?? .modal, item: $store.selectedScenario) { data in
            ScenarioDisplaySheet(data: data) {
                store.selectedScenario = nil
            }
            .environmentObject(store)
        }
    }

    func emptyContent() -> some View {
        VStack(spacing: .zero) {
            Text("This filter resulted in 0 results")
                .foregroundColor(Color(.label))
                .font(.body)
                .bold()
                .lineLimit(nil)
                .padding(24)
                .padding(.top, 24)

            Spacer.zero
        }
    }

    func searchBar() -> some View {
        VStack(spacing: .zero) {
            SearchBar(text: searchTextBinding(), height: 44)

            Counter(
                numerator: store.result.matchedCount,
                denominator: store.scenariosCount
            )

            HorizontalSeparator()
                .padding(.top, 8)
        }
    }
}
