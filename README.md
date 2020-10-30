<p align="center">
<img src="https://raw.githubusercontent.com/playbook-ui/mediakit/master/logo/default-h%402x.png" alt="Playbook" width="400">
</p>

<p align="center">A library for isolated developing UI components and automatically taking snapshots of them.</p>

<p align="center">
<img src="https://raw.githubusercontent.com/playbook-ui/playbook-ios/master/assets/demo.png" alt="playbook" width="850">
</p>

# Playbook

<img src="https://raw.githubusercontent.com/playbook-ui/playbook-ios/master/assets/mockup.gif" alt="Playbook" width="350" align="right">

<a href="https://developer.apple.com/swift"><img alt="Swift5" src="https://img.shields.io/badge/language-Swift5-orange.svg"/></a>
<a href="https://github.com/playbook-ui/playbook-ios/actions"><img alt="CI Status" src="https://github.com/playbook-ui/playbook-ios/workflows/GitHub%20Actions/badge.svg"/></a>
<a href="LICENSE"><img alt="Lincense" src="http://img.shields.io/badge/License-Apache%202.0-black.svg"/></a>
<br>
<a href="https://github.com/playbook-ui/playbook-ios/releases/latest"><img alt="Release" src="https://img.shields.io/github/v/release/playbook-ui/playbook-ios.svg"/></a>
<a href="https://swift.org/package-manager"><img alt="Swift Package Manager" src="https://img.shields.io/badge/SwiftPM-compatible-yellowgreen.svg"/></a>
<a href="https://cocoapods.org/pods/Playbook"><img alt="CocoaPods" src="https://img.shields.io/cocoapods/v/Playbook.svg"/></a>
<a href="https://github.com/Carthage/Carthage"><img alt="Carthage" src="https://img.shields.io/badge/Carthage-compatible-yellow.svg"/></a>

`Playbook` is a library that provides a sandbox for building UI components without having to worry about application-specific dependencies, strongly inspired by [Storybook](https://storybook.js.org/) for JavaScript in web-frontend development.  

Components built by using `Playbook` can generate a standalone app as living styleguide.  
This allows you to not only review UI quickly but also deliver more robost designs by separating business logics out of components.

Besides, snapshots of each component can be automatically generated by unit tests, and visual regression tests can be performed by using arbitrary third-party tools.

For complex modern app development, it’s important to catch UI changes more sensitively and keep improving them faster.  
With the `Playbook`, you don't have to struggle through preparing the data and spend human resources for manual testings.  

> *Android version is 🔜*

<br clear="all">

---

## Usage

- [API Document](https://playbook-ui.github.io/playbook-ios)
- [Example App](https://github.com/playbook-ui/playbook-ios/tree/master/Example)

---

### Playbook

`Playbook` is a framework that provides the basic functionality for managing components. It supports both `SwiftUI` and `UIKit`.  
Components are uniquely stored as scenarios. A `Scenario` has the way to layout component. Please check the [API Doc](https://playbook-ui.github.io/playbook-ios/ScenarioLayout.html) for the variety of layouts.  

```swift
Playbook.default.addScenarios(of: "Home") {
    Scenario("CategoryHome", layout: .fill) {
        CategoryHome().environmentObject(UserData.stub)
    }

    Scenario("LandmarkList", layout: .fill) {
        NavigationView {
            LandmarkList().environmentObject(UserData.stub)
        }
    }

    Scenario("UIView red", layout: .fixed(length: 100)) {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }
}
```

`ScenarioProvider` allows you to isolate additional scenarios and keep your playbook building clean.  

```swift
struct HomeScenarios: ScenarioProvider {
    static func addScenarios(into playbook: Playbook) {
        playbook.addScenarios(of: "Home") {
            Scenario("CategoryHome", layout: .fill) {
                CategoryHome().environmentObject(UserData.stub)
            }
        }
    }
}

struct AllScenarios: ScenarioProvider {
    static func addScenarios(into playbook: Playbook) {
        playbook.add(HomeScenarios.self)
    }
}
```

You can use the `ScenarioContext` passed to the closure that creates the component to get the screen size in snapshot, or wait before generating a snapshot.  

```swift
Scenario("MapView", layout: .fill) { context in
    MapView(coordinate: landmarkData[10].locationCoordinate) {
        // This closure will called after the map has completed to render.
        context.snapshotWaiter.fulfill()
     }
     .onAppear(perform: context.snapshotWaiter.wait)
}
```

---

### PlaybookSnapshot

Scenarios can be tested by the instance of types conform to `TestTool` protocol.  
`Snapshot` is one of them, which can generate the snapshots of all scenarios with simulate the screen size and safe area of the given devices.  
Since `Snapshot` depends on `XCTest`, it should be used in the module for unit test.   

```swift
final class SnapshotTests: XCTestCase {
    func testTakeSnapshot() throws {
        let directory = ProcessInfo.processInfo.environment["SNAPSHOT_DIR"]!

        try Playbook.default.run(
            Snapshot(
                directory: URL(fileURLWithPath: directory),
                clean: true,
                format: .png,
                keyWindow: UIApplication.shared.windows.first { $0.isKeyWindow },
                devices: [.iPhone11Pro(.portrait)]
            )
        )
    }
}
```

<img src="https://raw.githubusercontent.com/playbook-ui/playbook-ios/master/assets/generated-images.png" alt="generate images" width="660">

---

### PlaybookUI

`PlaybookUI` is a framework that provides user interfaces made by `SwiftUI` for browsing a list of scenarios.  

#### PlaybookGallery

The component visuals are listed and displayed.  
Those that are displayed on the top screen are not actually doing layout, but rather display the snapshots that are efficiently generated at runtime.  

| Browser | Detail |
| ------- | ------ |
|<img src="https://raw.githubusercontent.com/playbook-ui/playbook-ios/master/assets/gallery-light.png" alt="Gellery Light" width="150"><img src="https://raw.githubusercontent.com/playbook-ui/playbook-ios/master/assets/gallery-dark.png" alt="Gellery Dark" width="150">|<img src="https://raw.githubusercontent.com/playbook-ui/playbook-ios/master/assets/gallery-content-light.png" alt="Gellery Content Light" width="150"><img src="https://raw.githubusercontent.com/playbook-ui/playbook-ios/master/assets/gallery-content-dark.png" alt="Gellery Content Dark" width="150">|

#### PlaybookCatalog

The UI that search and select a scenario in a drawer. It's more similar to `Storybook`.  
If you have too many scenarios, this may be more efficient than `PlaybookCatalog`.  

| Browser | Detail |
| ------- | ------ |
|<img src="https://raw.githubusercontent.com/playbook-ui/playbook-ios/master/assets/catalog-drawer-light.png" alt="Catalog Drawer Light" width="150"><img src="https://raw.githubusercontent.com/playbook-ui/playbook-ios/master/assets/catalog-drawer-dark.png" alt="Catalog Drawer Dark" width="150">|<img src="https://raw.githubusercontent.com/playbook-ui/playbook-ios/master/assets/catalog-light.png" alt="Catalog Light" width="150"><img src="https://raw.githubusercontent.com/playbook-ui/playbook-ios/master/assets/catalog-dark.png" alt="Catalog Dark" width="150">|

#### How to Save Snapshot Images

To save snapshot images to the photo library from the share button on each UI, `NSPhootLibraryAddUsageDescription` must be supported.  See the [official document](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW73) for more information.

---

### Integration with Third-party Tools

The snapshot image files generated on the host machine's file system by `PlaybookSnapshot` can be used with a variety of third-party tools.  

#### [reg-viz/reg-suit](https://github.com/reg-viz/reg-suit)

It's highly recommended to use `reg-suit` in order to sublimate the snapshot images to the visual regression test.  
It sends a report of UI changes for each pull request and visually check the impact on the existing components.  
See [reg-viz/reg-suit](https://github.com/reg-viz/reg-suit) for more details.  

[Example pull-request](https://github.com/playbook-ui/playbook-ios/pull/13) is here.  

<img src="https://raw.githubusercontent.com/playbook-ui/playbook-ios/master/assets/reg-report.png" alt="Report from reg-suit" width="600">

---

## Requirements

- Swift 5.1+
- Xcode 11.0+
- iOS
  - `Playbook`: 11.0+
  - `PlaybookSnapshot`: 11.0+
  - `PlaybookUI`: 13.0+

---

## Installation

Playbook features are separated into the following frameworks.  

- `Playbook`: Core system of component management.
- `PlaybookSnapshot`: Generates snapshots of all components.
- `PlaybookUI`: Products a browsing UI for components managed by Playbook.

### [CocoaPods](https://cocoapods.org)

Add the following to your `Podfile`:

```ruby
target 'YourPlaybook' do
  pod 'Playbook'
  pod 'PlaybookUI'

  target 'YourPlaybookTests' do
    inherit! :search_paths

    pod 'PlaybookSnapshot'
  end
end
```

### [Carthage](https://github.com/Carthage/Carthage)

Add the following to your `Cartfile`:

```
github "playbook-ui/playbook-ios"
```

### [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)

Select Xcode menu `File > Swift Packages > Add Package Dependency...` and enter repository URL with GUI.

```
Repository: https://github.com/playbook-ui/playbook-ios
```

Note: Currently, SwiftPM doesn't support specifying the OS version for each library, so only `iOS13` is supported.  

---

## License

Playbook is released under the [Apache 2.0 License](https://github.com/playbook-ui/playbook-ios/tree/master/LICENSE).

<br>
<p align="center">
<img alt="Playbook" src="https://raw.githubusercontent.com/playbook-ui/mediakit/master/logo/default%402x.png" width="280">
</p>
