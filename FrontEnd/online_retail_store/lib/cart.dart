import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'paymentDetails.dart';

class CartItem {
  late String product;
  late String brand;
  late String cost;
  late int quantity;
  late String totalCost;
  late String image;

  CartItem(
      {required this.product,
      required this.brand,
      required this.cost,
      required this.quantity,
      required this.totalCost});
}

class Cart extends StatefulWidget {
  final String username;
  const Cart({Key? key, required this.username}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  late String _username;
  int userid = 0;
  late String name;
  late String email;
  late String mobileNumber;
  String grandTotal = 'Loading';
  String address = 'Loading';
  FocusNode couponFocus = FocusNode();
  late String coupon;

  @override
  void initState() {
    super.initState();
    _username = widget.username;

    print(_username);
  }

  Future<String> total() async {
    var total = await http.get(Uri.parse('http://127.0.0.1:5000/cartTotal/'));
    var gtotal = json.decode(total.body);

    grandTotal = gtotal[userid - 1][1];
    return grandTotal;
  }

  Future<String> addressGet() async {
    var data = await http.get(Uri.parse(
        'http://127.0.0.1:5000/getUserDetailsFromEmail/' +
            "'" +
            _username +
            "'"));
    var jsonData = json.decode(data.body);
    address = jsonData[0][1];
    return address;
  }

  Widget buildCoupon() {
    @override
    void dispose() {
      couponFocus.dispose();
      super.dispose();
    }

    void requestFocus() {
      setState(() {
        FocusScope.of(context).requestFocus(couponFocus);
      });
    }

    return Container(
      width: MediaQuery.of(context).size.width - 90,
      child: TextFormField(
        focusNode: couponFocus,
        onTap: () {
          requestFocus();
        },
        decoration: InputDecoration(
          focusColor: Colors.teal,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal),
          ),
          labelText: "Enter Coupon Code",
          labelStyle: TextStyle(
            color: couponFocus.hasFocus ? Colors.teal : Colors.black,
          ),
        ),
        maxLength: 30,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Password cannot be empty";
          }
          return null;
        },
        onSaved: (value) {
          if (value != null) coupon = value;
        },
      ),
    );
  }

  Widget generateCards() {
    double h = 400;
    return Container(
      height: h,
      child: FutureBuilder(
          future: getUserData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              h = 600;
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 120,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ClipOval(
                          child: Image.network(
                            snapshot.data[index].image,
                            width: 80,
                            height: 180,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Center(
                                    child: Text(
                                      '${snapshot.data[index].brand}' +
                                          " " +
                                          '${snapshot.data[index].product}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                  )),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${snapshot.data[index].cost}' +
                                      " x " +
                                      '${snapshot.data[index].quantity}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${snapshot.data[index].totalCost}',
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            } else {
              h = 40;
              return Container(
                height: 40,
                child: Text('Loading'),
              );
            }
          }),
    );
  }

  Widget AddressBar() {
    return Container(
      child: FutureBuilder(
          future: total(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return Container(
                  height: 70,
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Delivery to',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Edit',
                              style:
                                  TextStyle(color: Colors.teal, fontSize: 13),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '$address',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ));
            } else
              return Container();
          }),
    );
  }

  Widget generateTotal() {
    return Container(
      child: FutureBuilder(
          future: total(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return Container(
                  height: 80,
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Grand Total',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              '₹',
                              style:
                                  TextStyle(color: Colors.teal, fontSize: 13),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '${snapshot.data}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ));
            } else
              return Container();
          }),
    );
  }

  Future<List<CartItem>> getUserData() async {
    var data = await http.get(Uri.parse(
        'http://127.0.0.1:5000/getUserDetailsFromEmail/' +
            "'" +
            _username +
            "'"));
    var jsonData = json.decode(data.body);
    userid = jsonData[0][0];
    name = jsonData[0][2];

    address = jsonData[0][1];

    email = jsonData[0][3];
    mobileNumber = jsonData[0][5];

    var cartData = await http.get(
        Uri.parse('http://127.0.0.1:5000/cartDetails/' + userid.toString()));

    var cartDecode = json.decode(cartData.body);
    print('here');
    print(cartDecode);
    print('gone');
    List<CartItem> cartItemList = [];
    for (var prod in cartDecode) {
      CartItem temp = new CartItem(
          product: prod[0],
          brand: prod[1],
          cost: prod[2],
          quantity: prod[3],
          totalCost: prod[4]);

      var links = await http.get(Uri.parse(
          'http://127.0.0.1:5000/getProductImage/' + prod[1] + '/' + prod[0]));

      var link = json.decode(links.body);
      temp.image = link;
      cartItemList.add(temp);
    }

    var total = await http.get(Uri.parse('http://127.0.0.1:5000/cartTotal/'));
    var gtotal = json.decode(total.body);

    grandTotal = gtotal[userid][1];

    return cartItemList;
  }

  Widget work() {
    setState(() {
      grandTotal = grandTotal;
    });
    return SizedBox(
      height: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          height: 1200,
          child: Column(
            children: [
              Text('This is the cart'),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.keyboard_arrow_left),
              ),
              Text('Welcome $_username'),
              generateCards(),
              AddressBar(),
              generateTotal(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Got a coupon ? Apply here',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildCoupon(),
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width - 60,
                  decoration: BoxDecoration(
                    color: Colors.teal[500],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                      child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(context, PageRouteBuilder(
                                pageBuilder: (BuildContext context, _, __) {
                              return PaymentForm();
                            }));
                          },
                          icon: Icon(
                            Icons.money,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Proceed to Payment',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color.fromARGB(255, 0, 150, 136)),
                          ),
                        ),
                      )
                    ],
                  )))
            ],
          ),
        ),
      )),
    );
  }
}
