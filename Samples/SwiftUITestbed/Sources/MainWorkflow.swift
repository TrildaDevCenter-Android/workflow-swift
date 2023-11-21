/*
 * Copyright 2023 Square Inc.
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

import MarketWorkflowUI
import Workflow

struct MainWorkflow: Workflow {
    let didClose: (() -> Void)?

    enum Output {
        case pushScreen
        case presentScreen
    }

    struct State {
        var title: String {
            didSet {
                if title == oldValue { return }
                isAllCaps = title.isAllCaps
            }
        }

        var isAllCaps: Bool {
            didSet {
                if isAllCaps == oldValue { return }
                title = isAllCaps ? title.uppercased() : title.lowercased()
            }
        }

        init(title: String) {
            self.title = title
            self.isAllCaps = title.isAllCaps
        }
    }

    func makeInitialState() -> State {
        State(title: "New item")
    }

    enum Action: WorkflowAction {
        typealias WorkflowType = MainWorkflow

        case pushScreen
        case presentScreen

        func apply(toState state: inout WorkflowType.State) -> WorkflowType.Output? {
            switch self {
            case .pushScreen:
                return .pushScreen
            case .presentScreen:
                return .presentScreen
            }
        }
    }

    typealias Rendering = MainViewModel

    func render(state: State, context: RenderContext<Self>) -> Rendering {
        let sink = context.makeSink(of: Action.self)

        return MainViewModel(
            title: context.makeBinding(get: \.title, set: { newValue in
                AnyWorkflowAction { state in
                    state.title = newValue
                    return nil
                }
            }),
            allCapsToggleIsOn: context.makeBinding(get: \.isAllCaps, set: { newValue in
                AnyWorkflowAction { state in
                    state.isAllCaps = newValue
                    return nil
                }
            }),
            allCapsToggleIsEnabled: !state.title.isEmpty,
            didTapPushScreen: { sink.send(.pushScreen) },
            didTapPresentScreen: { sink.send(.presentScreen) },
            didTapClose: didClose
        )
    }
}

private extension String {
    var isAllCaps: Bool {
        allSatisfy { character in
            character.isUppercase || !character.isCased
        }
    }
}
