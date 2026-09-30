//
//  LaunchScreen.swift
//  SplitPay
//
//  Created by Co Quach on 29/9/26.
//

import SwiftUI
import SystemDesign

struct LaunchScreen<RootView: View, Logo: View>: Scene {
    var config: LaunchScreenConfig = .init()
    @ViewBuilder var logo: () -> Logo
    @ViewBuilder var rootContent: RootView

    var body: some Scene {
        WindowGroup {
            rootContent
                .modifier(LaunchScreenModifier(config: config, logo: logo))
        }
    }
}

private struct LaunchScreenModifier<Logo: View>: ViewModifier {
    var config: LaunchScreenConfig
    @ViewBuilder var logo: Logo

    @Environment(\.scenePhase) private var scenePhase
    @State private var splashWindow: UIWindow?
    func body(content: Content) -> some View {
        content
            /// Adding. an overlay. window. so that the splash. screen will be visible on top of the entire SwiftUi App!
            .onAppear {
                let scenes = UIApplication.shared.connectedScenes

                for scene in scenes {
                    guard let windowScene = scene as? UIWindowScene,
                        checkStates(windowScene.activationState),
                        /// Checking the window scene is already. having a splash window!
                        !windowScene.windows.contains(where: {
                            $0.tag == 1009
                        })
                    else {
                        print("Already have a splash window for this scene")
                        continue
                    }
                    let window = UIWindow(windowScene: windowScene)
                    window.backgroundColor = .clear
                    window.isHidden = false
                    window.isUserInteractionEnabled = true
                    let rootViewController = UIHostingController(
                        rootView: LaunchScreenView(config: config) {
                            logo
                        } isCompleted: {
                            window.isHidden = true
                            window.isUserInteractionEnabled = false
                        }
                    )
                    rootViewController.view.backgroundColor = .clear
                    window.rootViewController = rootViewController
                    self.splashWindow = window
                    print("Splash window added")
                }

            }
    }

    /// Checking both the ScenePhase and WindowScene activation states are the same!
    private func checkStates(_ state: UIWindowScene.ActivationState) -> Bool {
        switch scenePhase {
        case .active: return state == .foregroundActive
        case .inactive: return state == .foregroundInactive
        case .background: return state == .background
        default: return state.hashValue == scenePhase.hashValue
        }
    }
}

struct LaunchScreenConfig {
    var initialDelay: Double = 0.35
    var backgroundColor: Color = Color.appPrimary
    var logoBackgroundColor: Color = Color.appSurfacePrimary
    var scaling: CGFloat = 4
    var forceHideLogo: Bool = false
    var animationDuration: CGFloat = 1

    var animation: Animation = .smooth(duration: 1, extraBounce: 0)
}

private struct LaunchScreenView<Logo: View>: View {
    var config: LaunchScreenConfig
    @ViewBuilder var logo: Logo

    var isCompleted: () -> Void
    @State private var scaleDown: Bool = false
    @State private var scaleUp: Bool = false
    var body: some View {
        Rectangle()
            .fill(config.backgroundColor)
            .mask {

                GeometryReader {
                    let size = $0.size.applying(
                        .init(scaleX: config.scaling, y: config.scaling)
                    )
                    Rectangle()
                        .overlay {
                            logo
                                .blur(radius: config.forceHideLogo ? 0 : (scaleUp ? 15 : 0))
                                .blendMode(.destinationOut)
                                .animation(
                                    .smooth(duration: 0.3, extraBounce: 0)
                                ) {
                                    content in
                                    content.scaleEffect(scaleDown ? 0.8 : 1)
                                }
                                .visualEffect { [scaleUp] content, proxy in
                                    let scaleX: CGFloat =
                                        size.width / proxy.size.width
                                    let scaleY: CGFloat =
                                        size.height / proxy.size.height
                                    let maxScale = Swift.max(scaleX, scaleY)

                                    return content.scaleEffect(
                                        scaleUp ? maxScale : 1
                                    )

                                }
                        }

                }

            }
            .opacity(config.forceHideLogo ? 1 : (scaleUp ? 0 : 1))
            .background {
                Rectangle()
                    .fill(config.backgroundColor)
                    .opacity(scaleUp ? 0 : 1)
            }
            .ignoresSafeArea()
            .task {
                guard !scaleDown else { return }
                try? await Task.sleep(for: .seconds(config.initialDelay))
                scaleDown = true
                try? await Task.sleep(for: .seconds(0.1))
                withAnimation(
                    config.animation,
                    completionCriteria: .logicallyComplete
                ) {
                    scaleUp = true
                } completion: {
                    isCompleted()
                }
            }
    }

}
