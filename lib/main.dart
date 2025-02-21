import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scientific Calculator',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  CalculatorScreenState createState() => CalculatorScreenState();
}

class CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '';
  bool _isScientific = false;
  bool _isDarkMode = false;

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        _expression = '';
        _result = '';
      } else if (buttonText == '=') {
        try {
          String parsedExpression = _expression
              .replaceAll('×', '*')
              .replaceAll('÷', '/')
              .replaceAll('%', '*0.01')
              .replaceAll('^', '^')
              .replaceAll('√', 'sqrt')
              .replaceAll('π', 'pi')
              .replaceAll('eˣ', 'e^');

          Parser p = Parser();
          Expression exp = p.parse(parsedExpression);
          ContextModel cm = ContextModel();
          double evalResult = exp.evaluate(EvaluationType.REAL, cm);
          _result = evalResult.toString().replaceAllMapped(
              RegExp(r'\.0$'), (Match m) => ''); // Remove trailing .0
        } catch (e) {
          _result = 'Error';
        }
      } else if (buttonText == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (buttonText == '()') {
        final openCount = _expression.split('(').length - 1;
        final closeCount = _expression.split(')').length - 1;
        _expression += openCount <= closeCount ? '(' : ')';
      } else if (buttonText == '(-)') {
        _expression += '-';
      } else if (buttonText =='sin⁻¹') {
        _expression += 'asin(';
      } else if (buttonText =='cos⁻¹') {
        _expression += 'acos(';
      } else if (buttonText =='tan⁻¹') {
        _expression += 'atan(';
      } else {
        if ([
          'sin',
          'cos',
          'tan',
          'ln',
          'log',
          '√',
          'eˣ'
        ].contains(buttonText)) {
          _expression += '${buttonText.replaceAll('√', 'sqrt')}(';
        } else {
          _expression += buttonText;
        }
      }
    });
  }

  Widget _buildButton(String buttonText,
      {Color? backgroundColor,
        Color textColor = Colors.white,
        bool isRound = true,
        double fontSize = 26}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: isRound
                ? const CircleBorder()
                : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(24), // Fixed padding for all buttons
          ),
          onPressed: () => _onButtonPressed(buttonText),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: _isScientific
                    ? (buttonText.length > 4 ? 20 : 24) // Text size adjustment only
                    : 26,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScientificButtonRow(List<String> buttons) {
    return Row(
      children: buttons
          .map((text) => _buildButton(text,
        backgroundColor: const Color(0xFF2E3743),
        textColor: Colors.white,
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF1D2630) : Colors.white,
      appBar: AppBar(
        backgroundColor: _isDarkMode ? const Color(0xFF1D2630) : Colors.white,
        elevation: 0,
        title: Text(
          _isScientific ? 'Scientific Calculator' : 'Simple Calculator',
          style: TextStyle(
            fontSize: 28,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          Switch(
            value: _isDarkMode,
            onChanged: (value) => setState(() => _isDarkMode = value),
            activeColor: Colors.lightBlueAccent,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Dark Mode',
                style: TextStyle(
                  fontSize: 16,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          Switch(
            value: _isScientific,
            onChanged: (value) => setState(() => _isScientific = value),
            activeColor: Colors.greenAccent,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'SCI',
                style: TextStyle(
                  fontSize: 16,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: TextStyle(
                      fontSize: 24,
                      color: _isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    _result.isEmpty ? '' : _result,
                    style: TextStyle(
                      fontSize: 40,
                      color: _isDarkMode ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: _isScientific
                ? [
              Row(children: [
                _buildButton('AC', backgroundColor: Color(0xFF636B75)),
                _buildButton('^', backgroundColor: Color(0xFF636B75)),
                _buildButton('√', backgroundColor: Color(0xFF636B75)),
                _buildButton('÷', backgroundColor: Color(0xFF636B75)),
              ]),
              _buildScientificButtonRow(['sin', 'cos', 'tan', '×']),
              _buildScientificButtonRow(['sin⁻¹', 'cos⁻¹', 'tan⁻¹', '-']),
              _buildScientificButtonRow(['log', 'ln', 'π', '+']),
              Row(children: [
                _buildButton('(-)', backgroundColor: Color(0xFF2E3743)),
                _buildButton('0', backgroundColor: Color(0xFF2E3743)),
                _buildButton('.', backgroundColor: Color(0xFF2E3743)),
                _buildButton('=',
                    backgroundColor: Color(0xFF3D9568), isRound: true),
              ]),
            ]
                : [
              Row(children: [
                _buildButton('AC', backgroundColor: Color(0xFF636B75)),
                _buildButton('()', backgroundColor: Color(0xFF636B75)),
                _buildButton('%', backgroundColor: Color(0xFF636B75)),
                _buildButton('÷', backgroundColor: Color(0xFF636B75)),
              ]),
              Row(children: [
                _buildButton('7', backgroundColor: Color(0xFF2E3743)),
                _buildButton('8', backgroundColor: Color(0xFF2E3743)),
                _buildButton('9', backgroundColor: Color(0xFF2E3743)),
                _buildButton('×', backgroundColor: Color(0xFF636B75)),
              ]),
              Row(children: [
                _buildButton('4', backgroundColor: Color(0xFF2E3743)),
                _buildButton('5', backgroundColor: Color(0xFF2E3743)),
                _buildButton('6', backgroundColor: Color(0xFF2E3743)),
                _buildButton('-', backgroundColor: Color(0xFF636B75)),
              ]),
              Row(children: [
                _buildButton('1', backgroundColor: Color(0xFF2E3743)),
                _buildButton('2', backgroundColor: Color(0xFF2E3743)),
                _buildButton('3', backgroundColor: Color(0xFF2E3743)),
                _buildButton('+', backgroundColor: Color(0xFF636B75)),
              ]),
              Row(children: [
                _buildButton('+/-', backgroundColor: Color(0xFF2E3743)),
                _buildButton('0', backgroundColor: Color(0xFF2E3743)),
                _buildButton('.', backgroundColor: Color(0xFF2E3743)),
                _buildButton('=',
                    backgroundColor: Color(0xFF3D9568), isRound: true),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}