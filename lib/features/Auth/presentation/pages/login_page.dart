import 'package:asset_yug_debugging/features/Auth/data/repository/auth_repo_impl.dart';
import 'package:asset_yug_debugging/features/Auth/data/repository/auth_token_repository_impl.dart';
import 'package:asset_yug_debugging/features/Auth/data/repository/firebase_authentication.dart';
import 'package:asset_yug_debugging/config/theme/snackbar__types_enum.dart';
import 'package:asset_yug_debugging/features/Main/presentation/pages/MainPage.dart';
import 'package:asset_yug_debugging/core/utils/widgets/d_snackbar.dart';
import 'package:asset_yug_debugging/core/utils/constants/sizes.dart';
import 'package:asset_yug_debugging/core/utils/constants/colors.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Repositories
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
  final AuthTokenRepositoryImpl _authTokenRepository =
      AuthTokenRepositoryImpl();

  // Hive box
  late Box _box;

  // State variables
  bool _isLoading = false;
  bool _isSignUpScreen = false;
  bool _isRememberMe = false;
  bool _isPasswordVisible = false;
  String? _deviceId;
  String? mobileId;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  // Initialize app
  Future<void> _initializeApp() async {
    await _createBox();
    await _getDeviceId();
  }

  // Initialize Hive box
  Future<void> _createBox() async {
    try {
      _box = await Hive.openBox('auth_data');
      _loadSavedData();
    } catch (e) {
      _showErrorSnackBar('Failed to initialize storage: $e');
    }
  }

  // Load saved login data
  void _loadSavedData() {
    final savedEmail = _box.get('email');
    final savedPassword = _box.get('password');

    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _isRememberMe = true;
      });
    }
  }

  // Get device ID
  Future<void> _getDeviceId() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        _deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        _deviceId = iosInfo.identifierForVendor;
      } else {
        _deviceId = "Unsupported Platform";
      }
    } catch (e) {
      _deviceId = "Unknown Device";
    }
  }

  // Validate input fields
  bool _validateInputs() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showErrorSnackBar('Please enter your email');
      return false;
    }

    if (!_isValidEmail(email)) {
      _showErrorSnackBar('Please enter a valid email address');
      return false;
    }

    if (password.isEmpty) {
      _showErrorSnackBar('Please enter your password');
      return false;
    }

    if (password.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters');
      return false;
    }

    return true;
  }

  // Email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Main sign in method
  Future<void> _signInUser() async {
    if (_isLoading) return;

    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      // Step 1: Validate credentials
      final loginResult = await AuthServices().loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (loginResult != "success") {
        _showErrorSnackBar("Invalid email or password");
        return;
      }

      // Step 2: Check device compatibility
      final isSameDevice = await _checkDeviceCompatibility();
      if (!isSameDevice) {
        _showErrorSnackBar("Device verification failed");
        return;
      }

      // Step 3: Get authentication token
      debugPrint('[LoginPage] Step 3: Fetching user token...');
      await _getUserToken();

      // Step 4: Fetch company details
      debugPrint('[LoginPage] Step 4: Fetching user company details...');
      await _fetchUserCompanyDetails();

      // Step 5: Log mobile session
      debugPrint('[LoginPage] Step 5: Logging mobile session...');
      await _logMobileSession();

      // Step 6: Handle remember me
      debugPrint('[LoginPage] Step 6: Handling remember me...');
      _handleRememberMe();

      // Step 7: Navigate to main page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    } catch (e) {
      debugPrint('[LoginPage] Login error: ${e.toString()}');
      _showErrorSnackBar('Login failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Check device compatibility
  Future<bool> _checkDeviceCompatibility() async {
    try {
      debugPrint('[LoginPage] _checkDeviceCompatibility called');
      // For now, returning true. Implement your device checking logic here
      // final isSameDevice = await _authTokenRepository.isSameDevice(
      //   _emailController.text.trim(),
      //   _deviceId!
      // );
      return true;
    } catch (e) {
      debugPrint('[LoginPage] _checkDeviceCompatibility error: $e');
      return false;
    }
  }

  // Get user authentication token
  Future<void> _getUserToken() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    debugPrint('[LoginPage] _getUserToken called for email: $email');

    final userData = await _authRepository.getLoginToken(
      email,
      password,
    );

    debugPrint('[LoginPage] _getUserToken response: $userData');

    if (userData == null) {
      throw Exception('Failed to get authentication token');
    }

    _box.put('auth_token', userData["token"]);
    _box.put('role', userData["role"]);
    debugPrint('[LoginPage] Saved auth_token: ${userData["token"]} and role: ${userData["role"]}');
  }

  // Fetch user company details
  Future<void> _fetchUserCompanyDetails() async {
    final email = _emailController.text.trim();
    debugPrint('[LoginPage] _fetchUserCompanyDetails called for email: $email');

    final companyDetails = await _authTokenRepository.getCompanyId(email);

    debugPrint('[LoginPage] _fetchUserCompanyDetails response: $companyDetails');

    if (companyDetails == null) {
      throw Exception('Failed to fetch company details');
    }

    _box.put('companyId', companyDetails['id'].toString());
    _box.put('companyName', companyDetails['companyName']);
    debugPrint('[LoginPage] Saved companyId: ${companyDetails['id']} and companyName: ${companyDetails['companyName']}');
  }

  // Log mobile session
  Future<void> _logMobileSession() async {
    try {
      final email = _emailController.text.trim();
      final userAgent = HttpClient().userAgent ?? "Unknown User Agent";
      debugPrint('[LoginPage] _logMobileSession called for userId: $email');

      await _authTokenRepository.addLoggedInMobile(
        userId: email,
        userAgent: userAgent,
      );
      debugPrint('[LoginPage] _logMobileSession successfully logged session');
    } catch (e) {
      // Log error but don't fail the login process
      debugPrint("[LoginPage] Failed to add logged in mobile session: $e");
    }
  }

  // Handle remember me functionality
  void _handleRememberMe() {
    if (_isRememberMe) {
      _box.put('email', _emailController.text.trim());
      _box.put('password', _passwordController.text.trim());
    } else {
      _box.delete('email');
      _box.delete('password');
    }
  }

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    if (mounted) {
      dSnackBar(context, message, TypeSnackbar.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tBlack,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background header
          _buildHeader(),

          // Main login card
          _buildLoginCard(),
        ],
      ),
    );
  }

  // Build header section
  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 10),
        height: MediaQuery.sizeOf(context).height / 2.5,
        decoration: const BoxDecoration(
          color: tPrimary,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.bitbucket,
              size: 40,
              color: tYellow,
            ),
            SizedBox(width: dPadding * 2),
            Text(
              "AssetYug",
              style: TextStyle(
                color: tWhite,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build main login card
  Widget _buildLoginCard() {
    return Positioned(
      top: MediaQuery.sizeOf(context).height / 3.2,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeIn,
        padding: const EdgeInsets.all(dPadding * 3),
        height: _isSignUpScreen ? 500 : 400,
        width: MediaQuery.sizeOf(context).width - 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          color: tWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Tab selection
              _buildTabSelection(),

              // Form content
              if (_isSignUpScreen) _buildSignupSection(),
              if (!_isSignUpScreen) _buildSignInSection(),

              // Submit button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Build tab selection
  Widget _buildTabSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Login tab
        _buildTab("LOGIN", !_isSignUpScreen, () {
          setState(() => _isSignUpScreen = false);
        }),

        // Signup tab (Web Link)
        _buildTab(
          "SIGNUP",
          _isSignUpScreen,
          () async {
            final signupUrl = Uri.parse(
                'http://assetyugg.com.s3-website-us-east-1.amazonaws.com/register');
            try {
              if (await canLaunchUrl(signupUrl)) {
                final launched =
                    await launchUrl(signupUrl, mode: LaunchMode.inAppWebView);
                if (!launched && mounted) {
                  _showErrorSnackBar("Could not open signup page");
                }
              } else {
                final launched = await launchUrl(signupUrl,
                    mode: LaunchMode.externalApplication);
                if (!launched && mounted) {
                  _showErrorSnackBar("Could not open signup page");
                }
              }
            } catch (e) {
              if (mounted) {
                _showErrorSnackBar("Could not open signup page");
              }
            }
          },
          isExternalLink: true,
        ),
      ],
    );
  }

  // Build individual tab
  Widget _buildTab(String title, bool isActive, VoidCallback? onTap,
      {bool isExternalLink = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: dTextSize,
                  color:
                      (isActive || isExternalLink) ? textColor1 : disabledText,
                ),
              ),
              if (isExternalLink) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.open_in_new,
                  size: 14,
                  color:
                      (isActive || isExternalLink) ? textColor1 : disabledText,
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          if (isActive)
            Container(
              height: 3,
              width: 55,
              decoration: BoxDecoration(
                color: title == "LOGIN" ? tPrimary : tYellow,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }

  // Build sign in section
  Widget _buildSignInSection() {
    return Column(
      children: [
        _buildTextField(
          icon: Icons.mail,
          hintText: "E-mail",
          controller: _emailController,
          isPassword: false,
          isEmail: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            if (!_isValidEmail(value.trim())) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        _buildTextField(
          icon: Icons.password,
          hintText: "Password",
          controller: _passwordController,
          isPassword: true,
          isEmail: false,
          showToggle: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        _buildRememberMeSection(),
      ],
    );
  }

  // Build remember me section
  Widget _buildRememberMeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              side: MaterialStateBorderSide.resolveWith(
                (states) => const BorderSide(width: 1.0, color: tPrimary),
              ),
              value: _isRememberMe,
              activeColor: tPrimary,
              checkColor: tWhite,
              onChanged: (value) {
                setState(() => _isRememberMe = value ?? false);
              },
            ),
            const Text(
              "Remember me",
              style: TextStyle(fontSize: 14, color: lighterGrey),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            // Implement forgot password functionality
          },
          child: const Text(
            "Forgot Password?",
            style: TextStyle(fontSize: 14, color: tPrimary),
          ),
        ),
      ],
    );
  }

  // Build signup section
  Widget _buildSignupSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: dPadding * 2),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField(
              icon: Icons.business,
              hintText: "Company Name",
              controller: _companyNameController,
              isPassword: false,
              isEmail: false,
            ),
            _buildTextField(
              icon: Icons.mail,
              hintText: "E-Mail",
              controller: _emailController,
              isPassword: false,
              isEmail: true,
            ),
            _buildTextField(
              icon: Icons.password,
              hintText: "Password",
              controller: _passwordController,
              isPassword: true,
              isEmail: false,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: "By pressing 'Submit' you agree to our ",
                  style: TextStyle(color: lighterGrey),
                  children: [
                    TextSpan(
                      text: "terms & conditions",
                      style: TextStyle(color: Colors.deepOrange, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build submit button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: 300,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: tPrimary,
          foregroundColor: tWhite,
          padding: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dBorderRadius),
          ),
        ),
        onPressed: _isLoading ? null : _signInUser,
        child: _isLoading
            ? const SizedBox(
                height: 20.0,
                width: 20.0,
                child: CircularProgressIndicator(color: tWhite),
              )
            : const Text(
                "Login",
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  // Build text field
  Widget _buildTextField({
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
    required bool isPassword,
    required bool isEmail,
    String? Function(String?)? validator,
    bool showToggle = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        style: const TextStyle(color: tBlack),
        controller: controller,
        cursorColor: tBlack,
        obscureText: isPassword && !(_isPasswordVisible),
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: tBlack),
          suffixIcon: isPassword && showToggle
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: tBlack,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.all(dPadding * 2),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: textColor1),
            borderRadius: BorderRadius.circular(dBorderRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: tPrimary),
            borderRadius: BorderRadius.circular(dBorderRadius),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(dBorderRadius),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(dBorderRadius),
          ),
          hintText: hintText,
        ),
      ),
    );
  }
}
