protocol SourceConfiguratorProtocol {
    func configure(_ vc: SourceVController)
    var newsRefresher: NewsRefresher? {get set}
}

import Foundation
class SourceConfigurator: SourceConfiguratorProtocol {
    var newsRefresher: NewsRefresher?
    func configure(_ vc: SourceVController) {
        let dataProvider = SourceDataProvider()
        let presenter = createPresenter(vc, dataProvider)
        let interactor = createInteractor(vc, presenter, dataProvider)
        vc.eventHandler = interactor
        vc.cellPresenter = presenter
    }
    private func createPresenter(_ vc: SourceVController,
                                 _ dataProvider: SourceDataProvider) -> SourcePresenter {
        return SourcePresenter(LoadingAnimator(vc.view), vc, dataProvider)
    }
    private func createInteractor(_ vc: SourceVController,
                                  _ presenter: SourcePresenter,
                                  _ dataProvider: SourceDataProvider) -> SourceInteractor {
        let sourceHolder = SourceHolder(UserDefaults.standard)
        let parameterHolder = SourceParameterHolder(UserDefaults.standard)
        let actionSheetPresenter = ActionSheetPresenter(vc)
        let interactorDependencies = SourceInteractorDependency(loader: SourceLoader(),
                                                                presenter: presenter,
                                                                sourceHolder: sourceHolder,
                                                                dataSource: dataProvider,
                                                                parameterHolder: parameterHolder,
                                                                actionSheetPresenter: actionSheetPresenter)
        let interactor = SourceInteractor(interactorDependencies)
        interactor.newsRefresher = newsRefresher
        actionSheetPresenter.selectionHandler = interactor
        return interactor
    }
}
