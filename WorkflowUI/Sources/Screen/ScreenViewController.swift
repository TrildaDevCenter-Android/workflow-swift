/*
 * Copyright 2020 Square Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#if canImport(UIKit)

import UIKit
@_spi(WorkflowGlobalObservation) import Workflow
import os.signpost

/// Generic base class that can be subclassed in order to to define a UI implementation that is powered by the
/// given screen type.
///
/// Using this base class, a screen can be implemented as:
/// ```
/// struct MyScreen: Screen {
///     func viewControllerDescription(environment: ViewEnvironment) -> ViewControllerDescription {
///         return MyScreenViewController.description(for: self)
///     }
/// }
///
/// private class MyScreenViewController: ScreenViewController<MyScreen> {
///     override func screenDidChange(from previousScreen: MyScreen, previousEnvironment: ViewEnvironment) {
///         // … update views as necessary
///     }
/// }
/// ```
open class ScreenViewController<ScreenType: Screen>: UIViewController {
    public private(set) final var screen: ScreenType

    public final var screenType: Screen.Type {
        return ScreenType.self
    }

    public private(set) final var environment: ViewEnvironment

    public required init(screen: ScreenType, environment: ViewEnvironment) {
        self.screen = screen
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        WorkflowObservation.sharedUIObserversInterceptor.workflowObservers(for: []).chained()?.screenDidAppear(screen, viewController: self, animated: animated, rootWorkflow: environment.originatingWorkflow)
        os_signpost(.event, log: .default, name: "ScreenViewController.viewDidAppear", "DidAppear screen %{public}@", "\(type(of: self.screen))")
    }

    open override func viewWillLayoutSubviews() {
        os_signpost(.event, log: .default, name: "ScreenViewController.viewWillLayoutSubviews", "WillLayout screen %{public}@", "\(type(of: self.screen))")
        super.viewWillLayoutSubviews()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        os_signpost(.event, log: .default, name: "ScreenViewController.viewDidLayoutSubviews", "DidLayout screen %{public}@", "\(type(of: self.screen))")
    }

    public final func update(screen: ScreenType, environment: ViewEnvironment) {
        let previousScreen = self.screen
        self.screen = screen
        let previousEnvironment = self.environment
        self.environment = environment
        os_signpost(.event, log: .default, name: "ScreenViewController.update", "Update with %{public}@ from %{public}@", "\(type(of: ScreenType.self))", "\(type(of: environment.originatingWorkflow))")
//        print("update screen \(ScreenType.self) from workflow: \(type(of: environment.originatingWorkflow))")
        screenDidChange(from: previousScreen, previousEnvironment: previousEnvironment)
        WorkflowObservation.sharedUIObserversInterceptor.workflowObservers(for: []).chained()?.viewControllerDidUpdateScreen(self, screen: screen, viewEnvironment: environment, rootWorkflow: environment.originatingWorkflow)
    }

    /// Subclasses should override this method in order to update any relevant UI bits when the screen model changes.
    open func screenDidChange(from previousScreen: ScreenType, previousEnvironment: ViewEnvironment) {}
}

extension ScreenViewController {
    /// Convenience to create a view controller description for the given screen
    /// value. See the example on the comment for ScreenViewController for
    /// usage.
    public final class func description(
        for screen: ScreenType,
        environment: ViewEnvironment,
        performInitialUpdate: Bool = true
    ) -> ViewControllerDescription {
        ViewControllerDescription(
            performInitialUpdate: performInitialUpdate,
            type: self,
            build: { self.init(screen: screen, environment: environment) },
            update: { $0.update(screen: screen, environment: environment) }
        )
    }
}

#endif
