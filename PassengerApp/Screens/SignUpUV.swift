//
//  SignUpUV.swift
//  PassengerApp
//
//  Created by ADMIN on 06/05/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit
import BEMCheckBox
import IQKeyboardManagerSwift

class SignUpUV: UIViewController, MyLabelClickDelegate, MyBtnClickDelegate, MyTxtFieldClickDelegate {
    
    @IBOutlet weak var instTxtField: MyTextField!
    @IBOutlet weak var instView: UIView!
    @IBOutlet weak var socialLoginStkView: UIStackView!
    @IBOutlet weak var googleImgView: UIImageView!
    @IBOutlet weak var twitterImgView: UIImageView!
    @IBOutlet weak var fbImgView: UIImageView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signUpHLbl: MyLabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var orLblContainer: UIView!
    @IBOutlet weak var orLbl: MyLabel!
    @IBOutlet weak var goToSignInContainerView: UIView!
    @IBOutlet weak var goToSignInContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var goSignInLbl: MyLabel!
    
    @IBOutlet weak var fNameTxtField: MyTextField!
    @IBOutlet weak var lNameTxtField: MyTextField!
    @IBOutlet weak var emailTxtField: MyTextField!
    @IBOutlet weak var cpfTxtField: MyTextField!
    @IBOutlet weak var countryTxtField: MyTextField!
    @IBOutlet weak var mobileNumTxtField: MyTextField!
    @IBOutlet weak var passwordTxtField: MyTextField!
    @IBOutlet weak var inviteCodeAreaHeight: NSLayoutConstraint!
    @IBOutlet weak var inviteCodeAreaView: UIView!
    @IBOutlet weak var inviteTxtField: MyTextField!
    @IBOutlet weak var helpImgView: UIImageView!
    @IBOutlet weak var registerBtn: MyButton!
    @IBOutlet weak var numRegisterTxtField: MyTextField!
    
    @IBOutlet weak var userProfilePicViewArea: UIView!
    @IBOutlet weak var profilePicViewArea: UIView!
    @IBOutlet weak var usrProfileImgView: UIImageView!
    @IBOutlet weak var editPicAreaView: UIView!
    @IBOutlet weak var editIconImgView: UIImageView!
    @IBOutlet weak var genderTxtField: MyTextField!
    @IBOutlet weak var genderContainerView: UIView!
    @IBOutlet weak var socialLoginStkHeight: NSLayoutConstraint!
    private var profileImageSelected: UIImage?
    private enum GenderType: String {
        case Male
        case Female
        case NotSelected
        func getGenderType() -> String {
            return self.rawValue
        }
    }
    private enum InstitutionIdType: Int {
        case pf = 1
        case bm = 2
        case pm = 3
        case gm = 4
        case pp = 5
        case pc = 6
        case fa = 7
        case fam = 8
        case faa = 9
        case NotSelected = 0
        func getnstitutionIdType() -> Int {
            return self.rawValue
        }
    }
    private var genderType = GenderType.NotSelected
    private var institutionIdType = InstitutionIdType.NotSelected

    var openImgSelection:OpenImageSelectionOption!
    
    @IBOutlet weak var termsLbl: MyLabel!
    @IBOutlet weak var termsCheckBox: BEMCheckBox!
    var isFromAppLogin = true
    
    let generalFunc = GeneralFunctions()
    
    var required_str = ""
    
    var isCountrySelected = false
    var selectedCountryCode = ""
    var selectedPhoneCode = ""
    
    var openFbLogin: OpenFbLogin!
    var openGoogleLogin: OpenGoogleLogin!
    var openTwitterLogin: OpenTwitterLogin!
    
    var isFirstLaunch = true
    //    var isViewProperShutDown = false
    
    var cntView:UIView!
    var previousNextView:IQPreviousNextView!
    
    var isSafeAreaSet = false
    var PAGE_HEIGHT: CGFloat = 1020//855 //+ 166 = 1021
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cntView = self.generalFunc.loadView(nibName: "SignUpScreenDesign", uv: self, contentView: scrollView)
        cntView.frame.size.width = Application.screenSize.width
        
        previousNextView = IQPreviousNextView(frame: cntView.frame)
        previousNextView.addSubview(cntView)
        previousNextView.center = cntView.center
        
        self.scrollView.addSubview(previousNextView)
        self.scrollView.bounces = false
        
        self.addBackBarBtn()
        
        let facebookLoginEnabled = GeneralFunctions.getValue(key: Utils.FACEBOOK_LOGIN_KEY)
        let googleLoginEnabled = GeneralFunctions.getValue(key: Utils.GOOGLE_LOGIN_KEY)
        let twitterLoginEnabled = GeneralFunctions.getValue(key: Utils.TWITTER_LOGIN_KEY)
        
        var isFBLoginEnabled = false
        var isGoogleLoginEnabled = false
        var isTwitterLoginEnabled = false
        if(facebookLoginEnabled != nil && (facebookLoginEnabled as! String).uppercased() == "NO"){
            isFBLoginEnabled = false
            self.fbImgView.isHidden = true
        }else{
            isFBLoginEnabled = true
        }
        
        if(googleLoginEnabled != nil && (googleLoginEnabled as! String).uppercased() == "NO"){
            isGoogleLoginEnabled = false
            self.googleImgView.isHidden = true
        }else{
            isGoogleLoginEnabled = true
        }
        
        if(twitterLoginEnabled != nil && (twitterLoginEnabled as! String).uppercased() == "NO"){
            isTwitterLoginEnabled = false
            self.twitterImgView.isHidden = true
        }else{
            isTwitterLoginEnabled = true
        }
        
        if(isFBLoginEnabled == false && isGoogleLoginEnabled == false && isTwitterLoginEnabled == false){
            for i in 0..<socialLoginStkView.subviews.count{
                let subView = socialLoginStkView.subviews[i]
                
                subView.isHidden = true
            }
            //Marlon
            //Mostrar painel da imagem do perfil aqui
            socialLoginStkView.isHidden = true
            userProfilePicViewArea.isHidden = false
         //   socialLoginStkHeight.constant = 0
            self.PAGE_HEIGHT = self.PAGE_HEIGHT - 180
        }
        
        let userProfileImgTapGue = UITapGestureRecognizer()
        userProfileImgTapGue.addTarget(self, action: #selector(self.profilePicTapped))
        self.profilePicViewArea.isUserInteractionEnabled = true
        self.profilePicViewArea.addGestureRecognizer(userProfileImgTapGue)
        
        setData()
        //getInstitutionList()
    }
    
    @objc func profilePicTapped(){
        self.openImgSelection = OpenImageSelectionOption(uv: self)
        self.openImgSelection.showOnly { (image) in
            self.profileImageSelected = image
            if (image != nil) {
                self.usrProfileImgView.image = image
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.configureRTLView()
    }
    
    func setData(){
        required_str = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FEILD_REQUIRD_ERROR_TXT")
        self.orLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_OR_TXT")
        //        LBL_PHONE_EMAIL
        self.registerBtn.isAppTheme = true
        if(GeneralFunctions.getValue(key: Utils.MOBILE_VERIFICATION_ENABLE_KEY) != nil && (GeneralFunctions.getValue(key: Utils.MOBILE_VERIFICATION_ENABLE_KEY) as! String).uppercased() == "YES"){
            self.registerBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_NEXT_TXT"))
        }else{
            self.registerBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_REGISTER_TXT"))
        }
        //        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "REGISTER", key: "LBL_BTN_REGISTER_TXT")
        self.title = self.generalFunc.getLanguageLabel(origValue: "SignUp", key: "LBL_SIGN_UP")
        //        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: JosefinFont.bold(with: 20), NSAttributedString.Key.foregroundColor: UIColor.white]
        
        self.orLblContainer.transform = CGAffineTransform(rotationAngle: 45 * CGFloat(CGFloat.pi/180))
        self.orLbl.transform = CGAffineTransform(rotationAngle: -45 * CGFloat(CGFloat.pi/180))
        
        //        self.signUpBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SIGN_IN_TXT"))
        //        self.signUpBtn.clickDelegate = self
        
        self.goSignInLbl.setClickDelegate(clickDelegate: self)
        self.registerBtn.clickDelegate = self
        self.numRegisterTxtField.setPlaceHolder(placeHolder: "N de Registro")
        self.fNameTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FIRST_NAME_HEADER_TXT"))
        self.lNameTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_LAST_NAME_HEADER_TXT"))
        self.emailTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_EMAIL_LBL_TXT"))
        self.cpfTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_TAXID_TXT"))
        self.countryTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_COUNTRY_TXT"))
        self.mobileNumTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_MOBILE_NUMBER_HEADER_TXT"))
        self.passwordTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PASSWORD_LBL_TXT"))
        self.inviteTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_INVITE_CODE_HINT"))
        //Marlon - Opção de sexo adicionada
        self.instTxtField.setText(text: "Selecione a Instituicao")

        self.instTxtField.setEnable(isEnabled: false)
        self.instTxtField.myTxtFieldDelegate = self
        self.instTxtField.addArrowView(color: UIColor(hex: 0xbfbfbf), transform: CGAffineTransform(rotationAngle: 90 * CGFloat(CGFloat.pi/180)))
        
        
        self.genderTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "Gênero", key: "LBL_GENDER_TXT"))
        self.genderTxtField.setText(text: "Selecione o Genero")
        self.genderTxtField.addArrowView(color: UIColor(hex: 0xbfbfbf), transform: CGAffineTransform(rotationAngle: 90 * CGFloat(CGFloat.pi/180)))
        self.genderTxtField.setEnable(isEnabled: false)
        self.genderTxtField.myTxtFieldDelegate = self
        usrProfileImgView.image = UIImage(named:"ic_no_pic_user")
        
        Utils.createRoundedView(view: usrProfileImgView, borderColor: UIColor.UCAColor.AppThemeColor_1, borderWidth: 2)
        
        editPicAreaView.backgroundColor = UIColor.UCAColor.AppThemeColor_1
        Utils.createRoundedView(view: editPicAreaView, borderColor: UIColor.clear, borderWidth: 0)
        
        GeneralFunctions.setImgTintColor(imgView: editIconImgView, color: .white)
        
        if(GeneralFunctions.getValue(key: Utils.REFERRAL_SCHEME_ENABLE) != nil && (GeneralFunctions.getValue(key: Utils.REFERRAL_SCHEME_ENABLE) as! String).uppercased() != "YES" ){
            
            self.inviteCodeAreaView.isHidden = true
            self.inviteCodeAreaHeight.constant = 0
            //            self.scrollView.setContentViewSize(offset: -50)
            
        }else{
            //            self.scrollView.setContentViewSize(offset: 15)
        }
        
        let inviteHelpTapGue = UITapGestureRecognizer()
        
        inviteHelpTapGue.addTarget(self, action: #selector(self.inviteHelpImgTapped(sender:)))
        self.helpImgView.isUserInteractionEnabled = true
        self.helpImgView.addGestureRecognizer(inviteHelpTapGue)
        
        self.countryTxtField.setEnable(isEnabled: false)
        self.countryTxtField.myTxtFieldDelegate = self
        self.orLbl.font = RobotoFont.medium(with: 15)
        
        
        signUpHLbl.text = self.generalFunc.getLanguageLabel(origValue: "SIGN UP WITH SOCIAL ACCOUNTS", key: "LBL_SIGN_UP_WITH_SOC_ACC")
        signUpHLbl.font = RobotoFont.bold(with: 14)
        
        self.goSignInLbl.text = self.generalFunc.getLanguageLabel(origValue: "Already have an account?", key: "LBL_ALREADY_HAVE_ACC")
        goSignInLbl.font = RobotoFont.bold(with: 16)
        
        self.goSignInLbl.textColor = UIColor.UCAColor.AppThemeTxtColor
        self.goToSignInContainerView.backgroundColor = UIColor.UCAColor.AppThemeColor
        fbImgView.isUserInteractionEnabled = true
        googleImgView.isUserInteractionEnabled = true
        twitterImgView.isUserInteractionEnabled = true
        
        let fbImgTapGue = UITapGestureRecognizer()
        let googleImgTapGue = UITapGestureRecognizer()
        let twittImgTapGue = UITapGestureRecognizer()
        
        fbImgTapGue.addTarget(self, action: #selector(self.fbBtnTapped))
        googleImgTapGue.addTarget(self, action: #selector(self.googleBtnTapped))
        twittImgTapGue.addTarget(self, action: #selector(self.twittBtnTapped))
        
        fbImgView.addGestureRecognizer(fbImgTapGue)
        googleImgView.addGestureRecognizer(googleImgTapGue)
        twitterImgView.addGestureRecognizer(twittImgTapGue)
        //        For Terms and Conditions
        
        self.termsCheckBox.boxType = .square
        self.termsCheckBox.offAnimationType = .bounce
        self.termsCheckBox.onAnimationType = .bounce
        self.termsCheckBox.onCheckColor = UIColor.UCAColor.AppThemeTxtColor
        self.termsCheckBox.onFillColor = UIColor.UCAColor.AppThemeColor
        self.termsCheckBox.onTintColor = UIColor.UCAColor.AppThemeColor
        self.termsCheckBox.tintColor = UIColor.UCAColor.AppThemeColor_1
        self.termsLbl.textColor = UIColor.black
        
        
        var multipleAttributes = [NSAttributedString.Key : Any]()
        multipleAttributes[NSAttributedString.Key.foregroundColor] = UIColor.UCAColor.AppThemeColor
        multipleAttributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
        
        let attrString1 = NSMutableAttributedString(string: "\(self.generalFunc.getLanguageLabel(origValue: "I agree to the", key: "LBL_TERMS_CONDITION_PREFIX")) ")
        let attrString2 = NSMutableAttributedString(string: self.generalFunc.getLanguageLabel(origValue: "Terms & Conditions and Privacy Policy", key: "LBL_TERMS_PRIVACY"))
        
        attrString2.addAttributes(multipleAttributes, range: NSMakeRange(0, attrString2.length))
        attrString1.append(attrString2)
        
        self.termsLbl.attributedText = attrString1
        self.termsLbl.font = RobotoFont.bold(with: 14)
        
        self.termsLbl.setClickDelegate(clickDelegate: self)
        self.termsLbl.fitText()
        
        if(GeneralFunctions.getValue(key: Utils.DEFAULT_COUNTRY_KEY) != nil && (GeneralFunctions.getValue(key: Utils.DEFAULT_COUNTRY_KEY) as! String) != "" && GeneralFunctions.getValue(key: Utils.DEFAULT_COUNTRY_CODE_KEY) != nil && (GeneralFunctions.getValue(key: Utils.DEFAULT_COUNTRY_CODE_KEY) as! String) != "" && GeneralFunctions.getValue(key: Utils.DEFAULT_PHONE_CODE_KEY) != nil && (GeneralFunctions.getValue(key: Utils.DEFAULT_PHONE_CODE_KEY) as! String) != ""){
            self.selectedCountryCode = (GeneralFunctions.getValue(key: Utils.DEFAULT_COUNTRY_CODE_KEY) as! String)
            self.selectedPhoneCode = (GeneralFunctions.getValue(key: Utils.DEFAULT_PHONE_CODE_KEY) as! String)
            
            self.countryTxtField.setText(text: "+\(self.selectedPhoneCode)")
            
            self.isCountrySelected = true
            self.countryTxtField.getTextField()!.sendActions(for: .editingChanged)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.emailTxtField.getTextField()!.keyboardType = .emailAddress
        self.cpfTxtField.getTextField()!.keyboardType = .numberPad
        self.passwordTxtField.getTextField()!.isSecureTextEntry = true
        self.mobileNumTxtField.getTextField()!.keyboardType = .numberPad
        
        if(isFirstLaunch){
            countryTxtField.addArrowView(color: UIColor(hex: 0xbfbfbf), transform: CGAffineTransform(rotationAngle: 90 * CGFloat(CGFloat.pi/180)))
            
            //            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.registerBtn.frame.maxY + 20)
            if(PAGE_HEIGHT < self.cntView.frame.height){
                self.PAGE_HEIGHT = self.cntView.frame.height
            }
            self.cntView.frame.size.height = self.PAGE_HEIGHT
            self.previousNextView.frame.size.height = self.PAGE_HEIGHT
            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: PAGE_HEIGHT)
            
            isFirstLaunch = false
            
        }
        //        if (isViewProperShutDown == true)
        //        {
        //            fNameTxtField.setText(text: "")
        //            lNameTxtField.setText(text: "")
        //            emailTxtField.setText(text: "")
        //            countryTxtField.setText(text: "")
        //            mobileNumTxtField.setText(text: "")
        //            passwordTxtField.setText(text: "")
        //            inviteTxtField.setText(text: "")
        //            isViewProperShutDown = false
        //        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
        if(isSafeAreaSet == false){
            self.goToSignInContainerViewHeight.constant = 50 + GeneralFunctions.getSafeAreaInsets().bottom
            isSafeAreaSet = true
        }
    }
    
    private func genderTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let masc = UIAlertAction(title: "Masculino", style: .default) { (action) in
            //ação do botão masculino
            self.genderType = GenderType.Male
            self.genderTxtField.setText(text: "Masculino")
        }
        let fem = UIAlertAction(title: "Feminino", style: .default) { (action) in
            //ação do botão feminino
            self.genderType = GenderType.Female
            self.genderTxtField.setText(text: "Feminino")
        }
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) in
            //ação do botão cancelar
        }
        actionSheet.addAction(masc)
        actionSheet.addAction(fem)
        actionSheet.addAction(cancel)
        //present(actionSheet, animated: true, completion: nil)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    private func intitutoTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let pf = UIAlertAction(title: "Policia Federal", style: .default) { (action) in
            //ação do botão masculino
            self.institutionIdType = InstitutionIdType.pf
            self.instTxtField.setText(text: "Policia Federal")
        }
        let bm = UIAlertAction(title: "Bombeiro Militar", style: .default) { (action) in
            //ação do botão masculino
            self.institutionIdType = InstitutionIdType.bm
            self.instTxtField.setText(text: "Bombeiro Militar")
        }
        let pm = UIAlertAction(title: "Policia Militar", style: .default) { (action) in
            //ação do botão masculino
            self.institutionIdType = InstitutionIdType.pm
            self.instTxtField.setText(text: "Policia Militar")
        }
        let gm = UIAlertAction(title: "Guarda Municipal", style: .default) { (action) in
            //ação do botão masculino
            self.institutionIdType = InstitutionIdType.gm
            self.instTxtField.setText(text: "Guarda Municipal")
        }
        let pp = UIAlertAction(title: "Policia Penal", style: .default) { (action) in
            //ação do botão masculino
            self.institutionIdType = InstitutionIdType.pp
            self.instTxtField.setText(text: "Policia Penal")
        }
        let pc = UIAlertAction(title: "Policia Civil", style: .default) { (action) in
            //ação do botão masculino
            self.institutionIdType = InstitutionIdType.pc
            self.instTxtField.setText(text: "Policia Civil")
        }
        let fa = UIAlertAction(title: "Forcas Armadas", style: .default) { (action) in
            //ação do botão masculino
            self.institutionIdType = InstitutionIdType.fa
            self.instTxtField.setText(text: "Forcas Armadas")
        }
        let fam = UIAlertAction(title: "Forcas Armadas - Marinha", style: .default) { (action) in
            //ação do botão masculino
            self.institutionIdType = InstitutionIdType.fam
            self.instTxtField.setText(text: "Forcas Armadas - Marinha")
        }
        let faa = UIAlertAction(title: "Forcas Armadas - Aeronautica", style: .default) { (action) in
            //ação do botão masculino
            self.institutionIdType = InstitutionIdType.faa
            self.instTxtField.setText(text: "Forcas Armadas - Aeronautica")
        }
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) in
            //ação do botão cancelar
        }
        
        actionSheet.addAction(pf)
        actionSheet.addAction(bm)
        actionSheet.addAction(pm)
        actionSheet.addAction(gm)
        actionSheet.addAction(pp)
        actionSheet.addAction(pc)
        actionSheet.addAction(fa)
        actionSheet.addAction(fam)
        actionSheet.addAction(faa)


        actionSheet.addAction(cancel)
        //present(actionSheet, animated: true, completion: nil)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func fbBtnTapped(){
        //        var isViewProperShutDown = true
        let window = UIApplication.shared.delegate!.window!
        
        openFbLogin = OpenFbLogin(uv: self, window: window!)
        
        openFbLogin.processData(openFbLoginInst: openFbLogin)
    }
    
    @objc func googleBtnTapped(){
        //        var isViewProperShutDown = true
        let window = UIApplication.shared.delegate!.window!
        
        openGoogleLogin = OpenGoogleLogin(uv: self, window: window!)
        openGoogleLogin.processData(currGoogleLoginInst: openGoogleLogin)
        
    }
    @objc func twittBtnTapped(){
        //        var isViewProperShutDown = true
        let window = UIApplication.shared.delegate!.window!
        
        openTwitterLogin = OpenTwitterLogin(uv: self, window: window!)
        openTwitterLogin.processData(currTwitterLoginInst: openTwitterLogin)
        
    }
    
    @objc func inviteHelpImgTapped(sender:UITapGestureRecognizer){
        self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_REFERAL_SCHEME"))
    }
    
    func myTxtFieldTapped(sender: MyTextField) {
        if(sender == self.countryTxtField){
            let countryListUv = GeneralFunctions.instantiateViewController(pageName: "CountryListUV") as! CountryListUV
            countryListUv.fromRegister = true
            self.pushToNavController(uv: countryListUv)
        } else if (sender == genderTxtField) {
            genderTapped()
        }
        else if (sender == instTxtField) {
            intitutoTapped()
        }
    }
    
    func myLableTapped(sender: MyLabel) {
        
        //        var isViewProperShutDown = true
        if(sender == goSignInLbl){
            if(isFromAppLogin){
                let signInUv = GeneralFunctions.instantiateViewController(pageName: "SignInUV") as! SignInUV
                signInUv.isFromAppLogin = false
                self.pushToNavController(uv: signInUv)
            }else{
                self.closeCurrentScreen()
            }
        }
        else if(sender == termsLbl)
        {
            let supportUv = GeneralFunctions.instantiateViewController(pageName: "SupportUV") as! SupportUV
            supportUv.isOnlyPrivacyAndTerms = true
            self.pushToNavController(uv: supportUv)
        }
    }
    
    func myBtnTapped(sender: MyButton) {
        if(sender == self.registerBtn){
            checkData()
        }
    }
    
    func checkData(){
        let noWhiteSpace = generalFunc.getLanguageLabel(origValue: "Password should not contain whitespace.", key: "LBL_ERROR_NO_SPACE_IN_PASS");
        let pass_length = "\(generalFunc.getLanguageLabel(origValue: "Password must be", key: "LBL_ERROR_PASS_LENGTH_PREFIX")) \(Utils.minPasswordLength) \(generalFunc.getLanguageLabel(origValue: "or more character long.",key: "LBL_ERROR_PASS_LENGTH_SUFFIX"))"
        let mobileInvalid = generalFunc.getLanguageLabel(origValue: "Invalid mobile no.", key: "LBL_INVALID_MOBILE_NO")
        
        let fNameEntered = Utils.checkText(textField: self.fNameTxtField.getTextField()!) ? true : Utils.setErrorFields(textField: self.fNameTxtField.getTextField()!, error: required_str)
        fNameTxtField.getTextField()?.isErrorRevealed = fNameEntered
        let lNameEntered = Utils.checkText(textField: self.lNameTxtField.getTextField()!) ? true : Utils.setErrorFields(textField: self.lNameTxtField.getTextField()!, error: required_str)
        lNameTxtField.getTextField()?.isErrorRevealed = lNameEntered
        let emailEntered = Utils.checkText(textField: self.emailTxtField.getTextField()!) ? (GeneralFunctions.isValidEmail(testStr: Utils.getText(textField: self.emailTxtField.getTextField()!)) ? true : Utils.setErrorFields(textField: self.emailTxtField.getTextField()!, error: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FEILD_EMAIL_ERROR_TXT"))) : Utils.setErrorFields(textField: self.emailTxtField.getTextField()!, error: required_str)
        emailTxtField.getTextField()?.isErrorRevealed = emailEntered
        let cpfEntered = Utils.checkText(textField: self.cpfTxtField.getTextField()!) ?
            (self.cpfTxtField.text.isValidCPF ? true: Utils.setErrorFields(textField:
                self.cpfTxtField.getTextField()!, error: required_str)) : Utils.setErrorFields(textField: self.cpfTxtField.getTextField()!, error: required_str)
        cpfTxtField.getTextField()?.isErrorRevealed = cpfEntered
        let mobileEntered = Utils.checkText(textField: self.mobileNumTxtField.getTextField()!) ? (Utils.getText(textField: self.mobileNumTxtField.getTextField()!).count >= Utils.minMobileLength ? true : Utils.setErrorFields(textField: self.mobileNumTxtField.getTextField()!, error: mobileInvalid)) : Utils.setErrorFields(textField: self.mobileNumTxtField.getTextField()!, error: required_str)
        mobileNumTxtField.getTextField()?.isErrorRevealed = mobileEntered
        let passwordEntered = Utils.checkText(textField: self.passwordTxtField.getTextField()!) ? (Utils.getText(textField: self.passwordTxtField.getTextField()!).contains(" ") ? Utils.setErrorFields(textField: self.passwordTxtField.getTextField()!, error: noWhiteSpace) : (Utils.getText(textField: self.passwordTxtField.getTextField()!).count >= Utils.minPasswordLength ? true : Utils.setErrorFields(textField: self.passwordTxtField.getTextField()!, error: pass_length))) : Utils.setErrorFields(textField: self.passwordTxtField.getTextField()!, error: required_str)
        passwordTxtField.getTextField()?.isErrorRevealed = passwordEntered
        let countryEntered = isCountrySelected ? true : Utils.setErrorFields(textField: self.countryTxtField.getTextField()!, error: required_str)
        countryTxtField.getTextField()?.isErrorRevealed = countryEntered
        
        let genderEntered = (genderType != GenderType.NotSelected) ? true : Utils.setErrorFields(textField: self.genderTxtField.getTextField()!, error: required_str)
        countryTxtField.getTextField()?.isErrorRevealed = genderEntered
        
        
        
        let numRegEntered = Utils.checkText(textField: self.numRegisterTxtField.getTextField()!) ? true : false
        let inviteCodeEntered = Utils.checkText(textField: self.inviteTxtField.getTextField()!) ? true : false
        
        if (profileImageSelected == nil) {
            self.generalFunc.setError(uv: self, title: "", content: "Por favor selecione uma imagem para seu cadastro.")
            return;
        }
        if ((!inviteCodeEntered && !numRegEntered)) {
            self.generalFunc.setError(uv: self, title: "", content: "Informe o seu numero de registro ou codigo de indicacao")
            return;
        }
        
        if (!genderEntered) {
            self.generalFunc.setError(uv: self, title: "", content: "Por favor selecione o gênero.")
            return;
        }
        
        if (fNameEntered == false || lNameEntered == false || emailEntered == false || cpfEntered == false
            || mobileEntered == false || countryEntered == false || passwordEntered == false || genderEntered == false) {
            return;
        }
        
        if (termsCheckBox.on == false){
            self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "Please accept our Terms & Condition and Privacy Policy", key: "LBL_ACCEPT_TERMS_PRIVACY_ALERT"))
            return;
        }
        
        if(GeneralFunctions.getValue(key: Utils.MOBILE_VERIFICATION_ENABLE_KEY) != nil && (GeneralFunctions.getValue(key: Utils.MOBILE_VERIFICATION_ENABLE_KEY) as! String).uppercased() == "YES"){
            checkUserExist()
        }else{
            registerUser()
        }
    }
    
    func checkUserExist(){
        let parameters = ["type":"isUserExist","Email": Utils.getText(textField: self.emailTxtField.getTextField()!), "Phone": Utils.getText(textField: self.mobileNumTxtField.getTextField()!), "PhoneCode": self.selectedPhoneCode]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: false)
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    
                    //                    LBL_CANCEL_TXT
                    DispatchQueue.main.async() {
                        self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_VERIFY_MOBILE_CONFIRM_MSG"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "OK", key: "LBL_BTN_OK_TXT"), nagativeBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCEL_TXT"), completionHandler: { (btnClickedId) in
                            
                            if(btnClickedId == 0){
                                let accountVerificationUv = GeneralFunctions.instantiateViewController(pageName: "AccountVerificationUV") as! AccountVerificationUV
                                accountVerificationUv.mobileNum = self.selectedPhoneCode + Utils.getText(textField: self.mobileNumTxtField.getTextField()!)
                                accountVerificationUv.isSignUpPage = true
                                accountVerificationUv.requestType = "DO_PHONE_VERIFY"
                                self.pushToNavController(uv: accountVerificationUv)
                            }
                        })
                    }
                }else{
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
        })
    }
    
    func getInstitutionList(){
        let parameters = ["type": "getInstitutionList"]
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: true)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                print(dataDict)
                if(dataDict.get("Action") == "1"){
                   
                    
                }else{
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
        })
    }
    
    func registerUser(){
        let userSelectedCurrency = GeneralFunctions.getValue(key: Utils.DEFAULT_CURRENCY_TITLE_KEY) as! String
        let userSelectedLanguage = GeneralFunctions.getValue(key: Utils.LANGUAGE_CODE_KEY) as! String
        
        let parameters = ["type":"signup","vFirstName": Utils.getText(textField: self.fNameTxtField.getTextField()!), "vLastName": Utils.getText(textField: self.lNameTxtField.getTextField()!), "vEmail": Utils.getText(textField: self.emailTxtField.getTextField()!), "vDoc": Utils.getText(textField: self.cpfTxtField.getTextField()!),"vPhone": Utils.getText(textField: self.mobileNumTxtField.getTextField()!), "vPassword": Utils.getText(textField: self.passwordTxtField.getTextField()!), "PhoneCode": self.selectedPhoneCode, "CountryCode": self.selectedCountryCode, "vDeviceType": Utils.deviceType, "vInviteCode": Utils.getText(textField: self.inviteTxtField.getTextField()!), "vCurrency": userSelectedCurrency, "vLang": userSelectedLanguage, "eGender": genderType.getGenderType(),
            "iInstitutionId": String(institutionIdType.getnstitutionIdType()),"vRegisterNumber": Utils.getText(textField: self.numRegisterTxtField.getTextField()!)]
        print(parameters)
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: true)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                print(dataDict)
                if(dataDict.get("Action") == "1"){
                    _ = SetUserData(uv: self, userProfileJson: dataDict, isStoreUserId: true)
                    
                    let userProfileJson = dataDict.getObj(Utils.message_str)
                    let sessionId = userProfileJson.get("tSessionId")
                    
                    //Salva a imagem localmente para
                    let imageData = self.profileImageSelected?.pngData()
                    GeneralFunctions.saveValue(key: Utils.USER_IMAGE_KEY, value: imageData as AnyObject)
                    GeneralFunctions.saveValue(key: Utils.SESSION_ID_KEY, value: sessionId as AnyObject)
                    
                    //Faz o upload da imagem selecionada pelo usuario
                    self.openImgSelection.myImageUploadRequest(image: self.profileImageSelected!)
                    
                    let window = UIApplication.shared.delegate!.window!
                    _ = OpenMainProfile(uv: self, userProfileJson: response, window: window!)
                    
                }else{
                    if(dataDict.get("message") == "LBL_CONTACT_US_STATUS_NOTACTIVE_PASSENGER"){
                        self.generalFunc.setError2(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                    }else{
                        self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                    }
                    
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
        })
    }
    
    @IBAction func unwindToSignUp(_ segue:UIStoryboardSegue) {
        
        if(segue.source .isKind(of: CountryListUV.self)){
            
            let sourceViewController = segue.source as? CountryListUV
            let selectedPhoneCode:String = sourceViewController!.selectedCountryHolder!.vPhoneCode
            let selectedCountryCode = sourceViewController!.selectedCountryHolder!.vCountryCode
            
            self.selectedCountryCode = selectedCountryCode
            self.selectedPhoneCode = selectedPhoneCode
            
            self.countryTxtField.setText(text: "+\(selectedPhoneCode)")
            
            self.isCountrySelected = true
            self.countryTxtField.getTextField()!.sendActions(for: .editingChanged)
        }else if(segue.source.isKind(of: AccountVerificationUV.self)){
            let accountVerificationUv = segue.source as! AccountVerificationUV
            
            if(accountVerificationUv.mobileNumVerified == true){
                registerUser()
            }
        }
        
    }
}
