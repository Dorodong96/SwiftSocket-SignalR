//
//  ViewControllerExtension.swift
//  InBodyBWA
//
//  Created by 전종상 on 2022/08/02.
//

import Foundation
import UIKit

extension UIViewController {
    /// 화면 탭시 키보드 숨기기
    func hideKeyboard() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard)
        )
        view.addGestureRecognizer(tapGesture)
    }
    
    /// 화면 탭시 키보드 숨기기 - RxSwift Select Longtap Issue 개선
    func hideKeyboardCancelsTouch() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard)
        )
        tapGesture.cancelsTouchesInView = false
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func tapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            UIView.animate(withDuration: 0) {
                let keyboardRectangle = keyboardFrame.cgRectValue
                self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height/3)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.transform = .identity
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    // API 통신 실패 시 띄우는 모달
//    func networkErrorModalVC(closeAction: @escaping () -> Void = {}) -> InBodyModalViewController {
//        guard let nextVC = UIStoryboard(name: InBodyModalViewController.storyboardName,
//                                        bundle: Bundle(for: InBodyModalViewController.self)).instantiateViewController(withIdentifier: InBodyModalViewController.id)
//                as? InBodyModalViewController else {
//            print("InBodyModalViewController 찾을 수 없음")
//            return InBodyModalViewController()
//        }
//
//        let modalConfig = InBodyModalConfig()
//            .withNumOfButtonLessThanFive(numOfButton: 1)
//            .withModalViewCornerRadius(modalViewCornerRadius: 40.0)
//            .withTitleFontOption(titleFontOption: TitleFontOption(titleText: "all_network_error_title".localized,
//                                                                  titleFont: .noto(fontSize: .subtitle1, family: .bold),
//                                                                  titleTextColor: .gray900))
//            .withDetailFontOption(detailFontOption: DetailFontOption(detailText: "all_network_error_description".localized,
//                                                                     detailFont: .noto(fontSize: .body2, family: .regular),
//                                                                     detailTextColor: .gray700))
//            .withButtonFirstFontOption(buttonFirstFontOption: ButtonFirstFontOption(buttonFirstText: "all_ok".localized,
//                                                                                    buttonFirstFont: .noto(fontSize: .subtitle1, family: .bold),
//                                                                                    buttonFirstTextColor: .blue600))
//
//        nextVC.inbodyModalConfig = modalConfig
//
//        nextVC.tapFirstButtonEvent = {
//            closeAction()
//        }
//
//        return nextVC
//    }
//
//    // 토큰 갱신 실패 로그아웃 해주는 모달
//    func refreshTokenErrorModalVC(logoutAction: @escaping () -> Void) -> InBodyModalViewController {
//        guard let nextVC = UIStoryboard(name: InBodyModalViewController.storyboardName,
//                                        bundle: Bundle(for: InBodyModalViewController.self)).instantiateViewController(withIdentifier: InBodyModalViewController.id)
//                as? InBodyModalViewController else {
//            print("InBodyModalViewController 찾을 수 없음")
//            return InBodyModalViewController()
//        }
//
//        let modalConfig = InBodyModalConfig()
//            .withNumOfButtonLessThanFive(numOfButton: 1)
//            .withModalViewCornerRadius(modalViewCornerRadius: 40.0)
//            .withTitleFontOption(titleFontOption: TitleFontOption(titleText: "all_network_unauthorized_title".localized,
//                                                                  titleFont: .noto(fontSize: .subtitle1, family: .bold),
//                                                                  titleTextColor: .gray900))
//            .withDetailFontOption(detailFontOption: DetailFontOption(detailText: "all_network_unauthorized_desc".localized,
//                                                                     detailFont: .noto(fontSize: .body2, family: .regular),
//                                                                     detailTextColor: .gray700))
//            .withButtonFirstFontOption(buttonFirstFontOption: ButtonFirstFontOption(buttonFirstText: "all_ok".localized,
//                                                                                    buttonFirstFont: .noto(fontSize: .subtitle1, family: .bold),
//                                                                                    buttonFirstTextColor: .blue600))
//
//        nextVC.inbodyModalConfig = modalConfig
//
//        nextVC.tapFirstButtonEvent = {
//            logoutAction()
//        }
//
//        return nextVC
//    }
//
//    // 로그인 실패 시 띄워주는 모달
//    func loginErrorModalVC() -> InBodyModalViewController {
//        guard let nextVC = UIStoryboard(name: InBodyModalViewController.storyboardName,
//                                        bundle: Bundle(for: InBodyModalViewController.self)).instantiateViewController(withIdentifier: InBodyModalViewController.id)
//                as? InBodyModalViewController else {
//            print("InBodyModalViewController 찾을 수 없음")
//            return InBodyModalViewController()
//        }
//
//        let modalConfig = InBodyModalConfig()
//            .withNumOfButtonLessThanFive(numOfButton: 1)
//            .withModalViewCornerRadius(modalViewCornerRadius: 40.0)
//            .withTitleFontOption(titleFontOption: TitleFontOption(titleText: "login_act_popup_login_error_title".localized,
//                                                                  titleFont: .noto(fontSize: .subtitle1, family: .bold),
//                                                                  titleTextColor: .gray900))
//            .withDetailFontOption(detailFontOption: DetailFontOption(detailText: "login_act_popup_login_error_body".localized,
//                                                                     detailFont: .noto(fontSize: .body2, family: .regular),
//                                                                     detailTextColor: .gray700))
//            .withButtonFirstFontOption(buttonFirstFontOption: ButtonFirstFontOption(buttonFirstText: "all_ok".localized,
//                                                                                    buttonFirstFont: .noto(fontSize: .subtitle1, family: .bold),
//                                                                                    buttonFirstTextColor: .blue600))
//        nextVC.inbodyModalConfig = modalConfig
//
//        nextVC.tapFirstButtonEvent = {
//
//        }
//        return nextVC
//    }
//
//    // toast message
//    func showToastMessageView(message: String = "all_save_alert".localized, iconName: String = "icon-save-check") {
////    func toastMessageModalView(message: String = "") {
//
//        let toastMessageView: ToastMessageView = .init(frame: .init(x: self.view.frame.width/2, y: UIScreen.main.bounds.height + 200, width: 0, height: 0))
//        toastMessageView.toastMessageIcon.image = .init(named: iconName)
//        toastMessageView.toastMessageLabel.text = message
//
////        self.view.addSubview(toastMessageView)
//
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let mainWindow = windowScene.windows.first else {
//            return
//        }
//
//        mainWindow.addSubview(toastMessageView)
//
//        toastMessageView.snp.makeConstraints {
//            $0.centerX.equalToSuperview()
//            $0.bottom.equalTo(mainWindow.safeAreaLayoutGuide)
//            $0.height.equalTo(toastMessageView.snp.height)
//        }
//
//        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
//            // 위로 올리기
//            toastMessageView.snp.updateConstraints {
//                $0.bottom.equalTo(mainWindow.safeAreaLayoutGuide).offset(-120)
//            }
//            toastMessageView.superview?.layoutIfNeeded()
//        }, completion: { _ in
//
//            UIView.animate(withDuration: 1.5, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
//                // 아래로 내리기
//                toastMessageView.snp.updateConstraints {
//                    $0.bottom.equalTo(mainWindow.safeAreaLayoutGuide).offset(UIScreen.main.bounds.height + 200)
//                }
//                toastMessageView.superview?.layoutIfNeeded()
//
//            }, completion: { _ in
//                // 제거
//                toastMessageView.removeFromSuperview()
//            })
//        })
//
//    }
//
//    // 사용자가 현재 ViewController화면을 보고있는가
//    func isVisible() -> Bool {
//        return self.viewIfLoaded?.window != nil
//    }
//
//    // InBodyTextField update
//
//    func updateTextField(_ textField: InBodyTextField, textHeight: NSLayoutConstraint?, borderColor: UIColor, warningText: String? = nil) {
//
//        if borderColor == .red {
//            textField.textFieldBorderColor = .red
//        } else if borderColor == .blue {
//            textField.textFieldBorderColor = .blue
//        } else {
//            textField.textFieldBorderColor = .none
//        }
//
//        if let warningText = warningText {
//
//            UIView.animate(withDuration: 0.3, animations: {
//                let warningLabelHeight = textField.addWarningBox(warningText: warningText)
//                textHeight?.constant = warningLabelHeight
//                self.view.layoutIfNeeded()
//            }, completion: nil)
//
//        } else {
//
//            UIView.animate(withDuration: 0.3, animations: {
//                let warningLabelHeight = textField.hideWarningBox()
//                textHeight?.constant = warningLabelHeight
//                self.view.layoutIfNeeded()
//            }, completion: nil)
//
//        }
//    }
//
//    func openURLInBrowser(urlString: String) {
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
//            if UIApplication.shared.canOpenURL(url) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            } else {
//                print("Failed to open URL")
//            }
//        })
//    }
}
