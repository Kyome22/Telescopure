import DataSource
import Observation
import UIKit
import UniformTypeIdentifiers

@MainActor @Observable public final class Share: Composable {
    private weak var viewController: UIViewController?
    private let uiApplicationClient: UIApplicationClient
    private let uiViewControllerClient: UIViewControllerClient

    public var sharedType: SharedType
    public let action: (Action) async -> Void

    public init(
        viewController: UIViewController,
        uiApplicationClient: UIApplicationClient,
        uiViewControllerClient: UIViewControllerClient,
        sharedType: SharedType = .undefined,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.viewController = viewController
        self.uiApplicationClient = uiApplicationClient
        self.uiViewControllerClient = uiViewControllerClient
        self.sharedType = sharedType
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case .task:
            let result = await extractSharedItem(from: viewController?.extensionContext)
            switch result {
            case let .success(sharedType):
                self.sharedType = sharedType
            case let .failure(error):
                guard let viewController else { return }
                try? await Task.sleep(for: .seconds(0.5))
                uiViewControllerClient.cancelRequest(viewController, error)
            }

        case .cancelButtonTapped:
            guard let viewController else { return }
            uiViewControllerClient.cancelRequest(viewController, ShareError.canceled)

        case .openButtonTapped:
            guard let viewController else { return }
            defer {
                uiViewControllerClient.completeRequest(viewController)
            }
            guard let shareURL = sharedType.shareURL else { return }
            uiApplicationClient.perform(viewController, shareURL)
        }
    }

    private func extractSharedItem(from context: NSExtensionContext?) async -> Result<SharedType, ShareError> {
        guard let item = context?.inputItems.first as? NSExtensionItem,
              let attachment = item.attachments?.first else {
            return .failure(ShareError.nonAttachmentsItem)
        }
        let urlID = UTType.url.identifier
        let plainTextID = UTType.plainText.identifier
        if attachment.hasItemConformingToTypeIdentifier(urlID) {
            return await withCheckedContinuation { continuation in
                attachment.loadItem(forTypeIdentifier: urlID) { loadedItem, _ in
                    if let value = loadedItem as? URL {
                        continuation.resume(returning: .success(.link(value)))
                    } else {
                        continuation.resume(returning: .failure(.nonURLItem))
                    }
                }
            }
        } else  if attachment.hasItemConformingToTypeIdentifier(plainTextID) {
            return await withCheckedContinuation { continuation in
                attachment.loadItem(forTypeIdentifier: plainTextID) { loadedItem, _ in
                    if let text = loadedItem as? String {
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
        case openButtonTapped
    }
}
