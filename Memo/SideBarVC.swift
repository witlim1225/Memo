//
//  SideBarVC.swift
//  Memo
//
//  Created by TWLim on 2022/04/21.
//

import UIKit

class SideBarVC: UITableViewController {
    
    // 목록 데이터 배열
    let titles = ["새글 작성하기", "친구 새글", "달력으로 보기", "공지사항", "통계", "계정 관리"]
    
    // 아이콘 데이터 배열
    let icons = [
        UIImage(named: "icon01.png"),
        UIImage(named: "icon02.png"),
        UIImage(named: "icon03.png"),
        UIImage(named: "icon04.png"),
        UIImage(named: "icon05.png"),
        UIImage(named: "icon06.png")
    ]
    
    // 이름, 이메일, 프로필 이미지 레이블
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let profileImage = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 테이블 뷰의 헤더 역할을 할 뷰를 정의한다.
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
        
        headerView.backgroundColor = .brown
        
        // 테이블 뷰의 헤더 뷰로 지정한다.
        self.tableView.tableHeaderView = headerView
        
        self.nameLabel.frame = CGRect(x: 70, y: 15, width: 100, height: 30) // 위치와 크기를 정의
        self.nameLabel.text = "태원씨"
        self.nameLabel.textColor = .white
        self.nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        self.nameLabel.backgroundColor = .clear
        
        headerView.addSubview(nameLabel)
        
        self.emailLabel.frame = CGRect(x: 70, y: 30, width: 100, height: 30)
        
        self.emailLabel.text = "witlim1225@gmail.com"
        self.emailLabel.textColor = .white
        self.emailLabel.font = UIFont.systemFont(ofSize: 11)
        self.emailLabel.backgroundColor = .clear
        
        headerView.addSubview(emailLabel)
        
        // 기본 이미지를 구현한다.
        let defaultProfile = UIImage(named: "account.jpg")
        self.profileImage.image = defaultProfile
        self.profileImage.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        
        // 이미지 둥글게
        self.profileImage.layer.cornerRadius = (self.profileImage.frame.width / 2) // 반원 형태로 라운딩
        self.profileImage.layer.borderWidth = 0 // 테두리 두꼐 0
        self.profileImage.layer.masksToBounds = true
        
        view.addSubview(self.profileImage)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //재사용 큐에서 테이블 셀을 꺼내온다. 없으면 새로 생성한다.
        let id = "menucell" // 테이블 셀 식별자
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ??
                        UITableViewCell(style: .default, reuseIdentifier: id)
        
        // 타이틀과 이미지를 대입한다.
        cell.textLabel?.text = self.titles[indexPath.row]
        cell.imageView?.image = self.icons[indexPath.row]
        
        // 폰트 설정
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { // 새글 작성
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "MemoForm")
            
            let target = self.revealViewController().frontViewController as! UINavigationController
            target.pushViewController(uv!, animated: true)
            self.revealViewController().revealToggle(self)
        } else if indexPath.row == 5 { // 계정 관리
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "_Profile")
            uv?.modalPresentationStyle = .fullScreen
            self.present(uv!, animated: true) {
                self.revealViewController().revealToggle(self) // 화면 전환시 사이드바 없애기. true->false
            }
            
        }
    }
    
}
