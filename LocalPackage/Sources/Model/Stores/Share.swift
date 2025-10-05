import DataSource
import Observation
import UIKit
import UniformTypeIdentifiers

@MainActor @Observable public final class Share: Composable {
    private let nsExtensionContextClient: NSExtensionContextClient
    private let extensionContext: () -> NSExtensionContext?
    private let openURL: (URL) -> Void

    public var sharedType: SharedType
    public let action: (Action) async -> Void

    public init(
        nsExtensionContextClient: NSExtensionContextClient,
        extensionContext: @escaping () -> NSExtensionContext?,
        openURL: @escaping (URL) -> Void,
        sharedType: SharedType = .undefined,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.nsExtensionContextClient = nsExtensionContextClient
        self.extensionContext = extensionContext
        self.openURL = openURL
        self.sharedType = sharedType
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case .task:
            let result = await extractSharedItem(from: extensionContext())
            switch result {
            case let .success(sharedType):
                self.sharedType = sharedType
            case let .failure(error):
                try? await Task.sleep(for: .seconds(0.5))
                nsExtensionContextClient.cancelRequest(extensionContext(), error)
            }

        case .cancelButtonTapped:
            nsExtensionContextClient.cancelRequest(extensionContext(), ShareError.canceled)

        case .confirmButtonTapped:
            defer {
                nsExtensionContextClient.completeRequest(extensionContext())
            }
            guard let shareURL = sharedType.shareURL else { return }
            openURL(shareURL)
        }
    }

    private func extractSharedItem(from context: NSExtensionContext?) async -> Result<SharedType, ShareError> {
        guard let item = nsExtensionContextClient.inputItems(context).first as? NSExtensionItem,
              let attachment = item.attachments?.first else {
            return .failure(ShareError.nonAttachmentsItem)
        }
        if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            return await withCheckedContinuation { continuation in
                _ = attachment.loadObject(ofClass: URL.self) { reading, _ in
                    if let value = reading {
                        continuation.resume(returning: .success(.link(value)))
                    } else {
                        continuation.resume(returning: .failure(.nonURLItem))
                    }
                }
            }
        } else if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            return await withCheckedContinuation { continuation in
                _ = attachment.loadObject(ofClass: String.self) { reading, _ in
                    if let text = reading {
                        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        continuation.resume(returning: .success(.plainText(value)))
                    } else {
                        continuation.resume(returning: .failure(.nonTextItem))
                    }
                }
            }
        } else {
            return .failure(.nonSupportedItem)
        }
    }

    public enum Action: Sendable {
        case task
        case cancelButtonTapped
        case confirmButtonTapped
    }
}
