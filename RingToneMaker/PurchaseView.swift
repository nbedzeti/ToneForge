//
//  PurchaseView.swift
//  RingToneMaker
//
//  Full-screen premium welcome page
//

import SwiftUI
import StoreKit

struct PurchaseView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var purchaseManager: PurchaseManager
    
    @State private var selectedProductID: String?
    @State private var showingError = false
    @State private var isPurchasing = false
    @State private var currentPage = 0
    @State private var marqueeOffset: CGFloat = 0
    
    private let features: [(icon: String, title: String, subtitle: String)] = [
        ("infinity", "Unlimited Ringtones", "Create as many as you want, no limits"),
        ("sparkles", "Premium Effects", "Fade, reverb, EQ and more"),
        ("waveform", "Audio Normalization", "Perfect volume every time"),
        ("nosign", "No Ads", "Clean, distraction-free experience")
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Fixed top bar with solid background
                VStack(spacing: 0) {
                    // Marquee ticker banner - in safe area zone
                    if !purchaseManager.isPremium {
                        marqueeTickerBanner
                            .padding(.top, 6)
                    }
                    
                    // Back button - below marquee where taps work
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.caption)
                                Text("Back")
                                    .font(.caption)
                            }
                            .foregroundColor(.green.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                        }
                        Spacer()
                    }
                }
                .background(Color.black)
                .zIndex(10)
                
                ScrollView(showsIndicators: true) {
                    VStack(spacing: 16) {
                        // Hero section
                        heroSection
                        
                        // Feature carousel
                        featureCarousel
                        
                        // Subscription plans
                        if purchaseManager.products.isEmpty {
                            if purchaseManager.isLoading {
                                loadingSection
                            } else {
                                staticPlansSection
                            }
                        } else {
                            plansSection
                        }
                        
                        // Restore purchases
                        restoreButton
                        
                        // Legal
                        legalSection
                        
                        Color.clear.frame(height: 20)
                    }
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                }
            }
        }
        .preferredColorScheme(.dark)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .top)
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = purchaseManager.errorMessage {
                Text(error)
            }
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 12) {
            // Animated crown icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 90, height: 90)
                
                Circle()
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    .frame(width: 90, height: 90)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            }
            
            Text("Go Premium")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Text("Unlock the full power of ToneForge Studio")
                .font(.subheadline)
                .foregroundColor(.green.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Feature Carousel
    
    private var featureCarousel: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentPage) {
                ForEach(0..<features.count, id: \.self) { index in
                    VStack(spacing: 10) {
                        Image(systemName: features[index].icon)
                            .font(.system(size: 32))
                            .foregroundColor(.green)
                        
                        Text(features[index].title)
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text(features[index].subtitle)
                            .font(.caption)
                            .foregroundColor(.green.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 120)
            
            // Page dots
            HStack(spacing: 6) {
                ForEach(0..<features.count, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.green : Color.green.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Marquee Ticker Banner
    
    private var marqueeText: String {
        if purchaseManager.remainingFreeCreations > 0 {
            return "🎁 \(purchaseManager.remainingFreeCreations) free ringtones remaining  •  Upgrade for unlimited access  •  "
        } else {
            return "⚠️ Free tier used — upgrade now for unlimited ringtones  •  Go Premium today  •  "
        }
    }
    
    private var marqueeColor: Color {
        purchaseManager.remainingFreeCreations > 0 ? .green : .orange
    }
    
    private var marqueeTickerBanner: some View {
        GeometryReader { geo in
            let textWidth: CGFloat = CGFloat(marqueeText.count) * 7.5
            let totalWidth = textWidth * 2
            
            HStack(spacing: 0) {
                Text(marqueeText)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(marqueeColor)
                Text(marqueeText)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(marqueeColor)
            }
            .fixedSize()
            .offset(x: marqueeOffset)
            .onAppear {
                marqueeOffset = 0
                withAnimation(.linear(duration: Double(marqueeText.count) * 0.18).repeatForever(autoreverses: false)) {
                    marqueeOffset = -textWidth
                }
            }
        }
        .frame(height: 20)
        .clipped()
        .background(marqueeColor.opacity(0.06))
    }
    
    // MARK: - Plans Section
    
    private var plansSection: some View {
        VStack(spacing: 12) {
            // Monthly + Yearly side by side
            HStack(spacing: 12) {
                ForEach(purchaseManager.products.filter { $0.id != PurchaseManager.ProductID.lifetime }, id: \.id) { product in
                    PlanTile(
                        product: product,
                        isSelected: selectedProductID == product.id,
                        isPurchasing: isPurchasing,
                        badge: badgeText(for: product),
                        savings: savingsText(for: product)
                    ) {
                        selectedProductID = product.id
                        Task { await purchaseProduct(product) }
                    }
                }
            }
            
            // Lifetime full-width
            if let lifetime = purchaseManager.products.first(where: { $0.id == PurchaseManager.ProductID.lifetime }) {
                PlanTile(
                    product: lifetime,
                    isSelected: selectedProductID == lifetime.id,
                    isPurchasing: isPurchasing,
                    badge: badgeText(for: lifetime),
                    savings: nil
                ) {
                    selectedProductID = lifetime.id
                    Task { await purchaseProduct(lifetime) }
                }
            }
        }
    }
    
    // MARK: - Static Plans Fallback
    
    private var staticPlansSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StaticPlanTile(
                    name: "Monthly",
                    price: "$4.99",
                    period: "/mo",
                    icon: "calendar",
                    badge: nil
                ) {
                    Task { await purchaseManager.loadProducts() }
                }
                
                StaticPlanTile(
                    name: "Yearly",
                    price: "$29.99",
                    period: "/yr",
                    icon: "star.fill",
                    badge: "BEST VALUE"
                ) {
                    Task { await purchaseManager.loadProducts() }
                }
            }
            
            StaticPlanTile(
                name: "Lifetime",
                price: "$49.99",
                period: "one-time",
                icon: "infinity",
                badge: "MOST POPULAR"
            ) {
                Task { await purchaseManager.loadProducts() }
            }
            
            if purchaseManager.errorMessage != nil {
                Text("Tap a plan to retry connecting to the App Store")
                    .font(.caption2)
                    .foregroundColor(.orange.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
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
                .font(.caption)
                .foregroundColor(.green.opacity(0.6))
        }
        .disabled(purchaseManager.isLoading)
        .padding(.top, 4)
    }
    
    // MARK: - Legal Section
    
    private var legalSection: some View {
        VStack(spacing: 10) {
            VStack(spacing: 4) {
                Text("Premium Monthly: $4.99/month, auto-renews")
                Text("Premium Yearly: $29.99/year, auto-renews")
                Text("Premium Lifetime: $49.99 one-time")
            }
            .font(.caption2)
            .foregroundColor(.green.opacity(0.4))
            .multilineTextAlignment(.center)
            
            Text("Payment charged to Apple ID at purchase. Auto-renews unless cancelled 24h before period ends. Manage in Settings → Subscriptions.")
                .font(.caption2)
                .foregroundColor(.green.opacity(0.35))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Link("Privacy Policy", destination: URL(string: "https://nbedzeti.github.io/ToneForge/privacy.html")!)
                    .font(.caption2)
                    .foregroundColor(.green.opacity(0.5))
                
                Text("•")
                    .font(.caption2)
                    .foregroundColor(.green.opacity(0.3))
                
                Link("Terms of Use", destination: URL(string: "https://nbedzeti.github.io/ToneForge/terms.html")!)
                    .font(.caption2)
                    .foregroundColor(.green.opacity(0.5))
            }
        }
    }
    
    // MARK: - Loading Section
    
    private var loadingSection: some View {
        VStack(spacing: 16) {
            if purchaseManager.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .green))
                Text("Loading plans...")
                    .font(.subheadline)
                    .foregroundColor(.green.opacity(0.7))
            } else if let error = purchaseManager.errorMessage {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text(error)
                    .font(.caption)
                    .foregroundColor(.orange.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Button("Try Again") {
                    Task { await purchaseManager.loadProducts() }
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Text("No plans available")
                    .font(.subheadline)
                    .foregroundColor(.green.opacity(0.7))
                
                Button("Retry") {
                    Task { await purchaseManager.loadProducts() }
                }
                .font(.subheadline)
                .foregroundColor(.green)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    
    // MARK: - Helpers
    
    private func badgeText(for product: Product) -> String? {
        switch product.id {
        case PurchaseManager.ProductID.yearly: return "BEST VALUE"
        case PurchaseManager.ProductID.lifetime: return "MOST POPULAR"
        default: return nil
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
                isPurchasing = false
                dismiss()
                return
            }
        } catch {
            purchaseManager.errorMessage = error.localizedDescription
            showingError = true
        }
        
        isPurchasing = false
    }
}

// MARK: - PlanTile Component

struct PlanTile: View {
    let product: Product
    let isSelected: Bool
    let isPurchasing: Bool
    let badge: String?
    let savings: String?
    let onTap: () -> Void
    
    private var isLifetime: Bool {
        product.id == PurchaseManager.ProductID.lifetime
    }
    
    private var periodLabel: String {
        if isLifetime { return "one-time" }
        if let sub = product.subscription {
            switch sub.subscriptionPeriod.unit {
            case .month: return "/mo"
            case .year: return "/yr"
            default: return ""
            }
        }
        return ""
    }
    
    private var icon: String {
        switch product.id {
        case PurchaseManager.ProductID.monthly: return "calendar"
        case PurchaseManager.ProductID.yearly: return "star.fill"
        case PurchaseManager.ProductID.lifetime: return "infinity"
        default: return "crown.fill"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: isLifetime ? 10 : 8) {
                // Badge ribbon
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green)
                        .clipShape(Capsule())
                } else {
                    // Spacer to keep alignment consistent
                    Color.clear.frame(height: 17)
                }
                
                // Icon
                Image(systemName: icon)
                    .font(.system(size: isLifetime ? 28 : 24))
                    .foregroundColor(.green)
                
                // Plan name
                Text(product.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // Price
                Text(product.displayPrice)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text(periodLabel)
                    .font(.caption2)
                    .foregroundColor(.green.opacity(0.5))
                
                // Savings
                if let savings = savings {
                    Text(savings)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.green.opacity(0.7))
                }
                
                // CTA button
                if isPurchasing && isSelected {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .frame(height: 32)
                } else {
                    Text(isLifetime ? "Buy Now" : "Subscribe")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.green.opacity(0.12) : Color.green.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.green.opacity(0.6) : Color.green.opacity(0.15), lineWidth: isSelected ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - StaticPlanTile (fallback when products don't load)

struct StaticPlanTile: View {
    let name: String
    let price: String
    let period: String
    let icon: String
    let badge: String?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green)
                        .clipShape(Capsule())
                } else {
                    Color.clear.frame(height: 17)
                }
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                
                Text(name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Text(price)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text(period)
                    .font(.caption2)
                    .foregroundColor(.green.opacity(0.5))
                
                Text(name == "Lifetime" ? "Buy Now" : "Subscribe")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.green.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    PurchaseView(purchaseManager: PurchaseManager())
}
