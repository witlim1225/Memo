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
        let image = UIImage(named: "account.jpg")
        
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
    }
    
    @objc func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
}

extension ProfileVC: UITableViewDelegate {
    
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
            cell.detailTextLabel?.text = "임태원"
        case 1 :
            cell.textLabel?.text = "계정"
            cell.detailTextLabel?.text = "witlim1225@gmail.com"
        default :
            ()
        }
        
        return cell
    }
    
    
}
