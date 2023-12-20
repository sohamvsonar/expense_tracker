import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyPage extends StatefulWidget {
  @override
  _CurrencyPageState createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  Map<String, dynamic>? _exchangeRates;
  String _baseCurrency = 'USD';
  String _targetCurrency = 'INR';

  @override
  void initState() {
    super.initState();
    _fetchExchangeRates();
  }

  Future<void> _fetchExchangeRates() async {
    final apiUrl = 'https://open.er-api.com/v6/latest/$_baseCurrency';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      final data = json.decode(response.body);

      setState(() {
        _exchangeRates = data['rates'];
      });
    } catch (error) {
      print('Error fetching exchange rates: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
        backgroundColor: Colors.blue,
      ),
      body: _exchangeRates != null
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCard(
                    label: 'Base Currency',
                    value: _baseCurrency,
                    onChanged: (value) {
                      setState(() {
                        _baseCurrency = value as String;
                        _fetchExchangeRates();
                      });
                    },
                  ),
                  _buildCard(
                    label: 'Target Currency',
                    value: _targetCurrency,
                    onChanged: (value) {
                      setState(() {
                        _targetCurrency = value as String;
                      });
                    },
                  ),
                  _buildResult(),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange),
            label: 'Currencies',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildCard({
    required String label,
    required String value,
    required Function onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                value: value,
                items: _exchangeRates!.keys
                    .map<DropdownMenuItem<String>>(
                      (currencyCode) => DropdownMenuItem<String>(
                        value: currencyCode,
                        child: Text(currencyCode),
                      ),
                    )
                    .toList(),
                onChanged: onChanged as void Function(String?),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final baseRate = _exchangeRates![_baseCurrency];
    final targetRate = _exchangeRates![_targetCurrency];

    if (baseRate != null && targetRate != null) {
      final result = targetRate / baseRate;

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '1 $_baseCurrency = $result $_targetCurrency',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
