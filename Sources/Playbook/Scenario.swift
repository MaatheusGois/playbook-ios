import UIKit
import SwiftUI

/// Represents part of the component state.
public struct Scenario {
    /// A unique name of scenario that describes component and its state.
    public var name: ScenarioName

    /// Represents how the component should be laid out.
    public var layout: ScenarioLayout

    /// A file path where defined this scenario.
    public var file: StaticString

    /// A line number where defined this scenario in file.
    public var line: UInt

    /// A custom timer to take the snapshot
    public var delay: TimeInterval

    /// Type of presentation when is open
    public var presentationStyle: PresentationStyle

    /// A closure that make a new content with passed context.
    public var content: (ScenarioContext) -> UIViewController

    /// Creates a new scenario.
    ///
    /// - Parameters:
    ///   - name: A unique name of this scenario.
    ///   - layout: Represents how the component should be laid out.
    ///   - presentationStyle: Type of presentation when is open.
    ///   - delay: A custom timer to take the snapshot.
    ///   - file: A file path where defined this scenario.
    ///   - line: A line number where defined this scenario in file.
    ///   - content: A closure that make a new content with passed context.
    public init(
        _ name: ScenarioName,
        layout: ScenarioLayout,
        presentationStyle: PresentationStyle = .modal,
        delay: TimeInterval = 0.2,
        file: StaticString = #file,
        line: UInt = #line,
        content: @escaping (ScenarioContext) -> UIViewController
    ) {
        self.name = name
        self.layout = layout
        self.delay = delay
        self.presentationStyle = presentationStyle
        self.file = file
        self.line = line
        self.content = content
    }

    /// Creates a new scenario.
    ///
    /// - Parameters:
    ///   - name: A unique name of this scenario.
    ///   - layout: Represents how the component should be laid out.
    ///   - presentationStyle: Type of presentation when is open.
    ///   - delay: A custom timer to take the snapshot.
    ///   - file: A file path where defined this scenario.
    ///   - line: A line number where defined this scenario in file.
    ///   - content: A closure that make a new content with passed context.
    public init(
        _ name: ScenarioName,
        layout: ScenarioLayout,
        presentationStyle: PresentationStyle = .modal,
        delay: TimeInterval = 0.2,
        file: StaticString = #file,
        line: UInt = #line,
        content: @escaping (ScenarioContext) -> UIView
    ) {
        self.init(
            name,
            layout: layout,
            presentationStyle: presentationStyle,
            delay: delay,
            file: file,
            line: line,
            content: { context in
                UIViewHostingController(view: content(context))
            }
        )
    }

    /// Creates a new scenario.
    ///
    /// - Parameters:
    ///   - name: A unique name of this scenario.
    ///   - layout: Represents how the component should be laid out.
    ///   - presentationStyle: Type of presentation when is open.
    ///   - delay: A custom timer to take the snapshot.
    ///   - file: A file path where defined this scenario.
    ///   - line: A line number where defined this scenario in file.
    ///   - content: A closure that make a new content.
    public init(
        _ name: ScenarioName,
        layout: ScenarioLayout,
        presentationStyle: PresentationStyle = .modal,
        delay: TimeInterval = 0.2,
        file: StaticString = #file,
        line: UInt = #line,
        content: @escaping () -> UIViewController
    ) {
        self.init(
            name,
            layout: layout,
            presentationStyle: presentationStyle,
            delay: delay,
            file: file,
            line: line,
            content: { _ in content() }
        )
    }

    /// Creates a new scenario.
    ///
    /// - Parameters:
    ///   - name: A unique name of this scenario.
    ///   - layout: Represents how the component should be laid out.
    ///   - presentationStyle: Type of presentation when is open.
    ///   - delay: A custom timer to take the snapshot.
    ///   - file: A file path where defined this scenario.
    ///   - line: A line number where defined this scenario in file.
    ///   - content: A closure that make a new content.
    public init(
        _ name: ScenarioName,
        layout: ScenarioLayout,
        presentationStyle: PresentationStyle = .modal,
        delay: TimeInterval = 0.2,
        file: StaticString = #file,
        line: UInt = #line,
        content: @escaping () -> UIView
    ) {
        self.init(
            name,
            layout: layout,
            presentationStyle: presentationStyle,
            delay: delay,
            file: file,
            line: line,
            content: { _ in
                UIViewHostingController(view: content())
            }
        )
    }
}

extension Scenario {
    public enum PresentationStyle {
        case modal
        case full
    }
}

extension View {
    public func show<Item, Content>(
        style: Scenario.PresentationStyle,
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item: Identifiable, Content: View {
        switch style {
        case .full:
            return AnyView(fullScreenCover(item: item, onDismiss: onDismiss, content: content))
        case .modal:
            return AnyView(sheet(item: item, onDismiss: onDismiss, content: content))
        }
    }
}

private final class UIViewHostingController: UIViewController {
    private let _view: UIView

    init(view: UIView) {
        self._view = view
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = _view
    }
}
