// import 'dart:html';
import 'dart:convert';
import 'dart:ui';
import 'package:coincap/pages/details_page.dart';
import 'package:coincap/services/http_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hexcolor/hexcolor.dart';

class HomePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
      return _HomePageState();
  }

}

class _HomePageState extends State<HomePage> {
  double? _deviceHeight, _deviceWidth;
  String? _selectedCoin = 'bitcoin';

  HTTPService? _http;

  @override
  void initState() {
    super.initState();
    _http = GetIt.instance.get<HTTPService>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _selectedCoinDropdown(),
              _dataWidgets(),
            ],
      ),
        ),)
    );
  }

    Widget _selectedCoinDropdown() {
    List<String> _coins = ['bitcoin', 'ethereum', 'tether', 'cardano', 'ripple', 'solana'];
    List<DropdownMenuItem<String>> _items = _coins
    .map(
      (e) => DropdownMenuItem(
        value: e,
        child: Text(
          e,
          style: const TextStyle(color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w600,
          ),
          ),
        ),
      )
      .toList();
    return DropdownButton(
      value: _selectedCoin,
      items: _items,
      onChanged: (dynamic _value) {
        setState(() {
          _selectedCoin = _value;
        });
      },
      dropdownColor: HexColor('#29524A'),
      iconSize: 30,
      icon: const Icon(Icons.arrow_drop_down_sharp,
      color: Colors.white,
      ),
      underline: Container(),
      );
  }

  Widget _dataWidgets() {
    return FutureBuilder(
      future: _http!.get('/coins/$_selectedCoin'),
      builder: (BuildContext _context, AsyncSnapshot _snapshot) {
        if (_snapshot.hasData) {
          Map _data = jsonDecode(_snapshot.data.toString(),
          );
          num _usdPrice = _data['market_data']['current_price']['brl'];
          num _change24h = _data['market_data']['price_change_percentage_24h'];
          String _imgURL = _data['image']['large'];
          String _description = _data['description']['en'];
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _coinImageWidget(_imgURL),
              _currentPriceWidget(_usdPrice),
              _percentageChangeWidget(_change24h),
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      },
    );
  }

  Widget _currentPriceWidget(num _rate) {
    return Text('${_rate.toStringAsFixed(2)} Reais',
    style: const TextStyle(
      color: Colors.white,
      fontSize: 30,
      fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _percentageChangeWidget(num _change) {
    return Text('${_change.toString()} %',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w300,
        ),
      );
  }

  Widget _coinImageWidget(String _imgURL) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: _deviceHeight! * 0.02,
        ),
      height: _deviceHeight! * 0.15,
      width: _deviceWidth! * 0.15,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(_imgURL),
          ),
        ),
    );
  }

}
