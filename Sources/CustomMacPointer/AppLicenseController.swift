import AppKit
import AmoreLicensing
import Foundation

@MainActor
final class AppLicenseController {
    enum Status: Equatable {
        case checking
        case activating
        case licensed(String)
        case gracePeriod(String)
        case unlicensed(String?)
        case unavailable(String)

        var canUseApp: Bool {
            switch self {
            case .licensed, .gracePeriod:
                return true
            case .checking, .activating, .unlicensed, .unavailable:
                return false
            }
        }
    }

    private enum Constants {
        static let bundleIdentifier = "com.burekcursor.app"
        static let licensePublicKey = "IEY17DUucftNPq34BcYfQScujA7CznCjhMJoKZGz31g="
        static let checkoutURL = URL(string: "https://api.amore.computer/v1/checkout/10D77FF6-6EB8-42FB-B1A7-6143E97725D4")!
    }

    private let licensing: AmoreLicensing?

    var status: Status = .checking {
        didSet {
            onStatusChange?(status)
        }
    }

    var onStatusChange: ((Status) -> Void)?

    init() {
        do {
            licensing = try AmoreLicensing(
                publicKey: Constants.licensePublicKey,
                bundleIdentifier: Constants.bundleIdentifier
            )
        } catch {
            licensing = nil
            status = .unavailable("Licensing could not start: \(error.localizedDescription)")
        }
    }

    func validateStoredLicense() async {
        guard let licensing else { return }
        status = .checking

        do {
            let validationStatus = try await licensing.validate()
            status = Self.status(from: validationStatus)
        } catch {
            status = .unlicensed(nil)
        }
    }

    func activate(licenseKey rawLicenseKey: String) async {
        guard let licensing else { return }

        let licenseKey = rawLicenseKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !licenseKey.isEmpty else {
            status = .unlicensed("Enter your license key first.")
            return
        }

        status = .activating

        do {
            try await licensing.activate(licenseKey: licenseKey)
            status = Self.status(from: licensing.status)
        } catch {
            status = .unlicensed(error.localizedDescription)
        }
    }

    func openCheckout() {
        NSWorkspace.shared.open(Constants.checkoutURL)
    }

    private static func status(from validationStatus: ValidationStatus) -> Status {
        switch validationStatus {
        case .valid(let license):
            return .licensed(license.name)
        case .gracePeriod(let license):
            return .gracePeriod(license.name)
        case .invalid:
            return .unlicensed("This license is invalid or has been revoked.")
        case .unknown:
            return .unlicensed(nil)
        }
    }
}
