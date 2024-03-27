import UIKit

extension UISpringTimingParameters {
    /// A design-friendly way to create a spring timing curve.
    ///
    /// - Parameters:
    ///   - damping: The 'bounciness' of the animation. Value must be between 0 and 1.
    ///   - response: The 'speed' of the animation.
    ///   - initialVelocity: The vector describing the starting motion of the property. Optional, default is `.zero`.
    convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }

    convenience init(duration: TimeInterval, bounce: CGFloat, initialVelocity: CGVector = .zero) {
        let mass = 1
        let stiffness = pow(2 * CGFloat.pi / CGFloat(duration), 2)
        let damping: CGFloat = {
            if bounce >= 0 {
                return 1 - ((4 * CGFloat.pi * bounce) / CGFloat(duration))
            } else {
                return (4 * CGFloat.pi) / (CGFloat(duration) + 4 * CGFloat.pi * bounce)
            }
        }()
        print("stiffness: \(stiffness)")
        print("damping: \(damping)")
        self.init(mass: 1, stiffness: stiffness, damping: damping, initialVelocity: initialVelocity)
    }
}
