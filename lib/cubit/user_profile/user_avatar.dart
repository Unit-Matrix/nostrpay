enum UserAvatar {
  satoshi('assets/mascot/Satoshi.svg'),
  jackMallers('assets/mascot/jack-mallers.svg'),
  rockstarDev('assets/mascot/rockstar-dev.svg'),
  lynAlden('assets/mascot/Lyn-Alden.svg'),
  bitcoinAlby('assets/mascot/Bitcoin-Alby.svg'),
  zeusBitcoin('assets/mascot/Zeus-bitcoin.svg');

  const UserAvatar(this.assetPath);

  final String assetPath;

  static UserAvatar fromIndex(int index) {
    if (index >= 0 && index < UserAvatar.values.length) {
      return UserAvatar.values[index];
    }
    return UserAvatar.satoshi; // Default fallback
  }

  int get avatarIndex => UserAvatar.values.indexOf(this);
}
