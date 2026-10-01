//
//  RouterTests.swift
//  RouterTests
//

import Router
import SwiftUI
import Testing

@MainActor
struct RouterTests {

    private struct StubDestination: Identifiable, Hashable {
        let id = UUID()
    }

    @Test
    func navigateGrowsThePath() {
        let router = Router()
        let first = StubDestination()
        let second = StubDestination()

        router.navigate(to: first)
        router.navigate(to: second)

        #expect(router.navPath.count == 2)
    }

    @Test
    func navigateBackRemovesOneDestination() {
        let router = Router()
        router.navigate(to: StubDestination())
        router.navigate(to: StubDestination())

        router.navigateBack()

        #expect(router.navPath.count == 1)
    }

    @Test
    func navigateToRootEmptiesThePath() {
        let router = Router()
        router.navigate(to: StubDestination())
        router.navigate(to: StubDestination())
        router.navigate(to: StubDestination())

        router.navigateToRoot()

        #expect(router.navPath.count == 0)
    }

    // Not tested: navigateBack() on an empty path — NavigationPath.removeLast()
    // traps there, and the Router deliberately leaves that precondition to
    // the UI (it only calls it when a screen is showing).

    @Test
    func presentSheetWrapsTheDestination() {
        let router = Router()
        let destination = StubDestination()

        router.presentSheet(destination: destination)

        #expect(router.presentedSheet?.destination as? StubDestination == destination)
    }

    @Test
    func presentingASecondSheetReplacesTheFirst() {
        let router = Router()
        let first = StubDestination()
        let second = StubDestination()

        router.presentSheet(destination: first)
        router.presentSheet(destination: second)

        #expect(router.presentedSheet?.destination as? StubDestination == second)
    }
}
