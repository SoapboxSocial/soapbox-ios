import Foundation

protocol HomePresenterOutput {}

class HomePresenter: HomeInteractorOutput {
    var output: HomePresenterOutput
}
