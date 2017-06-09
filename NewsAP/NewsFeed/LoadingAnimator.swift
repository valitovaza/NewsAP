protocol LoadingAnimatorProtocol {
    func animateLoading()
    func removeLoadingAnimation()
}

import Lottie

protocol LottieViewProtocol {
    var loopAnimation: Bool {get set}
    func play()
    func pause()
}
extension LOTAnimationView: LottieViewProtocol {}

class LoadingAnimator: LoadingAnimatorProtocol {
    static let loaderName = "trail_loading"
    private var view: UIView
    private(set) var animationView: LottieViewProtocol
    init(_ view: UIView,
         _ animationView: LottieViewProtocol = LOTAnimationView(name: loaderName)!) {
        self.view = view
        self.animationView = animationView
        self.animationView.loopAnimation = true
    }
    private var isAnimating = false
    func animateLoading() {
        if !isAnimating {
            animate()
        }
    }
    private func animate() {
        isAnimating = true
        addSubview()
        animationView.play()
    }
    private func addSubview() {
        let animation = animationView as! UIView
        view.addSubview(animation)
        addConstraints(animation: animation)
    }
    
    var loaderSize: CGFloat = 200.0
    private func addConstraints(animation: UIView) {
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.addConstraint(NSLayoutConstraint(item: animation,
                                                   attribute: .width,
                                                   relatedBy: .equal,
                                                   toItem: nil,
                                                   attribute: .notAnAttribute,
                                                   multiplier: 1.0, constant: loaderSize))
        animation.addConstraint(NSLayoutConstraint(item: animation,
                                                   attribute: .height,
                                                   relatedBy: .equal,
                                                   toItem: nil,
                                                   attribute: .notAnAttribute,
                                                   multiplier: 1.0, constant: loaderSize))
        view.addConstraint(NSLayoutConstraint(item: animation,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerX,
                                              multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: animation,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerY,
                                              multiplier: 1.0, constant: 0.0))
    }
    
    func removeLoadingAnimation() {
        if isAnimating {
            removeAnimation()
        }
    }
    private func removeAnimation() {
        isAnimating = false
        animationView.pause()
        (animationView as! UIView).removeFromSuperview()
    }
}
