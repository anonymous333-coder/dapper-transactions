import PackNFT from 0xd48ab9abecdde33c
import IPackNFT from 0xd48ab9abecdde33c

// This transcation opens an on-chain pack, revealing its contents and placing them into the account's NFT collection.
transaction(revealID: UInt64) {
  prepare(owner: AuthAccount) {
    let collectionRef = owner.borrow<&PackNFT.Collection>(from: PackNFT.CollectionStoragePath)!
    collectionRef.borrowPackNFT(id: revealID)!.reveal(openRequest: true)
  }
}
