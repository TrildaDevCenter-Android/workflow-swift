/*
 * Copyright 2022 Square Inc.
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

#if canImport(SwiftUI) && swift(>=5.1)

    import SwiftUI

    @available(iOS 13.0, macOS 10.15, *)
    public struct WithModel<Model, Content: View>: View {
        @ObservedObject private var model: ObservableValue<Model>
        private let content: (ObservableValue<Model>) -> Content

        public init(
            model: ObservableValue<Model>,
            @ViewBuilder content: @escaping (ObservableValue<Model>) -> Content
        ) {
            self.model = model
            self.content = content
        }

        public var body: Content {
            content(model)
        }
    }

#endif
