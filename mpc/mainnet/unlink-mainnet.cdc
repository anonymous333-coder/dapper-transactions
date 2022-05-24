import NonFungibleToken from 0x1d7e57aa55817448
import MetaPandaVoucher from 0xf2af175e411dfff8
import MetaPanda from 0xf2af175e411dfff8

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
