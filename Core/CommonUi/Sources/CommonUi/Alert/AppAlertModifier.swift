//
//  AppAlertModifier.swift
//  CommonUi
//
//  Created by Co Quach on 18/9/26.
//

import SwiftUI

private struct AppAlertModifier: ViewModifier {

    @Binding
    private var alert: AppAlert?

    init(alert: Binding<AppAlert?>) {
        self._alert = alert
    }

    func body(content: Content) -> some View {
        content
            .alert(
                alert?.title ?? "",
                isPresented: Binding(
                    get: {
                        alert != nil
                    },
                    set: { isPresented in
                        if !isPresented {
                            alert = nil
                        }
                    }
                ),
                presenting: alert
            ) { _ in
                Button("OK", role: .cancel) {
                    alert = nil
                }
            } message: { alert in
                Text(alert.message)
            }
    }
}

public extension View {

    func appAlert(
        item alert: Binding<AppAlert?>
    ) -> some View {
        modifier(
            AppAlertModifier(alert: alert)
        )
    }
}
