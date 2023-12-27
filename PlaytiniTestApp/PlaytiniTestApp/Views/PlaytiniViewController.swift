//
//  PlaytiniViewController.swift
//  PlaytiniTestApp
//
//  Created by Дмитрий Процак on 26.12.2023.
//

import UIKit
import SnapKit

final class PlaytiniViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var collisionCounter: UILabel = {
        let label = UILabel()
        label.text = "Collision counter: 0"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemPink
        return label
    }()
    
    private lazy var rotatedCircle: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ball"))
        imageView.backgroundColor = .red
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
    
    private lazy var horizontalUpLine: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var horizontalDownLine: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .white
        return view
    }()
    
    private var sizeChangingTimer: Timer?
    
    private var counter: Int = 0
    
    private var displayLink: CADisplayLink?
    
    private var firstObjectCollisionDetected = false
    private var secondObjectCollisionDetected = false
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupConstraints()
        rotateCircle()
        animationsTopLine()
        animationsBottomLine()
        startCollisionDetection()
    }
    
    // MARK: - ViewDidLayoutSubviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCircleViews()
    }
    
    // MARK: - Private Methods
    
    private func addSubviews() {
        view.addSubview(rotatedCircle)
        view.addSubview(buttonStackView)
        view.addSubview(collisionCounter)
        view.addSubview(horizontalUpLine)
        view.addSubview(horizontalDownLine)
    }
    
    private func setupConstraints() {
        horizontalUpLine.frame = CGRect(x: view.bounds.width + 70, y: (view.bounds.height / 2) - 55, width: 70, height: 20)
        horizontalDownLine.frame = CGRect(x: view.bounds.width + 90, y: (view.bounds.height / 2) + 40, width: 90, height: 20)
        
        collisionCounter.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        
        rotatedCircle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(60)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
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
    
    private func animationsTopLine() {
        UIView.animateKeyframes(withDuration: 6.8, delay: 0.1) {
            self.horizontalUpLine.frame.origin.x = -self.view.bounds.width
        } completion: { _ in
            let randomWidth = Int.random(in: 50...120)
            let randomHeight = Int.random(in: 15...35)
            self.horizontalUpLine.frame.size = CGSize(width: randomWidth, height: randomHeight)
            self.horizontalUpLine.frame.origin.x = self.view.bounds.width + CGFloat(randomWidth)
            self.horizontalUpLine.frame.origin.y = (self.view.bounds.height / 2) - CGFloat(randomHeight * 2)
            UIView.animate(withDuration: 6.0) {
                self.horizontalUpLine.frame.origin.x = -self.view.bounds.width
            } completion: { _ in
                self.animationsTopLine()
            }
        }
    }
    
    private func animationsBottomLine() {
        UIView.animateKeyframes(withDuration: 7.2, delay: 0.6) {
            self.horizontalDownLine.frame.origin.x = -self.view.bounds.width
        } completion: { _ in
            let randomWidth = Int.random(in: 60...120)
            let randomHeight = Int.random(in: 15...30)
            self.horizontalDownLine.frame.size = CGSize(width: randomWidth, height: randomHeight)
            self.horizontalDownLine.frame.origin.x = self.view.bounds.width + CGFloat(randomWidth)
            self.horizontalDownLine.frame.origin.y = (self.view.bounds.height / 2) + CGFloat(randomHeight * 2)
            UIView.animate(withDuration: 6.0) {
                self.horizontalDownLine.frame.origin.x = -self.view.bounds.width
            } completion: { _ in
                self.animationsBottomLine()
            }
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
    
    func rotateCircle() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2)
        rotationAnimation.duration = 2.0
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float.greatestFiniteMagnitude
        rotatedCircle.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    private func startCollisionDetection() {
        displayLink = CADisplayLink(target: self, selector: #selector(checkCollision))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    // MARK: - Private @objc Methods
    
    @objc private func increasedCircleSize() {
        let currentSize = rotatedCircle.bounds.size.width
        let maximumSize: CGFloat = 150
        
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
    
    @objc func checkCollision() {
        let circlePresentationFrame = rotatedCircle.frame.insetBy(dx: .zero, dy: 1)
        let upLineFrame = horizontalUpLine.layer.presentation()?.frame ?? rotatedCircle.frame
        let downLineFrame = horizontalDownLine.layer.presentation()?.frame ?? rotatedCircle.frame
        
        if circlePresentationFrame.intersects(upLineFrame) {
            if !firstObjectCollisionDetected {
                firstObjectCollisionDetected = true
                counter += 1
                collisionCounter.text = "Collision counter: \(counter)"
            }
        } else {
            firstObjectCollisionDetected = false
        }
        
        if circlePresentationFrame.intersects(downLineFrame) {
            if !secondObjectCollisionDetected {
                secondObjectCollisionDetected = true
                counter += 1
                collisionCounter.text = "Collision counter: \(counter)"
            }
        } else {
            secondObjectCollisionDetected = false
        }
    }
}
