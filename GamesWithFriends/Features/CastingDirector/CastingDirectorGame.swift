import SwiftUI

/// Casting Director game definition for the Games With Friends app
struct CastingDirectorGame: GameDefinition {
    let id = "casting-director"
    let name = "Casting Director"
    let description = "Guess the actor from progressive clues"
    let iconName = "person.crop.rectangle.stack"
    let accentColor = Color.indigo

    func makeRootView() -> AnyView {
        AnyView(CastingDirectorRootView())
    }
}
