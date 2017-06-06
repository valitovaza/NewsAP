import XCTest
@testable import NewsAP

class LoadingAnimatorTests: XCTestCase {
    
    var sut: LoadingAnimator!
    var view: UIViewSpy!
    var animation: AnimationSpy!
    
    override func setUp() {
        super.setUp()
        view = UIViewSpy()
        animation = AnimationSpy()
        sut = LoadingAnimator(view, animation)
    }
    
    override func tearDown() {
        sut = nil
        view = nil
        animation = nil
        super.tearDown()
    }
    
    func testAnimateLoadingMustAddLOTView() {
        sut.animateLoading()
        XCTAssertEqual(view.addSubviewWasInvoked, 1)
        XCTAssertNotNil(view.addedView as? LottieViewProtocol)
    }
    
    func testLoopAnimationMustBeSetted() {
        XCTAssertTrue(animation.loopAnimation)
    }
    
    func testAnimateMustInvokePlayOnLottie() {
        sut.animateLoading()
        XCTAssertEqual(animation.playWasInvoked, 1)
    }
    
    func testSecondAnimateLoadingWithoutRemoveMustBeIgnored() {
        sut.animateLoading()
        sut.animateLoading()
        XCTAssertEqual(animation.playWasInvoked, 1)
        XCTAssertEqual(view.addSubviewWasInvoked, 1)
    }
    
    func testRemoveLoadingAnimationMustBeIgnoredIfNoAnimating() {
        sut.removeLoadingAnimation()
        XCTAssertEqual(animation.removeFromSuperviewWasInvoked, 0)
    }
    
    func testRemoveLoadingAnimationMustRemoveFromSuperview() {
        sut.animateLoading()
        sut.removeLoadingAnimation()
        XCTAssertEqual(animation.removeFromSuperviewWasInvoked, 1)
    }
    func testRemoveLoadingAnimationMustPauseAnimation() {
        sut.animateLoading()
        sut.removeLoadingAnimation()
        XCTAssertEqual(animation.pauseWasInvoked, 1)
    }
    
    func testAnimate_Remove_AnimateSequence() {
        sut.animateLoading()
        sut.removeLoadingAnimation()
        sut.animateLoading()
        XCTAssertEqual(animation.removeFromSuperviewWasInvoked, 1)
        XCTAssertEqual(animation.playWasInvoked, 2)
    }
}
extension LoadingAnimatorTests {
    class UIViewSpy: UIView {
        var addSubviewWasInvoked = 0
        var addedView: UIView?
        override func addSubview(_ view: UIView) {
            addSubviewWasInvoked += 1
            addedView = view
        }
    }
    class AnimationSpy: UIView, LottieViewProtocol {
        var loopAnimation: Bool = false
        var playWasInvoked = 0
        func play() {
            playWasInvoked += 1
        }
        var pauseWasInvoked = 0
        func pause() {
            pauseWasInvoked += 1
        }
        var removeFromSuperviewWasInvoked = 0
        override func removeFromSuperview() {
            removeFromSuperviewWasInvoked += 1
        }
    }
}
