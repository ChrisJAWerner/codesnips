import UIKit

extension UIView {
    func apply(constraints: [NSLayoutConstraint] ){
        guard superview != nil else {
            assert(false, "\(self) must have a superview for constraints to be added")
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }
    
    func pinEdgesToSuperView(){
        guard let view = superview else {
            assert(false, "\(self) must have a superview for constraints to be added")
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
