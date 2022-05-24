import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import NFTStorefront from 0x94b06cfca1d8a476
import DapperUtilityCoin from 0x82ec283f88a62e65
import MetadataViews from 0x631e88ae7f1d7c20
import AnchainUtils from 0x26e7006d6734ba69
import MetaPanda from 0x26e7006d6734ba69

// This transcation purchases a pack on from a dapp. This tranasction will also initialize the buyer's account with a pack NFT
// collection and an NFT collection if it does not already have them.
transaction(storefrontAddress: Address, listingResourceID: UInt64, expectedPrice: UFix64) {
  let paymentVault: @FungibleToken.Vault
  let buyerNFTCollection: &AnyResource{NonFungibleToken.CollectionPublic}
  let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
  let listing: &NFTStorefront.Listing{NFTStorefront.ListingPublic}
  let balanceBeforeTransfer: UFix64
  let mainDUCVault: &DapperUtilityCoin.Vault
  let dappAddress: Address
  let salePrice: UFix64

  prepare(dapp: AuthAccount, dapper: AuthAccount, buyer: AuthAccount) {
    self.dappAddress = dapp.address

    // Initialize the collection if the buyer does not already have one
    if buyer.borrow<&MetaPanda.Collection>(from: MetaPanda.CollectionStoragePath) == nil {
      let collection <- MetaPanda.createEmptyCollection()
      buyer.save(<-collection, to: MetaPanda.CollectionStoragePath)
      buyer.link<&{
        NonFungibleToken.CollectionPublic, 
        MetadataViews.ResolverCollection, 
        AnchainUtils.ResolverCollection
      }>(
        MetaPanda.CollectionPublicPath,
        target: MetaPanda.CollectionStoragePath
      ) ?? panic("Could not link collection Pub Path")
    }

    // Although the Storefront is available as a public capability, we want to borrow
    // from storage so that we can enforce the need for MetaPanda to sign this transaction
    self.storefront = dapp
      .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
      .borrow()
      ?? panic("Could not borrow a reference to the storefront")
    self.listing = self.storefront.borrowListing(listingResourceID: listingResourceID)
      ?? panic("No Listing with that ID in Storefront")

    self.salePrice = self.listing.getDetails().salePrice

    self.mainDUCVault = dapper.borrow<&DapperUtilityCoin.Vault>(from: /storage/dapperUtilityCoinVault)
      ?? panic("Could not borrow reference to Dapper Utility Coin vault")
    self.balanceBeforeTransfer = self.mainDUCVault.balance
    self.paymentVault <- self.mainDUCVault.withdraw(amount: self.salePrice)

    self.buyerNFTCollection = buyer
      .getCapability<&{NonFungibleToken.CollectionPublic}>(MetaPanda.CollectionPublicPath)
      .borrow()
      ?? panic("Cannot borrow NFT collection receiver from account")
  }

  pre {
    self.salePrice == expectedPrice: "unexpected price"
    self.dappAddress == 0x26e7006d6734ba69 && self.dappAddress == storefrontAddress: "Requires valid authorizing signature"
  }

  execute {
    let item <- self.listing.purchase(payment: <-self.paymentVault)
    self.buyerNFTCollection.deposit(token: <-item)
    self.storefront.cleanup(listingResourceID: listingResourceID)
  }

  post {
    self.mainDUCVault.balance == self.balanceBeforeTransfer: "DUC leakage"
  }
}