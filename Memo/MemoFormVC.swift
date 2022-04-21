//
//  MemoFormVC.swift
//  Memo
//
//  Created by TWLim on 2022/04/19.
//

import UIKit

class MemoFormVC: UIViewController {

    var subject: String!
    
    @IBOutlet weak var contents: UITextView!
    @IBOutlet weak var preview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.contents.delegate = self
        
        // 배경 이미지 설정
        let bgImage = UIImage(named: "memo-background.png")!
        self.view.backgroundColor = UIColor(patternImage: bgImage)
        
        // 텍스트뷰의 기본 속성
        self.contents.layer.borderWidth = 0
        self.contents.layer.borderColor = UIColor.clear.cgColor
        self.contents.backgroundColor = UIColor.clear
        
        // 줄 간격
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 9
        self.contents.attributedText = NSAttributedString(string: " ", attributes: [.paragraphStyle: style])
        self.contents.text = ""
    }

    @IBAction func save(_ sender: Any) {
        // 경고창에 사용될 컨텐츠 뷰 컨트롤러 구성
        let alertVC = UIViewController()
        let iconImage = UIImage(named: "warning-icon-60")
        alertVC.view = UIImageView(image: iconImage)
        alertVC.preferredContentSize = iconImage?.size ?? CGSize.zero
        
        
        guard self.contents.text?.isEmpty == false else {
            let alert = UIAlertController(title: nil, message: "내용을 입력해주세요", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(cancelAction)
            
            alert.setValue(alertVC, forKey: "contentViewController")
            
            self.present(alert, animated: true)
            return
        }
        
        // MemoData 객체를 생성하고, 데이터를 담는다.
        let data = MemoData()
        
        data.title = self.subject
        data.contents = self.contents.text
        data.image = self.preview.image
        data.regdate = Date()
        
        //앱 델리게이트 객체를 읽어온 다음, memoList 배열에 객체를 추가한다.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memolist.append(data)
        
        // 작성폼 화면을 종료하고, 이전 화면으로 되돌아간다.
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func pick(_ sender: Any) {
        //이미지 피커 컨트롤러 인스턴스 생성
        let picker = UIImagePickerController()
        
        // 이미지 피커 컨트롤러 인스턴스의 델리게이트 속성을 현재의 VC인스턴스로 설정한다
        picker.delegate = self
        picker.allowsEditing = true // 이미지 편집 허용
        
        self.present(picker, animated: true) // 화면 표시
    }
    
    // 화면 터치시 네비게이션 바 사라지도록
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bar = self.navigationController?.navigationBar
        let ts = TimeInterval(0.3)
        UIView.animate(withDuration: ts) {
            bar?.alpha = (bar?.alpha == 0 ? 1 : 0)
        }
    }
}

extension MemoFormVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //선택한 이미지를 미리보기에 출력한다
        self.preview.image = info[.editedImage] as? UIImage
        
        //이미지 피커 컨트롤러를 닫는다.
        picker.dismiss(animated: false)
    }
}

extension MemoFormVC: UINavigationControllerDelegate {
    
}

extension MemoFormVC: UITextViewDelegate {
    //텍스트 뷰에 입력시 호출되는 메소드
    func textViewDidChange(_ textView: UITextView) {
        // 내용의 최대 15자리까지 읽어 subject 변수에 저장
        let contents = textView.text as NSString
        let length = ( contents.length > 15) ? 15 : contents.length
        
        self.subject = contents.substring(with: NSRange(location: 0, length: length))
        
        //타이틀에 표현
        self.navigationItem.title = self.subject
    }
}
