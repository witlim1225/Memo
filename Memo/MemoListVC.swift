//
//  MemoListVC.swift
//  Memo
//
//  Created by TWLim on 2022/04/19.
//

import UIKit

class MemoListVC: UITableViewController {
    
    // 앱 델리게이트 객체의 참조 정보
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // SWRevealViewController 라이브러리의 revealViewController 객체를 읽어온다.
        if let revealVC = self.revealViewController() {
            // 바 버튼 아이템 객체를 정의한다.
            let btn = UIBarButtonItem()
            btn.image = UIImage(named: "sidemenu.png")
            btn.target = revealVC // 버튼 클릭시 호출할 메소드가 정의된 객체를 지정
            btn.action = #selector(revealVC.revealToggle(_:)) // 버튼 클릭 시 revealToggle 호출
            
            // 정의된 바 버튼을 네비게이션 바으 ㅣ왼쪽 아이템으로 등록한다.
            self.navigationItem.leftBarButtonItem = btn
            
            //제스쳐 객체를 뷰에 추가한다.
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.appDelegate.memolist.count
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // memolist 배열 데이터에서 주어진 행에 맞는 데이터를 꺼낸다.
        let row = self.appDelegate.memolist[indexPath.row]
        
        // 이미지 속성이 비어있을 경우 "memoCell", 아니면 "memoCellWithImage"
        let cellId = row.image == nil ? "memoCell" : "memoCellWithImage"
        
        // 재사용 큐로부터 프토로타입 셀의 인스턴스를 전달받는다.
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? MemoCell {
            
            //cell 구성
            cell.subject.text = row.title
            cell.contents.text = row.contents
            cell.img?.image = row.image
            
            // Date 타입의 날짜를 yyyy-MM-dd HH:mm:ss 포맵으로 변환
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            cell.regdate?.text = formatter.string(from: row.regdate!)
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //memolist 배열에서 선택된 행에 맞는 데이터를 꺼낸다.
        let row = self.appDelegate.memolist[indexPath.row]
        
        // 상세화면의 인스턴스를 생성한다.
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MemoRead") as? MemoReadVC else { return }
        
        //값을 전달한 다음, 상세화면으로 이동.
        vc.param = row
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
