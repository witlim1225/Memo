//
//  MemoData.swift
//  Memo
//
//  Created by TWLim on 2022/04/19.
//

import UIKit
import CoreData

class MemoData {
    var memoIdx : Int? // 데이터 식별값
    var title : String? // 메모 제목
    var contents : String? // 메모 내용
    var image : UIImage? // 이미지
    var regdate: Date?  // 작성일
    
    // 원본 MemoMO 객체를 참조하기 위한 속성
    var objectID: NSManagedObjectID?
}
