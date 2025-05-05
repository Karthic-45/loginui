import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/colors.dart'; // Assuming colors.dart exists and has primaryColor

// If you have a colors.dart file, you can import it:
// import 'colors.dart';

// Assuming LoginScreen is in this file or imported correctly
import 'login_screen.dart'; // Make sure this file exists and contains LoginScreen

// Main entry point of the application
void main() {
  // Ensure Flutter bindings are initialized for plugins like Firebase
  WidgetsFlutterBinding.ensureInitialized();
  // IMPORTANT: Initialize Firebase before runApp if you haven't elsewhere
  // WidgetsFlutterBinding.ensureInitialized(); // Already called above
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform, // Use flutterfire_cli generated options
  // );
  runApp(MyApp());
}

// The root widget of the application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // --- Global Theme Definition ---
      theme: ThemeData(
        // Set the primary color swatch for the app (defines primaryColor)
        primarySwatch: Colors.blue, // This makes Colors.blue the primaryColor
        // Define the global theme for all ElevatedButtons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            // Set a distinct background color
            backgroundColor: MaterialStateProperty.all<Color>(
              primaryColor, // Use primaryColor from colors.dart
            ),
            // Set the text/icon color for contrast
            foregroundColor: MaterialStateProperty.all<Color>(
              Colors.white, // White text usually looks good on colored buttons
            ),
            // Define the button shape (rounded corners)
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0), // Rounded corners
              ),
            ),
            // Add padding inside the button
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            // Set the shadow elevation
            elevation: MaterialStateProperty.all<double>(5.0),
            // Optional: Customize the text style (e.g., make it bold)
            textStyle: MaterialStateProperty.all<TextStyle>(
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
        // Define AppBar theme globally (optional but good practice)
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor, // Explicitly set AppBar color
          // CHANGED: Set foregroundColor to primaryColor for title and icons
          foregroundColor: primaryColor, // Color for icons and text in AppBar
        ),
        // Define BottomNavigationBar theme (optional)
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: primaryColor, // Use primary color for selected item
          unselectedItemColor: Colors.grey, // Set unselected color for contrast
        ),
      ),
      // --- End of Theme Definition ---
      // Use an AuthWrapper or similar logic to show LoginScreen or HomeScreen
      // based on Firebase Auth state for a real app.
      // For this example, we directly go to HomeScreen, assuming login happened before.
      home: HomeScreen(), // Set the initial screen
    );
  }
}

// The main screen of the application displaying food items
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();

  // Sample list of food items (banners) - unchanged
  final List<Map<String, dynamic>> Bannerslist = [
    {
      "image":
      "https://www.inspiredtaste.net/wp-content/uploads/2022/10/Baked-French-Fries-Recipe-2-1200.jpg",
      "title": "French Fries",
      "rating": 4.5,
      "category": "Cafe Western Food",
      "price": 120
    },
    {
      "image":
      "https://media.istockphoto.com/id/1442417585/photo/person-getting-a-piece-of-cheesy-pepperoni-pizza.jpg?s=1024x1024&w=is&k=20&c=faq73viCFGvfpKxcBuHcOI8kyT99B-p-jScipke-VuQ=",
      "title": "Cheesy Pizza",
      "rating": 4.7,
      "category": "Italian",
      "price": 220
    },
    {
      "image":
      "https://melam.com/wp-content/uploads/2022/12/ambur-biriyani-600x400.jpg",
      "title": "Spicy Biryani",
      "rating": 4.6,
      "category": "Indian",
      "price": 180
    },
    {
      "image":
      "https://images.immediate.co.uk/production/volatile/sites/30/2023/07/Chicken-burger-recipes-d0908a0.jpg?quality=90&webp=true&resize=375,341",
      "title": "Chicken Burger",
      "rating": 4.4,
      "category": "Fast Food",
      "price": 150
    },
    {
      "image":
      "https://blog.livpure.com/wp-content/uploads/2022/04/colorful-soda-drinks-macro-shot-300x200.jpg",
      "title": "Cold Drinks",
      "rating": 4.3,
      "category": "Beverages",
      "price": 80
    },
  ];

  // State variables - unchanged
  List<Map<String, dynamic>> filteredList = [];
  List<Map<String, dynamic>> cartItems = [];
  final List<String> categories = [
    'All',
    'Cafe Western Food',
    'Italian',
    'Indian',
    'Fast Food',
    'Beverages'
  ];
  String selectedCategory = 'All';
  String? userEmail; // Holds the logged-in user's email

  @override
  void initState() {
    super.initState();
    filteredList = List.from(Bannerslist);

    // --- Fetch User Email ---
    // This correctly gets the email IF the user is logged in when HomeScreen loads.
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Use setState to ensure the UI updates if the user data retrieval is async
      // (though currentUser is usually synchronous)
      setState(() {
        userEmail = user.email;
        print("User Email Found: $userEmail"); // Debug print
      });
    } else {
      print("No Firebase user found on HomeScreen init."); // Debug print
    }
    // --- End Fetch User Email ---

    // Optional: Listen for auth state changes if login can happen while HomeScreen is active
    // FirebaseAuth.instance.authStateChanges().listen((User? user) {
    //   if (user == null) {
    //     print('User is currently signed out!');
    //     setState(() { userEmail = null; });
    //   } else {
    //     print('User is signed in! Email: ${user.email}');
    //     setState(() { userEmail = user.email; });
    //   }
    // });
  }

  // Filter the list based on search query and selected category - unchanged
  void filterSearch(String query) {
    setState(() {
      filteredList = Bannerslist.where((item) {
        final title = item['title'].toString().toLowerCase();
        final category = item['category'].toString();
        final matchesSearch =
            query.isEmpty || title.contains(query.toLowerCase());
        final matchesCategory =
            selectedCategory == 'All' || category == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  // Add an item to the shopping cart or increase its quantity - unchanged
  void addToCart(Map<String, dynamic> item) {
    setState(() {
      int existingIndex =
      cartItems.indexWhere((cartItem) => cartItem['title'] == item['title']);
      if (existingIndex != -1) {
        cartItems[existingIndex]['quantity']++;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${item['title']} quantity increased'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating, // Optional: Make SnackBar float
        ));
      } else {
        Map<String, dynamic> newItem = Map.from(item);
        newItem['quantity'] = 1;
        cartItems.add(newItem);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${item['title']} added to cart'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ));
      }
    });
  }

  // Remove an item from the shopping cart (decreases quantity or removes) - unchanged
  void removeFromCart(Map<String, dynamic> item) {
    setState(() {
      int existingIndex =
      cartItems.indexWhere((cartItem) => cartItem['title'] == item['title']);
      if (existingIndex != -1) {
        if (cartItems[existingIndex]['quantity'] > 1) {
          cartItems[existingIndex]['quantity']--;
        } else {
          cartItems.removeAt(existingIndex);
        }
        // Close and reopen the dialog to reflect changes
        // This ensures the dialog UI updates correctly.
        Navigator.of(context).pop();
        _showCartDialog();
      }
    });
  }

  // Calculate the total price of items in the cart - unchanged
  int calculateTotal() {
    num total =
    cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
    return total.toInt();
  }

  // Log the user out using Firebase Auth and navigate to LoginScreen - unchanged
  void logout() async {
    await FirebaseAuth.instance.signOut();
    // Use pushReplacement to ensure user can't navigate back to HomeScreen after logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Get the current device location using Geolocator - unchanged
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location services are disabled. Please enable them.')));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location permissions are permanently denied.')));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Current Location: Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}"), // Format coords
      ));
      print("Current Location: ${position.latitude}, ${position.longitude}");

    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get current location.')));
    }
  }

  // Helper method to show the cart dialog - unchanged
  void _showCartDialog() {
    if (!mounted) return; // Check if the widget is still in the tree
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use StatefulBuilder ONLY if you need the dialog itself to update state
        // without closing/reopening. Since removeFromCart closes/reopens it,
        // StatefulBuilder isn't strictly necessary here but doesn't hurt.
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Shopping Cart'), // More descriptive title
            contentPadding:
            const EdgeInsets.fromLTRB(20, 20, 20, 0), // Adjust padding
            content: SizedBox(
              // Constrain height if cart gets very long
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (cartItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text("Your cart is empty.",
                            style: TextStyle(fontSize: 16)),
                      )
                    else
                    // Use ListView for better structure if list is long
                      ListView.separated(
                        shrinkWrap: true,
                        physics:
                        const NeverScrollableScrollPhysics(), // Let AlertDialog handle scroll
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                item['image'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: Icon(Icons.error_outline)),
                              ),
                            ),
                            title: Text(item['title']),
                            subtitle: Text('Qty: ${item['quantity']}'),
                            trailing: Row(
                              // Price and remove button
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('₹${item['price'] * item['quantity']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.red),
                                  padding: EdgeInsets.zero,
                                  constraints:
                                  const BoxConstraints(), // Remove extra padding
                                  onPressed: () => removeFromCart(item),
                                ),
                              ],
                            ),
                            contentPadding: EdgeInsets.zero, // Remove ListTile padding
                          );
                        },
                        separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                      ),
                    const Divider(),
                    // Display total only if cart is not empty
                    if (cartItems.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "Total: ₹${calculateTotal()}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween, // Align actions
            actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              if (cartItems.isNotEmpty)
                ElevatedButton(
                  // Checkout button uses global theme
                  onPressed: () {
                    // TODO: Implement actual checkout navigation/logic
                    print("Checkout button pressed. Total: ${calculateTotal()}");
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Proceeding to checkout (not implemented)')),
                    );
                  },
                  child: const Text('Checkout'),
                )
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get primary color from theme for reuse
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        // Use primary color from theme variable
        backgroundColor: Colors.blue,
        toolbarHeight: 120,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // These text widgets are not affected by AppBar's foregroundColor
            const Text("Delivering to",
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            InkWell(
              onTap: _getCurrentLocation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("Current location",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Icon(Icons.keyboard_arrow_down, size: 30, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.blue), // Use primary color
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: filterSearch,
                      decoration: const InputDecoration(
                        hintText: "Search Foods",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      print("Filter button clicked");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Filter functionality not implemented')),
                      );
                    },
                    // Use primary color for filter icon
                    icon: Icon(Icons.filter_alt_outlined, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // This icon's color is now primaryColor due to AppBarTheme
          IconButton(
            icon: const Icon(Icons.shopping_cart, size: 30,color: Colors.white,),
            onPressed: _showCartDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedCategory = cat;
                                filterSearch(searchController.text);
                              });
                            }
                          },
                          selectedColor: Colors.blue, // Use primary color
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          pressElevation: 5,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Use titleWidget - it will now use primaryColor
              titleWidget(context, "Popular Dishes",),
              const SizedBox(height: 15),
              if (filteredList.isEmpty)
                Center(
                  /* Placeholder - unchanged */
                )
              else
                ListView.builder(
                  /* List rendering - unchanged */
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              /* Image - unchanged */
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                item['image'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey.shade200,
                                      child: Icon(Icons.broken_image,
                                          color: Colors.grey.shade400),
                                    ),
                                loadingBuilder: (context, child, loadingProgress) {
                                  /* Loading indicator - unchanged */
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes !=
                                            null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              /* Details - unchanged */
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'],
                                    style: const TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['category'],
                                    style: TextStyle(
                                        color: Colors.grey.shade600, fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    /* Price and Button - unchanged */
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "₹${item['price']}",
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87),
                                      ),
                                      ElevatedButton(
                                        // Uses global theme style
                                        onPressed: () => addToCart(item),
                                        child: const Text("Add to Cart",),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        /* Styling uses theme - unchanged */
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const OrderHistoryScreen()));
          } else if (index == 2) {
            _showProfileMenu(context);
          }
        },
      ),
    );
  }

  // Function to show the profile menu using a Modal Bottom Sheet - UPDATED for attractiveness
  void _showProfileMenu(BuildContext context) {
    if (!mounted) return; // Check if widget is mounted
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Make background transparent
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          // Wrap with Container for background color and rounded corners
          decoration: const BoxDecoration(
            color: Colors.white, // White background for the sheet content
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Optional: Add a subtle drag handle
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),
              // User Info Section (Optional: Add Avatar)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24, // Adjust size as needed
                      // backgroundColor: Theme.of(context)
                      //     .primaryColor,
                      //Use primary color for avatar background
                      backgroundColor: Colors.blue,
                      child: Text(
                        userEmail != null && userEmail!.isNotEmpty
                            ? userEmail![0].toUpperCase()
                            : '?', // Display first letter or ?
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Logged in as:",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            userEmail ?? "Not logged in", // Display email or message
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow
                                .ellipsis, // Prevent long emails from overflowing
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 30, thickness: 1), // More prominent divider

              // Menu Options with enhanced styling
              // _buildProfileMenuItem(
              //   context,
              //   icon: Icons.history_outlined,
              //   title: 'Order History',
              //   onTap: () {
              //     Navigator.pop(context); // Close bottom sheet
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => const OrderHistoryScreen()));
              //   },
              // ),
              _buildProfileMenuItem(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Settings clicked (not implemented)")),
                  );
                },
              ),
              _buildProfileMenuItem(
                context,
                icon: Icons.logout,
                title: 'Logout',
                color: Colors.red.shade700, // Red color for logout
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  logout();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Helper method to build attractive profile menu items
  Widget _buildProfileMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        Color? color, // Optional color for the icon and text
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color:
        color ?? Theme.of(context).primaryColor, // Use provided color or primary
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: color ?? Colors.black87, // Use provided color or dark gray
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 18, color: Colors.grey), // Add a trailing icon
      onTap: onTap,
      // Add a subtle visual effect on tap
      tileColor: Colors.transparent, // Ensure no default tile color
      hoverColor: Colors.grey.shade200, // Highlight on hover
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 24.0, vertical: 4.0), // Adjust padding
    );
  }

  // ----- Helper widget for creating styled section titles -----
  // ----- UPDATED to use primaryColor from the theme -----
  Widget titleWidget(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        // Use the primary color defined in the app's theme
        color: Theme.of(context).primaryColor,
      ),
    );
  }
// ----- End of updated titleWidget -----
}

// Placeholder screen for Order History - unchanged
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        // AppBar uses theme background color implicitly if not overridden
      ),
      body: const Center(
        child: Text(
          "No order history yet.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}