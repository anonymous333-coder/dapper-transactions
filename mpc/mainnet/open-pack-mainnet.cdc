import PackNFT from 0xe4cf4bdc1751c65d
import IPackNFT from 0x44c6a6fd2281b6cc

// This transcation opens an on-chain pack, revealing its contents and placing them into the account's NFT collection.
transaction(revealID: UInt64) {
  prepare(owner: AuthAccount) {
    let collectionRef = owner.borrow<&PackNFT.Collection>(from: PackNFT.CollectionStoragePath)!
    collectionRef.borrowPackNFT(id: revealID)!.reveal(openRequest: true)
  }
}
