//
//  PurchaseManager.swift
//  RingToneMaker
//
//  Created on 1/18/26.
//

import Foundation
import StoreKit
import Combine

/// Manages in-app purchases, subscriptions, and free tier tracking
@MainActor
@Observable
class PurchaseManager {
    
    // MARK: - Testing Flag
    
    /// Set to true to enable premium features for testing (REMOVE BEFORE PRODUCTION!)
    private let enablePremiumForTesting = false // ⚠️ MUST BE FALSE FOR PRODUCTION
    
    // MARK: - Published Properties
    
    /// All available products from App Store
    var products: [Product] = []
    
    /// Whether user has premium access (active subscription or lifetime purchase)
    var isPremium: Bool = false
    
    /// Current subscription status
    var subscriptionStatus: SubscriptionStatus = .notSubscribed
    
    /// Loading state for UI
    var isLoading: Bool = false
    
    /// Error message for UI display
    var errorMessage: String?
    
    // MARK: - Free Tier Tracking
    
    /// Number of free creations used (0-3)
    var freeCreationsUsed: Int {
        didSet {
            UserDefaults.standard.set(freeCreationsUsed, forKey: UserDefaultsKeys.freeCreationsUsed)
        }
    }
    
    // V1.1: Ad-related properties (disabled for v1.0)
    // These will be re-enabled when AdMob SDK is integrated in v1.1
    /*
    /// Extra creations unlocked by watching ads
    var extraCreationsAvailable: Int {
        didSet {
            UserDefaults.standard.set(extraCreationsAvailable, forKey: UserDefaultsKeys.extraCreationsAvailable)
        }
    }
    
    /// Total ads watched (for tracking)
    var totalAdsWatched: Int {
        didSet {
            UserDefaults.standard.set(totalAdsWatched, forKey: UserDefaultsKeys.totalAdsWatched)
        }
    }
    
    /// Ads watched towards next unlock (0-2)
    var adsWatchedForNextUnlock: Int {
        didSet {
            UserDefaults.standard.set(adsWatchedForNextUnlock, forKey: UserDefaultsKeys.adsWatchedForNextUnlock)
        }
    }
    */
    
    // MARK: - Computed Properties
    
    /// Whether user can create a ringtone (v1.0: 3 free + premium only)
    var canCreateRingtone: Bool {
        return isPremium || freeCreationsUsed < 3
    }
    
    /// Remaining free creations (0-3)
    var remainingFreeCreations: Int {
        return max(0, 3 - freeCreationsUsed)
    }
    
    /// Whether user needs to upgrade (v1.0: no ads, just upgrade)
    var needsToWatchAdsOrUpgrade: Bool {
        return !isPremium && freeCreationsUsed >= 3
    }
    
    // MARK: - Product IDs
    
    enum ProductID {
        static let monthly = "com.IceFireSoul.ToneForge.premium.monthly"
        static let yearly = "com.IceFireSoul.ToneForge.premium.yearly"
        static let lifetime = "com.IceFireSoul.ToneForge.premium.lifetime"
        
        static var all: [String] {
            return [monthly, yearly, lifetime]
        }
    }
    
    // MARK: - UserDefaults Keys
    
    private enum UserDefaultsKeys {
        static let freeCreationsUsed = "freeCreationsUsed"
        // V1.1: Ad-related keys (disabled for v1.0)
        // static let extraCreationsAvailable = "extraCreationsAvailable"
        // static let totalAdsWatched = "totalAdsWatched"
        // static let adsWatchedForNextUnlock = "adsWatchedForNextUnlock"
        static let firstLaunchDate = "firstLaunchDate"
        static let totalCreationsCount = "totalCreationsCount"
    }
    
    // MARK: - Private Properties
    
    nonisolated(unsafe) private var updateListenerTask: Task<Void, Error>?
    private var purchasedProductIDs: Set<String> = []
    // V1.1: AdManager will be re-enabled when AdMob SDK is integrated
    // var adManager: AdManager?
    
    // MARK: - Initialization
    
    init() {
        // TESTING: Enable premium features for testing
        if enablePremiumForTesting {
            self.isPremium = true
            print("🧪 TESTING MODE: Premium features enabled at init")
        }
        
        // Load saved values from UserDefaults (v1.0: only free creations)
        self.freeCreationsUsed = UserDefaults.standard.integer(forKey: UserDefaultsKeys.freeCreationsUsed)
        
        // V1.1: Ad-related initialization (disabled for v1.0)
        /*
        self.extraCreationsAvailable = UserDefaults.standard.integer(forKey: UserDefaultsKeys.extraCreationsAvailable)
        self.totalAdsWatched = UserDefaults.standard.integer(forKey: UserDefaultsKeys.totalAdsWatched)
        self.adsWatchedForNextUnlock = UserDefaults.standard.integer(forKey: UserDefaultsKeys.adsWatchedForNextUnlock)
        */
        
        // Set first launch date if not set
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.firstLaunchDate) == nil {
            UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.firstLaunchDate)
        }
        
        // V1.1: Initialize ad manager (disabled for v1.0)
        /*
        Task { @MainActor in
            self.adManager = AdManager()
        }
        */
        
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        // Load products and check entitlements
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    nonisolated deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    /// Load products from App Store
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let loadedProducts = try await Product.products(for: ProductID.all)
            
            // Sort products: monthly, yearly, lifetime
            self.products = loadedProducts.sorted { product1, product2 in
                let order = [ProductID.monthly, ProductID.yearly, ProductID.lifetime]
                let index1 = order.firstIndex(of: product1.id) ?? 999
                let index2 = order.firstIndex(of: product2.id) ?? 999
                return index1 < index2
            }
            
            print("✅ Loaded \(products.count) products")
            for product in products {
                print("  - \(product.displayName): \(product.displayPrice)")
            }
            
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("❌ Error loading products: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase Methods
    
    /// Purchase a product
    func purchase(_ product: Product) async throws -> Transaction? {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)
                
                // Update purchased products
                await updatePurchasedProducts()
                
                // Finish the transaction
                await transaction.finish()
                
                print("✅ Purchase successful: \(product.displayName)")
                return transaction
                
            case .userCancelled:
                print("ℹ️ User cancelled purchase")
                return nil
                
            case .pending:
                print("⏳ Purchase pending")
                return nil
                
            @unknown default:
                print("⚠️ Unknown purchase result")
                return nil
            }
            
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            print("❌ Purchase error: \(error)")
            throw error
        }
    }
    
    /// Restore purchases
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            print("✅ Purchases restored")
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            print("❌ Restore error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Entitlement Checking
    
    /// Update purchased products and premium status
    func updatePurchasedProducts() async {
        var newPurchasedIDs: Set<String> = []
        var hasActiveSubscription = false
        var hasLifetimePurchase = false
        
        // Check for current entitlements
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Add to purchased IDs
                newPurchasedIDs.insert(transaction.productID)
                
                // Check if it's a subscription
                if transaction.productID == ProductID.monthly || transaction.productID == ProductID.yearly {
                    hasActiveSubscription = true
                    print("✅ Active subscription: \(transaction.productID)")
                }
                
                // Check if it's lifetime
                if transaction.productID == ProductID.lifetime {
                    hasLifetimePurchase = true
                    print("✅ Lifetime purchase verified")
                }
                
            } catch {
                print("❌ Transaction verification failed: \(error)")
            }
        }
        
        // Update state
        purchasedProductIDs = newPurchasedIDs
        
        // TESTING: Override with testing flag
        if enablePremiumForTesting {
            isPremium = true
            print("🧪 TESTING MODE: Premium features enabled")
        } else {
            isPremium = hasActiveSubscription || hasLifetimePurchase
        }
        
        // Update subscription status
        if hasLifetimePurchase {
            subscriptionStatus = .lifetime
        } else if hasActiveSubscription {
            await updateSubscriptionStatus()
        } else {
            subscriptionStatus = .notSubscribed
        }
        
        print("📊 Premium status: \(isPremium)")
        print("📊 Subscription status: \(subscriptionStatus)")
    }
    
    /// Update subscription status with detailed info
    private func updateSubscriptionStatus() async {
        // Get subscription status for the subscription group
        guard let product = products.first(where: { $0.id == ProductID.monthly || $0.id == ProductID.yearly }) else {
            return
        }
        
        guard let subscription = product.subscription else {
            return
        }
        
        do {
            let statuses = try await subscription.status
            
            for status in statuses {
                switch status.state {
                case .subscribed:
                    subscriptionStatus = .active
                    print("✅ Subscription active")
                    
                case .expired:
                    subscriptionStatus = .expired
                    print("⚠️ Subscription expired")
                    
                case .inBillingRetryPeriod:
                    subscriptionStatus = .inGracePeriod
                    print("⚠️ Subscription in billing retry")
                    
                case .inGracePeriod:
                    subscriptionStatus = .inGracePeriod
                    print("⚠️ Subscription in grace period")
                    
                case .revoked:
                    subscriptionStatus = .revoked
                    print("❌ Subscription revoked")
                    
                default:
                    subscriptionStatus = .notSubscribed
                    print("⚠️ Unknown subscription state")
                }
            }
        } catch {
            print("❌ Error checking subscription status: \(error)")
        }
    }
    
    /// Check if a transaction is verified
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Transaction Listener
    
    /// Listen for transaction updates
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction: Transaction
                    switch result {
                    case .unverified:
                        throw PurchaseError.failedVerification
                    case .verified(let safe):
                        transaction = safe
                    }
                    
                    // Update purchased products
                    await self.updatePurchasedProducts()
                    
                    // Finish the transaction
                    await transaction.finish()
                    
                    print("✅ Transaction update processed: \(transaction.productID)")
                    
                } catch {
                    print("❌ Transaction update failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Free Tier Management
    
    /// Use a free creation (v1.0: simple 3 free + premium model)
    func useFreeCreation() {
        guard canCreateRingtone else {
            print("❌ Cannot create ringtone - no creations available")
            return
        }
        
        if isPremium {
            // Premium users have unlimited
            print("✅ Premium user - unlimited creations")
        } else if freeCreationsUsed < 3 {
            // Use free creation
            freeCreationsUsed += 1
            print("✅ Used free creation. Remaining: \(remainingFreeCreations)")
        }
        
        // Increment total count
        let total = UserDefaults.standard.integer(forKey: UserDefaultsKeys.totalCreationsCount)
        UserDefaults.standard.set(total + 1, forKey: UserDefaultsKeys.totalCreationsCount)
    }
    
    /// Reset free creations (for testing only)
    func resetFreeCreations() {
        freeCreationsUsed = 0
        // V1.1: Reset ad-related counters (disabled for v1.0)
        // extraCreationsAvailable = 0
        // totalAdsWatched = 0
        // adsWatchedForNextUnlock = 0
        print("🔄 Reset free creations")
    }
    
    // MARK: - V1.1: Rewarded Ads (Disabled for v1.0)
    // These methods will be re-enabled when AdMob SDK is integrated in v1.1
    
    /*
    /// Called when user watches a rewarded ad
    func rewardedAdWatched() {
        guard !isPremium else {
            print("ℹ️ Premium user - no need for ads")
            return
        }
        
        // Increment counters
        totalAdsWatched += 1
        adsWatchedForNextUnlock += 1
        
        print("📺 Ad watched. Progress: \(adsWatchedForNextUnlock)/3")
        
        // Check if user earned a creation
        if adsWatchedForNextUnlock >= 3 {
            extraCreationsAvailable += 1
            adsWatchedForNextUnlock = 0
            print("🎉 Unlocked 1 extra creation! Total available: \(extraCreationsAvailable)")
        }
    }
    
    /// Show rewarded ad for extra creation
    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard !isPremium else {
            print("ℹ️ Premium user - no need for ads")
            completion(false)
            return
        }
        
        print("📺 Showing rewarded ad...")
        
        // Use AdManager
        guard let adManager = adManager else {
            print("❌ AdManager not initialized")
            completion(false)
            return
        }
        
        adManager.showRewardedAdForExtraCreation { [weak self] success in
            if success {
                self?.rewardedAdWatched()
            }
            completion(success)
        }
    }
    */
    
    // MARK: - Helper Methods
    
    /// Get product by ID
    func product(for id: String) -> Product? {
        return products.first { $0.id == id }
    }
    
    /// Check if product is purchased
    func isPurchased(_ productID: String) -> Bool {
        return purchasedProductIDs.contains(productID)
    }
    
    /// Get formatted price for product
    func formattedPrice(for productID: String) -> String {
        guard let product = product(for: productID) else {
            return "$0.00"
        }
        return product.displayPrice
    }
    
    /// Get display name for product
    func displayName(for productID: String) -> String {
        guard let product = product(for: productID) else {
            return "Unknown"
        }
        return product.displayName
    }
    
    /// Get subscription period (for display)
    func subscriptionPeriod(for productID: String) -> String? {
        guard let product = product(for: productID),
              let subscription = product.subscription else {
            return nil
        }
        
        let unit = subscription.subscriptionPeriod.unit
        let value = subscription.subscriptionPeriod.value
        
        switch unit {
        case .day:
            return value == 1 ? "Daily" : "\(value) days"
        case .week:
            return value == 1 ? "Weekly" : "\(value) weeks"
        case .month:
            return value == 1 ? "Monthly" : "\(value) months"
        case .year:
            return value == 1 ? "Yearly" : "\(value) years"
        @unknown default:
            return nil
        }
    }
    
    /// Calculate savings for yearly vs monthly
    func yearlySavings() -> String {
        guard let monthly = product(for: ProductID.monthly),
              let yearly = product(for: ProductID.yearly) else {
            return "0%"
        }
        
        let monthlyAnnual = monthly.price * 12
        let yearlySavings = monthlyAnnual - yearly.price
        let savingsPercent = (yearlySavings / monthlyAnnual) * 100
        
        return String(format: "%.0f%%", NSDecimalNumber(decimal: savingsPercent).doubleValue)
    }
}

// MARK: - Supporting Types

/// Subscription status
enum SubscriptionStatus: String {
    case notSubscribed = "Not Subscribed"
    case active = "Active"
    case expired = "Expired"
    case inGracePeriod = "Grace Period"
    case revoked = "Revoked"
    case lifetime = "Lifetime"
}

/// Purchase errors
enum PurchaseError: Error, LocalizedError {
    case failedVerification
    case productNotFound
    case purchaseFailed
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Purchase verification failed. Please try again."
        case .productNotFound:
            return "Product not found. Please try again later."
        case .purchaseFailed:
            return "Purchase failed. Please try again."
        }
    }
}

// MARK: - Extensions

extension PurchaseManager {
    /// Get usage statistics for display (v1.0: simplified without ads)
    var usageStats: UsageStats {
        let total = UserDefaults.standard.integer(forKey: UserDefaultsKeys.totalCreationsCount)
        let firstLaunch = UserDefaults.standard.object(forKey: UserDefaultsKeys.firstLaunchDate) as? Date ?? Date()
        
        return UsageStats(
            totalCreations: total,
            freeCreationsUsed: freeCreationsUsed,
            // V1.1: Ad-related stats (disabled for v1.0)
            // extraCreationsAvailable: extraCreationsAvailable,
            // totalAdsWatched: totalAdsWatched,
            memberSince: firstLaunch,
            isPremium: isPremium,
            subscriptionStatus: subscriptionStatus
        )
    }
}

/// Usage statistics
struct UsageStats {
    let totalCreations: Int
    let freeCreationsUsed: Int
    // V1.1: Ad-related stats (disabled for v1.0)
    // let extraCreationsAvailable: Int
    // let totalAdsWatched: Int
    let memberSince: Date
    let isPremium: Bool
    let subscriptionStatus: SubscriptionStatus
    
    var memberDays: Int {
        return Calendar.current.dateComponents([.day], from: memberSince, to: Date()).day ?? 0
    }
}
