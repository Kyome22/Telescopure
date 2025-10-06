import Foundation
import os
import Testing
import UniformTypeIdentifiers

@testable import DataSource
@testable import Model

struct ShareTests {
    @MainActor @Test
    func send_task_extract_failed_nonAttachmentsItem() async {
        let errors = OSAllocatedUnfairLock<[any Error]>(initialState: [])
        let sut = Share(
            nsExtensionContextClient: testDependency(of: NSExtensionContextClient.self) {
                $0.inputItems = { _ in [] }
                $0.cancelRequest = { _, error in
                    errors.withLock { $0.append(error) }
                }
            },
            extensionContext: { nil },
            openURL: { _ in },
            sharedType: .undefined
        )
        await sut.send(.task)
        #expect(errors.withLock(\.self).compactMap({ $0 as? ShareError }) == [ShareError.nonAttachmentsItem])
    }

    @MainActor @Test
    func send_task_extract_failed_nonSupportedItem() async {
        let errors = OSAllocatedUnfairLock<[any Error]>(initialState: [])
        let sut = Share(
            nsExtensionContextClient: testDependency(of: NSExtensionContextClient.self) {
                $0.inputItems = { _ in
                    let item = NSExtensionItem()
                    item.attachments = [
                        NSItemProvider(item: NSData(), typeIdentifier: UTType.data.identifier)
                    ]
                    return [item]
                }
                $0.cancelRequest = { _, error in
                    errors.withLock { $0.append(error) }
                }
            },
            extensionContext: { nil },
            openURL: { _ in },
            sharedType: .undefined
        )
        await sut.send(.task)
        #expect(errors.withLock(\.self).compactMap({ $0 as? ShareError }) == [ShareError.nonSupportedItem])
    }

    @MainActor @Test
    func send_task_extract_link() async {
        let sut = Share(
            nsExtensionContextClient: testDependency(of: NSExtensionContextClient.self) {
                $0.inputItems = { _ in
                    let item = NSExtensionItem()
                    item.attachments = [
                        NSItemProvider(
                            item: NSURL(string: "https://example.com"),
                            typeIdentifier: UTType.url.identifier
                        )
                    ]
                    return [item]
                }
            },
            extensionContext: { nil },
            openURL: { _ in },
            sharedType: .undefined
        )
        await sut.send(.task)
        #expect(sut.sharedType == .link(URL(string: "https://example.com")!))
    }

    @MainActor @Test
    func send_task_extract_plainText() async {
        let sut = Share(
            nsExtensionContextClient: testDependency(of: NSExtensionContextClient.self) {
                $0.inputItems = { _ in
                    let item = NSExtensionItem()
                    item.attachments = [
                        NSItemProvider(
                            item: NSString(string: "dummy"),
                            typeIdentifier: UTType.plainText.identifier
                        )
                    ]
                    return [item]
                }
            },
            extensionContext: { nil },
            openURL: { _ in },
            sharedType: .undefined
        )
        await sut.send(.task)
        #expect(sut.sharedType == .plainText("dummy"))
    }

    @MainActor @Test
    func send_cancelButtonTapped() async {
        let errors = OSAllocatedUnfairLock<[any Error]>(initialState: [])
        let sut = Share(
            nsExtensionContextClient: testDependency(of: NSExtensionContextClient.self) {
                $0.cancelRequest = { _, error in
                    errors.withLock { $0.append(error) }
                }
            },
            extensionContext: { nil },
            openURL: { _ in },
            sharedType: .undefined
        )
        await sut.send(.cancelButtonTapped)
        #expect(errors.withLock(\.self).compactMap({ $0 as? ShareError }) == [ShareError.canceled])
    }

    @MainActor @Test
    func send_confirmButtonTapped_undefined_not_open_url() async {
        let completeCount = OSAllocatedUnfairLock(initialState: 0)
        let urls = OSAllocatedUnfairLock<[URL]>(initialState: [])
        let sut = Share(
            nsExtensionContextClient: testDependency(of: NSExtensionContextClient.self) {
                $0.completeRequest = { _ in
                    completeCount.withLock { $0 += 1 }
                }
            },
            extensionContext: { nil },
            openURL: { url in
                urls.withLock { $0.append(url) }
            },
            sharedType: .undefined
        )
        await sut.send(.confirmButtonTapped)
        #expect(completeCount.withLock(\.self) == 1)
        #expect(urls.withLock(\.self).isEmpty)
    }

    @MainActor @Test
    func send_confirmButtonTapped_link_open_url() async {
        let completeCount = OSAllocatedUnfairLock(initialState: 0)
        let urls = OSAllocatedUnfairLock<[URL]>(initialState: [])
        let sut = Share(
            nsExtensionContextClient: testDependency(of: NSExtensionContextClient.self) {
                $0.completeRequest = { _ in
                    completeCount.withLock { $0 += 1 }
                }
            },
            extensionContext: { nil },
            openURL: { url in
                urls.withLock { $0.append(url) }
            },
            sharedType: .link(URL(string: "https://example.com")!)
        )
        await sut.send(.confirmButtonTapped)
        #expect(completeCount.withLock(\.self) == 1)
        #expect(urls.withLock(\.self) == [URL(string: "telescopure://?link=https://example.com")!])
    }

    @MainActor @Test
    func send_confirmButtonTapped_plain_text_open_url() async {
        let completeCount = OSAllocatedUnfairLock(initialState: 0)
        let urls = OSAllocatedUnfairLock<[URL]>(initialState: [])
        let sut = Share(
            nsExtensionContextClient: testDependency(of: NSExtensionContextClient.self) {
                $0.completeRequest = { _ in
                    completeCount.withLock { $0 += 1 }
                }
            },
            extensionContext: { nil },
            openURL: { url in
                urls.withLock { $0.append(url) }
            },
            sharedType: .plainText("dummy")
        )
        await sut.send(.confirmButtonTapped)
        #expect(completeCount.withLock(\.self) == 1)
        #expect(urls.withLock(\.self) == [URL(string: "telescopure://?plaintext=dummy")!])
    }
}
