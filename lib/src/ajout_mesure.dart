import 'dart:math';

import 'package:faani/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../my_theme.dart';
// import '../my_theme.dart';

class AjoutMesure extends StatelessWidget {
  const AjoutMesure({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 240, 236, 236),
      ),
      body: Container(
        color: const Color.fromARGB(255, 240, 236, 236),
        height: double.infinity,
        child: Column(
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Image.asset('assets/images/measurement.png')),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Column(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const MesurePaveView()));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 28.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: inputBorderColor, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/manual_measurements.png',
                              width: 35,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              'Ajout manuel',
                              style:
                                  TextStyle(fontSize: 18, color: primaryColor),
                            )
                          ],
                        ),
                      )),
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Fonctionnalité en cours'),
                              content: const Text('Arrive bientôt!  😊'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 28.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: inputBorderColor, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_sharp, color: primaryColor),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Par caméra',
                              style:
                                  TextStyle(fontSize: 18, color: primaryColor),
                            )
                          ],
                        ),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MesurePaveView extends StatefulWidget {
  const MesurePaveView({super.key});

  @override
  State<MesurePaveView> createState() => _MesurePaveViewState();
}

class _MesurePaveViewState extends State<MesurePaveView> {
  final PageController _pageController = PageController(initialPage: 0);
  TextEditingController _epauleController = TextEditingController();
  TextEditingController _coudController = TextEditingController();
  TextEditingController _poitrineController = TextEditingController();
  TextEditingController _longeurController = TextEditingController();
  TextEditingController _hancheController = TextEditingController();
  TextEditingController _brasController = TextEditingController();
  int _currentValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 240, 236, 236),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
        title: Row(
          children: [
            const Text(''),
            const Spacer(),
            IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close, color: Colors.black))
          ],
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 240, 236, 236),
        child: Container(
          child: PageView(
            controller: _pageController,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  const Text('1/6',
                      style: TextStyle(fontSize: 20, color: primaryColor)),
                  const SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/images/epaules.jpg')),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 58.0),
                    child: Row(
                      children: [
                        const Text(
                          'Epaules',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        Spacer(),
                        Container(
                          width: 100,
                          height: 40,
                          child: TextField(
                            controller: _epauleController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ], // Allow only digits
                            onChanged: (value) {
                              _currentValue = int.tryParse(value) ?? 0;
                            },
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: inputBorderColor,
                                width: 1,
                              )),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: inputBorderColor,
                                width: 1,
                                // )),
                              )),
                              suffixIcon: SizedBox(
                                height: 24,
                                width: 50,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            _currentValue++;
                                            _epauleController.text =
                                                _currentValue.toString();
                                          });
                                        },
                                        child: const Icon(Icons.arrow_drop_up),
                                      ),
                                    ),
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            _currentValue =
                                                max(0, _currentValue - 1);
                                            _epauleController.text =
                                                _currentValue.toString();
                                          });
                                        },
                                        child:
                                            const Icon(Icons.arrow_drop_down),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Text('Cm'),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 200,
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: inputBorderColor, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: const Text(
                          'Continuer',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: primaryColor,
                          ),
                        ),
                      ))
                ]),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  const Text('2/6',
                      style: TextStyle(fontSize: 20, color: primaryColor)),
                  const SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/images/epaules.jpg')),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 58.0),
                    child: Row(
                      children: [
                        const Text(
                          'Poitrine',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        Spacer(),
                        Container(
                          width: 100,
                          height: 40,
                          child: TextField(
                            controller: _poitrineController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ], // Allow only digits
                            onChanged: (value) {
                              _currentValue = int.tryParse(value) ?? 0;
                            },
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: inputBorderColor,
                                width: 1,
                              )),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: inputBorderColor,
                                width: 1,
                                // )),
                              )),
                              suffixIcon: SizedBox(
                                height: 24,
                                width: 50,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            _currentValue++;
                                            _epauleController.text =
                                                _currentValue.toString();
                                          });
                                        },
                                        child: const Icon(Icons.arrow_drop_up),
                                      ),
                                    ),
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            _currentValue =
                                                max(0, _currentValue - 1);
                                            _epauleController.text =
                                                _currentValue.toString();
                                          });
                                        },
                                        child:
                                            const Icon(Icons.arrow_drop_down),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Text('Cm'),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 200,
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: inputBorderColor, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: const Text(
                          'Continuer',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: primaryColor,
                          ),
                        ),
                      ))
                ]),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  const Text('3/6',
                      style: TextStyle(fontSize: 20, color: primaryColor)),
                  const SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/images/epaules.jpg')),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 58.0),
                    child: Row(
                      children: [
                        const Text(
                          'Coude',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        Spacer(),
                        Container(
                          width: 100,
                          height: 40,
                          child: TextField(
                            controller: _coudController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ], // Allow only digits
                            onChanged: (value) {
                              _currentValue = int.tryParse(value) ?? 0;
                            },
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: inputBorderColor,
                                width: 1,
                              )),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: inputBorderColor,
                                width: 1,
                                // )),
                              )),
                              suffixIcon: SizedBox(
                                height: 24,
                                width: 50,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            _currentValue++;
                                            _epauleController.text =
                                                _currentValue.toString();
                                          });
                                        },
                                        child: const Icon(Icons.arrow_drop_up),
                                      ),
                                    ),
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            _currentValue =
                                                max(0, _currentValue - 1);
                                            _epauleController.text =
                                                _currentValue.toString();
                                          });
                                        },
                                        child:
                                            const Icon(Icons.arrow_drop_down),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Text('Cm'),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 200,
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: inputBorderColor, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: const Text(
                          'Continuer',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: primaryColor,
                          ),
                        ),
                      ))
                ]),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  const Text('4/6',
                      style: TextStyle(fontSize: 20, color: primaryColor)),
                  const SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/images/epaules.jpg')),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 58.0),
                    child: Row(
                      children: [
                        const Text(
                          'Longueur',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        Spacer(),
                        Container(
                          width: 100,
                          height: 40,
                          child: TextField(
                            controller: _longeurController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ], // Allow only digits
                            onChanged: (value) {
                              _currentValue = int.tryParse(value) ?? 0;
                            },
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: inputBorderColor,
                                width: 1,
                              )),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: inputBorderColor,
                                width: 1,
                                // )),
                              )),
                              suffixIcon: SizedBox(
                                height: 24,
                                width: 50,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            _currentValue++;
                                            _epauleController.text =
                                                _currentValue.toString();
                                          });
                                        },
                                        child: const Icon(Icons.arrow_drop_up),
                                      ),
                                    ),
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            _currentValue =
                                                max(0, _currentValue - 1);
                                            _epauleController.text =
                                                _currentValue.toString();
                                          });
                                        },
                                        child:
                                            const Icon(Icons.arrow_drop_down),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Text('Cm'),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 200,
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: inputBorderColor, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: const Text(
                          'Continuer',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: primaryColor,
                          ),
                        ),
                      ))
                ]),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  const Text('5/6',
                      style: TextStyle(fontSize: 20, color: primaryColor)),
                  const SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/images/epaules.jpg')),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 58.0),
                    child: Row(
                      children: [
                        const Text(
                          'Hanche',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        Spacer(),
                        Container(
                          width: 100,
                          height: 40,
                          child: TextField(
                            controller: _hancheController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ], // Allow only digits
                            onChanged: (value) {
                              _currentValue = int.tryParse(value) ?? 0;
                            },
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: inputBorderColor,
                                width: 1,
                              )),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: inputBorderColor,
                                width: 1,
                                // )),
                              )),
                              suffixIcon: SizedBox(
                                height: 24,
                                width: 50,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            _currentValue++;
                                            _epauleController.text =
                                                _currentValue.toString();
                                          });
                                        },
                                        child: const Icon(Icons.arrow_drop_up),
                                      ),
                                    ),
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            _currentValue =
                                                max(0, _currentValue - 1);
                                            _epauleController.text =
                                                _currentValue.toString();
                                          });
                                        },
                                        child:
                                            const Icon(Icons.arrow_drop_down),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Text('Cm'),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 200,
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: inputBorderColor, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: const Text(
                          'Continuer',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: primaryColor,
                          ),
                        ),
                      ))
                ]),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  const Text('6/6',
                      style: TextStyle(fontSize: 20, color: primaryColor)),
                  const SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/images/epaules.jpg')),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 58.0),
                    child: Row(
                      children: [
                        const Text(
                          'Bras',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        Spacer(),
                        Container(
                          width: 100,
                          height: 40,
                          child: TextField(
                            controller: _brasController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ], // Allow only digits
                            onChanged: (value) {
                              _currentValue = int.tryParse(value) ?? 0;
                            },
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: inputBorderColor,
                                width: 1,
                              )),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: inputBorderColor,
                                width: 1,
                                // )),
                              )),
                              suffixIcon: SizedBox(
                                height: 24,
                                width: 50,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            _currentValue++;
                                            _epauleController.text =
                                                _currentValue.toString();
                                          });
                                        },
                                        child: const Icon(Icons.arrow_drop_up),
                                      ),
                                    ),
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            _currentValue =
                                                max(0, _currentValue - 1);
                                            _epauleController.text =
                                                _currentValue.toString();
                                          });
                                        },
                                        child:
                                            const Icon(Icons.arrow_drop_down),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Text('Cm'),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 200,
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: inputBorderColor, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: const Text(
                          'Continuer',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: primaryColor,
                          ),
                        ),
                      ))
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
