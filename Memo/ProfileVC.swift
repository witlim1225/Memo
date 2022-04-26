//
//  ProfileVC.swift
//  Memo
//
//  Created by TWLim on 2022/04/21.
//

import UIKit
import Alamofire
import LocalAuthentication

class ProfileVC: UIViewController {
    let profileImage = UIImageView() // 프로필 사진 이미지
    let tv = UITableView() // 프로필 목록
    
    // API 호출 상태값을 관리할 변수
    var isCalling = false
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    // 개인 정보 관리 매니저
    let userInfo = UserInfoManager()
    
    override func viewWillAppear(_ animated: Bool) {
        // 토큰 인증 여부 체크
        self.tokenValidate()
    }
    
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
        
        // 인디케이터를 최상위 레이어로
        self.view.bringSubviewToFront(self.indicatorView)
        
        // 키체인 저장 여부 확인을 위한 임시 코드
        let token = TokenUtils()
        if let accessToken = token.load("TWLim.Memo", account: "accessToken") {
            print("accessToken = \(accessToken)")
        } else {
            print("accessToken is nil")
        }
        
        if let refreshToken = token.load("TWLim.Memo", account: "refreshToken") {
            print("refreshToken = \(refreshToken)")
        } else {
            print("refreshToken is nil")
        }
    }
    
    @objc func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func doLogin(_ sender: Any) {
        if self.isCalling == true {
            self.alert("응답을 기다리는 중입니다. \n잠시만 기다려주세요.")
            return
        } else {
            self.isCalling = true
        }
        // 인디케이터 실행
        self.indicatorView.startAnimating()
        
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
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // 취소버튼을 눌렀을 시에도 false를 만들어줘야 앱 재시작해서 로그인하는 불상사가 없음.
            self.isCalling = false
        })
        loginAlert.addAction(UIAlertAction(title: "Login", style: .default) { _ in
            let account = loginAlert.textFields?[0].text ?? "" // 첫번째 필드 = 계정
            let passwd = loginAlert.textFields?[1].text ?? "" // 두번째 필드 = 비밀번호
            
            //비동기식으로 변경
            self.userInfo.login(account: account, passwd: passwd, success: {
                self.indicatorView.stopAnimating() // 인디케이터 종료
                self.isCalling = false
            
                //UI 갱신
                self.tv.reloadData() // 텡치블 뷰를 갱신한다.
                self.profileImage.image = self.userInfo.profile // 이미지 프로필을 갱신한다.
                self.drawBtn()
                
                // 서버와 데이터 동기화
                let sync = DataSync()
                DispatchQueue.global(qos: .background).async {
                    sync.downloadBackupData()// 서버에 저장된 데이터가 있으면 내려받는다.
                }
                
                DispatchQueue.global(qos: .background).async {
                    sync.uploadData()// 서버에 저장해야할 데이터가 있으면 업로드한다.
                }
            }, fail: { msg in
                self.indicatorView.stopAnimating() // 인디케이터 종료
                self.isCalling = false
                
                self.alert(msg)
            })
        })
        
        self.present(loginAlert, animated: true)
    }
    
    @objc func doLogout(_ sender: Any) {
        let msg = "로그아웃 하시겠습니까?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            //인디케이터 실행
            self.indicatorView.startAnimating()
            
            // 로그아웃 시 처리할 내용.
            self.userInfo.logout() {
                // logout API 호출과 logout() 실행이 모두 끝나면 인디케이터도 중지
                self.indicatorView.stopAnimating()
                
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
    
    @IBAction func backProfileVC(_ segue: UIStoryboardSegue) {
        // 단지 프로필 화면으로 되돌아오기 위한 표식 역할만 할 뿐, 아무내용 x
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
        // 인디케이터 실행
        self.indicatorView.startAnimating()
        
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.userInfo.newProfile(img, success: {
                // 인디케이터 종료
                self.indicatorView.stopAnimating()
                self.profileImage.image = img
            }, fail: { msg in
                // 인디케이터 종료
                self.indicatorView.stopAnimating()
                self.alert(msg)
            })
        }
        
        picker.dismiss(animated: true)
    }
}

extension ProfileVC {
    // 토큰 인증 메소드
    func tokenValidate() {
        // 응답 캐시를 사용하지 앙ㄴㅎ도록
        URLCache.shared.removeAllCachedResponses()
        
        // 키 체인에 액세스 토큰이 없을 경우 유효성 검증을 진행하지 않음
        let token = TokenUtils()
        guard let header = token.getAuthorizationHeader() else { return }
        
        // 로딩 인디케이터 시작
        indicatorView.startAnimating()
        
        // API 호출
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/tokenValidate"
        let validate = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        
        validate.responseJSON { response in
            self.indicatorView.stopAnimating()
            
            let responseBody = try! response.result.get()
            print(responseBody)
            guard let jsonObject = responseBody as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }
            
            // 응답 결과 처리
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode != 0 { // 응답결과가 실패일 때, 즉 토큰 만료 상태 일때
                // 로컬인증 실행
                self.touchId()
                
                
            }
        }
    }
    // 터치 아이디 인증 메소드
    func touchId() {
        // LAContext 인스턴스 생성
        let context = LAContext()
        
        // 로컬 인증에 사용할 변수 정의
        var error: NSError?
        let msg = "인증이 필요합니다."
        let deviceAuth = LAPolicy.deviceOwnerAuthenticationWithBiometrics // 인증 정책
        
        // 로컬 인증이 사용가능한지 여부 확인
        if context.canEvaluatePolicy(deviceAuth, error: &error) {
            // 터치 아이디 인증 창 실행
            context.evaluatePolicy(deviceAuth, localizedReason: msg) { success, e in
                if success {
                    // 인증 성공 -> 토큰 갱신 로직 실행
                    self.refresh()
                } else {
                    // 인증 실패 원인에 대한 대응 로직
                    print((e?.localizedDescription)!)
                    
                    switch (e!._code) {
                    case LAError.systemCancel.rawValue:
                        self.alert("시스템에 의해 인증이 취소되었습니다.")
                    case LAError.userCancel.rawValue:
                        self.alert("사용자에 의해 인증이 취소되었습니다.")
                        self.commonLogout(true)
                    case LAError.userFallback.rawValue:
                        OperationQueue.main.addOperation {
                            self.commonLogout(true)
                        }
                    default:
                        OperationQueue.main.addOperation {
                            self.commonLogout(true)
                        }
                    }
                }
            }
        } else {
            // 인증창이 실행되지 못한 이유 -> 기기가 지원 않거나 터치아이디가 등록이 되어 있지 않으므로 commonLogout으로 대안을 준다.
            // 인증창 실행 불가 원인에 대한 대응 로직
            print(error!.localizedDescription)
            switch (error!.code) {
            case LAError.biometryNotEnrolled.rawValue:
                print("터치 아이디가 등록되어 있지 않습니다.")
            case LAError.passcodeNotSet.rawValue:
                print("패스 코드가 설정되어 있지 않습니다.")
            default://LAERROR.touchIDNotAvailable 포함.
                print("터치 아이디를 사용할 수 없습니다.")
            }
            OperationQueue.main.addOperation {
                self.commonLogout()
            }
        }
    }
    // 토큰 갱신 메소드
    func refresh() {
        //로딩 시작
        self.indicatorView.startAnimating()
        
        // 인증 헤더
        let token = TokenUtils()
        let header = token.getAuthorizationHeader()
        
        // 리프레시 토큰 전달 준비
        let refreshToken = token.load("TWLim.Memo", account: "refreshToken")
        let param : Parameters = [ "refresh_token" : refreshToken! ]
        
        // 호출 및 응답
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/refresh"
        let refresh = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
        refresh.responseJSON { response in
            // 로딩 중지
            self.indicatorView.stopAnimating()
            
            guard let jsonObject = try! response.result.get() as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }
            
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {
                // 성공 : 액세스 토큰이 갱신
                // 키 체인에 저장된 액세스 토큰 교체
                let accessToken = jsonObject["access_token"] as! String
                token.save("TWLim.Memo", account:"accessToken", value: accessToken)
            } else {
                // 실패 : 액세스 토큰 만료
                // 리프레시 토큰을 이용하여 갱신API호출 시 에러는 폐기 된것
                self.alert("인증이 만료되었으므로 다시 로그인해야 합니다.") {
                    OperationQueue.main.addOperation {
                        self.commonLogout(true)
                    }
                }
                //로그아웃
            }
        }
    }
    
    func commonLogout(_ isLogin: Bool = false) {
        // 저장된 기존 개인 정보 & 키 체인 데이터를 삭제하여 로그아웃 상태로 전환
        let userInfo = UserInfoManager()
        userInfo.deviceLogout()
        
        // 현쟁즤 화면이 프로필 화면이라면 바로 UI를 갱신한다.
        self.tv.reloadData()
        self.profileImage.image = userInfo.profile
        self.drawBtn()
        
        // 기본 로그인 창 실행여부
        if isLogin {
            self.doLogin(self)
        }
    }
}
