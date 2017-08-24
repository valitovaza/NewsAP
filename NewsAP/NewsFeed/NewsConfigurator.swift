protocol NewsConfiguratorProtocol {
    func configure(_ vc: NewsVController)
}

import Foundation
class NewsConfigurator: NewsConfiguratorProtocol {
    func configure(_ vc: NewsVController) {
        let store = NewsStore()
        let faveStore = FavoriteNewsCache(UserDefaults.standard)
        let interactor = NewsInteractor()
        let presenter = NewsPresenter(vc, LoadingAnimator(vc.loadAnimationView))
        presenter.store = store
        presenter.faveStore = faveStore
        configureEventHandler(interactor,
                              presenter,
                              vc,
                              store,
                              faveStore)
        vc.cellPresenter = presenter
    }
    private func configureEventHandler(_ interactor: NewsInteractor,
                                       _ presenter: NewsPresenter,
                                       _ vc: NewsVController,
                                       _ store: NewsStore,
                                       _ faveStore: FavoriteNewsCache) {
        interactor.store = store
        interactor.sourceHolder = SourceHolder(UserDefaults.standard)
        interactor.settingsHolder = SettingsHolder(UserDefaults.standard)
        interactor.newsSaver = faveStore
        interactor.presenter = presenter
        interactor.notificationController = LocalNotificationController()
        interactor.loader = NewsLoader()
        interactor.router = router(vc, interactor)
        vc.eventHandler = interactor
    }
    private func router(_ vc: NewsVController,
                        _ interactor: NewsInteractor) -> NewsRouter {
        let router = NewsRouter()
        router.viewController = vc
        router.newsSaver = interactor
        return router
    }
}
