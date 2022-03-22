import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _senderBalance = 0;
  double receiverBalance = 0;

  final String _rpcUrl = "http://192.168.10.101:7545";
  final String _wsUrl = "http://192.168.10.101:7545";

  late Web3Client _web3;
  late String _abiCode;
  late EthereumAddress _contractAddress;
  late EthereumAddress _ownAddress;
  late DeployedContract _contract;

  late ContractFunction _getBalance;

  @override
  void initState() {
    super.initState();
    initialSetup();
  }

  Future<void> initialSetup() async {
    _web3 = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });
    await getAbi();
    await getDeployedContract();
    BigInt senderBalance =
        await getBalance("0x156b6c9D84118E80D70f0AEe5FA8Cb58c76956FC");
    setState(() {
      _senderBalance = (senderBalance / BigInt.from(1000000000000000000));
    });
  }

  Future<void> getAbi() async {
    String abiStringFile =
        await rootBundle.loadString("src/contracts/Transaction.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);
    _contractAddress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
  }

  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "Transaction"), _contractAddress);
    _getBalance = _contract.function("getBalance");
  }

  Future<BigInt> getBalance(String address) async {
    BigInt balance = BigInt.from(0);
    try {
      EthereumAddress _address = EthereumAddress.fromHex(address);
      // print(address);
      List<dynamic> balanceList = await _web3
          .call(contract: _contract, function: _getBalance, params: [_address]);

      balance = balanceList[0];
    } catch (err) {
      // print(err);
    }
    return balance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tran-Dapp"),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Color.fromRGBO(3, 32, 60, 1)),
        child: ListView(
          children: [
            const SizedBox(
              height: 30.0,
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 30.0,
                right: 30.0,
              ),
              height: 350,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(99, 97, 102, 1),
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "Sender Info",
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  Text(
                    "${_senderBalance} Eth",
                    style: const TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  const Text(
                    "Send Ether",
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  SizedBox(
                    width: 250.0,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Receiver Address",
                        contentPadding: EdgeInsets.only(left: 10.0),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 150.0,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Amount in Wei",
                            contentPadding: EdgeInsets.only(left: 10.0),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                      ),
                      const Text(
                        "< = 1 Eth",
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Send",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 30.0,
                right: 30.0,
              ),
              height: 150,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(99, 97, 102, 1),
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Text(
                    "Receiver Info",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "0 Eth",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
