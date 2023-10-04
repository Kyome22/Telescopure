# <img src="Resources/rounded-icon.png" alt="logo" width="25px" height="25px" /> MinBrowser

MinBrowser is a browser for iOS which has minimal functions.<br>
You can use MinBrowser to debug your application that work with the browser.

Download this app from App Store.<br>
https://apps.apple.com/us/app/minbrowser/id1643406104

## Functions

- Open an HTTP or HTTPS link.
- Search by keywords.
- Browse a page in the full screen.
- Pull to refresh a page.
- Bookmark user's favorite page.
- Open a link of other app in MinBrowser.
- User can select a search engine (Google/Bing/DuckDuckGo).
- Support light and dark themes.
- Localized (English, Japanese).

## Requirements

- Written in Swift 5
- Compatible with iOS 16.4+
- Development with Xcode 13.4.1+

## Screenshots

### Top

<div>
  <img src="Resources/light/1-top.png" alt="top" width="150px" />
  <img src="Resources/dark/1-top.png" alt="top" width="150px" />
</div>
    
### Browsing

<div>
  <img src="Resources/light/2-browsing.png" alt="browsing" width="150px" />
  <img src="Resources/light/3-full-screen.png" alt="full screen" width="150px" />
  <img src="Resources/dark/2-browsing.png" alt="browsing" width="150px" />
  <img src="Resources/dark/3-full-screen.png" alt="full screen" width="150px" />
</div>
    
### Bookmark

<div>
  <img src="Resources/light/4-bookmark.png" alt="bookmark" width="150px" />
  <img src="Resources/dark/4-bookmark.png" alt="bookmark" width="150px" />
</div>

### Open link via other app

<div>
  <img src="Resources/light/5-open-link.png" alt="open link" width="150px" />
  <img src="Resources/dark/5-open-link.png" alt="open link" width="150px" />
</div>
    
## Implementation

- SwiftUI based App
- WKWebView wrapped in UIViewRepresentable
- UIAlertController via ViewModifier
- Share Extension

## Tree

```plain
.
├── MinBrowser
│   ├── Info.plist
│   ├── InfoPlist.strings
│   ├── Localizable.strings
│   ├── Assets.xcassets
│   ├── Settings.bundle
│   │   ├── Root.plist
│   │   └── Root.strings
│   ├── DebugLog.swift
│   ├── MinBrowserApp.swift
│   ├── View
│   │   ├── BookmarkButtonStyle.swift
│   │   ├── BookmarkView.swift
│   │   ├── LogoView.swift
│   │   ├── SearchBar.swift
│   │   ├── ShowToolBarButton.swift
│   │   ├── ToolBar.swift
│   │   ├── WebView.swift
│   │   └── WrappedWKWebView.swift
│   ├── ViewModel
│   │   ├── Bookmark.swift
│   │   ├── Mock
│   │   │   └── WebViewModelMock.swift
│   │   ├── SearchEngine.swift
│   │   ├── WebDialog.swift
│   │   └── WebViewModel.swift
│   └── Extensions
│       ├── Color+Extensions.swift
│       ├── String+Extensions.swift
│       └── WKWebView+Extension.swift
└── MinBrowserShare
    ├── Info.plist
    ├── Localizable.strings
    ├── View
    │   ├── MainInterface.storyboard
    │   ├── ShareView.swift
    │   └── ShareViewController.swift
    └── ViewModel
        ├── Mock
        │   └── ShareViewModelMock.swift
        ├── ShareError.swift
        ├── ShareViewModel.swift
        └── SharedType.swift
```

## How to be the Default Browser

The goal is to make MinBrowser the Default Browser.

[Apple - Preparing Your App to be the Default Browser or Email Client](https://developer.apple.com/documentation/xcode/preparing-your-app-to-be-the-default-browser-or-email-client)

## Debug Functions

The following page can be used for debugging MinBrowser.

https://kyome.io/debug/index.html

### JS Dialog

- Alert (`window.alert()`)
- Confirm (`window.confirm()`)
- Prompt (`window.prompt()`)

### Custom Scheme

- SMS `sms://`
- Telephone `tel://`
- FaceTime `facetime://` and `facetime-audio://`
- iMessage `imessage://`
- Mail `mailto://`

### Permission

- Photo Library (Load)
  - `WKWebView` does not need permission to upload photos/videos.
- Photo Library (Save)
  - Privacy - Photo Library Additions Usage Description (`NSPhotoLibraryAddUsageDescription`)
- Device Location
  - Privacy - Location When In Use Usage Description (`NSLocationWhenInUseUsageDescription`)
- Camera/Microphone
  - Privacy - Camera Usage Description (`NSCameraUsageDescription`)
  - Privacy - Microphone Usage Description (`NSMicrophoneUsageDescription`)
