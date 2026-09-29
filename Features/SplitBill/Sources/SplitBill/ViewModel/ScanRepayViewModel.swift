//
//  ScanRepayViewModel.swift
//  SplitBill
//
//  Created by Dinh Long on 29/9/26.
//

import Domains
import Observation

@MainActor
@Observable
public final class ScanRepayViewModel {

    public enum State: Equatable {
        case scanning
        case decoding
        case failed(DomainError)
    }

    public private(set) var state: State = .scanning

    private let splitQRRepository: ISplitQRRepository

    public init(splitQRRepository: ISplitQRRepository) {
        self.splitQRRepository = splitQRRepository
    }

    public var errorMessage: String? {
        guard case .failed(let error) = state else { return nil }
        return error.message
    }

    // Returns nil on failure; the view stays on the failed state and lets the
    // user retry rather than the camera silently re-scanning the same code.
    public func decode(_ payload: String) async -> ScannedRepayment? {
        state = .decoding

        do {
            let review = try await splitQRRepository.decodeQR(payload: payload)
            state = .scanning
            return ScannedRepayment(payload: payload, review: review)
        } catch let error as DomainError {
            state = .failed(error)
            return nil
        } catch {
            state = .failed(.unknown(code: nil, message: error.localizedDescription))
            return nil
        }
    }

    public func retry() {
        state = .scanning
    }
}
