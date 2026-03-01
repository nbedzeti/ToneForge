//
//  PurchaseView.swift
//  RingToneMaker
//
//  Created on 1/18/26.
//

import SwiftUI
import StoreKit

struct PurchaseView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var purchaseManager: PurchaseManager
    
    @State private var selectedProductID: String?
    @State private var showingError = false
    @State private var isPurchasing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Free tier status
                        if !purchaseManager.isPremium {
                            freeStatusSection
                        }
                        
                        // Products
                        if purchaseManager.products.isEmpty {
                            loadingSection
                        } else {
                            productsSection
                        }
                        
                        // Features
                        featuresSection
                        
                        // Restore purchases
                        restoreButton
                        
                        // Legal
                        legalSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Upgrade to Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.green)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                if let error = purchaseManager.errorMessage {
                    Text(error)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Unlock Unlimited Ringtones")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .multilineTextAlignment(.center)
            
            Text("Create as many custom ringtones as you want with no ads")
                .font(.subheadline)
                .foregroundColor(.green.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }
    
    // MARK: - Free Status Section
    
    private var freeStatusSection: some View {
        VStack(spacing: 12) {
            if purchaseManager.remainingFreeCreations > 0 {
                HStack {
                    Image(systemName: "gift.fill")
                        .foregroundColor(.blue)
                    Text("\(purchaseManager.remainingFreeCreations) free ringtones remaining")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Show upgrade message when free tier is used
            if !purchaseManager.isPremium && purchaseManager.remainingFreeCreations == 0 {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        Text("Free tier used")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Text("Upgrade to Premium for unlimited ringtones")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Products Section
    
    private var productsSection: some View {
        VStack(spacing: 16) {
            ForEach(purchaseManager.products, id: \.id) { product in
                ProductCard(
                    product: product,
                    isSelected: selectedProductID == product.id,
                    isPurchasing: isPurchasing,
                    badge: badgeText(for: product),
                    savings: savingsText(for: product)
                ) {
                    selectedProductID = product.id
                    Task {
                        await purchaseProduct(product)
                    }
                }
            }
        }
    }
    
    // MARK: - Features Section
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Premium Features")
                .font(.headline)
                .foregroundColor(.green)
            
            FeatureRow(icon: "infinity", title: "Unlimited Ringtones", description: "Create as many as you want")
            FeatureRow(icon: "sparkles", title: "All Premium Effects", description: "Fade, reverb, EQ, and more")
            FeatureRow(icon: "waveform", title: "Audio Normalization", description: "Perfect volume levels")
            FeatureRow(icon: "heart.fill", title: "Support Development", description: "Help us build more great features")
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
    
    // MARK: - Restore Button
    
    private var restoreButton: some View {
        Button(action: {
            Task {
                await purchaseManager.restorePurchases()
                if purchaseManager.isPremium {
                    dismiss()
                }
            }
        }) {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundColor(.green)
        }
        .disabled(purchaseManager.isLoading)
    }
    
    // MARK: - Legal Section
    
    private var legalSection: some View {
        VStack(spacing: 12) {
            // Subscription terms
            VStack(spacing: 8) {
                Text("Subscription Information")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Text("• Premium Monthly: $4.99/month, auto-renews monthly")
                    .font(.caption2)
                    .foregroundColor(.green.opacity(0.7))
                
                Text("• Premium Yearly: $29.99/year, auto-renews yearly")
                    .font(.caption2)
                    .foregroundColor(.green.opacity(0.7))
                
                Text("• Premium Lifetime: $49.99 one-time payment")
                    .font(.caption2)
                    .foregroundColor(.green.opacity(0.7))
            }
            .multilineTextAlignment(.center)
            .padding(.vertical, 8)
            
            Text("Payment will be charged to your Apple ID at confirmation of purchase. Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period. Manage subscriptions in Settings → [Your Name] → Subscriptions.")
                .font(.caption2)
                .foregroundColor(.green.opacity(0.5))
                .multilineTextAlignment(.center)
            
            // Legal links
            HStack(spacing: 16) {
                Link("Privacy Policy", destination: URL(string: "https://nbedzeti.github.io/ToneForge/privacy.html")!)
                    .font(.caption2)
                    .foregroundColor(.green)
                
                Text("•")
                    .font(.caption2)
                    .foregroundColor(.green.opacity(0.5))
                
                Link("Terms of Use", destination: URL(string: "https://nbedzeti.github.io/ToneForge/terms.html")!)
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
        .padding(.top)
    }
    
    // MARK: - Loading Section
    
    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                .scaleEffect(1.2)
            Text("Loading products...")
                .font(.subheadline)
                .foregroundColor(.green.opacity(0.7))
            
            Text("Note: In-app purchases require a real device and App Store configuration")
                .font(.caption)
                .foregroundColor(.green.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Helper Methods
    
    private func badgeText(for product: Product) -> String? {
        switch product.id {
        case PurchaseManager.ProductID.yearly:
            return "BEST VALUE"
        case PurchaseManager.ProductID.lifetime:
            return "MOST POPULAR"
        default:
            return nil
        }
    }
    
    private func savingsText(for product: Product) -> String? {
        if product.id == PurchaseManager.ProductID.yearly {
            return "Save \(purchaseManager.yearlySavings())"
        }
        return nil
    }
    
    private func purchaseProduct(_ product: Product) async {
        isPurchasing = true
        
        do {
            let transaction = try await purchaseManager.purchase(product)
            
            if transaction != nil {
                // Purchase successful
                dismiss()
            }
        } catch {
            showingError = true
        }
        
        isPurchasing = false
    }
}

// MARK: - Product Card

struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let isPurchasing: Bool
    let badge: String?
    let savings: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Badge
                if let badge = badge {
                    Text(badge)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                // Product name
                Text(product.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Price
                Text(product.displayPrice)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Period
                if let subscription = product.subscription {
                    let period = subscriptionPeriodText(subscription.subscriptionPeriod)
                    Text(period)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Savings
                if let savings = savings {
                    Text(savings)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                // Purchase button
                if isPurchasing {
                    ProgressView()
                        .padding(.top, 4)
                } else {
                    Text("Subscribe")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.top, 4)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.black.opacity(0.1), radius: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isPurchasing)
    }
    
    private func subscriptionPeriodText(_ period: Product.SubscriptionPeriod) -> String {
        let value = period.value
        let unit = period.unit
        
        switch unit {
        case .day:
            return value == 1 ? "per day" : "per \(value) days"
        case .week:
            return value == 1 ? "per week" : "per \(value) weeks"
        case .month:
            return value == 1 ? "per month" : "per \(value) months"
        case .year:
            return value == 1 ? "per year" : "per \(value) years"
        @unknown default:
            return ""
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.green)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.green.opacity(0.7))
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    PurchaseView(purchaseManager: PurchaseManager())
}
