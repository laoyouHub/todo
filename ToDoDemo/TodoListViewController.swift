//
//  ViewController.swift
//  TodoDemo
//
//  Created by Mars on 24/04/2017.
//  Copyright © 2017 Mars. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class TodoListViewController: UIViewController {
    
    let bag = DisposeBag()
    var todoitems = BehaviorRelay<[TodoItem]>(value: [])
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearTodoBtn: UIButton!
    @IBOutlet weak var addTodo: UIBarButtonItem!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadTodoItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        /// 订阅事件
        todoitems.asObservable().subscribe(
            onNext: { [weak self] todos in
            self?.updateUI(todos: todos)
        }).disposed(by: bag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let naviController = segue.destination as! UINavigationController
        let currController = naviController.topViewController as! TodoDetailViewController
        
        if segue.identifier == "AddTodo" {
            currController.title = "Add Todo"
            _ = currController.todo.subscribe(
                onNext: {
                    [weak self] newTodo in
                    var todos = self?.todoitems.value
                    todos?.append(newTodo)
                    self?.todoitems.accept(todos ?? [])
                },
                onDisposed: {
                    print("Finish adding a new todo.")
                }
            )
        }
        
        else if segue.identifier == "EditTodo" {
            currController.title = "Edit todo"
            if let indexPath = tableView.indexPath(
                for: sender as! UITableViewCell) {

                // 3. Pass the selected todo
                currController.todoItem = todoitems.value[indexPath.row]
                
                _ = currController.todo.subscribe(
                    onNext: { [weak self] todo in
                        var todos = self?.todoitems.value ?? []
                        todos[indexPath.row] = todo
                        self?.todoitems.accept(todos)
                    },
                    onDisposed: {
                        print("Finish editing a todo.")
                    }
                )
            }
        }
    }
    
    func updateUI(todos:[TodoItem]) {
        // 清空列表后应该禁用绿色按钮
        clearTodoBtn.isEnabled = !todos.isEmpty
        // 限制最多只能存在4个未完成的todo，否则就禁用添加按钮
        addTodo.isEnabled = todos.filter { !$0.isFinished }.count < 4
        // 顶部的标题应该显示当前todo的个数
        title = todos.isEmpty ? "Todo" : "\(todos.count) ToDos"
        self.tableView.reloadData()
    }
    
    @IBAction func addTodoItem(_ sender: Any) {
        var newTodos = todoitems.value
        let todoItem = TodoItem(name: "Todo Demo", isFinished: false, pictureMemoFilename: "")
        newTodos.append(todoItem)
        todoitems.accept(newTodos)
    }
    
    @IBAction func saveTodoList(_ sender: Any) {
        _ = saveTodoItems().subscribe(
            onError: { [weak self] error in
                self?.flash(title: "Error",
                            message: error.localizedDescription)
            },
            onCompleted: { [weak self] in
                self?.flash(title: "Success",
                            message: "All Todos are saved on your phone.")
            },
            onDisposed: { print("SaveOb disposed") }
        )
        
        /*
            如果一个Controller会常驻在内存里不会释放，我们就不要把这种单次事件的订阅对象放到它的DisposeBag里。
            实际上，对于这种单次的事件序列，我们可以在订阅之后不做任何事情。因为订阅的Observable对象，一定会结束，
            要不就是正常的onCompleted，要不就是异常的onError，无论是哪种情况，在订阅到之后，Observable都会结束，
            订阅也随之会自动取消，分配给Obserable的资源也就会被回收了
         */
    }
    
    @IBAction func clearTodoList(_ sender: Any) {
        todoitems.accept([]) 
    }
    
    @IBAction func syncToCloud(_ sender: Any) {
        // Add sync code here
        _ = syncTodoToCloud().subscribe(
            onNext: {
                self.flash(title: "Success",
                    message: "All todos are synced to: \($0)")
            },
            onError: {
                self.flash(title: "Failed",
                    message: "Sync failed due to: \($0.localizedDescription)")
            },
            onDisposed: {
                print("SyncOb disposed")
            }
        )
        
    }
}
