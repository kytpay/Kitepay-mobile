const options = [
  'Mainnet',
  'ProjectSerum',
  'Testnet',
  'Devnet',
];

enum Network { Mainnet, ProjectSerum, Testnet, Devnet }

class NetworkUrl {
  late String rpc;
  late String ws;
  late String network;
  NetworkUrl(this.rpc, this.ws, this.network);
  static var urlOptions = {
    Network.Mainnet.name: NetworkUrl('https://api.mainnet-beta.solana.com',
        'ws://api.mainnet-beta.solana.com', Network.Mainnet.name),
    Network.ProjectSerum.name: NetworkUrl('https://solana-api.projectserum.com',
        'ws://solana-api.projectserum.com', Network.ProjectSerum.name),
    Network.Testnet.name: NetworkUrl('https://api.testnet.solana.com',
        'ws://api.testnet.solana.com', Network.Testnet.name),
    Network.Devnet.name: NetworkUrl('https://api.devnet.solana.com',
        'ws://api.devnet.solana.com', Network.Devnet.name),
  };
  static NetworkUrl getNetworkUrl(String network) {
    var net = NetworkUrl('https://api.mainnet-beta.solana.com',
        'ws://api.mainnet-beta.solana.com', 'Mainnet');
    if (urlOptions.containsKey(network)) {
      switch (network) {
        case 'Mainnet':
          {
            net = NetworkUrl('https://api.mainnet-beta.solana.com',
                'ws://api.mainnet-beta.solana.com', 'Mainnet');
          }
          break;
        case 'ProjectSerum':
          {
            net = NetworkUrl('https://solana-api.projectserum.com',
                'ws://solana-api.projectserum.com', 'ProjectSerum');
          }
          break;
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
           net = NetworkUrl('https://api.mainnet-beta.solana.com',
                'ws://api.mainnet-beta.solana.com', 'Mainnet');
          }
          break;
      }
    }
    return net;
  }
}

