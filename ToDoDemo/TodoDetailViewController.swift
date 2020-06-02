//
//  TodoDetailViewController.swift
//  ToDoDemo
//
//  Created by Mars on 26/04/2017.
//  Copyright © 2017 Mars. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class TodoDetailViewController: UITableViewController {
    @IBOutlet weak var todoName: UITextField!
    @IBOutlet weak var isFinished: UISwitch!
    @IBOutlet weak var doneBarBtn: UIBarButtonItem!
    
    fileprivate var todoCollage: UIImage?
    @IBOutlet weak var memoCollageBtn: UIButton!
    
    var todoItem: TodoItem!
    
    var bag = DisposeBag()
    
    fileprivate let images = BehaviorRelay<[UIImage]>(value: [])
    
    /// 为了避免todoSubject意外从TodoDetailViewController外部接受onNext事件，我们把它定义成了fileprivate属性
    /// 使用了PublishSubject，而不是其他的Subject呢
    /// 这是因为其他的Subject会向事件的订阅者发送一个当前的默认值，
    /// 当我们在segue中订阅事件的时候就会订阅到这个默认值。如果此时我们在新建Todo，
    /// 那么就会同时创建出来两个Todo，一个是默认值，一个是用户自己添加的。这种行为，显然不是我们期望的
    fileprivate let todoSubject = PublishSubject<TodoItem>()
    // 对外，只提供了一个仅供订阅的Observable属性todo
    var todo: Observable<TodoItem> {
        return todoSubject.asObservable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 这段订阅的代码一定要放在viewDidLoad中初始化UI的代码前面，否则，当用户打开编辑Todo的时候，
        // 由于此时还未选择任何图片，订阅代码会重置memoCollageBtn的状态，我们就看不到之前合成的图片了
        images.asObservable().subscribe(onNext: {
            [weak self] images in
            guard let `self` = self else {
                return
            }
            guard !images.isEmpty else {
                self.resetMemoBtn()
                return
            }
            /// 1. Merge photos
            self.todoCollage = UIImage.collage(images: images,
                in: self.memoCollageBtn.frame.size)

            /// 2. Set the merged photo as the button background
            self.setMemoBtn(bkImage: self.todoCollage ?? UIImage())
        }).disposed(by: bag)
        
        if let todoItem = todoItem, todoItem.pictureMemoFilename != "" {
            let url = getDocumentsDir().appendingPathComponent(
                todoItem.pictureMemoFilename)

            if let data = try? Data(contentsOf: url) {
                self.memoCollageBtn.setBackgroundImage(
                    UIImage(data: data),
                    for: .normal)

                self.memoCollageBtn.setTitle("", for: .normal)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let todoItem = todoItem {
            self.todoName.text = todoItem.name
            self.isFinished.isOn = todoItem.isFinished
        }
        else {
            todoItem = TodoItem()
        }
        todoName.becomeFirstResponder()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// 对于一个Observable来说，除了所有订阅者都取消订阅会导致其被回收之外，
        /// Observable自然结束（onCompleted）或发生错误结束（onError）也会自动让所有订阅者取消订阅，
        /// 并导致Observable占用的资源被回收。
        todoSubject.onCompleted()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photoCollectionViewController =
            segue.destination as! PhotoCollectionViewController
        images.accept([])
        resetMemoBtn()
        /*
            我们希望这两次订阅实际上使用的是同一个Observable，但执行一下就会在控制台看到，打印了两次1 2 3 4 5，也就是说每次订阅，都会产生一个新的Observable对象，多次订阅的默认行为，并不是共享同一个序列上的事件
         */
        let selectedPhotos = photoCollectionViewController.selectedPhotos.share()
        /*
            过滤重复选择的图片
            介绍一个之前没提过的operator：scan，它有点儿类似集合中的reduce，
            可以把一个序列中所有的事件，通过一个自定义的closure，最终归并到一个事件，用序列图表示
            在上面这个图里，我们指定合并的初始值是0，合并动作是把历史和并结果和新的事件值相加。
            于是，在事件2的时候订阅，订阅到的结果就是3，3的时候订阅，订阅的结果就是6，以此类推
            可以看到，scan的初始值是一个空的数组，然后selectedPhotos中每发生一次图片选中事件，
            我们就检查图片是否已经添加过了，如果加过就删掉，否则就添加进来。处理完之后，我们把当前所有合并的[UIImage]返回
            在接下来的订阅里，我们订阅到的就是一个已经处理好的[UIImage]
         */
        _ = selectedPhotos.scan([]){
        (photos: [UIImage], newPhoto: UIImage) in
            var newPhotos = photos

            if let index = newPhotos.firstIndex(where: { UIImage.isEqual(lhs: newPhoto, rhs: $0) }) {
                newPhotos.remove(at: index)
            }
            else {
                newPhotos.append(newPhoto)
            }

            return newPhotos
        }.subscribe(onNext: { photos in
            self.images.accept(photos)
        }, onDisposed: {
            print("Finished choose photo memos.")
        })
        /// 忽略掉所有next事件
        _ = selectedPhotos.ignoreElements()
        .subscribe(onCompleted: { self.setMemoSectionHederText() })
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done() {
        
        todoItem.name = todoName.text!
        todoItem.isFinished = isFinished.isOn
        todoItem.pictureMemoFilename = savePictureMemos()

        todoSubject.onNext(todoItem)
        todoSubject.onCompleted()
        dismiss(animated: true, completion: nil)
    }
}

extension TodoDetailViewController {
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    func setMemoSectionHederText() {
        // Todo: Set section header to the number of
        // pictures selected.
        guard !images.value.isEmpty,
              let headerView = self.tableView.headerView(forSection: 2) else { return }

        headerView.textLabel?.text = "\(images.value.count) MEMOS"
    }
}

extension TodoDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        doneBarBtn.isEnabled = newText.length > 0
        
        return true
    }
}

extension TodoDetailViewController {
    fileprivate func getDocumentsDir() -> URL {
        return FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask)[0]
    }
    
    fileprivate func resetMemoBtn() {
        // Todo: Reset the add picture memo btn style
        memoCollageBtn.setBackgroundImage(nil, for: .normal)
        memoCollageBtn.setTitle("Tap here to add your picture memos", for: .normal)
    }
    
    fileprivate func setMemoBtn(bkImage: UIImage) {
        // Todo: Set the background and title of add picture memo btn
        memoCollageBtn.setBackgroundImage(bkImage, for: .normal)
        memoCollageBtn.setTitle("", for: .normal)
    }
    
    fileprivate func savePictureMemos() -> String {
        if let todoCollage = todoCollage,
            let data = todoCollage.pngData() {
            let path = getDocumentsDir()
            let filename = self.todoName.text! + UUID().uuidString + ".png"
            let memoImageUrl = path.appendingPathComponent(filename)

            try? data.write(to: memoImageUrl)

            return filename
        }

        return self.todoItem.pictureMemoFilename
    }
}
