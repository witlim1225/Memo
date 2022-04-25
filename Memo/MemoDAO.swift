//
//  MemoDAO.swift
//  Memo
//
//  Created by TWLim on 2022/04/25.
//

import UIKit
import CoreData

class MemoDAO {
    // 관리 객체 컨텍스트
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    // 저장된 메모(전체)를 불러오는 메소드
    func fetch(keyword text: String? = nil) -> [MemoData] {
        var memoList = [MemoData]()
        
        // 요청 객체 생성
        let fetchRequest: NSFetchRequest<MemoMO> = MemoMO.fetchRequest()
        
        // 최신 글 순으로 정렬하도록 정렬 객체 생성
        let regdateDesc = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [regdateDesc]

        // 검색 키워드가 있을 경우 검색 조건 추가
        if let t = text, t.isEmpty == false {
            fetchRequest.predicate = NSPredicate(format: "contents CONTAINS[c] %@", t)
        }
        
        do {
            let resultSet = try self.context.fetch(fetchRequest)
            
            // 읽어온 결과 집합을 순회하면서 [MemoData] 타입으로 변환한다.
            for record in resultSet {
                // MemoData 객체를 생성한다.
                let data = MemoData()
                
                // MemoMO 프로퍼티 값을 MemoData의 프로퍼티로 복사한다.
                data.title = record.title
                data.contents = record.contents
                data.regdate = record.regdate! as Date
                data.objectID = record.objectID
                
                // 이미지가 있을때에만 복사
                if let image = record.image as Data? {
                    data.image = UIImage(data: image)
                }
                
                //  MemoData 객체를 memoList 배열에 추가한다.
                memoList.append(data)
            }
        } catch let e as NSError{
            NSLog("An error has occurred : %s", e.localizedDescription)
        }
        return memoList
    }
    
    func insert(_ data: MemoData) {
        // 관리 객체 인스턴스 생성
        let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO
        
        // MemoData로 부터 값을 복사한다
        object.title = data.title
        object.contents = data.contents
        object.regdate = data.regdate!
        
        if let image = data.image {
            object.image = image.pngData()!
        }
        
        // 영구 저장소에 변경사항을 반영한다.
        do {
            try self.context.save()
        } catch let e as NSError {
            NSLog("An error has occured : %s", e.localizedDescription)
        }
    }
    
    func delete(_ objectID: NSManagedObjectID) -> Bool {
        // 삭제할 객체를 찾아. 컨텍스트에서 삭제한다.
        let object = self.context.object(with: objectID)
        self.context.delete(object)
        
        do {
            //삭제된 내역을 영구저장소에 반영한다.
            try self.context.save()
            return true
        } catch let e as NSError {
            NSLog("An error has occured : %s", e.localizedDescription)
            return false
        }
    }
    
}
