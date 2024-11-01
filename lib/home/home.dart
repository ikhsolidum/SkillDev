import 'package:flutter/material.dart';
import 'package:skilldev_mobapp/login/logout.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;

class HomePage extends StatefulWidget {
  final String email;
  final String password;
  final String username;  // Add username parameter
  final String? profileImagePath;

  HomePage({
    required this.email,
    required this.password,
    required this.username,  // Make username required
    this.profileImagePath,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _email;
  late String _username;  // Change to late initialization
  late Widget _profileImageWidget;

  @override
  void initState() {
    super.initState();
    _email = widget.email;
    _username = widget.username;  // Use the passed username instead of email split
    _initializeProfileImage();
  }

  void _initializeProfileImage() {
    if (widget.profileImagePath != null && widget.profileImagePath!.isNotEmpty) {
      if (kIsWeb) {
        // For web platform
        _profileImageWidget = Image.network(
          widget.profileImagePath!,
          fit: BoxFit.cover,
        );
      } else {
        // For mobile platform
        _profileImageWidget = Image.file(
          File(widget.profileImagePath!),
          fit: BoxFit.cover,
        );
      }
    } else {
      // Fallback to default asset image
      _profileImageWidget = Image.asset(
        'assets/images/profile.jpg',
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 110, 227, 192),
                  Colors.white,
                ],
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // App Bar with menu button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return NavigationBar(
                                email: _email,
                                username: _username,
                                profileImageWidget: _profileImageWidget,
                              );
                            },
                            backgroundColor: Colors.transparent,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.menu, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),

                // Welcome section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        _username,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick actions grid
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(24),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: [
                        _buildQuickActionCard(
                          'My Files',
                          Icons.folder,
                          () {
                            // Navigate to files
                          },
                        ),
                        _buildQuickActionCard(
                          'Enroll Now',
                          Icons.school,
                          () {
                            // Navigate to enrollment
                          },
                        ),
                        _buildQuickActionCard(
                          'Settings',
                          Icons.settings,
                          () {
                            // Navigate to settings
                          },
                        ),
                        _buildQuickActionCard(
                          'Help',
                          Icons.help,
                          () {
                            // Navigate to help
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 110, 227, 192).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: Color.fromARGB(255, 110, 227, 192),
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationBar extends StatelessWidget {
  final String email;
  final String username;
  final Widget profileImageWidget;

  NavigationBar({
    required this.email,
    required this.username,
    required this.profileImageWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Profile section
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: ClipOval(child: profileImageWidget),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Navigation items
          _buildNavItem(context, 'Files', Icons.folder),
          _buildNavItem(context, 'Settings', Icons.settings),
          _buildNavItem(context, 'Enroll', Icons.school),
          _buildNavItem(context, 'Help', Icons.help),
          Divider(),
          // Logout item
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // Close the navigation drawer first
              Navigator.pop(context);
              
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm Logout'),
                    content: Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          LogoutHandler.logout(context);
                        },
                        child: Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : Color.fromARGB(255, 110, 227, 192),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (isLogout) {
          // Handle logout
          Navigator.of(context).pushReplacementNamed('/login');
        } else {
          // Handle navigation
        }
      },
    );
  }
}