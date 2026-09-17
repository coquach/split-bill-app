//
//  AppContainer.swift
//  SplitPay
//
//  Created by Co Quach on 17/9/26.
//

import Swinject

final class AppContainer {
    
    let container: Container
    
    init() {
        let container = Container()
        self.container = container
    }
}
