//
//  TutorialMasterVC.swift
//  Memo
//
//  Created by TWLim on 2022/04/24.
//

import UIKit

class TutorialMasterVC: UIViewController {
    var pageVC: UIPageViewController!
    
    var contentTitles = ["STEP 1", "STEP 2", "STEP 3", "STEP 4"]
    var contentImages = ["Page0", "Page1", "Page2", "Page3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 페이지 뷰 컨트롤러 객체 생성하기
        self.pageVC = self.instanceTutorialVC(name: "PageVC") as? UIPageViewController
        self.pageVC.dataSource = self
        
        // 페이지 뷰 컨트롤러의 기본 페이지 지정
        let startContentVC = self.getContentVC(atIndex: 0)! // 최초 노출될 콘텐츠 뷰 컨트롤러
        self.pageVC.setViewControllers([startContentVC], direction: .forward, animated: true)
        
        // 페이지 뷰 컨트롤러의 출력 영역 지정
        self.pageVC.view.frame.origin = CGPoint(x: 0, y: 0)
        self.pageVC.view.frame.size.width = self.view.frame.width
        self.pageVC.view.frame.size.height = self.view.frame.height - 50
        
        // 페이지 뷰 컨트롤러를 마스터 뷰 컨트롤러의 자식 뷰 컨트롤러로 설정
        self.addChild(self.pageVC)
        self.view.addSubview(self.pageVC.view)
        self.pageVC.didMove(toParent: self)
    }
    
    func getContentVC(atIndex idx: Int) -> UIViewController? {
        // 인덱스가 데이터 배열 크기 범위를 벗어나면 nil 반환
        guard self.contentTitles.count >= idx && self.contentImages.count > 0 else {
            return nil
        }
        
        // "ContestsVC"라는 StoryboardID 를 가진 컨트롤러의 인스턴스를 생성하고 캐스팅한다.
        guard let contentsVC = self.instanceTutorialVC(name: "ContentsVC") as? TutorialContentsVC else {
            return nil
        }
        
        // 컨텐츠 뷰 컨트롤러의 내용을 구성
        contentsVC.titleText = self.contentTitles[idx]
        contentsVC.imageFile = self.contentImages[idx]
        contentsVC.pageIndex = idx
        
        return contentsVC
    }
    
    @IBAction func close(_ sender: Any) {
        let ud = UserDefaults.standard
        ud.set(true, forKey: UserInfoKey.tutorial)
        ud.synchronize()
        
        self.presentingViewController?.dismiss(animated: true)
    }
    
}


extension TutorialMasterVC: UIPageViewControllerDataSource {
    
    // 현재의 컨텐츠 뷰 컨트롤러보다 앞쪽에 올 컨텐츠 뷰 컨트롤러 객체
    // 즉, 현재의 상태에서 앞쪽으로 스와이프 했을 때 보여줄 콘텐츠 뷰 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // 현재의 페이지 인덱스
        guard var index = (viewController as! TutorialContentsVC).pageIndex else {
            return nil
        }
        
        // 현재의 인덱스가 맨 앞이라면 nil을 반환하고 종료
        guard index > 0 else { return nil }
        
        // 현재의 인덱스에서 하나를 빼서 이전페이지 세팅
        index -= 1
        return self.getContentVC(atIndex: index)
    }
    // 현재의 컨텐츠 뷰 컨트롤러보다 뒤쪽에 올 컨텐츠 뷰 컨트롤러 객체
    // 즉, 현재의 상태에서 뒤쪽으로 스와이프 했을 때 보여줄 콘텐츠 뷰 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // 현재의 페이지 인덱스
        guard var index = (viewController as! TutorialContentsVC).pageIndex else { return nil }
        
        index += 1 // 다음페이지 인덱스
        
        guard index < self.contentTitles.count else {
            return nil
        }
        
        return self.getContentVC(atIndex: index)
    }
    
    // 출력할 페이지의 개수를 알려준다.
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.contentTitles.count
    }
    
    //최초에 출력할 컨텐츠 뷰의 인덱스 번호를 알려준다.
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
