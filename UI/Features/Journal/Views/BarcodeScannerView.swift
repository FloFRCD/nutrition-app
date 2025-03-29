//
//  BarreCodeScannerView.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 29/03/2025.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

struct BarcodeScannerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var journalViewModel: JournalViewModel
    
    let mealType: MealType
    
    @State private var isScanning = false
    @State private var selectedProduct: OpenFoodFactsProduct?
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        ZStack {
            if isScanning {
                BarcodeScannerRepresentable(
                    isScanning: $isScanning,
                    scannedCode: { code in
                        searchProduct(barcode: code)
                    }
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    Text("Positionnez le code-barres dans le cadre")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                    Spacer().frame(height: 100)
                }
            } else {
                VStack(spacing: 30) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Scanner un code-barres")
                        .font(.title)
                    
                    Text("Positionnez le code-barres d'un produit devant la caméra pour obtenir ses informations nutritionnelles")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Commencer le scan") {
                        isScanning = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 20)
                }
                .padding()
            }
        }
        .navigationTitle("Scanner un produit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
        }
        .alert(isPresented: $showingError) {
            Alert(
                title: Text("Erreur"),
                message: Text(errorMessage ?? "Une erreur est survenue"),
                dismissButton: .default(Text("OK"))
            )
        }

        // Utilisez
        .sheet(item: $selectedProduct) { product in
            BarcodeProductView(
                product: product,
                mealType: mealType,
                onAdd: { foodEntry in
                    journalViewModel.addFoodEntry(foodEntry)
                    selectedProduct = nil  // Ferme la sheet
                }
            )
            .environmentObject(journalViewModel)
        }
    }
    
    private func searchProduct(barcode: String) {
          print("🔍 Recherche du produit avec code: \(barcode)")
          isScanning = false
          
          OpenFoodFactsService().getProduct(barcode: barcode)
              .receive(on: DispatchQueue.main)
              .sink(
                  receiveCompletion: { completion in
                      print("⚙️ Completion reçue: \(completion)")
                      switch completion {
                      case .finished:
                          print("✅ Requête terminée avec succès")
                      case .failure(let error):
                          print("❌ Erreur: \(error.localizedDescription)")
                          self.errorMessage = "Impossible de trouver le produit: \(error.localizedDescription)"
                          self.showingError = true
                          // Permettre un nouveau scan après une erreur
                          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                              self.isScanning = true
                          }
                      }
                  },
                  receiveValue: { product in
                      print("📦 Produit reçu: \(product.product.productName ?? "Nom inconnu")")
                          
                          // Créez une copie validée du produit
                          let validatedProduct = OpenFoodFactsProduct(
                              code: product.code,
                              product: OpenFoodFactsProduct.ProductDetails(
                                  productName: product.product.productName,
                                  nutriments: product.product.nutriments ?? OpenFoodFactsProduct.Nutriments(
                                      energyKcal100g: 0,
                                      proteins100g: 0,
                                      carbohydrates100g: 0,
                                      fat100g: 0,
                                      fiber100g: 0
                                  ),
                                  ingredients: product.product.ingredients
                              )
                          )
                          
                          print("🔄 Produit validé: \(validatedProduct.product.productName ?? "nil")")
                          
                          // Assignez directement à selectedProduct
                          DispatchQueue.main.async {
                              self.selectedProduct = validatedProduct
                              print("🎯 Product défini avant affichage: \(self.selectedProduct?.code ?? "nil")")
                          }                  }
              )
              .store(in: &cancellables)  // Stockez l'abonnement ici
      }
}

// Représentable pour la caméra et la détection de code-barres
struct BarcodeScannerRepresentable: UIViewControllerRepresentable {
    @Binding var isScanning: Bool
    var scannedCode: (String) -> Void
    
    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
        // Mise à jour si nécessaire
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, BarcodeScannerViewControllerDelegate {
        var parent: BarcodeScannerRepresentable
        
        init(_ parent: BarcodeScannerRepresentable) {
            self.parent = parent
        }
        
        func didScanCode(_ code: String) {
            parent.scannedCode(code)
        }
    }
}

// Classe UIViewController pour la caméra
protocol BarcodeScannerViewControllerDelegate: AnyObject {
    func didScanCode(_ code: String)
}

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: BarcodeScannerViewControllerDelegate?
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Ajouter un cadre de visée
        let scanArea = UIView()
        scanArea.layer.borderColor = UIColor.green.cgColor
        scanArea.layer.borderWidth = 2
        scanArea.frame = CGRect(x: view.bounds.width / 2 - 100, y: view.bounds.height / 2 - 50, width: 200, height: 100)
        view.addSubview(scanArea)
        
        // Définir la zone d'intérêt pour la détection de code-barres
        let rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: scanArea.frame)
        metadataOutput.rectOfInterest = rectOfInterest
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            // Feedback haptique
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Arrêter la session pour éviter les scans multiples
            captureSession.stopRunning()
            
            // Appeler le délégué
            delegate?.didScanCode(stringValue)
        }
    }
}
