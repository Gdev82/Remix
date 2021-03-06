//  Copyright © 2017 cutting.io. All rights reserved.

import Wireframe
import Entity
import GroupSelectionFeature

class SplitDiscoveryCoordinator {

    struct Dependencies {

        var splitWireframe: SplitWireframe
        let navigationWireframeFactory: NavigationWireframeFactory

        let interactor: DiscoveryInteractor
        let detailFormatter: AdvertDetailFormatter
        let detailViewFactory: ItemDetailViewFactory

        let advertListFeature: AdvertListFeature
        let groupSelectionFeature: GroupSelectionFeature
        let insertionFeature: InsertionFeature
    }

    private var deps: Dependencies
    private var advertListCoordinator: AdvertListCoordinator?
    private var groupSelectionCoordinator: GroupSelectionCoordinator?
    private var insertionCoordinator: InsertionCoordinator?

    init(dependencies: Dependencies) {
        deps = dependencies
    }

    func start() {
        startAdvertList()
    }
}

extension SplitDiscoveryCoordinator: AdvertListCoordinatorDelegate {

    private func startAdvertList() {
        let navigationWireframe = deps.navigationWireframeFactory.make()
        let coordinator = deps.advertListFeature.makeCoordinator(navigationWireframe: navigationWireframe)
        coordinator.delegate = self
        advertListCoordinator = coordinator
        deps.splitWireframe.master = navigationWireframe
        coordinator.start()
    }

    func didSelect(advertID: AdvertID) {
        showDetailView(for: advertID)
    }

    private func showDetailView(for advertID: AdvertID) {
        deps.interactor.fetchDetail(for: advertID) { result in
            switch result {
            case let .success(advert):
                self.showDetailView(for: advert)
            case .error:
                self.presentError()
            }
        }
    }

    private func showDetailView(for advert: Advert) {
        let detailView = deps.detailViewFactory.make()
        detailView.viewData = deps.detailFormatter.prepare(advert: advert)
        deps.splitWireframe.detail = detailView
    }

    private func presentError() {
        print("could not load advert details")  // See AutoGroupInsertionCoordinator example
    }

    func didSelectNewAdvertAction() {
        startAdvertInsertion()
    }

    func didSelectFiltersAction() {
        startGroupSelection()
    }
}

extension SplitDiscoveryCoordinator: GroupSelectionCoordinatorDelegate {

    private func startGroupSelection() {
        let navigationWireframe = deps.navigationWireframeFactory.make()
        let coordinator = deps.groupSelectionFeature.makeCoordinator(navigationWireframe: navigationWireframe)
        coordinator.delegate = self
        groupSelectionCoordinator = coordinator
        coordinator.start()
        deps.splitWireframe.present(view: navigationWireframe)
    }

    func didSelect(groupID: GroupID?) {
        advertListCoordinator?.updateAdverts(for: groupID)
        finishGroupSelection()
    }

    func didCancelSelection() {
        finishGroupSelection()
    }

    private func finishGroupSelection() {
        deps.splitWireframe.dismiss()
        groupSelectionCoordinator = nil
    }
}

extension SplitDiscoveryCoordinator: InsertionCoordinatorDelegate {

    private func startAdvertInsertion() {
        let navigationWireframe = deps.navigationWireframeFactory.make()
        let coordinator = deps.insertionFeature.makeCoordinator(navigationWireframe: navigationWireframe)
        coordinator.delegate = self
        insertionCoordinator = coordinator
        coordinator.start()
        deps.splitWireframe.present(view: navigationWireframe)
        navigationWireframe.setLeftButton(title: "Cancel", target: self, selector: #selector(finishAdvertInsertion))
    }

    func didPublishAdvert(advertID: AdvertID) {
        advertListCoordinator?.reloadAdverts()
        finishAdvertInsertion()
    }

    func didCancelInsertion() {
        finishAdvertInsertion()
    }

    @objc private func finishAdvertInsertion() {
        deps.splitWireframe.dismiss()
        insertionCoordinator = nil
    }
}
