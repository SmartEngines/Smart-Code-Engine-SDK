/*
  Copyright (c) 2016-2025, Smart Engines Service LLC
  All rights reserved.
*/

import UIKit

protocol SampleSmartCodeViewControllerProtocol : class {
  func setModeAndDocumentTypeMask(mode: String, docTypeMask: String)
}

class SampleViewController: UIViewController,
                            UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate,
                            SampleSmartCodeViewControllerProtocol,
                            SmartCodeEngineInitializationDelegate {
  var currentDocumenttypeMask : String?
  
  func setModeAndDocumentTypeMask(mode: String, docTypeMask: String) {
    self.currentDocumenttypeMask = docTypeMask
    
    smartCodeController.configureDocumentTypeLabel(self.currentDocumenttypeMask!)
    print("Current doc type mask is \(docTypeMask)")
    initSessionSettings()
  }
  
  func initSessionSettings() {
    smartCodeController.setRoiWithOffsetX(0.0, andY: 0.0, orientation: UIDeviceOrientation.portrait, displayRoi: false)
    smartCodeController.shouldDisplayRoi = false
    
    self.engineInstance.resetSessionSettings()
    
    smartCodeController.sessionSettings().setOptionWithName("global.enableMultiThreading", to: "true")
    smartCodeController.sessionSettings().setOptionWithName("global.sessionTimeout", to: "5.0")
    
    if currentDocumenttypeMask == nil {
      return
    }
    
    if currentDocumenttypeMask == "barcode" {
      if (galleryModeFlag) {
        smartCodeController.sessionSettings().setOptionWithName("barcode.roiDetectionMode", to: "anywhere")
      } else {
        smartCodeController.sessionSettings().setOptionWithName("barcode.roiDetectionMode", to: "focused")
      }
      smartCodeController.sessionSettings().setOptionWithName("barcode.enabled", to: "true")
      smartCodeController.sessionSettings().setOptionWithName("barcode.COMMON.enabled", to: "true")
      smartCodeController.sessionSettings().setOptionWithName("barcode.maxAllowedCodes", to: "5")
    }
    
    if currentDocumenttypeMask == "barcode_session" {
      if (galleryModeFlag) {
        smartCodeController.sessionSettings().setOptionWithName("barcode.roiDetectionMode", to: "anywhere")
      } else {
        smartCodeController.sessionSettings().setOptionWithName("barcode.roiDetectionMode", to: "focused")
      }
      smartCodeController.sessionSettings().setOptionWithName("barcode.enabled", to: "true")
      smartCodeController.sessionSettings().setOptionWithName("barcode.COMMON.enabled", to: "true")
      smartCodeController.sessionSettings().setOptionWithName("barcode.maxAllowedCodes", to: "50")
      smartCodeController.sessionSettings().setOptionWithName("global.sessionTimeout", to: "0.0")
      smartCodeController.sessionSettings().setOptionWithName("barcode.feedMode", to: "sequence")
    }
    
    if currentDocumenttypeMask == "bank_card" {
      smartCodeController.sessionSettings().setOptionWithName("bank_card.enabled", to: "true")
    }
    
    if (currentDocumenttypeMask!.contains("code_text_line")) {
      smartCodeController.sessionSettings().setOptionWithName("code_text_line.enabled", to: "true")
      smartCodeController.sessionSettings().setOptionWithName(currentDocumenttypeMask! + ".enabled", to: "true")
      
      smartCodeController.shouldDisplayRoi = true
      smartCodeController.setRoiWithOffsetX(0.0, andY: 0.5, orientation: UIDeviceOrientation.portrait, displayRoi: true)
    }
    
    
    if currentDocumenttypeMask == "mrz" {
      smartCodeController.sessionSettings().setOptionWithName(currentDocumenttypeMask! + ".enabled", to: "true")
    }
    
    if currentDocumenttypeMask == "payment_details" {
      smartCodeController.sessionSettings().setOptionWithName(currentDocumenttypeMask! + ".enabled", to: "true")
      
      smartCodeController.shouldDisplayRoi = true
      smartCodeController.setRoiWithOffsetX(0.0, andY: 0.5, orientation: UIDeviceOrientation.portrait, displayRoi: true)
    }
  }
  
  // Selfie-related
  
  var currentPhotoImage : SECommonImage? = nil;
  
  func reinitSelfieButton() {
    self.selfieButton.isEnabled = false
    self.selfieButton.isHidden = true
    self.currentPhotoImage = nil;
  }
  
  let selfieImagePicker : UIImagePickerController = {
    let picker = UIImagePickerController()
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
      picker.sourceType = UIImagePickerController.SourceType.camera
      picker.modalPresentationStyle = .fullScreen
      picker.cameraFlashMode = .off
      picker.cameraDevice = .front
      picker.cameraCaptureMode = .photo
    }
    return picker
  }()
  
  // View-related
    
  var galleryModeFlag = false // flag if recognize only one picture from Gallery
  
  var pickerImageActivityIndicator:UIActivityIndicatorView!
  var pickerImageActivityIndicatorContainer:UIView!
  var pickerIAIContainerBackground:UIView!
  
  var docTypeListViewController : DocTypesListController!
    
  var resultTableView : UITableView = {
    var resultTableView = UITableView()
    resultTableView.register(TextFieldCell.self, forCellReuseIdentifier: "TextCell")
    resultTableView.register(ImageViewCell.self, forCellReuseIdentifier: "ImageCell")
    resultTableView.estimatedRowHeight = 100
    resultTableView.translatesAutoresizingMaskIntoConstraints = false
    return resultTableView
  }()
    
  func setTableViewAnchors() {
    if #available(iOS 11.0, *) {
      resultTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
      resultTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
      resultTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
      resultTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
    } else {
      resultTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
      resultTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
      resultTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
      resultTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
    }
    resultTableView.estimatedRowHeight = 600
    resultTableView.allowsSelection = false
  }
    
  private var resultTextFields = [(fieldName: String, value: String)]()
    
  func setResult(result: SECodeEngineResultRef) {
    resultTextFields.removeAll()
    
    let code_object_it = result.objectsBegin()
    
    while !code_object_it.isEqual(toIter: result.objectsEnd()) {
      let code_object = code_object_it.getValue()
      
      var value = code_object.getTypeStr()
      
      var fields: [String: SECodeFieldRef] = [:]
      let code_object_fields = code_object.fieldsBegin()
      
      while !code_object_fields.isEqual(toIter: code_object.fieldsEnd()) {
        let code_field = code_object_fields.getValue()
        fields[code_object_fields.getKey()] = code_field
        code_object_fields.advance()
        
        if code_field.hasOcrStringRepresentation(){
          value = code_field.getOcrString().getFirstString()
        } else {
          value = code_field.getBinaryRepresentation().getBase64String()
        }
        resultTextFields.append((code_field.name(), value))
      }
      
      code_object_it.advance()
      
    }

    
    resultTextFields.sort(by: {
        return $0.0 < $1.0
    })
  }
    
  let cameraButton: UIButton = {
    let button = UIButton(type: .roundedRect)
    button.autoresizingMask = .flexibleWidth
    button.setTitle("...", for: .normal)
    button.isEnabled = false
    button.layer.borderColor = UIColor.blue.cgColor
    return button
  }()
    
  let galleryButton: UIButton = {
    let button = UIButton(type: .roundedRect)
    button.autoresizingMask = .flexibleWidth
    button.setTitle("initializing ...", for: .normal)
    button.isEnabled = false
    button.layer.borderColor = UIColor.blue.cgColor
    return button
  }()
    
  let documentListButton: UIButton = {
    let button = UIButton(type: .roundedRect)
    button.autoresizingMask = .flexibleWidth
    button.setTitle("...", for: .normal)
    button.isEnabled = false
    button.layer.borderColor = UIColor.blue.cgColor
    return button
  }()
    
  let selfieButton : UIButton = {
    let button = UIButton(type: .roundedRect)
    button.autoresizingMask = .flexibleWidth
    button.setTitle("Compare with selfie", for: .normal)
    button.isEnabled = false
    button.isHidden = true
    button.layer.borderColor = UIColor.blue.cgColor
    return button
  }()
  
  let resultTextView: UITextView = {
    let view = UITextView()
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.isEditable = false
    view.font = UIFont(name: "Menlo-Regular", size: 12)
    return view
  }()
    
  let resultImageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFit
    view.backgroundColor = UIColor(white: 0.9, alpha: 0.5)
    return view
  }()
  
  let photoLibraryImagePicker : UIImagePickerController = {
    let picker = UIImagePickerController()
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
      picker.sourceType = .photoLibrary
      picker.modalPresentationStyle = .fullScreen
    }
    return picker
  }()
  
  let engineInstance : SmartCodeEngineInstance = {
    let signature = "Place your signature here (see doc\README.html)"
    return SmartCodeEngineInstance(signature: signature)
  }()
  
  func smartCodeEngineInitialized() {
    self.galleryButton.setTitle("Gallery", for: .normal)
    self.cameraButton.setTitle("Camera", for: .normal)
    self.documentListButton.setTitle("Select type", for: .normal)
    
    self.galleryButton.isEnabled = true
    self.cameraButton.isEnabled = true
    self.documentListButton.isEnabled = true
    
    self.smartCodeController.attach(self.engineInstance)
    self.configureSessionOptions() // calling _after_ attaching engine instance
  }
  
  let smartCodeController: SmartCodeViewController = {
    let smartCodeController = SmartCodeViewController(lockedOrientation: false, withTorch: false, withBestDevice: true)
    smartCodeController.modalPresentationStyle = .fullScreen
    smartCodeController.captureButtonDelegate = smartCodeController
    
    // configure optional visualization properties (they are NO by default)
    smartCodeController.displayZonesQuadrangles = true
    smartCodeController.displayDocumentQuadrangle = true
    smartCodeController.displayProcessingFeedback = true
    
    return smartCodeController
  }()
    
  override func viewDidLayoutSubviews() {
    let bottomSafeArea: CGFloat
    let topSafeArea: CGFloat
    
    // safe area for phones with notch
    
    if #available(iOS 11.0, *) {
      bottomSafeArea = view.safeAreaInsets.bottom
      topSafeArea = view.safeAreaInsets.top
    } else {
      bottomSafeArea = bottomLayoutGuide.length
      topSafeArea = topLayoutGuide.length
    }
    
    let buttonHeight: CGFloat = 50
    
    cameraButton.frame = CGRect(x: 0,
                                y: view.bounds.size.height - bottomSafeArea - buttonHeight,
                                width: view.bounds.size.width/3,
                                height: buttonHeight)
    
    galleryButton.frame = CGRect(x: view.bounds.size.width/3,
                                 y: view.bounds.size.height - bottomSafeArea - buttonHeight,
                                 width: view.bounds.size.width/3,
                                 height: buttonHeight)
    
    documentListButton.frame = CGRect(x: view.bounds.size.width*2/3,
                                      y: view.bounds.size.height - bottomSafeArea - buttonHeight,
                                      width: view.bounds.size.width/3,
                                      height: buttonHeight)
    
    selfieButton.frame = CGRect(x: view.bounds.size.width/2,
                                y: topSafeArea,
                                width: view.bounds.size.width/2,
                                height: buttonHeight)
  }
    
  func configureSessionOptions() {
    // you can set mode and document mask here, if you are not using document types table,
    // or other options such as time out or extracting template images
    smartCodeController.sessionSettings().setOptionWithName("global.sessionTimeout", to: "5.0")
    
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    smartCodeController.smartCodeDelegate = self
    
    if #available(iOS 13.0, *) {
      self.view.backgroundColor = .systemBackground
    } else {
      self.view.backgroundColor = .white
    }
    
    view.addSubview(resultTableView)
    setTableViewAnchors()
    resultTableView.delegate = self
    resultTableView.dataSource = self
    
    view.addSubview(cameraButton)
    view.addSubview(galleryButton)
    view.addSubview(documentListButton)
    
    cameraButton.addTarget(
        self, action:#selector(showSmartCodeViewController), for: .touchUpInside)
    galleryButton.addTarget(
        self, action: #selector(showGalleryImagePickerToProcessImage), for: .touchUpInside)
    documentListButton.addTarget(
        self, action: #selector(showDocumenttypeList), for: .touchUpInside)
    
    setupImagePickerActivityBackground()
    
    self.engineInstance.setInitializationDelegate(self)
    
    DispatchQueue.main.async {
      
      self.engineInstance.initializeEngine()
      var docTypesList = [String:[String]]()
      
      let scipSettings = ["global"]
      var masks = [String]()
      var engines = Set<String>()
      
      let settings_it = self.smartCodeController.sessionSettings().settingsBegin()
      while !settings_it.isEqual(toIter: self.smartCodeController.sessionSettings().settingsEnd()) {
        var mask = settings_it.getKey().components(separatedBy: ".")[0] // get "type" from "type.smth.enabled" setting
        if !scipSettings.contains(mask) {
          if !engines.contains(mask) && (settings_it.getKey().components(separatedBy: ".").count == 3 || mask == "mrz"){
            print(mask)
            if mask == "code_text_line"{
              let doctype : String = settings_it.getKey().components(separatedBy: ".")[1]
              mask = mask + "." + doctype
            }
            if mask == "barcode" {
              masks.append("barcode_session")
            }
            masks.append(mask)
            engines.insert(mask)
           
          }
        }
        settings_it.advance()
      }
      docTypesList["default"] = masks
      
      if (docTypesList["default"]!.count == 1) {
        self.setModeAndDocumentTypeMask(
            mode: "default",
            docTypeMask: docTypesList["default"]![0])
      }
      
      self.docTypeListViewController = DocTypesListController(docTypesList: docTypesList)
      self.docTypeListViewController.delegateSampSID = self
    }
  }
    
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
    
   
  func showAlert(msg: String) {
    let alert = UIAlertController(title: "Warning", message: msg, preferredStyle: .alert)
    alert.addAction(UIAlertAction(
        title: NSLocalizedString("OK", comment: "Default action"),
        style: .default,
        handler: { _ in
      NSLog("The \"OK\" alert occured.")
    }))
    self.present(alert, animated: true, completion: nil)
  }
    
  @objc func showGalleryImagePickerToProcessImage() {
    if currentDocumenttypeMask != nil {
      galleryModeFlag = true
      initSessionSettings()
      self.photoLibraryImagePicker.delegate = self
      DispatchQueue.main.async {
        self.pickerIAIContainerBackground.isHidden = true
        self.pickerImageActivityIndicatorContainer.isHidden = true
      }
      
      self.present(self.photoLibraryImagePicker, animated: true, completion: nil)
    } else {
      showAlert(msg: "Select document type")
    }
    self.reinitSelfieButton()
  }
    
  @objc func showSmartCodeViewController() {
    if currentDocumenttypeMask != nil {
      galleryModeFlag = false
      initSessionSettings()
      present(smartCodeController, animated: true, completion: {
        print("sample: smartCodeViewController presented")
      })
    } else {
      showAlert(msg: "Select document type")
    }
    self.reinitSelfieButton()
  }
    
  @objc func showDocumenttypeList() {
    present(docTypeListViewController, animated: true, completion: nil)
  }
}

// MARK: SEResultTableView

extension SampleViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return resultTextFields.count
  }
    
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = resultTableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextFieldCell
    cell.fieldName.text = resultTextFields[indexPath.row].fieldName
    cell.resultTextView.text = resultTextFields[indexPath.row].value
    return cell
    
  }
    
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}

extension SampleViewController {
    
  func pickImageByUIImage(image: UIImage) {
    self.setupImagePickerActivity()
    self.pickerImageActivityIndicator.startAnimating()
    DispatchQueue.main.async { [weak self] in
      self?.smartCodeController.processUIImage(image)
      self?.pickerImageActivityIndicator.stopAnimating()
    }
  }

    
  func initImagePickerActivityContainer() -> UIView {
    let activityWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)/5
    let activityContainer = UIView()
    activityContainer.backgroundColor = .black
    activityContainer.alpha = 0.8
    activityContainer.layer.cornerRadius = 10
    
    self.photoLibraryImagePicker.view.addSubview(activityContainer)
    
    activityContainer.translatesAutoresizingMaskIntoConstraints = false
    activityContainer.centerXAnchor.constraint(equalTo: self.photoLibraryImagePicker.view.centerXAnchor).isActive = true
    activityContainer.centerYAnchor.constraint(equalTo: self.photoLibraryImagePicker.view.centerYAnchor).isActive = true
    activityContainer.widthAnchor.constraint(equalToConstant: activityWidth).isActive = true
    activityContainer.heightAnchor.constraint(equalToConstant: activityWidth).isActive = true
    activityContainer.isHidden = true
    
    return activityContainer
  }
  
  func initImagePickerContainerBackground() {
    self.pickerIAIContainerBackground = UIView()
    self.pickerIAIContainerBackground.alpha = 0.2
    self.pickerIAIContainerBackground.backgroundColor = .gray
    self.pickerIAIContainerBackground.isUserInteractionEnabled = false
    self.pickerIAIContainerBackground.isHidden = true
    
    self.photoLibraryImagePicker.view.addSubview(self.pickerIAIContainerBackground)
    
    self.pickerIAIContainerBackground.translatesAutoresizingMaskIntoConstraints = false
    self.pickerIAIContainerBackground.centerXAnchor.constraint(equalTo: self.photoLibraryImagePicker.view.centerXAnchor).isActive = true
    self.pickerIAIContainerBackground.centerYAnchor.constraint(equalTo: self.photoLibraryImagePicker.view.centerYAnchor).isActive = true
    
    self.pickerIAIContainerBackground.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
    self.pickerIAIContainerBackground.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
  }
  
  func addImagePickerActivityToContainer() {
    self.pickerImageActivityIndicator = UIActivityIndicatorView()
    self.pickerImageActivityIndicator.style = .whiteLarge
    self.pickerImageActivityIndicator.color = .red
    self.pickerImageActivityIndicatorContainer.addSubview(self.pickerImageActivityIndicator)
    self.pickerImageActivityIndicatorContainer.center  = self.pickerImageActivityIndicator.center
    self.pickerImageActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
    self.pickerImageActivityIndicator.centerXAnchor.constraint(equalTo: self.pickerImageActivityIndicatorContainer.centerXAnchor).isActive = true
    self.pickerImageActivityIndicator.centerYAnchor.constraint(equalTo: self.pickerImageActivityIndicatorContainer.centerYAnchor).isActive = true
  }
  
  func setupImagePickerActivityBackground() {
    initImagePickerContainerBackground()
    self.pickerImageActivityIndicatorContainer = initImagePickerActivityContainer()
    self.addImagePickerActivityToContainer()
  }
  
  func setupImagePickerActivity() {
    self.pickerIAIContainerBackground.isHidden = false
    self.pickerImageActivityIndicatorContainer.isHidden = false
    self.pickerImageActivityIndicator.isHidden = false
  }
    
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if picker == self.photoLibraryImagePicker {
      pickImageByUIImage(image: info[.originalImage] as! UIImage)
    } else {
      // noop
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.resultTextView.text = "Recognition cancelled by user!"
    self.resultImageView.image = nil
    self.dismiss(animated: true, completion: nil)
  }
}

extension SampleViewController: SmartCodeViewControllerDelegate {
  func smartCodeViewControllerDidRecognize(_ result: SECodeEngineResult, from buffer: CMSampleBuffer?, processTime: TimeInterval) {
    let resultRef = result.getRef()
    if resultRef.isTerminal() {
      self.setResult(result: resultRef)
      resultTableView.reloadData()
      dismiss(animated: true, completion: nil)
    }
  }
  
  func smartCodeViewControllerDidRecognizeSingleImage(_ result: SECodeEngineResult) {
    self.setResult(result: result.getRef())
    resultTableView.reloadData()
    dismiss(animated: true, completion: nil)
  }
  
  func smartCodeViewControllerDidCancel() {
    resultTextView.text = "Recognition cancelled by user!"
    resultImageView.image = nil
    dismiss(animated: true, completion: nil)
  }
  
  func smartCodeViewControllerDidStop(_ result: SECodeEngineResult, processTime: TimeInterval) {
    self.setResult(result: result.getRef())
    resultTableView.reloadData()
    dismiss(animated: true, completion: nil)
  }
}
