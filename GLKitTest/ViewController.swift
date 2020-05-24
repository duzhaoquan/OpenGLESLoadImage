//
//  ViewController.swift
//  GLKitTest
//
//  Created by dzq_mac on 2020/5/14.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var tableView:UITableView?
    var titles = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
//        setupButton()
        setupTableView()
        
    }
    
    func setupButton() {
        
        let buttonX = UIButton(frame: CGRect.zero)
        buttonX.tag = 101
        buttonX.setTitle("rotateX", for: UIControl.State.normal)
        buttonX.addTarget(self, action: #selector(buttonClick(btn:)), for: UIControl.Event.touchUpInside)
        buttonX.backgroundColor = UIColor.gray
        let buttonY = UIButton(frame: CGRect.zero)
        buttonY.tag = 102
        buttonY.setTitle("rotateY", for: UIControl.State.normal)
        buttonY.addTarget(self, action: #selector(buttonClick(btn:)), for: UIControl.Event.touchUpInside)
        buttonY.backgroundColor = UIColor.gray
        
        let buttonZ = UIButton(frame: CGRect.zero)
        buttonZ.tag = 103
        buttonZ.setTitle("rotateZ", for: UIControl.State.normal)
        buttonZ.addTarget(self, action: #selector(buttonClick(btn:)), for: UIControl.Event.touchUpInside)
        buttonZ.backgroundColor = UIColor.gray
        
        view.addSubview(buttonX)
        view.addSubview(buttonY)
        view.addSubview(buttonZ)
//        self.view.translatesAutoresizingMaskIntoConstraints = false
        buttonX.translatesAutoresizingMaskIntoConstraints = false
        buttonY.translatesAutoresizingMaskIntoConstraints = false
        buttonZ.translatesAutoresizingMaskIntoConstraints = false
        //宽相等
        NSLayoutConstraint.activate(
            [
                buttonX.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 20),
                buttonX.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
                buttonX.heightAnchor.constraint(equalToConstant: 80),

                buttonY.leftAnchor.constraint(equalTo: buttonX.rightAnchor,constant: 10),
                buttonY.topAnchor.constraint(equalTo: buttonX.topAnchor),
                buttonY.bottomAnchor.constraint(equalTo: buttonX.bottomAnchor),

                buttonZ.leftAnchor.constraint(equalTo: buttonY.rightAnchor,constant: 10),
                buttonZ.topAnchor.constraint(equalTo: buttonX.topAnchor),
                buttonZ.bottomAnchor.constraint(equalTo: buttonX.bottomAnchor),
                buttonZ.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -20),

                //buttonX.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.333),
                buttonY.widthAnchor.constraint(equalTo: buttonX.widthAnchor),
                buttonZ.widthAnchor.constraint(equalTo: buttonX.widthAnchor)

            ]
        )
        
        
       
    }
    
    func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), style: UITableView.Style.plain)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView!)
        
        titles = ["GLKit load Image","GLKit Cube","Core Animation Cube","ESView load image","ESView load rectanglar","GLKnormal","esLight","emitter"];
    }
    @objc func buttonClick(btn: UIButton){
        
    }

}
extension ViewController :UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return titles.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
       
        cell.textLabel?.text = titles[indexPath.row]

        
        return cell
      
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    @available(*, deprecated, message: "ios13")
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var twoVC : UIViewController = UIViewController()
        
        
        switch indexPath.row {
        case 0:
            twoVC = GLKImgeViewController()
            
        case 1:
            twoVC = GLKCubeViewController()
            
        case 2:
            twoVC = CACubeViewController()
        case 3:
            twoVC = GLKViewController()
        case 4:
            twoVC = GLKViewController()
            (twoVC as! GLKViewController).type = .rectangulr
        case 5:
            twoVC = GLKNormalViewController()
        case 6:
            twoVC = GLKViewController()
            (twoVC as! GLKViewController).type = .light
        case 7:
            twoVC = EmitterViewController()
            
        default:
            twoVC = GLKImgeViewController()
        
        }
        self.navigationController?.pushViewController(twoVC, animated: true)
    }
}
