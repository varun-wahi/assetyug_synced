import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/snackbar__types_enum.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/constants/sizes.dart';
import '../../../../core/utils/widgets/d_snackbar.dart';
import '../../../../core/utils/widgets/my_elevated_button.dart';
import '../../../Main/presentation/riverpod/refresh_provider.dart';
import '../../data/models/customers_model.dart';
import '../../data/repository/company_customer_repository_impl.dart';
import '../pages/view_customer_page.dart';

class CustomerDetailsCard extends ConsumerStatefulWidget {
  final CustomersModel data;
  final VoidCallback? onCustomerDeleted;

  const CustomerDetailsCard({
    super.key,
    required this.data,
    this.onCustomerDeleted,
  });

  @override
  ConsumerState<CustomerDetailsCard> createState() => _CustomerDetailsCardState();
}

class _CustomerDetailsCardState extends ConsumerState<CustomerDetailsCard> {
  bool isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToCustomerDetails,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: dPadding),
        decoration: _cardDecoration(),
        child: ListTile(
          leading: _buildAvatar(),
          title: _buildTitle(),
          subtitle: _buildSubtitle(),
          trailing: _buildPopupMenu(),
        ),
      ),
    );
  }

  void _navigateToCustomerDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ViewCustomerPage(
          customerObjectId: widget.data.id.toString(),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: tWhite,
      borderRadius: BorderRadius.circular(dBorderRadius),
      border: Border.all(color: tGreyLight),
    );
  }

Widget _buildAvatar() {
  String displayChar = '?';
  final name = widget.data.name;

  if (name != null && name.trim().isNotEmpty) {
    displayChar = name.trim()[0].toUpperCase();
  }

  return CircleAvatar(
    backgroundColor: tPrimary,
    child: Text(
      displayChar,
      style: boldHeading(size: 17, color: tWhite),
    ),
  );
}


  Widget _buildTitle() {
    return Text(
      widget.data.name ?? 'Unknown',
      style: boldHeading(size: 16),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email: ${widget.data.email ?? 'No email'}",
          style: containerText(weight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      onSelected: _handleMenuSelection,
      itemBuilder: (context) => const [
        PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }

  void _handleMenuSelection(String value) {
    if (value == 'delete') {
      _showDeleteConfirmationDialog();
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text('Are you sure you want to delete this customer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          DElevatedButton(
            onPressed: _deleteCustomer,
            child: isDeleting
                ? const SizedBox.square(
                    dimension: 20.0,
                    child: CircularProgressIndicator(),
                  )
                : const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer() async {
    if (isDeleting) return;

    setState(() => isDeleting = true);

    try {
      final response = await CompanyCustomerRepositoryImpl()
          .deleteCompanyCustomer(widget.data.id!);

      if (response.statusCode == 200) {
        _showSuccessMessage();
        _refreshData();
        widget.onCustomerDeleted?.call();
      } else {
        _showErrorMessage();
      }
    } catch (e) {
      _showErrorMessage();
    } finally {
      if (mounted) {
        setState(() => isDeleting = false);
        Navigator.of(context).pop();
      }
    }
  }

  void _showSuccessMessage() {
    dSnackBar(context, "Customer deleted successfully", TypeSnackbar.info);
  }

  void _showErrorMessage() {
    dSnackBar(
      context,
      "Some error occurred while deleting customer",
      TypeSnackbar.error,
    );
  }

  void _refreshData() {
    ref.read(refreshProvider.notifier).state = !ref.read(refreshProvider);
  }
}