#if canImport(SwiftUI) && canImport(Combine)

import SwiftUI

@available(iOS 13.0, *)
public extension Scenario {
    /// Creates a new scenario with SwiftUI view.
    ///
    /// - Parameters:
    ///   - name: A unique name of this scenario.
    ///   - layout: Represents how the component should be laid out.
    ///   - presentationStyle: Type of presentation when is open.
    ///   - delay: A custom timer to take the snapshot.
    ///   - file: A file path where defined this scenario.
    ///   - line: A line number where defined this scenario in file.
    ///   - content: A closure that make a new content with passed context.
    init<Content: View>(
        _ name: ScenarioName,
        layout: ScenarioLayout,
        presentationStyle: PresentationStyle = .modal,
        delay: TimeInterval = 0.2,
        file: StaticString = #file,
        line: UInt = #line,
        content: @escaping (ScenarioContext) -> Content
    ) {
        self.init(name, layout: layout, presentationStyle: presentationStyle, delay: delay, file: file, line: line) { context in
            let content = content(context).transaction { transaction in
                if context.isSnapshot {
                    transaction.disablesAnimations = true
                }
            }
            let controller = UIHostingController(rootView: content)
            controller.view.backgroundColor = .clear
            return controller
        }
    }

    /// Creates a new scenario with SwiftUI view.
    ///
    /// - Parameters:
    ///   - name: A unique name of this scenario.
    ///   - layout: Represents how the component should be laid out.
    ///   - presentationStyle: Type of presentation when is open.
    ///   - delay: A custom timer to take the snapshot.
    ///   - file: A file path where defined this scenario.
    ///   - line: A line number where defined this scenario in file.
    ///   - content: A closure that make a new content.
    init<Content: View>(
        _ name: ScenarioName,
        layout: ScenarioLayout,
        presentationStyle: PresentationStyle = .modal,
        delay: TimeInterval = 0.2,
        file: StaticString = #file,
        line: UInt = #line,
        content: @escaping () -> Content
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
}

#endif
