import NonFungibleToken from 0x631e88ae7f1d7c20
import MetaPandaVoucher from 0x26e7006d6734ba69
import MetaPanda from 0x26e7006d6734ba69

transaction {
  prepare(acct: AuthAccount) {
    if acct.borrow<&MetaPanda.Collection>(from: MetaPanda.CollectionStoragePath) != nil {
      acct.unlink(MetaPanda.CollectionPublicPath)
      destroy <- acct.load<@AnyResource>(from: MetaPanda.CollectionStoragePath)
    }
    if acct.borrow<&MetaPandaVoucher.Collection>(from: MetaPandaVoucher.CollectionStoragePath) != nil {
      acct.unlink(MetaPandaVoucher.CollectionPublicPath)
      destroy <- acct.load<@AnyResource>(from: MetaPandaVoucher.CollectionStoragePath)
    }
  }
}
