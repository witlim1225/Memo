//
//  Utils.swift
//  Memo
//
//  Created by TWLim on 2022/04/24.
//

import UIKit

extension UIViewController {
    var tutorialSB: UIStoryboard {
        return UIStoryboard(name: "Tutorial", bundle: Bundle.main)
    }
    
    func instanceTutorialVC(name: String) -> UIViewController? {
        return self.tutorialSB.instantiateViewController(withIdentifier: name)
    }
    
    func alert(_ message: String, completion: (() -> Void)? = nil) {
        // 메인 스레드에서 실행되도록
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "확인", style: .cancel) { _ in
                completion?() // completion 매개변수 값이 nil 이 아닐때에만 실행되도록
            }
            
            alert.addAction(okAction)
            self.present(alert, animated: false)
        }
    }
}
