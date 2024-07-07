const options = [
  'Testnet',
  'Devnet',
];

enum Network { Testnet, Devnet }

class NetworkUrl {
  late String rpc;
  late String ws;
  late String network;
  NetworkUrl(this.rpc, this.ws, this.network);
  static var urlOptions = {
    Network.Testnet.name: NetworkUrl('https://api.testnet.solana.com',
        'ws://api.testnet.solana.com', Network.Testnet.name),
    Network.Devnet.name: NetworkUrl('https://api.devnet.solana.com',
        'ws://api.devnet.solana.com', Network.Devnet.name),
  };
  static NetworkUrl getNetworkUrl(String network) {
    var net = NetworkUrl('https://api.devnet.solana.com',
        'ws://api.mainnet-beta.solana.com', 'Mainnet');
    if (urlOptions.containsKey(network)) {
      switch (network) {
        case 'Testnet':
          {
            net = NetworkUrl('https://api.testnet.solana.com',
                'ws://api.testnet.solana.com', 'Testnet');
          }
          break;
        case 'Devnet':
          {
            net = NetworkUrl('https://api.devnet.solana.com',
                'ws://api.devnet.solana.com', 'Devnet');
          }
          break;
        default:
          {
           net = NetworkUrl('https://api.devnet.solana.com',
                'ws://api.devnet.solana.com', 'Devnet');
          }
          break;
      }
    }
    return net;
  }
}

