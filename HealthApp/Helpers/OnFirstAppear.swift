import SwiftUI

// put reference
private struct OnFirstAppear: ViewModifier {
    final class ReferenceState {
        var hasAppeared = false
    }
    @State private var referenceState = ReferenceState()
    var perform: () -> Void
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !referenceState.hasAppeared else { return }
                referenceState.hasAppeared = true
                perform()
            }
    }
}

extension View {
    func onFirstAppear(perform: @escaping () -> Void) -> some View {
        self.modifier(OnFirstAppear(perform: perform))
    }
}
