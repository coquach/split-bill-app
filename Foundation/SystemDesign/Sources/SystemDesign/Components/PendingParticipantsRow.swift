//
//  PendingParticipantsRow.swift
//  SystemDesign
//
//  Created by Dinh Long on 28/9/26.
//

import SwiftUI

/// The single aggregate row standing in for everyone who hasn't paid yet.
///
/// Deliberately a *different* type from `ParticipantRow`, not a variant of
/// it. The participant list may only ever contain people who actually paid
/// through the QR — there are no placeholder "pending payer" people to model,
/// because the backend has no record of who they are. Counting them is the
/// only truthful thing we can show, so this row takes a count and nothing
/// else, and it can't be given a name or made tappable by accident.
public struct PendingParticipantsRow: View {
    private let count: Int

    public init(count: Int) {
        self.count = count
    }

    public var body: some View {
        HStack(spacing: AppSpacing.sm) {
            // Dashed outline, no fill — an absence, not a person.
            Circle()
                .strokeBorder(
                    Color.appTextTertiary,
                    style: StrokeStyle(lineWidth: 1, dash: [3, 3])
                )
                .frame(width: 32, height: 32)

            Text("\(count) pending")
                .font(AppTypography.body)
                .foregroundStyle(Color.appTextSecondary)

            Spacer()
        }
        .padding(.vertical, AppSpacing.xs)
    }
}
