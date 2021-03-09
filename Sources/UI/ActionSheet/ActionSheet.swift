import UIKit
import DrawerView

class ActionSheet {
    
    private var view: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var actions = [ActionSheetActionView]()
    
    func add(action: ActionSheetActionView) {
        view.addSubview(action)
        
        NSLayoutConstraint.activate([
            action.leftAnchor.constraint(equalTo: view.leftAnchor),
            action.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        actions.append(action)
                
        
//        stack.addArrangedSubview(action)
    }
    
    func present(_ context: UIView) {
        let drawer = DrawerView(withView: view)
        drawer.translatesAutoresizingMaskIntoConstraints = false
        drawer.attachTo(view: context)
        drawer.cornerRadius = 30.0
        drawer.backgroundEffect = nil
        drawer.snapPositions = [.closed, .open]
        drawer.backgroundColor = .foreground
        drawer.openHeightBehavior = .fitting
        drawer.insetAdjustmentBehavior = .superviewSafeArea
        drawer.contentVisibilityBehavior = .allowPartial
        
        view.autoPinEdgesToSuperview()
        
        context.addSubview(drawer)

        drawer.setPosition(.closed, animated: false)
        drawer.setPosition(.open, animated: true)
    }
}
