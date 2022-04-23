//
//  ProfileVC.swift
//  Memo
//
//  Created by TWLim on 2022/04/21.
//

import UIKit

class ProfileVC: UIViewController {
    let profileImage = UIImageView() // 프로필 사진 이미지
    let tv = UITableView() // 프로필 목록
    
    // 개인 정보 관리 매니저
    let userInfo = UserInfoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "프로필"
        
        // 뒤로 가기 버튼 처리
        let backBtn = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(close(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // 배경 이미지 설정
        let bg = UIImage(named: "profile-bg")
        let bgImg = UIImageView(image: bg)
        
        bgImg.frame.size = CGSize(width: bgImg.frame.size.width, height: bgImg.frame.size.height)
        bgImg.center = CGPoint(x: view.frame.width / 2, y: 40)
        
        bgImg.layer.cornerRadius = bgImg.frame.size.width / 2
        bgImg.layer.borderWidth = 0
        bgImg.layer.masksToBounds = true
        
        view.addSubview(bgImg)
        
        view.bringSubviewToFront(tv)
        view.bringSubviewToFront(profileImage)
        
        // 프로필 사진에 들어갈 기본 이미지
//        let image = UIImage(named: "account.jpg")
        let image = self.userInfo.profile
        
        // 프로필 이미지 처리
        profileImage.image = image
        profileImage.frame.size = CGSize(width: 100, height: 100)
        profileImage.center = CGPoint(x: view.frame.width / 2, y: 270)
        
        // 프로필 이미지 둥글게 처리
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.layer.borderWidth = 0
        profileImage.layer.masksToBounds = true
        
        // 루트 뷰에 추가
        view.addSubview(profileImage)
        
        // 테이블 뷰
        tv.frame = CGRect(
            x: 0,
            y: profileImage.frame.origin.y + profileImage.frame.size.height + 20,
            width: view.frame.width,
            height: 100)
        tv.dataSource = self
        tv.delegate = self
        
        view.addSubview(tv)
        
        navigationController?.navigationBar.isHidden = true
        
        self.drawBtn()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(profile(_:)))
        self.profileImage.addGestureRecognizer(tap)
        self.profileImage.isUserInteractionEnabled = true
    }
    
    @objc func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func doLogin(_ sender: Any) {
        let loginAlert = UIAlertController(title: "LOGIN", message: nil, preferredStyle: .alert)
        
        // 알림창에 들어갈 입력폼 추가
        loginAlert.addTextField() { tf in
            tf.placeholder = "Your Account"
        }
        loginAlert.addTextField() { tf in
            tf.placeholder = "Password"
            tf.isSecureTextEntry = true
        }
        
        // 알림창 버튼 추가
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        loginAlert.addAction(UIAlertAction(title: "Login", style: .default) { _ in
            let account = loginAlert.textFields?[0].text ?? "" // 첫번째 필드 = 계정
            let passwd = loginAlert.textFields?[1].text ?? "" // 두번째 필드 = 비밀번호
            
            if self.userInfo.login(account: account, passwd: passwd) {
                //TODO: 로그인 성공시 처리할 내용
                self.tv.reloadData() // 테이블 뷰를 갱신한다.
                self.profileImage.image = self.userInfo.profile // 이미지 프로필을 갱신한다.
                self.drawBtn() // 로그인 상태에 따라 적절히 버튼 출력
                
            } else {
                let msg = "로그인에 실패하였습니다."
                let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
                
            }
            
        })
        
        self.present(loginAlert, animated: true)
    }
    
    @objc func doLogout(_ sender: Any) {
        let msg = "로그아웃 하시겠습니까?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            if self.userInfo.logout() {
                //TODO: 로그아웃 시 처리할 내용.
                self.tv.reloadData()
                self.profileImage.image = self.userInfo.profile
                self.drawBtn()
            }
        })
        
        self.present(alert, animated: true)
    }
    
    //로그인 로그아웃 버튼
    func drawBtn() {
        let v = UIView()
        v.frame.size.width = self.view.frame.width
        v.frame.size.height = 40
        v.frame.origin.x = 0
        v.frame.origin.y = self.tv.frame.origin.y + self.tv.frame.height
        v.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        
        self.view.addSubview(v)
        
        // 버튼을 정의한다.
        let btn = UIButton(type: .system)
        btn.frame.size.width = 100
        btn.frame.size.height = 30
        btn.center.x = v.frame.size.width / 2
        btn.center.y = v.frame.size.height / 2
        
        // 로그인 상태일 때는 로그아웃 버튼을, 로그아웃 상태일떄는 로그인 버튼을 만들어 준다.
        if self.userInfo.isLogin {
            btn.setTitle("로그아웃", for: .normal)
            btn.addTarget(self, action: #selector(doLogout(_:)), for: .touchUpInside)
        } else {
            btn.setTitle("로그인", for: .normal)
            btn.addTarget(self, action: #selector(doLogin(_:)), for: .touchUpInside)
        }
        
        v.addSubview(btn)
    }
    
    
}

extension ProfileVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.userInfo.isLogin == false {
            //로그인 되어 있지 않다면 로그인 창을 띄워준다.
            self.doLogin(self.tv)
        }
    }
    
}

extension ProfileVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.row {
        case 0 :
            cell.textLabel?.text = "이름"
//            cell.detailTextLabel?.text = "임태원"
            cell.detailTextLabel?.text = self.userInfo.name ?? "Login Please"
        case 1 :
            cell.textLabel?.text = "계정"
//            cell.detailTextLabel?.text = "witlim1225@gmail.com"
            cell.detailTextLabel?.text = self.userInfo.account ?? "Login Please"
        default :
            ()
        }
        
        return cell
    }
}

//이미지 피커를 사용하기 위해서는 아래의 델리게이트 프로토콜 2개가 필요함
extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imgPicker(_ source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true)
    }
    
    @objc func profile(_ sender: UIButton) {
        //로그인이 되어있지 않은 경우 프로필 이미지 등록을 막고 대신 로그인 창을 띄워준다.
        guard self.userInfo.account != nil else {
            self.doLogin(self)
            return
        }
        
        let alert = UIAlertController(title: nil, message: "사진을 가져올 곳을 선택해 주세요", preferredStyle: .actionSheet)
        
        //카메라를 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "카메라", style: .default) { _ in
                self.imgPicker(.camera)
            })
        }
        // 저장된 앨범을 사용할 수 있으먼
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            alert.addAction(UIAlertAction(title: "저장된 앨범", style: .default) { _ in
                self.imgPicker(.savedPhotosAlbum)
            })
        }
        // 포토 라이브러리를 사용할 수 있으먼
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "포토 라이브러리", style: .default) { _ in
                self.imgPicker(.photoLibrary)
            })
        }
        //취소 버튼 추가
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        //액션 시트 창 실행
        self.present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.userInfo.profile = img
            self.profileImage.image = img
        }
        
        picker.dismiss(animated: true)
    }
}
