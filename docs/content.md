:::header

# ![Telescopure](images/icon.png =30x30) Telescopure

A minimal iOS browser — perfect for debugging web applications

[Download on the App Store](https://apps.apple.com/us/app/telescopure/id1643406104)　[View on GitHub](https://github.com/Kyome22/Telescopure)

:::

## What is Telescopure?

**Telescopure** is a minimal iOS browser that can be set as your default browser. It is designed for web developers who need a clean, distraction-free browser for debugging web applications.

- Built with **Swift 6.2** and **SwiftUI**
- Requires **iOS 18.0+**
- Supports **English, Japanese, and Korean**
- Open source under the **MIT License**

---

## Features

~ | [~feat-a] | [~feat-b] | [~feat-c] |
~ | :-------- | :-------- | :-------- |

:::warp feat-a

### Default Browser

Can be set as the system default browser on iOS. Links from other apps open directly in Telescopure.

---

### HTTP / HTTPS

Open any `http://` or `https://` link. Search by keyword using your preferred search engine.

:::

:::warp feat-b

### Search Engines

Choose from **Google**, **Bing**, or **DuckDuckGo** as your default search engine.

---

### Full Screen Browsing

Browse pages in full screen mode, free from distractions.

:::

:::warp feat-c

### Bookmarks

Save and manage your favorite pages for quick access.

---

### More

- Pull to refresh
- Page zoom control
- Light / Dark theme
- Share Extension
- Web Inspector support

:::

---

## Screenshots

~ | [~ss-a] | [~ss-b] | [~ss-c] | [~ss-d] |
~ | :-----: | :-----: | :-----: | :-----: |

:::warp ss-a
![Browsing](images/1-browsing-1.png =180x)

**Browsing**
:::

:::warp ss-b
![Full Screen](images/2-browsing-2.png =180x)

**Full Screen**
:::

:::warp ss-c
![Bookmarks](images/3-bookmark.png =180x)

**Bookmarks**
:::

:::warp ss-d
![Settings](images/4-settings-1.png =180x)

**Settings**
:::

~ | [~ss-e] | [~ss-f] | [~ss-g] | [~ss-h] |
~ | :-----: | :-----: | :-----: | :-----: |

:::warp ss-e
![Default Browser](images/5-settings-2.png =180x)

**Default Browser**
:::

:::warp ss-f
![Search Engine](images/6-settings-3.png =180x)

**Search Engine**
:::

:::warp ss-g
![Share Extension](images/7-share-link-1.png =180x)

**Share Extension**
:::

:::warp ss-h
![Share Extension 2](images/8-share-link-2.png =180x)

**Share Extension (2)**
:::

---

## Architecture

Telescopure follows a three-layer architecture implemented as a local Swift Package (`LocalPackage/`).

~ | [~arch-ds] | [~arch-mo] | [~arch-ui] |
~ | :--------- | :--------- | :--------- |

:::warp arch-ds

### DataSource

Defines entities, external dependency clients, and repositories.

Uses the `DependencyClient` pattern — structs with `liveValue` and `testValue` — making unit testing straightforward without mocks or protocols.

:::

:::warp arch-mo

### Model

Business logic stores conforming to the `Composable` protocol.

Each store has an `Action` enum and a `reduce(_:)` method. Dispatch actions with `send(_:)`, which calls `reduce` then propagates up to the parent store.

:::

:::warp arch-ui

### UserInterface

SwiftUI views and scenes.

Receives `AppDependencies` via SwiftUI's `@Environment` and interacts with Model stores. All stores run on `@MainActor`.

:::

---

## Debug Functions

Telescopure is built for debugging. Use the test page at https://kyome.io/debug/index.html to verify the following features.

### JavaScript Dialogs

| Type    | Function           |
| :------ | :----------------- |
| Alert   | `window.alert()`   |
| Confirm | `window.confirm()` |
| Prompt  | `window.prompt()`  |

### Custom URL Schemes

| Type      | Scheme                              |
| :-------- | :---------------------------------- |
| SMS       | `sms://`                            |
| Telephone | `tel://`                            |
| FaceTime  | `facetime://` & `facetime-audio://` |
| iMessage  | `imessage://`                       |
| Mail      | `mailto://`                         |

:::details Permissions (click to expand)

| Category             | Permission                                                      |
| :------------------- | :-------------------------------------------------------------- |
| Photo Library (Load) | `WKWebView` does not require permission to upload photos/videos |
| Photo Library (Save) | `NSPhotoLibraryAddUsageDescription`                             |
| Device Location      | `NSLocationWhenInUseUsageDescription`                           |
| Camera               | `NSCameraUsageDescription`                                      |
| Microphone           | `NSMicrophoneUsageDescription`                                  |

:::

:::footer

MIT License © 2022 Takuto NAKAMURA (Kyome)

[GitHub](https://github.com/Kyome22/Telescopure) · [App Store](https://apps.apple.com/us/app/telescopure/id1643406104) · [kyome.io](https://kyome.io)

:::
