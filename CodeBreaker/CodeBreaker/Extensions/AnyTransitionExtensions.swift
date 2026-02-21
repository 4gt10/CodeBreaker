import SwiftUI

extension AnyTransition {
    static let pegChooser = AnyTransition.offset(x: 0, y: 200)
    
    static func attempt(isGameOver: Bool) -> AnyTransition {
        .asymmetric(
            insertion: isGameOver ? .opacity : .move(edge: .top),
            removal: .move(edge: .trailing)
        )
    }
}
