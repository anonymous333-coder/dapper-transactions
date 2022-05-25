import NFTStorefront from 0x94b06cfca1d8a476
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20
import AnchainUtils from 0x26e7006d6734ba69
import MetaPandaAirdropNFT from 0x26e7006d6734ba69
import MetaPandaVoucher from 0x26e7006d6734ba69
import MetaPanda from 0x26e7006d6734ba69

// This transcation initializes an account with a collection that allows it to hold NFTs from a specific contract. It will
// do nothing if the account is already initialized.
transaction {
  prepare(collector: AuthAccount) {
    // Install a storefront
    if collector.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath) == nil {
      let storefront <- NFTStorefront.createStorefront() as! @NFTStorefront.Storefront
      collector.save(<-storefront, to: NFTStorefront.StorefrontStoragePath)
      collector.link<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath, target: NFTStorefront.StorefrontStoragePath)
    }

    // Install a MetaPanda collection
    if collector.borrow<&MetaPanda.Collection>(from: MetaPanda.CollectionStoragePath) == nil {
      let collection <- MetaPanda.createEmptyCollection()
      collector.save(<-collection, to: MetaPanda.CollectionStoragePath)
      collector.link<&{
        NonFungibleToken.CollectionPublic, 
        MetadataViews.ResolverCollection, 
        AnchainUtils.ResolverCollection
      }>(
        MetaPanda.CollectionPublicPath,
        target: MetaPanda.CollectionStoragePath
      )
    }

    // Install a MetaPandaVoucher collection
    if collector.borrow<&MetaPandaVoucher.Collection>(from: MetaPandaVoucher.CollectionStoragePath) == nil {
      let collection <- MetaPandaVoucher.createEmptyCollection()
      collector.save(<-collection, to: MetaPandaVoucher.CollectionStoragePath)
      collector.link<&{
        NonFungibleToken.CollectionPublic, 
        MetadataViews.ResolverCollection, 
        AnchainUtils.ResolverCollection
      }>(
        MetaPandaVoucher.CollectionPublicPath,
        target: MetaPandaVoucher.CollectionStoragePath
      )
    }
    
    // Install a MetaPandaAirdropNFT collection
    if collector.borrow<&MetaPandaAirdropNFT.Collection>(from: MetaPandaAirdropNFT.CollectionStoragePath) == nil {
      let collection <-MetaPandaAirdropNFT.createEmptyCollection()
      collector.save(<-collection, to: MetaPandaAirdropNFT.CollectionStoragePath)
      collector.link<&{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, AnchainUtils.ResolverCollection}>(
        MetaPandaAirdropNFT.CollectionPublicPath,
        target: MetaPandaAirdropNFT.CollectionStoragePath
      )
    }
  }
}
