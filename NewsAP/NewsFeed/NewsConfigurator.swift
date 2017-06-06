protocol NewsConfiguratorProtocol {
    func configure(_ vc: NewsVController)
}

import Foundation
class NewsConfigurator: NewsConfiguratorProtocol {
    func configure(_ vc: NewsVController) {
        let store = NewsStore()
        let interactor = NewsInteractor()
        let presenter = NewsPresenter(vc, LoadingAnimator(vc.view))
        presenter.store = store
        configureEventHandler(interactor, presenter, vc, store)
        vc.cellPresenter = presenter
    }
    private func configureEventHandler(_ interactor: NewsInteractor,
                                       _ presenter: NewsPresenter,
                                       _ vc: NewsVController,
                                       _ store: NewsStore) {
        interactor.store = store
        interactor.sourceHolder = SourceHolder(UserDefaults.standard)
        interactor.presenter = presenter
        interactor.loader = NewsLoader()
        interactor.router = router(vc)
        vc.eventHandler = interactor
    }
    private func router(_ vc: NewsVController) -> NewsRouter {
        let router = NewsRouter()
        router.viewController = vc
        return router
    }
}
