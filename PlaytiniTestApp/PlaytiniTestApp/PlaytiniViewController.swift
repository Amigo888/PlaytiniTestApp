//
//  PlaytiniViewController.swift
//  PlaytiniTestApp
//
//  Created by Дмитрий Процак on 26.12.2023.
//

import UIKit
import SnapKit

final class PlaytiniViewController: UIViewController {
    
//    private lazy var rotatedCircle: UIView = {
//        let view = UIView()
//        view.backgroundColor = .gray
//        return view
//    }()
    
    private lazy var rotatedCircle: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ball"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var reducedButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .orange
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.tintColor = .black
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 4
        button.addTarget(self, action: #selector(reducedCircleSize), for: .touchUpInside)
        button.addGestureRecognizer(reducedGesture)
        return button
    }()
    
    private lazy var increasedButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .orange
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .black
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 4
        button.addTarget(self, action: #selector(increasedCircleSize), for: .touchUpInside)
        button.addGestureRecognizer(increasedGesture)
        return button
    }()
    
    private lazy var increasedGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleIncreasedGesture(_:)))
        return gesture
    }()
    
    private lazy var reducedGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleReducedGesture(_:)))
        return gesture
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            reducedButton,
            increasedButton
        ])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private var sizeChangingTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        addSubviews()
        setupConstraints()
        rotateCircle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCircleViews()
    }
    
    private func addSubviews() {
        view.addSubview(rotatedCircle)
        view.addSubview(buttonStackView)
    }
    
    private func setupConstraints() {
        rotatedCircle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(80)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(32)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        increasedButton.snp.makeConstraints { make in
            make.width.height.equalTo(100)
        }
        
        reducedButton.snp.makeConstraints { make in
            make.width.height.equalTo(100)
        }
    }
    
    private func setupCircleViews() {
        rotatedCircle.layer.cornerRadius = rotatedCircle.bounds.size.width / 2
        rotatedCircle.clipsToBounds = true
        
        reducedButton.layer.cornerRadius = reducedButton.bounds.size.width / 2
        reducedButton.clipsToBounds = true
        
        increasedButton.layer.cornerRadius = increasedButton.bounds.size.width / 2
        increasedButton.clipsToBounds = true
    }
    
    @objc private func increasedCircleSize() {
        let currentSize = rotatedCircle.bounds.size.width
        let maximumSize: CGFloat = 300
        
        var newSize = currentSize + 10
        if newSize > maximumSize {
            newSize = maximumSize
        }
        animateCircleSize(to: newSize)
    }
    
    @objc private func reducedCircleSize() {
        let newSize = max(rotatedCircle.bounds.size.width - 10, 30)
        animateCircleSize(to: newSize)
    }
    
    @objc private func handleIncreasedGesture(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            startIncreasing()
        case .ended, .cancelled:
            stopChangingSize()
        default:
            break
        }
    }

    @objc private func handleReducedGesture(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            startReducing()
        case .ended, .cancelled:
            stopChangingSize()
        default:
            break
        }
    }
    
    private func startIncreasing() {
        sizeChangingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.increasedCircleSize()
        }
    }

    private func startReducing() {
        sizeChangingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.reducedCircleSize()
        }
    }

    private func stopChangingSize() {
        sizeChangingTimer?.invalidate()
        sizeChangingTimer = nil
    }
    
    private func animateCircleSize(to newSize: CGFloat) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.rotatedCircle.snp.updateConstraints { make in
                make.size.equalTo(newSize)
            }
            self?.view.layoutIfNeeded()
        }
    }
    
    private func rotateCircle() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2)
        rotationAnimation.duration = 2.0
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float.greatestFiniteMagnitude
        rotatedCircle.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
}
