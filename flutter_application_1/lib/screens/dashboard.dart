import 'package:flutter/material.dart';
import 'profile.dart'; // Profile page
import 'sign_in.dart'; // Login page
import 'devices.dart'; // Device management page

class DashboardPage extends StatefulWidget {
  final bool showSignUpSuccess;
  const DashboardPage({super.key, this.showSignUpSuccess = false});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // default select
  String selectedItem = "John's Cane";

  // list of all linked canes
  final List<String> caneList = [];

  // color
  final Color primaryBlue = const Color(0xFF0057B8);

  @override
  void initState() {
    super.initState();
    if (widget.showSignUpSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign up success'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  // show "no notifications" popup
  void _showNotificationPopover(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(Offset.zero, ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: const [
        PopupMenuItem(
          child: Text('No notifications yet'),
        ),
      ],
    );
  }

  // show menu, Profile and Logout options
  void _showProfilePopover(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(Offset.zero, ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu(
      context: context,
      position: position,
      items: const [
        PopupMenuItem<String>(value: 'profile', child: Text('Profile')),
        PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
      ],
    );

    if (selected == 'profile') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } else if (selected == 'logout') {
      _showLogoutConfirmationDialog(context);
    }
  }

  // logout confirmition
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
                const SizedBox(height: 16),
                const Text('Confirm Logout',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // cancel button
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(width: 24),
                    // confirm logout
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Logout', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Dashboard',
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // notification icon
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () => _showNotificationPopover(context),
              color: primaryBlue,
            ),
          ),
          // profile icon
          Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                onTap: () => _showProfilePopover(context),
                child: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.person_outline, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),

      // dashboard content
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // cane selector dropdown and manage button
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black45),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: caneList.isEmpty
                        ? DropdownButton<String>(
                            value: null,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: const [],
                            hint: const Text('No device linked yet'),
                            onChanged: null,
                          )
                        : DropdownButton<String>(
                            value: selectedItem,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: caneList.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedItem = newValue!;
                              });
                            },
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DevicePage()),
                    );
                  },
                  icon: const Icon(Icons.settings, color: Colors.white),
                  label: const Text('Manage', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Placeholder for map (for goofle maps integration)
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('Map')),
            ),

            const SizedBox(height: 16),

            // status cards
            Row(
              children: [
                // battery status
                Expanded(
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: caneList.isEmpty
                          ? const Text('No device data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Battery Status',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Icon(Icons.battery_charging_full, color: Colors.white, size: 40),
                                SizedBox(height: 8),
                                Text('50%',
                                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // recent activity
                Expanded(
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: caneList.isEmpty
                          ? const Text('No device data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Recent Activity',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text('Last Movement',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text('5 minutes ago', style: TextStyle(color: Colors.white)),
                                SizedBox(height: 8),
                                Text('Obstacle Detected',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text('5 minutes ago', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}